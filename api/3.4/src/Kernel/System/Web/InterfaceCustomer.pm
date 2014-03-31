# --
# Kernel/System/Web/InterfaceCustomer.pm - the customer interface file (incl. auth)
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Web::InterfaceCustomer;

use strict;
use warnings;

=head1 NAME

Kernel::System::Web::InterfaceCustomer - the customer web interface

=head1 SYNOPSIS

the global customer web interface (incl. auth, session, ...)

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create customer web interface object

    use Kernel::System::Web::InterfaceCustomer;

    my $Debug = 0;
    my $InterfaceCustomer = Kernel::System::Web::InterfaceCustomer->new(
        Debug      => $Debug,
        WebRequest => CGI::Fast->new(), # optional, e. g. if fast cgi is used, the CGI object is already provided
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get debug level
    $Self->{Debug} = $Param{Debug} || 0;

    # performance log
    $Self->{PerformanceLogStart} = time();

    # create common framework objects 1/2
    $Self->{ConfigObject} = $Kernel::OM->Get('ConfigObject');
    $Kernel::OM->ObjectParamAdd(
        LogObject => {
            LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
        },
        ParamObject => {
            WebRequest => $Param{WebRequest} || 0,
        },

    );

    for my $Needed (qw( EncodeObject LogObject MainObject TimeObject ParamObject )) {
        $Self->{$Needed} = $Kernel::OM->Get($Needed);
    }

    # debug info
    if ( $Self->{Debug} ) {
        $Self->{LogObject}->Log(
            Priority => 'debug',
            Message  => 'Global handle started...',
        );
    }

    return $Self;
}

=item Run()

execute the object

    $InterfaceCustomer->Run();

=cut

