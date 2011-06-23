
package C4::AR::Usuarios;

=head1 NAME

C4::AR::Usuarios 

=head1 SYNOPSIS

  use C4::AR::Usuarios;

=head1 DESCRIPTION

  Descripción del modulo COMPLETAR

=head1 FUNCTIONS

=over 2

=cut



=item
####################################### About PM ########################################################
    Author: Heredado de KOHA V2
    Updates: Carbone Miguel, Pagano Matias, Rajoy Gaspar
    Version: 3.0 (Meran)
    Language: Perl
    Description: Este Modulo contiene todas las funciones necesarias para manipular usuarios.
                 Todas las funciones que recolentan datos de un socio en particular, retornan 0 (cero)
                 en caso de que la consulta fue fallida.
####################################### End About PM #####################################################
=cut

use strict;
require Exporter;


use C4::AR::Validator;
use C4::AR::Prestamos qw(cantidadDePrestamosPorUsuario);
use C4::Modelo::UsrPersona;
use C4::Modelo::UsrPersona::Manager;
use C4::Modelo::UsrEstado;
use C4::Modelo::UsrEstado::Manager;
use C4::Modelo::UsrSocio;
use C4::Modelo::UsrSocio::Manager;
use C4::AR::Preferencias;
use Digest::SHA qw(sha256_base64);
use Switch;

use vars qw(@EXPORT_OK @ISA);
@ISA=qw(Exporter);

@EXPORT_OK=qw(
    agregarAutorizado
    agregarPersona
    habilitarPersona
    deshabilitarPersona
    resetPassword
    eliminarUsuario
    _verficarEliminarUsuario
    t_cambiarPermisos
    cambiarPassword
    _verificarDatosBorrower
    actualizarSocio
    getSocioInfo
    getSocioInfoPorNroSocio
    getSocioInfoPorMixed
    existeSocio
    getSocioLike
    llegoMaxReservas
    estaSancionado
    BornameSearchForCard
    isUniqueDocument
    esRegular
    updateUserDataValidation
    needsDataValidation
    crearPersonaLDAP
    _verificarLibreDeuda
    recoverPassword
    checkRecoverLink
    changePasswordFromRecover
    updateUserProfile
);

=item
    Este modulo agrega un autorizado (persona apta para retirar ejemplares a su nombre)
    a un socio (UsrSocio).
    Parametros: 
                HASH: {nro_socio},{nombre_apellido_autorizado},{telefono_autorizado},{dni_autorizado}
=cut
sub agregarAutorizado {

    my ($params)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    my ($socio) = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});

    if ($socio){
        my $db = $socio->db;
            $db->{connect_options}->{AutoCommit} = 0;
            $db->begin_work;

            eval{
                $socio->agregarAutorizado($params);
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U397', 'params' => []});
                $db->commit;
            };

            if ($@){
                &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U398', 'params' => []} ) ;
                $db->rollback;
            }

            $db->{connect_options}->{AutoCommit} = 1;
    }
    else{
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U353', 'params' => []} ) ;
    }
    return ($msg_object);
}

=item
    Este modulo agrega una persona al sistema, que dependiendo de las preferencias de MERAN se auto-activara (conviertiendose en Real) o no.
    Parametros: 
                HASH: con toda la info de una persona (ver UsrPersona->agregar() )
=cut
sub agregarPersona {

    my ($params)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    my ($person) = C4::Modelo::UsrPersona->new();
    my $db = $person->db;

    _verificarDatosBorrower($params,$msg_object);
    if (!($msg_object->{'error'})){

        $params->{'iniciales'} = "DGR";
        #genero un estado de ALTA para la persona para una fuente de informacion
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
        eval{
            $person->agregar($params);
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U329', 'params' => []});
            $db->commit;
        };

        if ($@){
            &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
            $db->rollback;
        }
        $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}

=item sub habilitarPersona

    Este modulo habilita un socio, para que pueda operar en la biblioteca.
    Parametros: 
    ARRAY: con los id de los socios a habilitar

=cut 
sub habilitarPersona {

    my ($id_socios_array_ref)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();

     eval {
        foreach my $socio (@$id_socios_array_ref){
            my ($partner) = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio);
            if ($partner){
                $partner->activar;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U347', 'params' => [$partner->getNro_socio]});
            }
        }
     };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
     }

    return ($msg_object);
}

=item
    Este modulo deshabilita un socio, para que no pueda operar en la biblioteca.
    Parametros:
                ARRAY: con los id de los socios a deshabilitar
=cut 
sub deshabilitarPersona {

    my ($id_socios_array_ref)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();

    eval {
        foreach my $socio (@$id_socios_array_ref){
            my ($partner) = getSocioInfo($socio);
            if ($partner){
                $partner->desactivar;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U363', 'params' => [$partner->getNro_socio]});
            }
        }
     };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
     }

    return ($msg_object);

}

=item
    Este modulo resetea (deja en blanco) el password de acceso de un usuario, que sera su nro_documento.
    Parametros: 
                HASH: {nro_socio}
