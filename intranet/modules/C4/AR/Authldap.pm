package C4::AR::Authldap;

=head1 NAME
  C4::AR::Authldap 
=head1 SYNOPSIS
  use C4::AR::Authldap;
=head1 DESCRIPTION
    En este modulo se centraliza todo lo relacionado a la authenticacion del usuario contra un ldap.
    Sirve tanto para utilizar el esquema propio de Meran como para autenticarse contra un dominio.
=cut

require Exporter;
use strict;
use Net::LDAP;
use Net::LDAPS;
use Net::LDAP::LDIF;
use Net::LDAP::Util qw(ldap_error_text);
use Net::LDAP::Constant qw(LDAP_EXTENSION_START_TLS);
use C4::AR::Preferencias;
use vars qw(@ISA @EXPORT_OK );
@ISA = qw(Exporter);
@EXPORT_OK = qw(
    &getLdapPreferences
    &setVariableLdap
    &checkpwldap 
    &getldappassword 
    &checkpwDC
    &_getValorPreferenciaLdap
    &datosUsuario
    &_conectarLDAP
);

=item
    setVariableLdap, esta funcion setea una variable en pref_ldap
=cut
sub setVariableLdap {
    my ($variable, $valor, $db) = @_;
    my  $preferencia;
    
    $preferencia = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => [variable => {eq => $variable}] );
    
    if(scalar(@$preferencia) > 0){
        $preferencia->[0]->setValue($valor);
        $preferencia->[0]->save();
    }
}

=item
    Esta funcion devuelve en una HASH todas las variables de pref_ldap, se filtra por categoria='auth'
=cut
sub getLdapPreferences{

    my $preferencias_array_ref;
    my @filtros;
    my $prefTemp = C4::Modelo::PrefPreferenciaSistema->new();
  
    $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( 
                                        query => [ categoria => { eq => 'auth' } ],
                                ); 
                                
    my %hash;
    foreach my $pref (@$preferencias_array_ref){
        $hash{$pref->getVariable} = $pref->getValue();
    }

    return (\%hash);                    
}

=item
    Esta funcion devuelve el valor de la preferencia 'variable' recibida como parametro
=cut
sub _getValorPreferenciaLdap{

    my ($variable)              = @_;
    my $preferencia_ldap_array_ref   = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( 
                                                            query => [  variable => { eq => $variable} ,
                                                                        categoria => { eq => 'auth'}
                                                                     ]
                                                            );

    if ($preferencia_ldap_array_ref->[0]){
        return ($preferencia_ldap_array_ref->[0]->getValue);
    } else{
        return 0;
    }
}

=item 
    Esa funcion devuelve un objeto socio a partir de los datos que estan en la base de Meran una vez que fue autenticado por el ldap,
    en caso de no existir en la base de MERAN lo agrega a la misma siempre y cuando la variable agregarDesdeLDAP este habilitada.
    Si no existe en la base y la variable esta en 0 devuelve 0. 
    
    Recibe el userid y un ldap con el bind ya realizado.
=cut
sub datosUsuario{
    my ($userid,$ldap)  = @_;
    my $socio           = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);

    if ($socio) { 
        return $socio;
    }
    else {
        # DATOS OBLIGATORIOS PARA CREAR UN NUEVO SOCIO
        # nro_socio , id_ui, cod_categoria, change_password (dejala en 0), id_estado (uno de UsrEstado), is_super_user 

        my $preferencias_ldap   = getLdapPreferences();
        my $agregar_ldap        = $preferencias_ldap->{'ldap_agregar_user'}||0; # esta en 0
        
        if ($agregar_ldap){
        
                my $LDAP_DB_PREF    = $preferencias_ldap->{'ldap_prefijo_base'};
                my $LDAP_U_PREF     = $preferencias_ldap->{'ldap_user_prefijo'};
                my $LDAP_FILTER     = $LDAP_U_PREF.'='.$userid;
                my $entries         = $ldap->search(
                        base   => $LDAP_DB_PREF,
                        filter => "($LDAP_FILTER)"
                );  
                my $entry           = $entries->entry(0);

                if ($entry){
                    $socio = C4::AR::Usuarios::crearPersonaLDAP($userid);
                    C4::AR::Debug::debug("Authldap =>datosUsuario".$LDAP_FILTER . ' entry '.$entry->ldif); 
                }                
        }
                C4::AR::Debug::debug("Authldap =>datosUsuario" );   
    }
        ######FIXME agregarSocio como inactivo o no???? preferencia???
        return $socio;
}

