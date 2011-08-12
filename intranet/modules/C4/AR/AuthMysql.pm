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
    checkPassword
    
);


=item 
    Funcion que recibe un userid y un password e intenta autenticarse ante un ldap, si lo logra devuelve un objeto Socio.
=cut
sub _checkPwPlana{
    #FIXME esto no existe, habria q ver de definirlo
    return undef;
}

=item
    Funcion que recibe un userid, un nroRandom y un password e intenta validarlo ante un ldap utilizando el mecanismo interno de Meran, si      lo logra devuelve un objeto Socio.
=cut
sub _checkPwEncriptada{
    my ($userid, $password, $nroRandom) = @_;
    C4::AR::Debug::debug("_checkpw=> busco el socio ".$userid."\n");
    C4::AR::Debug::debug("_checkpw=> busco el password ".$password."\n");
    my ($socio)= C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
    if ($socio){
         C4::AR::Debug::debug("_checkpw=> lo encontre!!! ".$userid."\n");
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
    C4::AR::Debug::debug($password. " nro random ".$nroRandom. " ".C4::AR::Auth::hashear_password($socio->getPassword.$nroRandom, C4::AR::Auth::getMetodoEncriptacion()). " original ".$socio->getPassword());
    if ($password eq C4::AR::Auth::hashear_password($socio->getPassword.$nroRandom, C4::AR::Auth::getMetodoEncriptacion())) {
        C4::AR::Debug::debug("ES VALIDO");
        #PASSWORD VALIDA
        return $socio;
    }else {
        #PASSWORD INVALIDA
        return undef;
    }
}

sub checkPassword{
    my ($userid,$password,$nroRandom) = @_;
    my $socio=undef;
	if (!C4::Context->config('plainPassword')){
	    ($socio) = _checkPwEncriptada($userid,$password,$nroRandom);
	}else{
	    ($socio) = _checkPwPlana($userid,$password);       
	}
    return $socio;
	
}	
	

sub validarPassword{
   my( $userid,$password,$nuevaPassword,$nroRandom)= @_;
	my $socio=undef;
    C4::AR::Debug::debug("ACCCCCCCCCCCCCCCCCAAAAAAAAA userid".$userid." password ".$password." nroRandom ".$nroRandom." nuevaPass ".$nuevaPassword);
     C4::AR::Debug::debug("ACCCCCCCCCCCCCCCCCAAAAAAAAA2".C4::AR::Auth::hashear_password($nuevaPassword.$nroRandom,C4::AR::Auth::getMetodoEncriptacion()));
    
    if ((!C4::Context->config('plainPassword') )&& ($password ne C4::AR::Auth::hashear_password($nuevaPassword.$nroRandom,C4::AR::Auth::getMetodoEncriptacion() ))){
            ($socio) = _checkPwEncriptada($userid,$password,$nroRandom);
        }elsif ($password eq $nuevaPassword){
            ($socio) = _checkPwPlana($userid,$password);       
        }
	return $socio;
}


sub setearPassword{
    my ($socio,$nuevaPassword,$nroRandom) = @_;
	if (!C4::Context->config('plainPassword') ){
        $nuevaPassword=C4::AR::Auth::hashear_password($nuevaPassword.$nroRandom,C4::AR::Auth::getMetodoEncriptacion() );
    }
    $socio->setPassword($nuevaPassword);	
    return $socio;
}


END { }       # module clean-up code here (global destructor)
1;
__END__