=cut 
sub desautorizarTercero {

    my ($params)=@_;
    my $nro_socio = $params->{'nro_socio'};
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

        eval {
            $socio->desautorizarTercero;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U396', 'params' => [$socio->getNro_socio]} ) ;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U398', 'params' => [$socio->getNro_socio]} ) ;
        }

    return ($msg_object);
}

=item
    Este modulo resetea (deja en blanco) el password de acceso de un usuario, que será su nro_documento.
    Parametros: 
                HASH: {nro_socio}
=cut 
sub resetPassword {

    my ($params)=@_;
    my $nro_socio = $params->{'nro_socio'};
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

# FIXME esa funcion debe cambiar, porque cambiaron los parametros
#     $msg_object = _verficarEliminarUsuario($params,$msg_object);

        eval {
            $socio->resetPassword;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U359', 'params' => [$socio->getNro_socio]} ) ;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U360', 'params' => [$socio->getNro_socio]} ) ;
        }

    return ($msg_object);
}

=item
    Este módulo es IDENTICO a deshabilitarPersona, pero por razones de posibles cambios en los requerimientos, de deja para que el sistema
    tenga suficiente escalabilidad.
=cut
# FIXME NO SE ESTA USANDO
sub eliminarUsuario {

    my ($nro_socio)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
# FIXME esa funcion debe cambiar, porque cambiaron los parametros
#     $msg_object = _verficarEliminarUsuario($params,$msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        eval {
            my ($error,$cod_msg) = $socio->desactivar;
            
            $error = $error || 0;
            $cod_msg = $cod_msg || 'U320'; 
            $msg_object->{'error'}= $error;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> $cod_msg, 'params' => [$socio->getNro_socio]} ) ;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => [$socio->getNro_socio]} ) ;
        }
    }

    return ($msg_object);
}

=item
    Este modulo verifica que un usuario se pueda eliminar.
=cut
# FIXME fijarse que aca no se checkea nada, por ejemplo si tiene reservas, libros en su poder, etc...
# FIXME ADEMAS NO ES ESTA USANDO, HAY QUE ARREGLARLA Y USARLA (MONO?)
# FIXME deberia usarse en deshabilitarPersona y checkear que no tenga prestamos, de lo contrario retorna FALSE

sub _verficarEliminarUsuario {

    my ($params,$msg_object)=@_;
    my ($cantVencidos,$cantIssues) = C4::AR::Prestamos::cantidadDePrestamosPorUsuario($params->{'borrowernumber'});
    my ($cantidadTotalDePrestamos) = $cantVencidos + $cantIssues;

    if( !($msg_object->{'error'}) && !( _existeUsuario($params->{'borrowernumber'})) ){
    #se verifica la existencia del usuario, que ahora no existe
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U321', 'params' => [$params->{'cardnumber'}]} ) ;
    } 
    elsif ($cantidadTotalDePrestamos > 0){
        #se verifica que no tenga prestamos activos
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U351', 'params' => [$params->{'cardnumber'}]} ) ;
    }
    elsif ($params->{'loggedInUser'} eq $params->{'borrowernumber'}){
    #   Se verifica que el usuario loggeado no sea el mismo que se va a eliminar
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U352', 'params' => [$params->{'cardnumber'}]} ) ;
    }
    return ($msg_object);
}

=item
    Este modulo es la transaccion para cambiar los permisos de acceso de un socio.
    Parametros:
                HASH: {nro_socio}, y nuevos permisos