sub Run {
    my $Self = shift;

    # get common framework params
    my %Param;

    # get session id
    $Param{SessionName} = $Self->{ConfigObject}->Get('CustomerPanelSessionName') || 'CSID';
    $Param{SessionID} = $Self->{ParamObject}->GetParam( Param => $Param{SessionName} ) || '';

    # drop old session id (if exists)
    my $QueryString = $ENV{QUERY_STRING} || '';
    $QueryString =~ s/(\?|&|;|)$Param{SessionName}(=&|=;|=.+?&|=.+?$)/;/g;

    # define framework params
    my $FrameworkParams = {
        Lang         => '',
        Action       => '',
        Subaction    => '',
        RequestedURL => $QueryString,
    };
    for my $Key ( sort keys %{$FrameworkParams} ) {
        $Param{$Key} = $Self->{ParamObject}->GetParam( Param => $Key )
            || $FrameworkParams->{$Key};
    }

    # Check if the browser sends the SessionID cookie and set the SessionID-cookie
    # as SessionID! GET or POST SessionID have the lowest priority.
    if ( $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        $Param{SessionIDCookie} = $Self->{ParamObject}->GetCookie( Key => $Param{SessionName} );
        if ( $Param{SessionIDCookie} ) {
            $Param{SessionID} = $Param{SessionIDCookie};
        }
    }

    my $CookieSecureAttribute;
    if ( $Self->{ConfigObject}->Get('HttpType') eq 'https' ) {

        # Restrict Cookie to HTTPS if it is used.
        $CookieSecureAttribute = 1;
    }

    $Kernel::OM->ObjectParamAdd(
        LayoutObject => {
            Lang => $Param{Lang},
        },
        LanguageObject => {
            UserLanguage => $Param{Lang},
        },
    );

    # check common objects
    $Self->{DBObject} = $Kernel::OM->Get('DBObject');
    if ( !$Self->{DBObject} || $Self->{ParamObject}->Error() ) {
        my $LayoutObject = $Kernel::OM->Get('LayoutObject');
        if ( !$Self->{DBObject} ) {
            $LayoutObject->CustomerFatalError(
                Comment => 'Please contact your administrator',
            );
            return;
        }
        if ( $Self->{ParamObject}->Error() ) {
            $LayoutObject->CustomerFatalError(
                Message => $Self->{ParamObject}->Error(),
                Comment => 'Please contact your administrator',
            );
            return;
        }
    }

    # create common framework objects 2/2
    $Self->{UserObject} = $Kernel::OM->Get('CustomerUserObject');
    for my $Needed (qw(GroupObject SessionObject)) {
        $Self->{$Needed} = $Kernel::OM->Get($Needed);
    }

    # application and add on application common objects
    my %CommonObject = %{ $Self->{ConfigObject}->Get('CustomerFrontend::CommonObject') };
    for my $Key ( sort keys %CommonObject ) {
        if ( $Self->{MainObject}->Require( $CommonObject{$Key} ) ) {

            # workaround for bug# 977 - do not use GroupObject in Kernel::System::Ticket
            $Self->{$Key} = $CommonObject{$Key}->new( %{$Self}, GroupObject => undef );
        }
        else {

            # print error
            my $LayoutObject = $Kernel::OM->Get('LayoutObject');
            $LayoutObject->CustomerFatalError( Comment => 'Please contact your administrator' );
        }
    }

    # get common application and add on application params
    my %CommonObjectParam = %{ $Self->{ConfigObject}->Get('CustomerFrontend::CommonParam') };
    for my $Key ( sort keys %CommonObjectParam ) {
        $Param{$Key} = $Self->{ParamObject}->GetParam( Param => $Key ) || $CommonObjectParam{$Key};
    }

    # security check Action Param (replace non-word chars)
    $Param{Action} =~ s/\W//g;

    # check request type
    if ( $Param{Action} eq 'Login' ) {

        # get params
        my $PostUser = $Self->{ParamObject}->GetParam( Param => 'User' ) || '';
        my $PostPw = $Self->{ParamObject}->GetParam( Param => 'Password', Raw => 1 ) || '';

        # create AuthObject
        my $AuthObject = $Kernel::OM->Get('CustomerAuthObject');

        # check submitted data
        my $User = $AuthObject->Auth( User => $PostUser, Pw => $PostPw );

        # login is vailid
        if ( !$User ) {

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {
                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                        . "?Reason=LoginFailed;RequestedURL=$Param{RequestedURL}",
                );
                return;
            }

            # show normal login
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => $Self->{LogObject}->GetLogEntry(
                        Type => 'Info',
                        What => 'Message',
                        )
                        || 'Login failed! Your user name or password was entered incorrectly.',
                    User        => $PostUser,
                    LoginFailed => 1,
                    %Param,
                ),
            );
            return;
        }

        # login is successful
        my %UserData = $Self->{UserObject}->CustomerUserDataGet( User => $User, Valid => 1 );

        # check needed data
        if ( !$UserData{UserID} || !$UserData{UserLogin} ) {

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                        . '?Reason=SystemError',
                );
                return;
            }

            # show need user data error message
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title => 'Panic!',
                    Message =>
                        'Authentication succeeded, but no customer record is found in the customer backend. Please contact your administrator.',
                    %Param,
                ),
            );
            return;
        }

        # get groups rw/ro
        for my $Type (qw(rw ro)) {
            my %GroupData = $Self->{GroupObject}->GroupMemberList(
                Result => 'HASH',
                Type   => $Type,
                UserID => $UserData{UserID},
            );
            for ( sort keys %GroupData ) {
                if ( $Type eq 'rw' ) {
                    $UserData{"UserIsGroup[$GroupData{$_}]"} = 'Yes';
                }
                else {
                    $UserData{"UserIsGroupRo[$GroupData{$_}]"} = 'Yes';
                }
            }
        }

        # create new session id
        my $NewSessionID = $Self->{SessionObject}->CreateSessionID(
            %UserData,
            UserLastRequest => $Self->{TimeObject}->SystemTime(),
            UserType        => 'Customer',
        );

        # show error message if no session id has been created
        if ( !$NewSessionID ) {

            # get error message
            my $Error = $Self->{SessionObject}->SessionIDErrorMessage() || '';

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # output error message
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => $Error,
                    %Param,
                ),
            );
            return;
        }

        # set time zone offset if TimeZoneFeature is active
        if (
            $Self->{ConfigObject}->Get('TimeZoneUser')
            && $Self->{ConfigObject}->Get('TimeZoneUserBrowserAutoOffset')
            )
        {
            my $TimeOffset = $Self->{ParamObject}->GetParam( Param => 'TimeOffset' ) || 0;
            if ( $TimeOffset > 0 ) {
                $TimeOffset = '-' . ( $TimeOffset / 60 );
            }
            else {
                $TimeOffset = ( $TimeOffset / 60 );
                $TimeOffset =~ s/-/+/;
            }
            $Self->{UserObject}->SetPreferences(
                UserID => $UserData{UserID},
                Key    => 'UserTimeZone',
                Value  => $TimeOffset,
            );
            $Self->{SessionObject}->UpdateSessionID(
                SessionID => $NewSessionID,
                Key       => 'UserTimeZone',
                Value     => $TimeOffset,
            );
        }

        # create a new LayoutObject with SessionIDCookie
        my $Expires = '+' . $Self->{ConfigObject}->Get('SessionMaxTime') . 's';
        if ( !$Self->{ConfigObject}->Get('SessionUseCookieAfterBrowserClose') ) {
            $Expires = '';
        }

        $Kernel::OM->ObjectParamAdd(
            LayoutObject => {
                SetCookies => {
                    SessionIDCookie => $Self->{ParamObject}->SetCookie(
                        Key      => $Param{SessionName},
                        Value    => $NewSessionID,
                        Expires  => $Expires,
                        Path     => $Self->{ConfigObject}->Get('ScriptAlias'),
                        Secure   => scalar $CookieSecureAttribute,
                        HTTPOnly => 1,
                    ),
                },
                SessionID   => $NewSessionID,
                SessionName => $Param{SessionName},
            },
        );

        # redirect with new session id and old params
        # prepare old redirect URL -- do not redirect to Login or Logout (loop)!
        if ( $Param{RequestedURL} =~ /Action=(Logout|Login|LostPassword)/ ) {
            $Param{RequestedURL} = '';
        }

        # redirect with new session id
        print $Kernel::OM->Get('LayoutObject')->Redirect( OP => $Param{RequestedURL} );
        return 1;
    }

    # logout
    elsif ( $Param{Action} eq 'Logout' ) {

        # check session id
        if ( !$Self->{SessionObject}->CheckSessionID( SessionID => $Param{SessionID} ) ) {

            # new layout object
            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {
                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                        . "?Reason=InvalidSessionID;RequestedURL=$Param{RequestedURL}",
                );
            }

            # show login screen
            print $LayoutObject->CustomerLogin(
                Title   => 'Logout',
                Message => 'Session invalid. Please log in again.',
                %Param,
            );
            return;
        }

        # get session data
        my %UserData = $Self->{SessionObject}->GetSessionIDData( SessionID => $Param{SessionID}, );

        # create new LayoutObject with new '%Param' and '%UserData'
        $Kernel::OM->ObjectParamAdd(
            LayoutObject => {
                SetCookies => {
                    SessionIDCookie => $Self->{ParamObject}->SetCookie(
                        Key      => $Param{SessionName},
                        Value    => '',
                        Expires  => '-1y',
                        Path     => $Self->{ConfigObject}->Get('ScriptAlias'),
                        Secure   => scalar $CookieSecureAttribute,
                        HTTPOnly => 1,
                    ),
                },
                %Param,
                %UserData,
            },
        );

        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # remove session id
        if ( !$Self->{SessionObject}->RemoveSessionID( SessionID => $Param{SessionID} ) ) {
            $LayoutObject->CustomerFatalError( Comment => 'Please contact your administrator' );
            return;
        }

        # redirect to alternate login
        if ( $Self->{ConfigObject}->Get('CustomerPanelLogoutURL') ) {
            print $LayoutObject->Redirect(
                ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLogoutURL')
                    . "?Reason=Logout",
            );
        }

        # show logout screen
        my $LogoutMessage = $LayoutObject->{LanguageObject}->Translate(
            'Logout successful. Thank you for using %s!',
            $Self->{ConfigObject}->Get("ProductName"),
        );

        $LayoutObject->Print(
            Output => \$LayoutObject->CustomerLogin(
                Title   => 'Logout',
                Message => $LogoutMessage,
                %Param,
            ),
        );
        return 1;
    }

    # CustomerLostPassword
    elsif ( $Param{Action} eq 'CustomerLostPassword' ) {

        # new layout object
        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # check feature
        if ( !$Self->{ConfigObject}->Get('CustomerPanelLostPassword') ) {

            # show normal login
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => 'Feature not active!',
                ),
            );
            return;
        }

        # get params
        my $User  = $Self->{ParamObject}->GetParam( Param => 'User' )  || '';
        my $Token = $Self->{ParamObject}->GetParam( Param => 'Token' ) || '';

        # get user login by token
        if ( !$User && $Token ) {
            my %UserList = $Self->{UserObject}->SearchPreferences(
                Key   => 'UserToken',
                Value => $Token,
            );
            USER_ID:
            for my $UserID ( sort keys %UserList ) {
                my %UserData = $Self->{UserObject}->CustomerUserDataGet(
                    User  => $UserID,
                    Valid => 1,
                );
                if (%UserData) {
                    $User = $UserData{UserLogin};
                    last USER_ID;
                }
            }
        }

        # get user data
        my %UserData = $Self->{UserObject}->CustomerUserDataGet( User => $User );
        if ( !$UserData{UserID} ) {

            # Security: pretend that password reset instructions were actually sent to
            #   make sure that users cannot find out valid usernames by
            #   just trying and checking the result message.
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => 'Sent password reset instructions. Please check your email.',
                ),
            );
            return;
        }

        # create email object
        my $EmailObject = Kernel::System::Email->new( %{$Self} );

        # send password reset token
        if ( !$Token ) {

            # generate token
            $UserData{Token} = $Self->{UserObject}->TokenGenerate(
                UserID => $UserData{UserID},
            );

            # send token notify email with link
            my $Body = $Self->{ConfigObject}->Get('CustomerPanelBodyLostPasswordToken')
                || 'ERROR: CustomerPanelBodyLostPasswordToken is missing!';
            my $Subject = $Self->{ConfigObject}->Get('CustomerPanelSubjectLostPasswordToken')
                || 'ERROR: CustomerPanelSubjectLostPasswordToken is missing!';
            for ( sort keys %UserData ) {
                $Body =~ s/<OTRS_$_>/$UserData{$_}/gi;
            }
            my $Sent = $EmailObject->Send(
                To       => $UserData{UserEmail},
                Subject  => $Subject,
                Charset  => $LayoutObject->{UserCharset},
                MimeType => 'text/plain',
                Body     => $Body
            );
            if ( !$Sent ) {
                $LayoutObject->FatalError(
                    Comment => 'Please contact your administrator'
                );
                return;
            }
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => 'Sent password reset instructions. Please check your email.',
                    %Param,
                ),
            );
            return 1;

        }

        # reset password
        # check if token is valid
        my $TokenValid = $Self->{UserObject}->TokenCheck(
            Token  => $Token,
            UserID => $UserData{UserID},
        );
        if ( !$TokenValid ) {
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => 'Invalid Token!',
                    %Param,
                ),
            );
            return;
        }

        # get new password
        $UserData{NewPW} = $Self->{UserObject}->GenerateRandomPassword();

        # update new password
        my $Success
            = $Self->{UserObject}->SetPassword( UserLogin => $User, PW => $UserData{NewPW} );

        if ( !$Success ) {
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title => 'Login',
                    Message =>
                        "Reset password unsuccessful. Please contact your administrator",
                    User => $User,
                ),
            );
            return;
        }

        # send notify email
        my $Body = $Self->{ConfigObject}->Get('CustomerPanelBodyLostPassword')
            || 'New Password is: <OTRS_NEWPW>';
        my $Subject = $Self->{ConfigObject}->Get('CustomerPanelSubjectLostPassword')
            || 'New Password!';
        for ( sort keys %UserData ) {
            $Body =~ s/<OTRS_$_>/$UserData{$_}/gi;
        }
        my $Sent = $EmailObject->Send(
            To       => $UserData{UserEmail},
            Subject  => $Subject,
            Charset  => $LayoutObject->{UserCharset},
            MimeType => 'text/plain',
            Body     => $Body
        );
        if ( !$Sent ) {
            $LayoutObject->CustomerFatalError(
                Comment => 'Please contact your administrator'
            );
            return;
        }
        $LayoutObject->Print(
            Output => \$LayoutObject->CustomerLogin(
                Title => 'Login',
                Message =>
                    "Sent new password to \%s. Please check your email.\", \"$UserData{UserEmail}",
                User => $User,
            ),
        );
        return 1;
    }

    # create new customer account
    elsif ( $Param{Action} eq 'CustomerCreateAccount' ) {

        # new layout object
        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # check feature
        if ( !$Self->{ConfigObject}->Get('CustomerPanelCreateAccount') ) {

            # show normal login
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => 'Feature not active!',
                ),
            );
            return;
        }

        # get params
        my %GetParams;
        for my $Entry ( @{ $Self->{ConfigObject}->Get('CustomerUser')->{Map} } ) {
            $GetParams{ $Entry->[0] } = $Self->{ParamObject}->GetParam( Param => $Entry->[1] )
                || '';
        }
        $GetParams{ValidID} = 1;

        # check needed params
        if ( !$GetParams{UserCustomerID} ) {
            $GetParams{UserCustomerID} = $GetParams{UserEmail};
        }
        if ( !$GetParams{UserLogin} ) {
            $GetParams{UserLogin} = $GetParams{UserEmail};
        }

        # get new password
        $GetParams{UserPassword} = $Self->{UserObject}->GenerateRandomPassword();

        # get user data
        my %UserData = $Self->{UserObject}->CustomerUserDataGet( User => $GetParams{UserLogin} );
        if ( $UserData{UserID} || !$GetParams{UserLogin} ) {
            $LayoutObject->Block( Name => 'SignupError' );
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title => 'Login',
                    Message =>
                        'This email address already exists. Please log in or reset your password.',
                    UserTitle     => $GetParams{UserTitle},
                    UserFirstname => $GetParams{UserFirstname},
                    UserLastname  => $GetParams{UserLastname},
                    UserEmail     => $GetParams{UserEmail},
                ),
            );
            return;
        }

        # create account
        my $Now = $Self->{TimeObject}->SystemTime2TimeStamp(
            SystemTime => $Self->{TimeObject}->SystemTime(),
        );
        my $Add = $Self->{UserObject}->CustomerUserAdd(
            %GetParams,
            Comment => "Added via Customer Panel ($Now)",
            ValidID => 1,
            UserID  => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
        );
        if ( !$Add ) {
            $LayoutObject->Block( Name => 'SignupError' );
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title         => 'Login',
                    Message       => 'Customer user can\'t be added!',
                    UserTitle     => $GetParams{UserTitle},
                    UserFirstname => $GetParams{UserFirstname},
                    UserLastname  => $GetParams{UserLastname},
                    UserEmail     => $GetParams{UserEmail},
                ),
            );
            return;
        }

        # send notify email
        my $EmailObject = Kernel::System::Email->new( %{$Self} );
        my $Body        = $Self->{ConfigObject}->Get('CustomerPanelBodyNewAccount')
            || 'No Config Option found!';
        my $Subject = $Self->{ConfigObject}->Get('CustomerPanelSubjectNewAccount')
            || 'New OTRS Account!';
        for ( sort keys %GetParams ) {
            $Body =~ s/<OTRS_$_>/$GetParams{$_}/gi;
        }

        # send account info
        my $Sent = $EmailObject->Send(
            To       => $GetParams{UserEmail},
            Subject  => $Subject,
            Charset  => $LayoutObject->{UserCharset},
            MimeType => 'text/plain',
            Body     => $Body
        );
        if ( !$Sent ) {
            my $Output = $LayoutObject->CustomerHeader(
                Area  => 'Core',
                Title => 'Error'
            );
            $Output .= $LayoutObject->CustomerWarning(
                Comment => 'Can\'t send account info!'
            );
            $Output .= $LayoutObject->CustomerFooter();
            $LayoutObject->Print( Output => \$Output );
            return;
        }

        # show sent account info
        if ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {

            # redirect to alternate login
            $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
            print $LayoutObject->Redirect(
                ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                    . "?RequestedURL=$Param{RequestedURL};User=$GetParams{UserLogin};"
                    . "Email=$GetParams{UserEmail};Reason=NewAccountCreated",
            );
            return 1;
        }

        # login screen
        $LayoutObject->Print(
            Output => \$LayoutObject->CustomerLogin(
                Title => 'Login',
                Message =>
                    "New account created. Sent login information to \%s. Please check your email.\", \"$GetParams{UserEmail}",
                User => $GetParams{UserLogin},
            ),
        );
        return 1;
    }

    # show login site
    elsif ( !$Param{SessionID} ) {

        # new layout object
        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # create AuthObject
        my $AuthObject = $Kernel::OM->Get('CustomerAuthObject');
        if ( $AuthObject->GetOption( What => 'PreAuth' ) ) {

            # automatic login
            $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
            print $LayoutObject->Redirect(
                OP => "Action=Login;RequestedURL=$Param{RequestedURL}",
            );
            return;
        }
        elsif ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {

            # redirect to alternate login
            $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
            print $LayoutObject->Redirect(
                ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                    . "?RequestedURL=$Param{RequestedURL}",
            );
            return;
        }

        # login screen
        $LayoutObject->Print(
            Output => \$LayoutObject->CustomerLogin(
                Title => 'Login',
                %Param,
            ),
        );
        return 1;
    }

    # run modules if a version value exists
    elsif ( $Self->{MainObject}->Require("Kernel::Modules::$Param{Action}") ) {

        # check session id
        if ( !$Self->{SessionObject}->CheckSessionID( SessionID => $Param{SessionID} ) ) {

            # create new LayoutObject with new '%Param'
            $Kernel::OM->ObjectParamAdd(
                LayoutObject => {
                    SetCookies => {
                        SessionIDCookie => $Self->{ParamObject}->SetCookie(
                            Key      => $Param{SessionName},
                            Value    => '',
                            Expires  => '-1y',
                            Path     => $Self->{ConfigObject}->Get('ScriptAlias'),
                            Secure   => scalar $CookieSecureAttribute,
                            HTTPOnly => 1,
                        ),
                    },
                    %Param,
                    }
            );

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {

                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                        . "?Reason=InvalidSessionID;RequestedURL=$Param{RequestedURL}",
                );
                return;
            }

            # show login
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Login',
                    Message => $Self->{SessionObject}->SessionIDErrorMessage(),
                    %Param,
                ),
            );
            return;
        }

        # get session data
        my %UserData = $Self->{SessionObject}->GetSessionIDData(
            SessionID => $Param{SessionID},
        );

        # check needed data
        if ( !$UserData{UserID} || !$UserData{UserLogin} || $UserData{UserType} ne 'Customer' ) {
            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('CustomerPanelLoginURL') ) {
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('CustomerPanelLoginURL')
                        . "?Reason=SystemError",
                );
                return;
            }

            # show login screen
            $LayoutObject->Print(
                Output => \$LayoutObject->CustomerLogin(
                    Title   => 'Panic!',
                    Message => 'Panic! Invalid Session!!!',
                    %Param,
                ),
            );
            return;
        }

        # module registry
        my $ModuleReg = $Self->{ConfigObject}->Get('CustomerFrontend::Module')->{ $Param{Action} };
        if ( !$ModuleReg ) {

            # new layout object
            my $LayoutObject = $Kernel::OM->Get('LayoutObject');
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message =>
                    "Module Kernel::Modules::$Param{Action} not registered in Kernel/Config.pm!",
            );
            $LayoutObject->CustomerFatalError( Comment => 'Please contact your administrator' );
            return;
        }

        # module permisson check
        if ( !$ModuleReg->{GroupRo} && !$ModuleReg->{Group} ) {
            $Param{AccessRo} = 1;
            $Param{AccessRw} = 1;
        }
        else {
            PERMISSION:
            for my $Permission (qw(GroupRo Group)) {
                my $AccessOk = 0;
                my $Group    = $ModuleReg->{$Permission};
                my $Key      = "UserIs$Permission";
                next PERMISSION if !$Group;
                if ( ref $Group eq 'ARRAY' ) {
                    GROUP:
                    for ( @{$Group} ) {
                        next GROUP if !$_;
                        next GROUP if !$UserData{ $Key . "[$_]" };
                        next GROUP if $UserData{ $Key . "[$_]" } ne 'Yes';
                        $AccessOk = 1;
                        last GROUP;
                    }
                }
                else {
                    if ( $UserData{ $Key . "[$Group]" } && $UserData{ $Key . "[$Group]" } eq 'Yes' )
                    {
                        $AccessOk = 1;
                    }
                }
                if ( $Permission eq 'Group' && $AccessOk ) {
                    $Param{AccessRo} = 1;
                    $Param{AccessRw} = 1;
                }
                elsif ( $Permission eq 'GroupRo' && $AccessOk ) {
                    $Param{AccessRo} = 1;
                }
            }
            if ( !$Param{AccessRo} ) {

                # new layout object
                my $LayoutObject = $Kernel::OM->Get('LayoutObject');
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => 'No Permission to use this frontend module!'
                );
                $LayoutObject->CustomerFatalError( Comment => 'Please contact your administrator' );
                return;
            }
        }

        # create new LayoutObject with new '%Param' and '%UserData'
        $Kernel::OM->ObjectParamAdd(
            LayoutObject => {
                %Param,
                %UserData,
                ModuleReg => $ModuleReg,
            },
        );

        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # updated last request time
        $Self->{SessionObject}->UpdateSessionID(
            SessionID => $Param{SessionID},
            Key       => 'UserLastRequest',
            Value     => $Self->{TimeObject}->SystemTime(),
        );

        # pre application module
        my $PreModule = $Self->{ConfigObject}->Get('CustomerPanelPreApplicationModule');
        if ($PreModule) {
            my %PreModuleList;
            if ( ref $PreModule eq 'HASH' ) {
                %PreModuleList = %{$PreModule};
            }
            else {
                $PreModuleList{Init} = $PreModule;
            }

            MODULE:
            for my $PreModuleKey ( sort keys %PreModuleList ) {
                my $PreModule = $PreModuleList{$PreModuleKey};
                next MODULE if !$PreModule;
                next MODULE if !$Self->{MainObject}->Require($PreModule);

                # debug info
                if ( $Self->{Debug} ) {
                    $Self->{LogObject}->Log(
                        Priority => 'debug',
                        Message  => "CustomerPanelPreApplication module $PreModule is used.",
                    );
                }

                # use module
                my $PreModuleObject = $PreModule->new(
                    %{$Self},
                    %Param,
                    %UserData,
                    LayoutObject => $LayoutObject,

                );
                my $Output = $PreModuleObject->PreRun();
                if ($Output) {
                    $LayoutObject->Print( Output => \$Output );
                    return 1;
                }
            }
        }

        # debug info
        if ( $Self->{Debug} ) {
            $Self->{LogObject}->Log(
                Priority => 'debug',
                Message  => 'Kernel::Modules::' . $Param{Action} . '->new',
            );
        }

        # proof of concept! - create $GenericObject
        my $GenericObject = ( 'Kernel::Modules::' . $Param{Action} )->new(
            %{$Self},
            %Param,
            %UserData,
            LayoutObject => $LayoutObject,
            ModuleReg    => $ModuleReg,
        );

        # debug info
        if ( $Self->{Debug} ) {
            $Self->{LogObject}->Log(
                Priority => 'debug',
                Message  => 'Kernel::Modules::' . $Param{Action} . '->run',
            );
        }

        # ->Run $Action with $GenericObject
        $LayoutObject->Print( Output => \$GenericObject->Run() );

        # log request time
        if ( $Self->{ConfigObject}->Get('PerformanceLog') ) {
            if ( ( !$QueryString && $Param{Action} ) || $QueryString !~ /Action=/ ) {
                $QueryString = 'Action=' . $Param{Action} . ';Subaction=' . $Param{Subaction};
            }
            my $File = $Self->{ConfigObject}->Get('PerformanceLog::File');
            ## no critic
            if ( open my $Out, '>>', $File ) {
                ## use critic
                print $Out time()
                    . '::Customer::'
                    . ( time() - $Self->{PerformanceLogStart} )
                    . "::$UserData{UserLogin}::$QueryString\n";
                close $Out;
                $Self->{LogObject}->Log(
                    Priority => 'notice',
                    Message  => 'Response::Customer: '
                        . ( time() - $Self->{PerformanceLogStart} )
                        . "s taken (URL:$QueryString:$UserData{UserLogin})",
                );
            }
            else {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => "Can't write $File: $!",
                );
            }
        }
        return 1;
    }

    # print an error screen
    my %Data = $Self->{SessionObject}->GetSessionIDData( SessionID => $Param{SessionID}, );
    $Kernel::OM->ObjectParamAdd(
        LayoutObject => {
            %Param,
            %Data,
        },
    );
    my $LayoutObject = $Kernel::OM->Get('LayoutObject');
    $LayoutObject->CustomerFatalError( Comment => 'Please contact your administrator' );
    return;
}

sub DESTROY {
    my $Self = shift;

    # debug info
    if ( $Self->{Debug} ) {
        $Self->{LogObject}->Log(
            Priority => 'debug',
            Message  => 'Global handle stopped.',
        );
    }

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