=item 
    Funcion interna al modulo q se conecta al sevidor LDAP y devuelve un objeto Net::LDAP o NET::LDAPS de acuerdo a la configuracion.
=cut
sub _conectarLDAP{

    my $preferencias_ldap   = getLdapPreferences();
    
    my $LDAP_SERVER = $preferencias_ldap->{'ldap_server'};
    my $LDAP_PORT   = $preferencias_ldap->{'ldap_port'};
    my $LDAP_TYPE   = $preferencias_ldap->{'ldap_type'};

    my $ldap;
    if ($LDAP_TYPE ne 'SSL'){
        $ldap = Net::LDAP->new($LDAP_SERVER, port => $LDAP_PORT) or die "Coult not create LDAP object because:\n$!";
        if ($LDAP_TYPE eq 'TLS') {
            my $dse             = $ldap->root_dse();
            my $doesSupportTLS  = $dse->supported_extension(LDAP_EXTENSION_START_TLS);
            C4::AR::Debug::debug("Authldap =>Server does not support TLS\n") unless($doesSupportTLS);
            my $startTLSMsg     = $ldap->start_tls();
            C4::AR::Debug::debug("Authldap =>".$startTLSMsg->error) if $startTLSMsg->is_error;
        } 
    }
    else{
        $ldap = Net::LDAPS->new($LDAP_SERVER, port => $LDAP_PORT) or die "Coult not create LDAP object because:\n$!";
    }
    return $ldap;
}

=item 
    Funcion que recibe un userid y un password e intenta autenticarse ante un ldap, si lo logra devuelve un objeto Socio.
=cut
sub checkpwDC{
    my ($userid, $password) = @_;
    my $preferencias_ldap   = getLdapPreferences();
    my $LDAP_DB_PREF        = $preferencias_ldap->{'ldap_prefijo_base'};
    my $LDAP_U_PREF         = $preferencias_ldap->{'ldap_user_prefijo'};
    my $userDN              = $LDAP_U_PREF.'='.$userid.','.$LDAP_DB_PREF;
    my $ldap                =_conectarLDAP();
    my $ldapMsg             = $ldap->bind($userDN, password => $password);
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->error. "codigo". $ldapMsg->code() );
    my $socio               = undef;
    if (!$ldapMsg->code()) {
            $socio = datosUsuario($userid,$ldap);
    }
    $ldap->unbind;
    return $socio;
}

=item
    Funcion que recibe un userid, un nroRandom y un password e intenta validarlo ante un ldap utilizando el mecanismo interno de Meran, si      lo logra devuelve un objeto Socio.
=cut
sub checkpwldap{
    my ($userid, $passwordCliente, $random_number) = @_;
    
    my $preferencias_ldap   = getLdapPreferences();
    
    my $LDAP_DB_PREF    = $preferencias_ldap->{'ldap_prefijo_base'};
    my $LDAP_U_PREF     = $preferencias_ldap->{'ldap_user_prefijo'};
    my $LDAP_ROOT       = $preferencias_ldap->{'ldap_bind_dn'};
    my $LDAP_PASS       = $preferencias_ldap->{'ldap_bind_pw'};
    my $LDAP_FILTER     = $LDAP_U_PREF.'='.$userid;
    my $passwordLDAP;
    my $ldap            = _conectarLDAP();
    my $ldapMsg         = $ldap->bind( $LDAP_ROOT , password => $LDAP_PASS) or die "$@";
    C4::AR::Debug::debug("Authldap => smsj ". $ldapMsg->code() );
    my $socio           = 0;
    if (!$ldapMsg->code()) {
        my $entries = $ldap->search(
            base   => $LDAP_DB_PREF,
            filter => "($LDAP_FILTER)"
        );
        my $entry;
        my $entry       = $entries->entry(0);
        $passwordLDAP   = $entry->get_value("userPassword");
        
        #FIXME
        my $metodo      = C4::AR::Auth::getMetodoEncriptacion();
        $passwordLDAP   = hashear_password($passwordLDAP.$random_number,$metodo);
        if (($passwordLDAP eq $passwordCliente)){
            $socio = datosUsuario($userid,$ldap);
        }
        $ldap->unbind;
    }
    return $socio;
}

END { }       # module clean-up code here (global destructor)
1;
__END__