=cut
sub t_cambiarPermisos {

    my ($params)=@_;
## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
        my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});

        my $db= $socio->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;

        eval {
            $socio->cambiarPermisos($params);
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U317', 'params' => []} ) ;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B421',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U331', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}

=item
    Modulo que recibe una hash con newpassword y  newpassword1, para checkear que sean iguales. Retortan 0 en caso de exito y 1 en error.
    Retorna la hash usada $msg_object
=cut
sub _verificarPassword {

    my ($params)=@_;

    my ($msg_object)= &C4::AR::Validator::checkPassword($params->{'newpassword'});

    if( !($msg_object->{'error'}) && ( $params->{'newpassword'} ne $params->{'newpassword1'} ) ){
    #las password no coinciden
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U315', 'params' => [$params->{'cardnumber'}]} ) ;
    }

    if ( !($msg_object->{'error'}) && ( C4::AR::Auth::getSessionNroSocio() != $params->{'nro_socio'} ) ){
    #no coincide el usuario logueado con el usuario al que se le va a cambiar la password
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U362', 'params' => [$params->{'nro_socio'}]} ) ;
    }

    return ($msg_object);
}

=item
    Modulo que persiste el cambio de password de un usuario por el nuevo.
    Parametros:
                HASH: con los datos de un socio.
=cut
sub cambiarPassword {
    my ($params)=@_;

    my $msg_object;
    my  $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});

    if ($socio){
    #si la password actual ingresada desde el cliente no es igual a la que se encuentra en la base las key seran <>
    #password1 y password seran distintas siempre, recordar que la key es sha256_base64(md5_base64( password))
        $params->{'actualPassword'}= C4::AR::Auth::desencriptar($params->{'actualPassword'}, $socio->getPassword());
        $params->{'newpassword'}= C4::AR::Auth::desencriptar($params->{'newpassword'}, $socio->getPassword());
        $params->{'newpassword1'}= C4::AR::Auth::desencriptar($params->{'newpassword1'}, $socio->getPassword());
        C4::AR::Debug::debug("newpassword=> ".$params->{'newpassword'});
        C4::AR::Debug::debug("newpassword1=> ".$params->{'newpassword1'});
        C4::AR::Debug::debug("actualpassword=> ".$params->{'actualPassword'});

        ($msg_object) = _verificarPassword($params);
    }else{
        $msg_object = C4::AR::Mensajes::create();
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U313', 'params' => [$params->{'nro_socio'}]} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
# FIXME si cambia la pass que pasa con LDAP??
        my $password_actual_desde_DB = $socio->getPassword;
        my $cambioDePasswordForzado;
        my $password_actual_desde_cliente_hasheada = C4::AR::Auth::prepare_password($params->{'actualPassword'});

        if( ($params->{'changePassword'} eq 1) && ($socio->getChange_password) ){
            $cambioDePasswordForzado= 1;
        }

        if ( $password_actual_desde_DB eq $password_actual_desde_cliente_hasheada){
            C4::AR::Debug::debug("Auth => cambiarPassword => cambioForzado ");
            #es un cambio forzado de la password, se obliga al usuario a cambiar la password, no se compara con la pass actual
            my $newPassword = $params->{'newpassword'};
            C4::AR::Debug::debug("Auth => cambiarPassword => nueva password=> ".$newPassword);
            C4::AR::Debug::debug("Auth => cambiarPassword => sha256_base64(md5_base64 actualpassword ".$password_actual_desde_cliente_hasheada);
            $socio->cambiarPassword($newPassword);
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
        }else{
            #El password actual NO coincide con el suyo    
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U361', 'params' => [$params->{'nro_socio'}]} ) ;
            C4::AR::Debug::debug("Auth => cambiarPassword => la password son <> ");
            C4::AR::Debug::debug("Auth => cambiarPassword => password_actual_desde_cliente_hasheada=> ".$password_actual_desde_cliente_hasheada);
            C4::AR::Debug::debug("Auth => cambiarPassword => password_actual_desde_DB=> ".$password_actual_desde_DB);
        }
    }

    return ($msg_object);
}

=item
    Modulo que chekea que todos los datos necesarios sean validos. Queda todo en $msg_object, ademas lo retorna;
=cut
sub _verificarDatosBorrower {

    my ($data, $msg_object)=@_;
    my $actionType = $data->{'actionType'};
    my $checkStatus;
    my $emailAddress = $data->{'email'};
    my $credential_type = lc $data->{'credential_type'};
    my $nro_socio = $data->{'nro_socio'};

    if ( (!($msg_object->{'error'})) && ($data->{'auto_nro_socio'} != 1) && (!$data->{'modifica'})){
          $msg_object->{'error'} = (existeSocio($nro_socio) > 0);
          if ($msg_object->{'error'}){
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U500', 'params' => []} ) ;
          }
    }

    if (!($msg_object->{'error'}) && ($credential_type eq "superlibrarian") ){
        my $socio = getSocioInfoPorNroSocio(C4::AR::Auth::getSessionNroSocio());
        if ( (!$socio) || (!($socio->isSuperUser())) ){
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U399', 'params' => []} ) ;
        }
    }

    if (!($msg_object->{'error'}) && (!(&C4::AR::Validator::isValidMail($emailAddress)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U332', 'params' => []} ) ;
    }

    #### EN ESTE IF VAN TODOS LOS CHECKS PARA UN NUEVO BORROWER, NO PARA UN UPDATE
    if ($actionType eq "new"){

        my $cardNumber = $data->{'nro_socio'};
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($cardNumber)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U333', 'params' => []} ) ;
        }
    }
    #### FIN NUEVO BORROWER's CHECKS

    my $surname = $data->{'apellido'};
    if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($surname)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U334', 'params' => []} ) ;
    }

    my $firstname = $data->{'nombre'};
    if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($firstname)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U335', 'params' => []} ) ;
    }

    my $tipo_doc = $data->{'tipo_documento'};
    if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($tipo_doc)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U800', 'params' => []} ) ;
    }

    my $documentnumber = $data->{'nro_documento'};
    $checkStatus = &C4::AR::Validator::isValidDocument($data->{'tipo_documento'},$documentnumber);
    if (!($msg_object->{'error'}) && ( $checkStatus == 0)){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U336', 'params' => []} ) ;
    }else{
          if ( (!C4::AR::Usuarios::isUniqueDocument($documentnumber,$data)) ) {
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U388', 'params' => []} ) ;
          }
    }
    return ($msg_object);
}

