package C4::AR::Authldap;


#package for ldap authentification
#Sirve tanto para utilizar el esquema propio de Meran como para 
#autenticarse en un dominio DC

require Exporter;
use strict;
use Net::LDAP;
use Net::LDAPS;
use Net::LDAP::LDIF;
use Net::LDAP::Util qw(ldap_error_text);
use Net::LDAP::Constant qw(LDAP_EXTENSION_START_TLS);

use vars qw(@ISA @EXPORT_OK );
@ISA = qw(Exporter);
@EXPORT_OK = qw(checkpwldap getldappassword checkpwDC);


sub datosUsuario
{
    my ($userid) = @_;
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
    if ($socio) { 
        return $socio;
    }
    else {
        ######FIXME agregarSocio como inactivo o no???? preferencia???
        return $socio;
    }
}


sub _conectarLDAP{
    my $LDAP_SERVER= C4::Context->config("ldapserver");
    my $LDAP_PORT= C4::Context->config("ldapport");
    my $LDAP_TYPE=C4::Context->config("ldaptype");
    my $ldap;
    if ($LDAP_TYPE ne 'SSL'){
        $ldap = Net::LDAP->new($LDAP_SERVER, port => $LDAP_PORT) or die "Coult not create LDAP object because:\n$!";
        if ($LDAP_TYPE eq 'TLS') {
            my $dse = $ldap->root_dse();
            my $doesSupportTLS = $dse->supported_extension(LDAP_EXTENSION_START_TLS);
            C4::AR::Debug::debug("Authldap =>Server does not support TLS\n") unless($doesSupportTLS);
            my $startTLSMsg = $ldap->start_tls();
            C4::AR::Debug::debug("Authldap =>".$startTLSMsg->error) if $startTLSMsg->is_error;
        } 
    }
    else{
        $ldap = Net::LDAPS->new($LDAP_SERVER, port => $LDAP_PORT) or die "Coult not create LDAP object because:\n$!";
    }
    return $ldap;
}

sub checkpwDC
{
    my ($userid, $password) = @_;
    my $LDAP_INFOS= C4::Context->config("ldapinfos");
    my $LDAP_SUFF=C4::Context->config("ldasuff");
    my $userDN = $LDAP_SUFF.'='.$userid.','.$LDAP_INFOS;
    my $ldap=_conectarLDAP();
    my $ldapMsg = $ldap->bind($userDN, password => $password);
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->code() );
    if (!$ldapMsg->code()) {
            return (datosUsuario($userid));
    }
    return 0;

}

sub checkpwldap{
    my ($userid, $password, $random_number) = @_;
    my $p= getldappassword($userid);
    #FIXME, este metodo de encriptacion posiblemente no funcione, reever
    $p= md5_base64($p.$random_number);
    if (($p eq $password)){
        return (datosUsuario($userid));
    }
    return 0;
}


sub getldappassword {
    #It gets the password for a particular userid
    my ($userid) = @_; 
    my $LDAP_INFOS= C4::Context->config("ldapinfos");
    my $LDAP_SUFF=C4::Context->config("ldasuff");
    my $LDAP_ROOT= C4::Context->config("ldaproot");
    my $LDAP_PASS= C4::Context->config("ldappass");
    my $LDAP_FILTER = $LDAP_SUFF.'='.$userid;
    my $ldap=_conectarLDAP();
    my $ldapMsg = $ldap->bind( $LDAP_ROOT , password => $LDAP_PASS) or die "$@";
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->code() );
    if (!$ldapMsg->code()) {
                 my %bindargs;
                 my $entries = $ldap->search(
                    base   => $LDAP_INFOS,
                    filter => "($LDAP_FILTER)"
                    );
                my $p;
                my $entry;
                my @values;
                foreach $entry ($entries->all_entries) {
                    @values = $entry->get_value("userPassword");
                    $p= @values[0];
                }
                return($p);}
    else{
        return "0";
    }
}
