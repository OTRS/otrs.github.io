# --
# Kernel/System/WebUserAgent.pm - a web user agent
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::WebUserAgent;

use strict;
use warnings;

use LWP::UserAgent;

use vars qw(@ISA);

=head1 NAME

Kernel::System::WebUserAgent - a web user agent lib

=head1 SYNOPSIS

All web user agent functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Main;
    use Kernel::System::DB;
    use Kernel::System::WebUserAgent;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $WebUserAgentObject = Kernel::System::WebUserAgent->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
        DBObject     => $DBObject,
        Timeout      => 15,                  # optional, timeout
        Proxy        => 'proxy.example.com', # optional, proxy
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(DBObject ConfigObject LogObject MainObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{Timeout} = $Param{Timeout} || $Self->{ConfigObject}->Get('WebUserAgent::Timeout') || 15;
    $Self->{Proxy}   = $Param{Proxy}   || $Self->{ConfigObject}->Get('WebUserAgent::Proxy')   || '';

    return $Self;
}

=item Request()

return the content of requested URL

    my %Response = $WebUserAgentObject->Request(
        URL => 'http://example.com/somedata.xml',
    );

returns

    %Response = (
        Status  => 200,         # http status
        Content => $ContentRef, # content of requested site
    );

=cut

sub Request {
    my ( $Self, %Param ) = @_;

    my $Response;

    {
        # set HTTPS proxy for ssl requests, localize %ENV because of mod_perl
        local %ENV = %ENV;

        # if a proxy is set, extract it and use it as environment variables for HTTPS
        if ( defined $Self->{Proxy} && $Self->{Proxy} =~ /:\/\/(.*)\// ) {
            my $ProxyAddress = $1;

            # extract authentication information if needed
            if ( $ProxyAddress =~ /(.*):(.*)@(.*)/ ) {
                $ENV{HTTPS_PROXY_USERNAME} = $1;
                $ENV{HTTPS_PROXY_PASSWORD} = $2;
                $ProxyAddress              = $3;
            }
            $ENV{HTTPS_PROXY} = $ProxyAddress;

            # force Net::SSL from Crypt::SSLeay. It does SSL connections through proxies
            # but it can't verify hostnames
            $ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS} = "Net::SSL";
            $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}    = 0;
        }

        # init agent
        my $UserAgent = LWP::UserAgent->new();

        # set timeout
        $UserAgent->timeout( $Self->{Timeout} );

        # set user agent
        $UserAgent->agent(
            $Self->{ConfigObject}->Get('Product') . ' ' . $Self->{ConfigObject}->Get('Version')
        );

        # set proxy - but only for non-https urls, the https urls must use the environment
        # variables:
        if ( $Self->{Proxy} && $Param{URL} !~ /^https/ ) {
            $UserAgent->proxy( [ 'http', 'ftp' ], $Self->{Proxy} );
        }

        # get file
        $Response = $UserAgent->get( $Param{URL} );
        if ( !$Response->is_success() ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Can't get file from $Param{URL}: " . $Response->status_line(),
            );
            return (
                Status => $Response->status_line(),
            );
        }
    }

    # return request
    return (
        Status  => $Response->status_line(),
        Content => \$Response->content(),
    );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