=item
    Este modulo recibe los mismos datos que agregarPersona, pero sirven como modificacion de los actuales.
    Parametros:
                HASH: con todos los datos de UsrPersona y UsrSocio
=cut
sub actualizarSocio {
    my ($params)    = @_;
    my $dbh         = C4::Context->dbh;
    my $msg_object  = C4::AR::Mensajes::create();

    $params->{'actionType'} = "update";
    $params->{'modifica'} = 1;

    _verificarDatosBorrower($params, $msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;

        eval {
            my $socio = getSocioInfoPorNroSocio($params->{'nro_socio'});
            $socio->modificar($params);
            $socio->setThemeINTRA($params->{'tema'} || 'default');
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U338', 'params' => []} ) ;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B424',"INTRA");
            $dbh->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U339', 'params' => []} ) ;
        }
        $dbh->{AutoCommit} = 1;
    }
    return ($msg_object);
}

=item
    Esta funcion devuelve la informacion del socio, segun el id_socio que recibe por parametro
=cut
sub getSocioInfo {
    my ($id_socio) = @_;
    my @filtros;

    push (@filtros, (id_socio => {eq =>$id_socio}) );

    my  $socio = C4::Modelo::UsrSocio::Manager->get_usr_socio(query => \@filtros,
                                                              require_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
                                                                                  'persona.documento'],
                                                              with_objects => ['persona.alt_ciudad_ref'],
                                                             );

    if (scalar(@$socio)){
        return ($socio->[0]);
    }else{
        return (0);
    }
}

=item
    Este funcion devuelve la informacion del usuario segun un nro_socio
=cut
sub getSocioInfoPorNroSocio {
    my ($nro_socio) = @_;

    if ($nro_socio){
        my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( 
                                                    query => [ nro_socio => { eq => $nro_socio } ],
                                                    require_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
                                                                        'persona.documento'],
                                                    with_objects => ['persona.alt_ciudad_ref'],
                                                    select       => ['persona.*','usr_socio.*','estado.*','ref_localidad.*'],
                                        );

        if($socio_array_ref){
            return ($socio_array_ref->[0]);
        }else{
            return 0;
        }
    }

    return 0;
}

=item
    Este funcion devuelve la informacion del usuario segun un nro_socio, su e-mail o su DNI
=cut
sub getSocioInfoPorMixed{
        my ($user_id) = @_;
        my @filtros;
        
        my $socio = undef;
        
        push (@filtros, (or   => [
                                   'usr_persona.email' => { eq => $user_id }, 
                                   'usr_persona.nro_documento' => { eq => $user_id },
                                   ])
        );
        
        
        my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( 
                                                     query              => \@filtros,
                                                     require_objects    => ['persona'],
                                                     select             => ['persona.*','usr_socio.*'],
                                         );
    
        if(scalar(@$socio_array_ref)){
             $socio =  $socio_array_ref->[0];
        }else{
             $socio =  C4::AR::Usuarios::getSocioInfoPorNroSocio($user_id);
        }
        
        return ($socio);
        
	
}

=item
    Este funcion devuelve 1 si existe el socio y 0 si no existe
=cut
sub existeSocio {
    my ($nro_socio)= @_;
    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio_count( query => [ nro_socio => { eq => $nro_socio } ]);
    return $socio_array_ref;
}

=item
    Esta funcion busca por nro_documento, nro_socio, apellido y combinados por ej: "27 Car", donde 27 puede ser parte del DNI o legajo o ambos
=cut
sub getSocioLike {
    my ($socio,$orden,$ini,$cantR,$habilitados,$inicial) = @_;


# C4::AR::Debug::debug("Usuarios => getSocioLike => orden => ".$orden);

    my @filtros;
    my $socioTemp           = C4::Modelo::UsrSocio->new();
    my @searchstring_array  = C4::AR::Utilidades::obtenerBusquedas($socio);
    my $limit_pref          = C4::AR::Preferencias::getValorPreferencia('limite_resultados_autocompletables') || 20;
    $cantR                  = $cantR || $limit_pref;


    if($socio ne 'TODOS'){
        #SI VIENE INICIAL, SE BUSCA SOLAMENTE POR APELLIDOS QUE COMIENCEN CON ESA LETRA, SINO EN TODOS LADOS CON LIKE EN AMBOS LADOS
        if (!($inicial)){
            foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   
                                                'persona.nombre'    => { like => $s.'%'},   
                                                'persona.nombre'    => { like => '% '.$s.'%'},
                                                apellido            => { like => $s.'%'},
                                                apellido            => { like => '% '.$s.'%'},
                                                nro_documento       => { like => '%'.$s.'%' }, 
                                                legajo              => { like => '%'.$s.'%' },
                                                nro_socio           => { like => '%'.$s.'%' }          
                                            ])
                     );
            }

