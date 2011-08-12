package C4::AR::AuthMysql;

=head1 NAME
  C4::AR::AuthMysql 
=head1 SYNOPSIS
  use C4::AR::AuthMysql;
=head1 DESCRIPTION
    En este modulo se centraliza todo lo relacionado a la authenticacion del usuario contra una base mysql.
    Sirve tanto para utilizar el esquema propio de Meran como para autenticarse con password planas.
=cut

require Exporter;
use strict;
use C4::AR::Preferencias;
use vars qw(@ISA @EXPORT_OK );
@ISA = qw(Exporter);
@EXPORT_OK = qw(
    &checkPwEncriptada
    &checkPwPlana
    
);


=item 
    Funcion que recibe un userid y un password e intenta autenticarse ante un ldap, si lo logra devuelve un objeto Socio.
=cut
sub checkPwPlana{
    #FIXME esto no existe, habria q ver de definirlo
    return undef;
}

=item
    Funcion que recibe un userid, un nroRandom y un password e intenta validarlo ante un ldap utilizando el mecanismo interno de Meran, si      lo logra devuelve un objeto Socio.
=cut
sub checkPwEncriptada{
    my ($userid, $password, $nroRandom) = @_;
    C4::AR::Debug::debug("_checkpw=> busco el socio ".$userid."\n");
    C4::AR::Debug::debug("_checkpw=> busco el socio ".$password."\n");
    my ($socio)= C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
    if ($socio){
         C4::AR::Debug::debug("_checkpw=> busco el socio ".$userid."\n");
         return _verificar_password_con_metodo($password, $socio, $nroRandom);
    }
    return undef;
}

=item sub _verificar_password_con_metodo

    Verifica la password ingresada por el usuario con la password recuperada de la base, todo esto con el metodo indicado por parametros   
    Parametros:
    $socio: recuperada de la base
    $nroRandom: el nroRandom previamente generado
    $password: ingresada por el usuario
=cut

sub _verificar_password_con_metodo {
    my ($password, $socio, $nroRandom) = @_;
    if ($password eq C4::AR::Auth::hashear_password($socio->getPassword.$nroRandom, C4::AR::Auth::getMetodoEncriptacion())) {
        #PASSWORD VALIDA
        return $socio;
    }else {
        #PASSWORD INVALIDA
        return undef;
    }
}

END { }       # module clean-up code here (global destructor)
1;
__END__
