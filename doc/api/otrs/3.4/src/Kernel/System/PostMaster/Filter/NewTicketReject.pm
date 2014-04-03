# --
# Kernel/System/PostMaster/Filter/NewTicketReject.pm - sub part of PostMaster.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster::Filter::NewTicketReject;

use strict;
use warnings;

use Kernel::System::Ticket;
use Kernel::System::Email;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug} = $Param{Debug} || 0;

    # get needed objects
    for (qw(ConfigObject LogObject DBObject MainObject TimeObject EncodeObject TicketObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    $Self->{EmailObject} = Kernel::System::Email->new( %{$Self} );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(JobConfig GetParam)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # get config options
    my %Config;
    my %Match;
    my %Set;
    if ( $Param{JobConfig} && ref $Param{JobConfig} eq 'HASH' ) {
        %Config = %{ $Param{JobConfig} };
        if ( $Config{Match} ) {
            %Match = %{ $Config{Match} };
        }
        if ( $Config{Set} ) {
            %Set = %{ $Config{Set} };
        }
    }

    # match 'Match => ???' stuff
    my $Matched    = '';
    my $MatchedNot = 0;
    for ( sort keys %Match ) {
        if ( $Param{GetParam}->{$_} && $Param{GetParam}->{$_} =~ /$Match{$_}/i ) {
            $Matched = $1 || '1';
            if ( $Self->{Debug} > 1 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched!",
                );
            }
        }
        else {
            $MatchedNot = 1;
            if ( $Self->{Debug} > 1 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched NOT!",
                );
            }
        }
    }
    if ( $Matched && !$MatchedNot ) {

        # check if new ticket
        my $Tn = $Self->{TicketObject}->GetTNByString( $Param{GetParam}->{Subject} );
        return 1 if $Tn && $Self->{TicketObject}->TicketCheckNumber( Tn => $Tn );

        # set attributes if ticket is created
        for ( sort keys %Set ) {
            $Param{GetParam}->{$_} = $Set{$_};
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message =>
                    "Set param '$_' to '$Set{$_}' (Message-ID: $Param{GetParam}->{'Message-ID'}) ",
            );
        }

        # send bounce mail
        my $Subject = $Self->{ConfigObject}->Get(
            'PostMaster::PreFilterModule::NewTicketReject::Subject'
        );
        my $Body = $Self->{ConfigObject}->Get(
            'PostMaster::PreFilterModule::NewTicketReject::Body'
        );
        my $Sender = $Self->{ConfigObject}->Get(
            'PostMaster::PreFilterModule::NewTicketReject::Sender'
        ) || '';
        $Self->{EmailObject}->Send(
            From       => $Sender,
            To         => $Param{GetParam}->{From},
            Subject    => $Subject,
            Body       => $Body,
            Charset    => 'utf-8',
            MimeType   => 'text/plain',
            Loop       => 1,
            Attachment => [
                {
                    Filename    => 'email.txt',
                    Content     => $Param{GetParam}->{Body},
                    ContentType => 'application/octet-stream',
                }
            ],
        );
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => "Send reject mail to '$Param{GetParam}->{From}'!",
        );

    }
    return 1;
}

1;