# TODO preferencia para ECONO
        } else {
            foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   apellido => { like => $s.'%'}, ]) );
            }
        }
    }

    if (!defined $habilitados){
        $habilitados = 1;
    }

    push(@filtros, ( activo => { eq => $habilitados}));
    push(@filtros, ( es_socio => { eq => $habilitados}));
    $orden = "apellido,nombre";
    my $ordenAux= $socioTemp->sortByString($orden);
    
    $ordenAux = 'agregacion_temp,'.$ordenAux;
    
    my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => $ordenAux,
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
                                                                            select => ['*','length(apellido) AS agregacion_temp'],
                                                              with_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
                                                                                  'persona.documento'],
     ); 

    #Obtengo la cant total de socios para el paginador
    my $socios_array_ref_count = C4::Modelo::UsrSocio::Manager->get_usr_socio_count( query => \@filtros,
                                                              with_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
                                                                                  'persona.documento'],
                                                                     );

    if(scalar(@$socios_array_ref) > 0){
        return ($socios_array_ref_count, $socios_array_ref);
    }else{
        return (0,());
    }
}

=item
    Verifica si el usuario llego al maximo de las resevas que puede relizar sengun la preferencia del sistema, recibe el numero de socio
=cut
sub llegoMaxReservas {

    my ($nro_socio)=@_;
    my $cant= &C4::AR::Reservas::cant_reservas($nro_socio);

C4::AR::Debug::debug("cant: ".$cant);
C4::AR::Debug::debug("maxreserves: ".C4::AR::Preferencias::getValorPreferencia("maxreserves"));

    return ( $cant >= C4::AR::Preferencias::getValorPreferencia("maxreserves") );
}

=item
    Verifica si un usuario esta sancionado segun un tipo de prestamo
=cut
sub estaSancionado {

    my ($nro_socio,$tipo_prestamo)=@_;
    my $sancionado= 0;
    my @sancion= C4::AR::Sanciones::permitionToLoan($nro_socio, $tipo_prestamo);

    if (($sancion[0]||$sancion[1])) { 
        $sancionado= 1;
    }

    return $sancionado;
}

sub editarAutorizado{
    my ($params)    = @_;

    my $nro_socio   = $params->{'nro_socio'};
    my $campo       = $params->{'id'};
    my $value       = $params->{'value'};
    my $socio       = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

    if ($socio){
        switch ($campo) {
            case "nombre_autorizado" { $socio->setNombre_apellido_autorizado($value); $socio->save();  }
            case "dni_autorizado" { $socio->setDni_autorizado($value); $socio->save();  }
            case "telefono_autorizado" { $socio->setTelefono_autorizado($value); $socio->save();  }
            else { }
        }
    }
    return ($value);
}
=item
    Busca todos los usuarios, con sus datos, entre un par de nombres o legajo para poder crear los carnet.
=cut
sub BornameSearchForCard {

#     my ($apellido1,$apellido2,$category,$branch,$orden,$regular,$legajo1,$legajo2) = @_;
    my ($params) = @_;
    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();

    if ((C4::AR::Utilidades::validateString($params->{'categoria_socio'}))&& ($params->{'categoria_socio'} ne 'SIN SELECCIONAR')) {
    
#    FIXME: ver si anda! cambiado el 16/05 porque no esta mas el cod_categoria en usr_socio, esta id_categoria
#           push (@filtros, (cod_categoria => { eq => $params->{'categoria_socio'} }) );

            push (@filtros, (id_categoria => { eq => $params->{'categoria_socio'} }) );
    }

    if ((C4::AR::Utilidades::validateString($params->{'apellido1'})) || (C4::AR::Utilidades::validateString($params->{'apellido2'}))){
        if ((C4::AR::Utilidades::validateString($params->{'apellido1'})) && (C4::AR::Utilidades::validateString($params->{'apellido2'}))){
                push (@filtros, ('persona.'.apellido => { gt => $params->{'apellido1'}, eq => $params->{'apellido1'} }) ); # >=
                push (@filtros, ('persona.'.apellido => { lt => $params->{'apellido2'}, eq => $params->{'apellido2'} }) ); # <=

 
       }
        elsif (C4::AR::Utilidades::validateString($params->{'apellido1'})){ 
                push (@filtros, ('persona.'.apellido => { like => '%'.$params->{'apellido1'}.'%'}) );
        }
        else {
                 push (@filtros, ('persona.'.apellido => { like => '%'.$params->{'apellido2'}.'%'}) );
        }
    }

    if ((C4::AR::Utilidades::validateString($params->{'legajo1'})) || (C4::AR::Utilidades::validateString($params->{'legajo2'}))){
        if ((C4::AR::Utilidades::validateString($params->{'legajo1'})) && (C4::AR::Utilidades::validateString($params->{'legajo2'}))){
                push (@filtros, ('persona.'.legajo => { gt => $params->{'legajo1'}, eq => $params->{'legajo1'} }) ); # >=
                push (@filtros, ('persona.'.legajo => { lt => $params->{'legajo2'}, eq => $params->{'legajo2'} }) ); # <=
        }
        elsif (C4::AR::Utilidades::validateString($params->{'legajo1'})) {
                push (@filtros, ('persona.'.legajo => { eq => $params->{'legajo1'}}) );
        }
        else {
               push (@filtros, ('persona.'.legajo => { eq => $params->{'legajo2'}}) );
        }
    }

     push (@filtros, ('persona.'.es_socio => { eq => 1}) );
     push (@filtros, (activo => { eq => 1}) );
     $params->{'cantR'} = $params->{'cantR'} || 0;
     $params->{'ini'} = $params->{'cantR'} || 0;
     my $socios_array_ref=0;
     my $socios_array_ref_count=0;
    eval{
        $socios_array_ref_count = C4::Modelo::UsrSocio::Manager->get_usr_socio_count(   query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($params->{'orden'}) ),
                                                              require_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
                                                                                  'persona.documento'],
        );
        $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($params->{'orden'}) ),
