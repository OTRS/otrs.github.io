# --
# Kernel/System/Web/InterfaceAgent.pm - the agent interface file (incl. auth)
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Web::InterfaceAgent;

use strict;
use warnings;

use Kernel::System::ObjectManager;

=head1 NAME

Kernel::System::Web::InterfaceAgent - the agent web interface

=head1 SYNOPSIS

the global agent web interface (incl. auth, session, ...)

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create agent web interface object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    my $Debug = 0,
    local $Kernel::OM = Kernel::System::ObjectManager->new(
        InterfaceAgentObject => {
            Debug   => 0,
            WebRequest => CGI::Fast->new(), # optional, e. g. if fast cgi is used,
                                            # the CGI object is already provided
        }
    );
    my $InterfaceAgent = $Kernel::OM->Get('InterfaceAgentObject');

=cut

sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {};
    bless( $Self, $Type );

    # Performance log
    $Self->{PerformanceLogStart} = time();

    # get debug level
    $Self->{Debug} = $Param{Debug} || 0;

    $Self->{ConfigObject} = $Kernel::OM->Get('ConfigObject');
    $Kernel::OM->ObjectParamAdd(
        LogObject => {
            LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
        },
        ParamObject => {
            WebRequest => $Param{WebRequest} || 0,
        },
    );

    for my $Object (
        qw( LogObject EncodeObject SessionObject MainObject TimeObject ParamObject UserObject GroupObject )
        )
    {
        $Self->{$Object} = $Kernel::OM->Get($Object);
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

    $InterfaceAgent->Run();

=cut

sub Run {
    my $Self = shift;

    # get common framework params
    my %Param;

    # get session id
    $Param{SessionName} = $Self->{ConfigObject}->Get('SessionName') || 'SessionID';
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

    # check if the browser sends the SessionID cookie and set the SessionID-cookie
    # as SessionID! GET or POST SessionID have the lowest priority.
    if ( $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        $Param{SessionIDCookie} = $Self->{ParamObject}->GetCookie( Key => $Param{SessionName} );
        if ( $Param{SessionIDCookie} ) {
            $Param{SessionID} = $Param{SessionIDCookie};
        }
    }

    $Kernel::OM->ObjectParamAdd(
        LayoutObject => {
            Lang         => $Param{Lang},
            UserLanguage => $Param{Lang},
        },
        LanguageObject => {
            UserLanguage => $Param{Lang}
        },
    );

    my $CookieSecureAttribute;
    if ( $Self->{ConfigObject}->Get('HttpType') eq 'https' ) {

        # Restrict Cookie to HTTPS if it is used.
        $CookieSecureAttribute = 1;
    }

    # check common objects
    $Self->{DBObject} = $Kernel::OM->Get('DBObject');
    if ( !$Self->{DBObject} || $Self->{ParamObject}->Error() ) {
        my $LayoutObject = $Kernel::OM->Get('LayoutObject');
        if ( !$Self->{DBObject} ) {
            $LayoutObject->FatalError(
                Comment => 'Please contact your administrator',
            );
            return;
        }
        if ( $Self->{ParamObject}->Error() ) {
            $LayoutObject->FatalError(
                Message => $Self->{ParamObject}->Error(),
                Comment => 'Please contact your administrator',
            );
            return;
        }
    }

    # application and add-on application common objects
    my %CommonObject = %{ $Self->{ConfigObject}->Get('Frontend::CommonObject') };

    # ensure that few required modules are included in ObjectHash()
    $Kernel::OM->Get('TicketObject');

    for my $Key ( sort keys %CommonObject ) {
        if ( $Self->{MainObject}->Require( $CommonObject{$Key} ) ) {
            $Self->{$Key} = $CommonObject{$Key}->new( $Kernel::OM->ObjectHash(), %{$Self} );
        }
        else {

            # print error
            $Kernel::OM->Get('LayoutObject')
                ->FatalError( Comment => 'Please contact your administrator' );
            return;
        }
    }

    # get common application and add-on application params
    my %CommonObjectParam = %{ $Self->{ConfigObject}->Get('Frontend::CommonParam') };
    for my $Key ( sort keys %CommonObjectParam ) {
        $Param{$Key} = $Self->{ParamObject}->GetParam( Param => $Key ) || $CommonObjectParam{$Key};
    }

    # security check Action Param (replace non word chars)
    $Param{Action} =~ s/\W//g;

    # check request type
    if ( $Param{Action} eq 'Login' ) {

        # get params
        my $PostUser = $Self->{ParamObject}->GetParam( Param => 'User' ) || '';
        my $PostPw = $Self->{ParamObject}->GetParam( Param => 'Password', Raw => 1 ) || '';

        # create AuthObject
        my $AuthObject = $Kernel::OM->Get('AuthObject');

        # check submitted data
        my $User = $AuthObject->Auth( User => $PostUser, Pw => $PostPw );

        # login is invalid
        if ( !$User ) {

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('LoginURL') ) {
                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('LoginURL')
                        . "?Reason=LoginFailed&RequestedURL=$Param{RequestedURL}",
                );
                return;
            }

            # show normal login
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
                    Title   => 'Login',
                    Message => $Self->{LogObject}->GetLogEntry(
                        Type => 'Info',
                        What => 'Message',
                        )
                        || 'Login failed! Your user name or password was entered incorrectly.',
                    LoginFailed => 1,
                    User        => $User,
                    %Param,
                ),
            );
            return;
        }

        # login is successful
        my %UserData = $Self->{UserObject}->GetUserData( User => $User, Valid => 1 );

        # check needed data
        if ( !$UserData{UserID} || !$UserData{UserLogin} ) {

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('LoginURL') ) {
                print $Kernel::OM->Get('LayoutObject')->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('LoginURL') . '?Reason=SystemError',
                );
                return;
            }

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # show need user data error message
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
                    Title => 'Panic!',
                    Message =>
                        'Panic, user authenticated but no user data can be found in OTRS DB!! Perhaps the user is invalid.',
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
            UserType        => 'User',
        );

        # show error message if no session id has been created
        if ( !$NewSessionID ) {

            # get error message
            my $Error = $Self->{SessionObject}->SessionIDErrorMessage() || '';

            # output error message
            my $LayoutObject = $Kernel::OM->Get('LayoutObject');
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
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
                $TimeOffset = $TimeOffset / 60;
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

        my $SecureAttribute;
        if ( $Self->{ConfigObject}->Get('HttpType') eq 'https' ) {

            # Restrict Cookie to HTTPS if it is used.
            $SecureAttribute = 1;
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

        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # check session id
        if ( !$Self->{SessionObject}->CheckSessionID( SessionID => $Param{SessionID} ) ) {

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('LoginURL') ) {
                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('LoginURL')
                        . "?Reason=InvalidSessionID&RequestedURL=$Param{RequestedURL}",
                );
                return;
            }

            # show login screen
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
                    Title   => 'Logout',
                    Message => 'Session invalid. Please log in again.',
                    %Param,
                ),
            );
            return;
        }

        # get session data
        my %UserData = $Self->{SessionObject}->GetSessionIDData(
            SessionID => $Param{SessionID},
        );

        # create a new LayoutObject with %UserData
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
                %UserData,
            },
        );
        $Kernel::OM->ObjectsDiscard( Objects => ['LayoutObject'] );
        $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # Prevent CSRF attacks
        $LayoutObject->ChallengeTokenCheck();

        # remove session id
        if ( !$Self->{SessionObject}->RemoveSessionID( SessionID => $Param{SessionID} ) ) {
            $LayoutObject->FatalError(
                Message => 'Can`t remove SessionID',
                Comment => 'Please contact your administrator',
            );
            return;
        }

        # redirect to alternate login
        if ( $Self->{ConfigObject}->Get('LogoutURL') ) {
            print $LayoutObject->Redirect(
                ExtURL => $Self->{ConfigObject}->Get('LogoutURL') . "?Reason=Logout",
            );
            return 1;
        }

        # show logout screen
        my $LogoutMessage = $LayoutObject->{LanguageObject}->Translate(
            'Logout successful. Thank you for using %s!',
            $Self->{ConfigObject}->Get("ProductName"),
        );

        $LayoutObject->Print(
            Output => \$LayoutObject->Login(
                Title   => 'Logout',
                Message => $LogoutMessage,
                %Param,
            ),
        );
        return 1;
    }

    # user lost password
    elsif ( $Param{Action} eq 'LostPassword' ) {

        my $LayoutObject = $Kernel::OM->Get('LayoutObject');

        # check feature
        if ( !$Self->{ConfigObject}->Get('LostPassword') ) {

            # show normal login
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
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
            USERS:
            for my $UserID ( sort keys %UserList ) {
                my %UserData = $Self->{UserObject}->GetUserData(
                    UserID => $UserID,
                    Valid  => 1,
                );
                if (%UserData) {
                    $User = $UserData{UserLogin};
                    last USERS;
                }
            }
        }

        # get user data
        my %UserData = $Self->{UserObject}->GetUserData( User => $User, Valid => 1 );
        if ( !$UserData{UserID} ) {

            # Security: pretend that password reset instructions were actually sent to
            #   make sure that users cannot find out valid usernames by
            #   just trying and checking the result message.
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
                    Title   => 'Login',
                    Message => 'Sent password reset instructions. Please check your email.',
                    %Param,
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
            my $Body = $Self->{ConfigObject}->Get('NotificationBodyLostPasswordToken')
                || 'ERROR: NotificationBodyLostPasswordToken is missing!';
            my $Subject = $Self->{ConfigObject}->Get('NotificationSubjectLostPasswordToken')
                || 'ERROR: NotificationSubjectLostPasswordToken is missing!';
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
                    Comment => 'Please contact your administrator',
                );
                return;
            }
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
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
                Output => \$LayoutObject->Login(
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
        $Self->{UserObject}->SetPassword( UserLogin => $User, PW => $UserData{NewPW} );

        # send notify email
        my $Body = $Self->{ConfigObject}->Get('NotificationBodyLostPassword')
            || 'New Password is: <OTRS_NEWPW>';
        my $Subject = $Self->{ConfigObject}->Get('NotificationSubjectLostPassword')
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
            $LayoutObject->FatalError(
                Comment => 'Please contact your administrator',
            );
            return;
        }
        $LayoutObject->Print(
            Output => \$LayoutObject->Login(
                Title => 'Login',
                Message =>
                    "Sent new password to \%s. Please check your email.\", \"$UserData{UserEmail}",
                User => $User,
                %Param,
            ),
        );
        return 1;
    }

    # show login site
    elsif ( !$Param{SessionID} ) {

        # create AuthObject
        my $AuthObject   = $Kernel::OM->Get('AuthObject');
        my $LayoutObject = $Kernel::OM->Get('LayoutObject');
        if ( $AuthObject->GetOption( What => 'PreAuth' ) ) {

            # automatic login
            $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
            print $LayoutObject->Redirect(
                OP => "Action=Login&RequestedURL=$Param{RequestedURL}",
            );
            return;
        }
        elsif ( $Self->{ConfigObject}->Get('LoginURL') ) {

            # redirect to alternate login
            $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
            print $LayoutObject->Redirect(
                ExtURL => $Self->{ConfigObject}->Get('LoginURL')
                    . "?RequestedURL=$Param{RequestedURL}",
            );
            return;
        }

        # login screen
        $LayoutObject->Print(
            Output => \$LayoutObject->Login(
                Title => 'Login',
                %Param,
            ),
        );
        return;
    }

    # run modules if a version value exists
    elsif ( $Self->{MainObject}->Require("Kernel::Modules::$Param{Action}") ) {

        # check session id
        if ( !$Self->{SessionObject}->CheckSessionID( SessionID => $Param{SessionID} ) ) {

            # put '%Param' into LayoutObject
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
                        %Param,
                    },
                    }
            );

            $Kernel::OM->ObjectsDiscard( Objects => ['LayoutObject'] );
            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # create AuthObject
            my $AuthObject = $Kernel::OM->Get('AuthObject');
            if ( $AuthObject->GetOption( What => 'PreAuth' ) ) {

                # automatic re-login
                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    OP => "?Action=Login&RequestedURL=$Param{RequestedURL}",
                );
                return;
            }
            elsif ( $Self->{ConfigObject}->Get('LoginURL') ) {

                # redirect to alternate login
                $Param{RequestedURL} = $LayoutObject->LinkEncode( $Param{RequestedURL} );
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('LoginURL')
                        . "?Reason=InvalidSessionID&RequestedURL=$Param{RequestedURL}",
                );
                return;
            }

            # show login
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
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
        if ( !$UserData{UserID} || !$UserData{UserLogin} || $UserData{UserType} ne 'User' ) {

            my $LayoutObject = $Kernel::OM->Get('LayoutObject');

            # redirect to alternate login
            if ( $Self->{ConfigObject}->Get('LoginURL') ) {
                print $LayoutObject->Redirect(
                    ExtURL => $Self->{ConfigObject}->Get('LoginURL') . '?Reason=SystemError',
                );
                return;
            }

            # show login screen
            $LayoutObject->Print(
                Output => \$LayoutObject->Login(
                    Title   => 'Panic!',
                    Message => 'Panic! Invalid Session!!!',
                    %Param,
                ),
            );
            return;
        }

        # check module registry
        my $ModuleReg = $Self->{ConfigObject}->Get('Frontend::Module')->{ $Param{Action} };
        if ( !$ModuleReg ) {

            $Self->{LogObject}->Log(
                Priority => 'error',
                Message =>
                    "Module Kernel::Modules::$Param{Action} not registered in Kernel/Config.pm!",
            );
            $Kernel::OM->Get('LayoutObject')
                ->FatalError( Comment => 'Please contact your administrator' );
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
                    INNER:
                    for ( @{$Group} ) {
                        next INNER if !$_;
                        next INNER if !$UserData{ $Key . "[$_]" };
                        next INNER if $UserData{ $Key . "[$_]" } ne 'Yes';
                        $AccessOk = 1;
                        last INNER;
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
            if ( !$Param{AccessRo} && !$Param{AccessRw} || !$Param{AccessRo} && $Param{AccessRw} ) {

                print $Kernel::OM->Get('LayoutObject')->NoPermission(
                    Message => 'No Permission to use this frontend module!'
                );
                return;
            }
        }

        # put '%Param' and '%UserData' into LayoutObject
        $Kernel::OM->ObjectParamAdd(
            LayoutObject => {
                %Param,
                %UserData,
                ModuleReg => $ModuleReg,
            },
        );
        $Kernel::OM->ObjectsDiscard( Objects => ['LayoutObject'] );

        # updated last request time
        $Self->{SessionObject}->UpdateSessionID(
            SessionID => $Param{SessionID},
            Key       => 'UserLastRequest',
            Value     => $Self->{TimeObject}->SystemTime(),
        );

        # pre application module
        my $PreModule = $Self->{ConfigObject}->Get('PreApplicationModule');
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
                        Message  => "PreApplication module $PreModule is used.",
                    );
                }

                my $LayoutObject = $Kernel::OM->Get('LayoutObject');

                # use module
                my $PreModuleObject = $PreModule->new(
                    $Kernel::OM->ObjectHash(),
                    %{$Self},
                    %Param,
                    %UserData,
                    ModuleReg    => $ModuleReg,
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
            $Kernel::OM->ObjectHash(),
            %Param,
            %UserData,
            LayoutObject => $Kernel::OM->Get('LayoutObject'),
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
        $Kernel::OM->Get('LayoutObject')->Print( Output => \$GenericObject->Run() );

        # log request time
        if ( $Self->{ConfigObject}->Get('PerformanceLog') ) {
            if ( ( !$QueryString && $Param{Action} ) || $QueryString !~ /Action=/ ) {
                $QueryString = 'Action=' . $Param{Action} . '&Subaction=' . $Param{Subaction};
            }
            my $File = $Self->{ConfigObject}->Get('PerformanceLog::File');
            ## no critic
            if ( open my $Out, '>>', $File ) {
                ## use critic
                print $Out time()
                    . '::Agent::'
                    . ( time() - $Self->{PerformanceLogStart} )
                    . "::$UserData{UserLogin}::$QueryString\n";
                close $Out;

                $Self->{LogObject}->Log(
                    Priority => 'notice',
                    Message  => "Response::Agent: "
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
    $Kernel::OM->Get('LayoutObject')->FatalError( Comment => 'Please contact your administrator' );
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
