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
    my $socio_password  = C4::AR::Auth::hashear_password($socio->getPassword().$nroRandom, C4::AR::Auth::getMetodoEncriptacion());
     C4::AR::Debug::debug("Password del socio $socio_password --- password ingresado $password --- Nro_random $nroRandom");
    if ($password eq $socio_password) {
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
	
sub passwordsIguales{
	my ($nuevaPassword1,$nuevaPassword2,$socio) = @_;
	
    my $key = $socio->getPassword;
	
    $nuevaPassword1 = C4::AR::Auth::desencriptar($nuevaPassword1,$key);
    $nuevaPassword2 = C4::AR::Auth::desencriptar($nuevaPassword2,$key);
	
	return ($nuevaPassword1 eq $nuevaPassword2);
	
	
}
sub validarPassword{
   my( $userid,$password,$nuevaPassword,$nroRandom)= @_;
   my $socio=undef;
   my $msg_object= C4::AR::Mensajes::create();

   C4::AR::Debug::debug("\nPassword actual ".$password."\nNuevo password ".$nuevaPassword);
   
   if (!C4::Context->config('plainPassword')){
            ($socio) = _checkPwEncriptada($userid,$password,$nroRandom);
            
            if (!$socio){
            	return undef;
            }
            
		    my $key = $socio->getPassword;
		    
		    $nuevaPassword = C4::AR::Auth::desencriptar($nuevaPassword,$key);

            $nuevaPassword = C4::AR::Auth::hashear_password($nuevaPassword,C4::AR::Auth::getMetodoEncriptacion());
            $nuevaPassword = C4::AR::Auth::hashear_password($nuevaPassword.$nroRandom,C4::AR::Auth::getMetodoEncriptacion());
            
            if (($socio) && ($password eq $nuevaPassword)){
                $msg_object->{'error'}=1;
            }
   }elsif($password ne $nuevaPassword){
            ($socio) = checkPwPlana($userid,$password);       
   }
    else{
            #esto quiere decir que el password actual es igual al nuevo
           
           $msg_object->{'error'}=1; 
         }
    if ($msg_object->{'error'}) { C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U499', 'params' => []} ) ;}
	
    return ($socio,$msg_object);
}

=item
    Función que setea el password de un socio, es independiente del tipo de authtencacion q se use, simplemente desencripta el password que viene encriptado con la password vieja del usuario
    y lo setea en la base
=cut
sub setearPassword{
    
    my ($socio,$nuevaPassword) = @_;
    my $key = $socio->getPassword;
            
    $nuevaPassword = C4::AR::Auth::desencriptar($nuevaPassword,$key);
    $nuevaPassword = C4::AR::Auth::hashear_password($nuevaPassword,C4::AR::Auth::getMetodoEncriptacion());

    $socio->setPassword($nuevaPassword);	
    return $socio;
}


END { }       # module clean-up code here (global destructor)
1;
__END__