#                                                                             limit => $params->{'cantR'},
#                                                                             offset => $params->{'ini'},
                                                              require_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
                                                                                  'persona.documento'],
        );
    };

    return ($socios_array_ref_count, $socios_array_ref);
}

=item
    Checkea que un nro_documento junto con su tipo, no existan en la base, porque por motivos de diseño, no se puede poner restriccion en la DB.
=cut
sub isUniqueDocument {
    my ($nro_documento,$params) = @_;
    my @filtros;

    push (@filtros, ( 'persona.nro_documento' => {eq => $nro_documento}, ) );

    if (C4::AR::Utilidades::validateString($params->{'nro_socio'})) {
        push (@filtros, (nro_socio => {ne => $params->{'nro_socio'} }) );
    }

    my $cant = C4::Modelo::UsrSocio::Manager::get_usr_socio_count( query => \@filtros,
                                                                   require_objects => ['persona']
                                                                );

    return ($cant == 0); # SE USA 0 PARA SABER QUE NADIE TIENE ESE DOCUMENTO, Y 1 PARA SABER QUE LO TIENE UNO SOLO, SIRVE PARA MODIFICAR
}

=item
    Modulo que dado un nro_socio, le dice al mismo esRegular.
=cut
sub esRegular {

    my ($nro_socio) = @_;
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

    if ($socio){
        return ($socio->esRegular);
    }else{
        return(0);
    }
}



=item
    Este funcion devuelve si el socio tiene que pasar por ventanilla a validar sus datos censales
=cut
sub needsDataValidation {
    my ($nro_socio) = @_;
    if ($nro_socio){
        my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( 
                                                   query => [ nro_socio => { eq => $nro_socio } ],
                                                    select       => ['*'],
                                       );
        if($socio_array_ref){
            my $socio = $socio_array_ref->[0];
       
            return ( $socio->needsValidation());
        }else{
            return 0;
        }
   }
}

=item
    Este funcion devuelve si el socio tiene que pasar por ventanilla a validar sus datos censales
=cut
sub updateUserDataValidation {
    my ($nro_socio) = @_;

    my $msg_object= C4::AR::Mensajes::create();
    use Date::Manip;
    
    if ($nro_socio){
        my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( 
                                                    query => [ nro_socio => { eq => $nro_socio } ],
                                                    select       => ['*'],
                                        );

        if($socio_array_ref){
            my $socio = $socio_array_ref->[0];
            
            eval{
                $socio->updateValidation();
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U415', 'params' => []});
            };
            if ($@){
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U416', 'params' => []} ) ;
            }
        }
    }
    
    return ($msg_object);
}


=item
=item sub getLastLoginTime

Esta funcion devuelve el momento en q se logeo el ultimo socio ed la biblioteca

=cut
sub getLastLoginTime{
    my $dbh = C4::Context->dbh;
    #WARNING: Cuando pasan dias habiles sin actividad se consideran automaticamente feriados
    my $sth=$dbh->prepare("SELECT MAX(last_login) AS lastlogin FROM usr_socio");
    $sth->execute();
    my $lastlogin= $sth->fetchrow;
    return $lastlogin;
}


sub crearPersonaLDAP{
    
    my ($nro_socio)                 = @_;
    use C4::AR::Preferencias;   
    
    my %params                      = {};
    $params{'id_ui'}                = C4::AR::Preferencias::getValorPreferencia("defaultUI");
    $params{'changepassword'}       = 0;
    $params{'apellido'}             = C4::AR::Authldap::_getValorPreferenciaLdap('ldap_lockconfig_field_map_lastname');
    $params{'nombre'}               = C4::AR::Authldap::_getValorPreferenciaLdap('ldap_lockconfig_field_map_firstnames');
    $params{'tipo_documento'}       = "DNI";
    $params{'nro_documento'}        = "999999999";
    $params{'legajo'}               = "99999";
    $params{'cumple_condicion'}     = 0;
    $params{'password'}             = "123456";  
    $params{'ciudad'}               = C4::AR::Authldap::_getValorPreferenciaLdap('ldap_lockconfig_field_map_city');
    $params{'credential_type'}      = "estudiante";
    $params{'nro_socio'}            = $nro_socio;
    $params{'id_categoria'}        = "1";
    
    my $person = C4::Modelo::UsrPersona->new();

    $person->agregar(\%params);
    
}

