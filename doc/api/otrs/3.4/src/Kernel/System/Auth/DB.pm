# --
# Kernel/System/Auth/DB.pm - provides the db authentication
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Auth::DB;

use strict;
use warnings;

use Crypt::PasswdMD5 qw(unix_md5_crypt);
use Digest::SHA;

use Kernel::System::Valid;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for (qw(LogObject ConfigObject DBObject EncodeObject MainObject UserObject)) {
        $Self->{$_} = $Param{$_} || die "No $_!";
    }
    $Self->{ValidObject} = Kernel::System::Valid->new( %{$Self} );

    # Debug 0=off 1=on
    $Self->{Debug} = 0;

    # get user table
    $Self->{UserTable} = $Self->{ConfigObject}->Get( 'DatabaseUserTable' . $Param{Count} )
        || 'users';
    $Self->{UserTableUserID}
        = $Self->{ConfigObject}->Get( 'DatabaseUserTableUserID' . $Param{Count} )
        || 'id';
    $Self->{UserTableUserPW}
        = $Self->{ConfigObject}->Get( 'DatabaseUserTableUserPW' . $Param{Count} )
        || 'pw';
    $Self->{UserTableUser} = $Self->{ConfigObject}->Get( 'DatabaseUserTableUser' . $Param{Count} )
        || 'login';

    return $Self;
}

sub GetOption {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{What} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => "Need What!" );
        return;
    }

    # module options
    my %Option = ( PreAuth => 0, );

    # return option
    return $Option{ $Param{What} };
}

sub Auth {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{User} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => "Need User!" );
        return;
    }

    # get params
    my $User       = $Param{User}      || '';
    my $Pw         = $Param{Pw}        || '';
    my $RemoteAddr = $ENV{REMOTE_ADDR} || 'Got no REMOTE_ADDR env!';
    my $UserID     = '';
    my $GetPw      = '';
    my $Method;

    # sql query
    my $SQL = "SELECT $Self->{UserTableUserPW}, $Self->{UserTableUserID} "
        . " FROM "
        . " $Self->{UserTable} "
        . " WHERE "
        . " valid_id IN ( ${\(join ', ', $Self->{ValidObject}->ValidIDsGet())} ) AND "
        . " $Self->{UserTableUser} = '" . $Self->{DBObject}->Quote($User) . "'";
    $Self->{DBObject}->Prepare( SQL => $SQL );

    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $GetPw  = $Row[0];
        $UserID = $Row[1];
    }

    # crypt given pw
    my $CryptedPw = '';
    my $Salt      = $GetPw;
    if (
        $Self->{ConfigObject}->Get('AuthModule::DB::CryptType')
        && $Self->{ConfigObject}->Get('AuthModule::DB::CryptType') eq 'plain'
        )
    {
        $CryptedPw = $Pw;
        $Method    = 'plain';
    }

    # md5, bcrypt or sha pw
    elsif ( $GetPw !~ /^.{13}$/ ) {

        # md5 pw
        if ( $GetPw =~ m{\A \$.+? \$.+? \$.* \z}xms ) {

            # strip Salt
            $Salt =~ s/^\$.+?\$(.+?)\$.*$/$1/;

            # encode output, needed by unix_md5_crypt() only non utf8 signs
            $Self->{EncodeObject}->EncodeOutput( \$Pw );
            $Self->{EncodeObject}->EncodeOutput( \$Salt );

            $CryptedPw = unix_md5_crypt( $Pw, $Salt );
            $Method = 'unix_md5_crypt';
        }

        # sha256 pw
        elsif ( $GetPw =~ m{\A .{64} \z}xms ) {

            my $SHAObject = Digest::SHA->new('sha256');

            # encode output, needed by sha256_hex() only non utf8 signs
            $Self->{EncodeObject}->EncodeOutput( \$Pw );

            $SHAObject->add($Pw);
            $CryptedPw = $SHAObject->hexdigest();
            $Method    = 'sha256';
        }

        elsif ( $GetPw =~ m{^BCRYPT:} ) {

            # require module, log errors if module was not found
            if ( !$Self->{MainObject}->Require('Crypt::Eksblowfish::Bcrypt') ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message =>
                        "User: '$User' tried to authenticate with bcrypt but 'Crypt::Eksblowfish::Bcrypt' is not installed!",
                );
                return;
            }

            # get salt and cost from stored PW string
            my ( $Cost, $Salt, $Base64Hash ) = $GetPw =~ m{^BCRYPT:(\d+):(.{16}):(.*)$}xms;

            # remove UTF8 flag, required by Crypt::Eksblowfish::Bcrypt
            $Self->{EncodeObject}->EncodeOutput( \$Pw );

            # calculate password hash with the same cost and hash settings
            my $Octets = Crypt::Eksblowfish::Bcrypt::bcrypt_hash(
                {
                    key_nul => 1,
                    cost    => $Cost,
                    salt    => $Salt,
                },
                $Pw
            );

            $CryptedPw = "BCRYPT:$Cost:$Salt:" . Crypt::Eksblowfish::Bcrypt::en_base64($Octets);
            $Method    = 'bcrypt';
        }

        # fallback: sha1 pw
        else {

            my $SHAObject = Digest::SHA->new('sha1');

            # encode output, needed by sha1_hex() only non utf8 signs
            $Self->{EncodeObject}->EncodeOutput( \$Pw );

            $SHAObject->add($Pw);
            $CryptedPw = $SHAObject->hexdigest();
            $Method    = 'sha1';
        }
    }

    # crypt pw
    else {

        # strip Salt only for (Extended) DES, not for any of Modular crypt's
        if ( $Salt !~ /^\$\d\$/ ) {
            $Salt =~ s/^(..).*/$1/;
        }

        # encode output, needed by crypt() only non utf8 signs
        $Self->{EncodeObject}->EncodeOutput( \$Pw );
        $Self->{EncodeObject}->EncodeOutput( \$Salt );
        $CryptedPw = crypt( $Pw, $Salt );
        $Method = 'crypt';
    }

    # just in case for debug!
    if ( $Self->{Debug} > 0 ) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message =>
                "User: '$User' tried to authenticate with Pw: '$Pw' ($UserID/$Method/$CryptedPw/$GetPw/$Salt/$RemoteAddr)",
        );
    }

    # just a note
    if ( !$Pw ) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => "User: $User without Pw!!! (REMOTE_ADDR: $RemoteAddr)",
        );
        return;
    }

    # login note
    elsif ( ( ($GetPw) && ($User) && ($UserID) ) && $CryptedPw eq $GetPw ) {

        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message => "User: $User authentication ok (Method: $Method, REMOTE_ADDR: $RemoteAddr).",
        );
        return $User;
    }

    # just a note
    elsif ( ($UserID) && ($GetPw) ) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message =>
                "User: $User authentication with wrong Pw!!! (Method: $Method, REMOTE_ADDR: $RemoteAddr)"
        );
        return;
    }

    # just a note
    else {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => "User: $User doesn't exist or is invalid!!! (REMOTE_ADDR: $RemoteAddr)"
        );
        return;
    }
}

1;
