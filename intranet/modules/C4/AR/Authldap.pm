package C4::AR::Authldap;


=head1 NAME

  C4::AR::Authldap 

=head1 SYNOPSIS

  use C4::AR::Authldap;

=head1 DESCRIPTION

    En este modulo se centraliza todo lo relacionado a la authenticacion del usuario contra un ldap.
    Sirve tanto para utilizar el esquema propio de Meran como para autenticarse contra un dominio

=head1 VARIABLES DEL meran.conf necesarias

    Hay algunas variables que se deben configurar para controlar el funcionamiento de este modulo:
    
    agregarDesdeLDAP: Esta variable indica si hay q agregar automaticamente a la base de Meran a un usuario valido en el ldap cuando se autentica positivamente.
    ldapsuf: Sufijo de la Base de Datos Ldap que se usa para completar el usuario. Ej: dc=unlp,dc=edu,dc=ar
    ldappref: Prefijo que va antes del identificador del usuario, ej uid. Esto se completara luego con el userid y el sufijo
    ldapserver:Server del ldap que se va a usar, ej:localhost.
    ldapport: Puerto del server ldap, por defecto si no esta definido es el 389.
    ldaptype: Indica como sera la comunicacion, SSL, TLS o PLAIN, por defecto es PLAIN
    ldaproot: Usuario de busqueda en el ldap, solo se usa cuando se utiliza authMERAN
    ldappass: password del usuario de busqueda del ldap

=head1 FUNCTIONS

=over 2

=cut

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
    Si no existe en la base y la variable esta en 0 devuelve 0. 
    
    Recibe el userid y un ldap con el bind ya realizado.
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
                my $LDAP_SUF= C4::Context->config("ldapsuf");
                my $LDAP_PREF=C4::Context->config("ldappref");
                my $LDAP_FILTER = $LDAP_PREF.'='.$userid;
                my $entries = $ldap->search(
                    base   => $LDAP_SUF,
                    filter => "($LDAP_FILTER)"
                );
                my $entry =$entries->entry(0);
                my $nombre= $entry->get_value("givenName:");
                my $apellido=$entry->get_value("sn");
                my $dni=$entry->get_value("dni");
                my $mail=$entry->get_value("mail");
                C4::AR::Debug::debug("Authldap =>datosUsuario".$LDAP_FILTER . ' entry '.$entry->ldif); 

                 }
                C4::AR::Debug::debug("Authldap =>datosUsuario" );   
        }
        ######FIXME agregarSocio como inactivo o no???? preferencia???
        return $socio;
}

=item sub _conectarLDAP

    Funcion interna al modulo q se conecta al sevidor LDAP y devuelve un objeto Net::LDAP o NET::LDAPS de acuerdo a las configuraciones del meran.conf 
 
=cut



sub _conectarLDAP{
    my $LDAP_SERVER= C4::Context->config("ldapserver");
    my $LDAP_PORT= C4::Context->config("ldapport")||389;
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


=item sub checkpwDC

    Funcion que recibe un userid y un password e intenta autenticarse ante un ldap, si lo logra devuelve un objeto Socio.
 
=cut

sub checkpwDC
{
    my ($userid, $password) = @_;
    my $LDAP_SUF= C4::Context->config("ldapsuf");
    my $LDAP_PREF=C4::Context->config("ldappref");
    my $userDN = $LDAP_PREF.'='.$userid.','.$LDAP_SUF;
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


=item sub checkpwldap

    Funcion que recibe un userid un nroRandom y un password e intenta validarlo ante un ldap utilizando el mecanismo interno de Meran, si lo logra devuelve un objeto Socio.
 
=cut

sub checkpwldap{
    my ($userid, $passwordCliente, $random_number) = @_;
    my $LDAP_SUF= C4::Context->config("ldapsuf");
    my $LDAP_PREF=C4::Context->config("ldapref");
    my $LDAP_ROOT= C4::Context->config("ldaproot");
    my $LDAP_PASS= C4::Context->config("ldappass");
    my $LDAP_FILTER = $LDAP_PREF.'='.$userid;
    my $passwordLDAP;
    my $ldap=_conectarLDAP();
    my $ldapMsg = $ldap->bind( $LDAP_ROOT , password => $LDAP_PASS) or die "$@";
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->code() );
    my $socio=0;
    if (!$ldapMsg->code()) {
        my $entries = $ldap->search(
            base   => $LDAP_SUF,
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