=item
    Modulo que chekea que el al usuario se le pueda emitir un libre deuda. Queda todo en $msg_object, ademas lo retorna;
=cut
sub _verificarLibreDeuda {

    my ($nro_socio)=@_;


    my $msg_object= C4::AR::Mensajes::create();

    my $libreD=C4::AR::Preferencias::getValorPreferencia("libreDeuda");
    my @array=split(//, $libreD);
    my $ok=1;
    my $msj="";
    # RESERVAS ADJUDICADAS 0--------> flag 1; function C4::AR::Reservas::cant_reservas($borum);
    # RESERVAS EN ESPERA   1--------> flag 2; function C4::AR::Reserves::cant_waiting($borum);
    # PRESTAMOS VENCIDOS   2--------> flag 3; fucntion C4::AR::Sanciones::hasDebts("",$borum); 1 tiene vencidos. 0 no.
    # PRESTAMOS EN CURSO   3--------> flag 4; fucntion C4::AR::Prestamos::DatosPrestamos($borum);
    # SANSIONADO           4--------> flag 5; function C4::AR::Sanciones::hasSanctions($borum);

    if($array[0] eq "1"){
        if(C4::AR::Reservas::_getReservasAsignadas($nro_socio)){
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U418', 'params' => []} ) ;
        }
    }
    if($array[1] eq "1" &&  (!($msg_object->{'error'}))){
        if(C4::AR::Reservas::getReservasDeSocioEnEspera($nro_socio)){
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U419', 'params' => []} ) ;
        }
    }
    if($array[2] eq "1" && (!($msg_object->{'error'}))){
        if(&C4::AR::Sanciones::tieneLibroVencido($nro_socio)){
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U420', 'params' => []} ) ;
        }
    }

     if($array[3] eq "1" && (!($msg_object->{'error'}))){
        if(&C4::AR::Prestamos::tienePrestamos($nro_socio)){
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U421', 'params' => []} ) ;
        }
    }

     if($array[4] eq "1" && (!($msg_object->{'error'}))){
        if(&C4::AR::Sanciones::tieneSanciones($nro_socio)){
          $msg_object->{'error'}= 1;
          C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U422', 'params' => []} ) ;
        }
    }

    return ($msg_object);
}


############################### PASSWORD RECOVERY SUBs #######################################

sub _sendRecoveryPasswordMail{
    my ($socio,$link) = @_;

    use C4::AR::Mail;

    my %mail;

    my $mail_from       = $mail{'mail_from'}  = C4::AR::Preferencias::getValorPreferencia("reserveFrom");
    my $mail_to         = $mail{'mail_to'}    = $socio->persona->getEmail;
    my $mail_subject    = $mail{'mail_subject'}          = C4::AR::Filtros::i18n("Instrucciones para reestablecer su clave");
    
    
## Datos para el mail
    use C4::Modelo::PrefUnidadInformacion;
    use MIME::Lite::TT::HTML;
    
    my $completo            = $socio->persona->getNombre." ".$socio->persona->getApellido;
    my $nro_socio           = $socio->getNro_socio;

    my $ui              = C4::AR::Referencias::obtenerDefaultUI();
    my $nombre_ui       = $ui->getNombre();

    my $mailMessage =
                C4::AR::Filtros::i18n("
		                Estimado/a ")."<b>$completo ($nro_socio)</b>, ".C4::AR::Filtros::i18n("socio de")." $nombre_ui, ".C4::AR::Filtros::i18n("recientemente UD ha solicitado reestablecer su clave.<br />
		                Para hacerlo, haga click en el siguiente enlace y siga los pasos que el sistema le va a indicar").":<br />
		                            <a href='$link'> $link </a> <br /><br /><br /><br /><br /><br />".
		                
		                C4::AR::Filtros::i18n("Si no puede abrir el enlace, copie y pegue la siguente URL en su navegador").": <br /> $link <br />".
		                
		                C4::AR::Filtros::i18n("<br /><br />Si UD no ha solicitado un reseteo de su clave, simplemente ignore este mail. <br />
		                
		                Atte.,")." $nombre_ui.
                ";
    
    
    $mail{'mail_message'}           = $mailMessage;
    $mail{'page_title'}             = C4::AR::Filtros::i18n("Olvido de su contrase&ntilde;a");
    
    my ($ok, $msg_error)            = C4::AR::Mail::send_mail(\%mail);
    
    return (!$ok,$msg_error);

}

sub _buildPasswordRecoverLink{
	my ($socio) = @_;
	my $link = "";
	
	my $hash = sha256_base64(localtime().$socio->getPassword().$socio->getLastValidation());

    my $encoded_hash    = C4::AR::Utilidades::escapeURL($hash);

	
    my $link = "http://".$ENV{'SERVER_NAME'}.C4::AR::Utilidades::getUrlPrefix()."/opac-recover-password.pl?key=".$encoded_hash;
    
    
    return ($link,$hash,$encoded_hash);	
	
	
}

sub _logClientIpAddress{
	my ($operation_type, $socio) = @_;
	use Date::Manip;
	my $client_id =  $ENV{'REMOTE_ADDR'}." <".$ENV{'REMOTE_NAME'}.">";
    my $today = Date::Manip::ParseDate("now");

    $socio->client_ip_recover_pwd($client_id);
    $socio->recover_date_of($today);
    
    $socio->save();

    
	
}

sub recoverPassword{
	my ($params) = @_;

    my $message             = undef;
    my $socio               = undef;
    my $reCaptchaPrivateKey =  C4::AR::Preferencias::getValorPreferencia('re_captcha_private_key');
    my $reCaptchaChallenge  = $params->{'recaptcha_challenge_field'};
    my $reCaptchaResponse   = $params->{'recaptcha_response_field'};
    my $isError             = 0;
    use HTML::Entities;
    
    use Captcha::reCAPTCHA;
    my $c = Captcha::reCAPTCHA->new;
    
    my $captchaResult = $c->check_answer(
        $reCaptchaPrivateKey, $ENV{'REMOTE_ADDR'},
        $reCaptchaChallenge, $reCaptchaResponse
    );

    if ( $captchaResult->{is_valid} ) {

	    my $user_id = C4::AR::Utilidades::trim($params->{'user-id'});
        my $socio   = getSocioInfoPorMixed($user_id);		
		if ($socio){
		    my $db = $socio->db;
            $db->{connect_options}->{AutoCommit} = 0;
            $db->begin_work;
		    
		    eval{
			    _logClientIpAddress('recover_password',$socio);
				my ($link,$hash) = _buildPasswordRecoverLink($socio);
				($isError)                      = _sendRecoveryPasswordMail($socio,$link);
                $socio->setRecoverPasswordHash($hash);
				$db->commit;
                $message                    = C4::AR::Mensajes::getMensaje('U600','opac');
            };
	        if (($@) || $isError){
	        	$message = C4::AR::Mensajes::getMensaje('U606','opac');
	            &C4::AR::Mensajes::printErrorDB($@, 'U606',"opac");
	            $db->rollback;
	        }

	        $db->{connect_options}->{AutoCommit} = 1;
	        		
		}else{
	        $message = C4::AR::Mensajes::getMensaje('U601','opac');
	        $isError = 1;
		}
    }else{
    	$message = C4::AR::Mensajes::getMensaje('U605','opac');
    	$isError = 1;
    }

    return ($isError,$message);
}


sub checkRecoverLink{
	my ($key) = @_;

    my $status = 0;
    
    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( 
                                                 query              => [ 'recover_password_hash' => { eq => $key } ],
                                     );

    if(scalar(@$socio_array_ref)){
        $status = 1;
        my $socio          = $socio_array_ref->[0];
        my $dateformat     = C4::Date::get_date_format();
        my $hoy            = Date::Manip::ParseDate("now");
        my $fecha_link     = $socio->recover_date_of;        
        my $err;

        my $fecha_link        = Date::Manip::DateCalc( $fecha_link, "+ 1 day", \$err );

        my $cmp_result = Date::Manip::Date_Cmp($fecha_link,$hoy);
        
        $status = $cmp_result >= 0; 
        
        if (!$status){
        	$socio->unsetRecoverPasswordHash();
        }
                
         
    }
	
	return ($status)
}


sub changePasswordFromRecover{
	my ($params) = @_;
    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( 
                                                 query              => [ 'recover_password_hash' => { eq => $params->{'key'} } ],
                                     );

    my $message;
    
    if(scalar(@$socio_array_ref)){
    	my $socio = $socio_array_ref->[0];
    	
    	if ($params->{'newpassword1'} eq $params->{'newpassword2'}){
    	   $socio->cambiarPassword($params->{'newpassword1'});
    	   $socio->unsetRecoverPasswordHash();
    	   $message = C4::AR::Mensajes::getMensaje('U603','opac');
    	   
    	}else{
    		$message = C4::AR::Mensajes::getMensaje('U604','opac');
    	}
    }else{
    	$message = C4::AR::Mensajes::getMensaje('U602','opac');
    }

    return ($message);
}   

sub updateUserProfile{
	my ($params) = @_;
	
	my $socio  =   C4::AR::Auth::getSessionNroSocio();
	
	$socio     = getSocioInfoPorNroSocio($socio);
	
	eval{
		$socio->persona->setEmail($params->{'email'});
        $socio->setLocale($params->{'language'});
        $socio->setThemeINTRA($params->{'temas_intra'});
        #SAVE DATA
		$socio->persona->save();
		$socio->save();
	};
	
	return ($socio);
}

END { }       # module clean-up code here (global destructor)

1;
__END__



