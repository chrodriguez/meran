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

=item sub datosUsuario

Esa funcion devuelve un objeto socio a partir de los datos que estan en la base de Meran una vez que fue autenticado por el ldap,
en caso de no existir en la base de MERAN lo agrega a la misma siempre y cuando la variable agregarDesdeLDAP este habilitada.
Si no existe en la base y la variable esta en 0 devulve 0. 
=cut

sub datosUsuario
{
    my ($userid,$ldap) = @_;
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
    if ($socio) { 
        return $socio;
    }
    else {
        #FIXME hay que agregar esta preferencia que ahora no se puede por algo q rompio MONO
        my $agregar=C4::Context->config("agregarDesdeLDAP")||0;
        if ($agregar){
                my $LDAP_INFOS= C4::Context->config("ldapinfos");
                my $LDAP_SUFF=C4::Context->config("ldasuff");
                my $LDAP_FILTER = $LDAP_SUFF.'='.$userid;
                my $entries = $ldap->search(
                    base   => $LDAP_INFOS,
                    filter => "($LDAP_FILTER)"
                );
                my $entry =$entries->entry(0);
                my $nombre= $entry->get_value("");
                my $apellido=$entry->get_value("");
                my $dni=$entry->get_value("");
                C4::AR::Debug::debug("Authldap =>datosUsuario".$LDAP_FILTER . ' entry '.$entry->ldif); 

                 }
                C4::AR::Debug::debug("Authldap =>datosUsuario" );   
        }
        ######FIXME agregarSocio como inactivo o no???? preferencia???
        return $socio;
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
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->error );
    my $socio=0;
    if (!$ldapMsg->code()) {
            $socio=datosUsuario($userid,$ldap);
    }
    $ldap->unbind;
    return $socio;

}

sub checkpwldap{
    my ($userid, $passwordCliente, $random_number) = @_;
    my $LDAP_INFOS= C4::Context->config("ldapinfos");
    my $LDAP_SUFF=C4::Context->config("ldasuff");
    my $LDAP_ROOT= C4::Context->config("ldaproot");
    my $LDAP_PASS= C4::Context->config("ldappass");
    my $LDAP_FILTER = $LDAP_SUFF.'='.$userid;
    my $passwordLDAP;
    my $ldap=_conectarLDAP();
    my $ldapMsg = $ldap->bind( $LDAP_ROOT , password => $LDAP_PASS) or die "$@";
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->code() );
    my $socio=0;
    if (!$ldapMsg->code()) {
        my $entries = $ldap->search(
            base   => $LDAP_INFOS,
            filter => "($LDAP_FILTER)"
        );
        my $entry;
        my $entry =$entries->entry(0);
        $passwordLDAP = $entry->get_value("userPassword");
        #FIXME
        my $metodo= C4::AR::Auth::getMetodoEncriptacion();
        $passwordLDAP= hashear_password($passwordLDAP.$random_number,$metodo);
        if (($passwordLDAP eq $passwordCliente)){
            $socio=datosUsuario($userid,$ldap);
        }
        $ldap->unbind;
    }
    return $socio;
}



END { }       # module clean-up code here (global destructor)
1;
__END__
