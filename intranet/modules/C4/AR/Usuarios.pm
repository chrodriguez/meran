package C4::AR::Usuarios;

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
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Validator;
use C4::AR::Prestamos;
use C4::Modelo::UsrPersona;
use C4::Modelo::UsrPersona::Manager;
use C4::Modelo::UsrEstado;
use C4::Modelo::UsrEstado::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);

@EXPORT=qw(
    &agregarAutorizado
    &agregarPersona
    &habilitarPersona
    &deshabilitarPersona
    &resetPassword
    &eliminarUsuario
    &_verficarEliminarUsuario
    &t_cambiarPermisos
    &_verificarPassword
    &cambiarPassword
    &_verificarDatosBorrower
    &actualizarSocio
    &getSocioInfo
    &getSocioInfoPorNroSocio
    &existeSocio
    &getSocioLike
    &llegoMaxReservas
    &estaSancionado
    &BornameSearchForCard
    &isUniqueDocument
    &esRegular
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
    else{
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U353', 'params' => []} ) ;
    }
    return ($msg_object);
}

=item
    Este modulo agrega una persona al sistema, que dependiendo de las preferencias de MERAN se auto-activará (conviertiendose en Real) o no.
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

=item
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
            my ($partner) = C4::Modelo::UsrSocio->new(id_socio => $socio);
            if ($partner){
                $partner->load();
                $partner->activar;
            }
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U347', 'params' => [$partner->getNro_socio]});
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
            my ($partner) = C4::Modelo::UsrSocio->new(id_socio => $socio);
            if ($partner){
                $partner->load();
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
            $socio->desactivar;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U320', 'params' => [$socio->getNro_socio]} ) ;
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
            $socio->load();

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
            eval {$db->rollback};
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

    if ( !($msg_object->{'error'}) && ( C4::Auth::getSessionNroSocio($params->{'session'}) != $params->{'nro_socio'} ) ){
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
    my ($msg_object)= _verificarPassword($params);

    if(!$msg_object->{'error'}){
    #No hay error
        my  $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});
        if ($socio->load()){
            my $actualPassword = $socio->getPassword;
#             my $cambioDePasswordForzado= 1;
            if( ($params->{'changePassword'} eq 1) && ($socio->getChange_password) ){
                $cambioDePasswordForzado= 1;
            }
            if ( $cambioDePasswordForzado ){
                #es un cambio forzado de la password, se obliga al usuario a cambiar la password, no se compara con la pass actual
                my $newPassword = $params->{'newpassword'};
                $socio->cambiarPassword($newPassword);
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
            }
            elsif ( $actualPassword eq C4::Auth::md5_base64($params->{'actualPassword'}) && !$cambioDePasswordForzado ){
            #es un cambio voluntario de la password
                my $newPassword = $params->{'newpassword'};
                $socio->cambiarPassword($newPassword);
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
            }
            else{
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U361', 'params' => [$params->{'nro_socio'}]} ) ;
                }
        }
        else{
                #Se setea error para el usuario
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U313', 'params' => [$params->{'nro_socio'}]} ) ;
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

    my $documentnumber = $data->{'nro_documento'};
    $checkStatus = &C4::AR::Validator::isValidDocument($data->{'tipo_documento'},$documentnumber);
    if (!($msg_object->{'error'}) && ( $checkStatus == 0)){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U336', 'params' => []} ) ;
    }else{
          if ( (!C4::AR::Usuarios::isUniqueDocument($documentnumber,$data)) && ( !$data->{'modifica'} ) ) {
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

    my ($params)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();
    use C4::Modelo::UsrSocio::Manager;

    $params->{'actionType'} = "update";
    $params->{'modifica'} = 1;

    _verificarDatosBorrower($params, $msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;

        eval {
#             my $socio = getSocioInfoPorNroSocio($params->{'nro_socio'});
            my $socio = C4::Modelo::UsrSocio->new(nro_socio => $params->{'nro_socio'});
            $socio->load();
            $socio->modificar($params);
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U338', 'params' => []} ) ;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B424',"INTRA");
            eval {$dbh->rollback};
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
    my  $socio = C4::Modelo::UsrSocio->new(id_socio => $id_socio);
    use C4::Modelo::UsrSocio;
    use C4::Modelo::UsrSocio::Manager;

    if ($socio){
        $socio->load();
        return ($socio);
    }else{
        return (0);
    }
}

=item
    Este funcion devuelve la informacion del usuario segun un nro_socio
=cut
sub getSocioInfoPorNroSocio {

    my ($nro_socio)= @_;
    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( query => [ nro_socio => { eq => $nro_socio } ]);
    use C4::Modelo::UsrSocio;

    if($socio_array_ref){
        return ($socio_array_ref->[0]);
    }else{
        return 0;
    }
}

=item
    Este funcion devuelve 1 si existe el socio y 0 si no existe
=cut
sub existeSocio {

    my ($nro_socio)= @_;
    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio_count( query => [ nro_socio => { eq => $nro_socio } ]);
    use C4::Modelo::UsrSocio;

	return $socio_array_ref;
}

=item
    Esta funcion busca por nro_documento, nro_socio, apellido y combinados por ej: "27 Car", donde 27 puede ser parte del DNI o legajo o ambos
=cut
sub getSocioLike {

    use C4::Modelo::UsrSocio;
    use C4::Modelo::UsrSocio::Manager;
    my ($socio,$orden,$ini,$cantR,$habilitados,$inicial) = @_;
    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();
    my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($socio);

    if($socio ne 'TODOS'){
        #SI VIENE INICIAL, SE BUSCA SOLAMENTE POR APELLIDOS QUE COMIENCEN CON ESA LETRA, SINO EN TODOS LADOS CON LIKE EN AMBOS LADOS
        if (!($inicial)){
            foreach my $s (@searchstring_array){ 
                push (	@filtros, ( or   => [   apellido => { like => '%'.$s.'%'}, 
                                                nro_documento => { like => '%'.$s.'%' }, 
                                                legajo => { like => '%'.$s.'%' }  
                                            ])
                     );
            }
        }else{
            foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   apellido => { like => $s.'%'}, 
                                            ])
                                    );
            }
        }
    }

    if (!defined $habilitados){
        $habilitados = 1;
    }

    push(@filtros, ( activo => { eq => $habilitados}));
    push(@filtros, ( es_socio => { eq => $habilitados}));
    my $ordenAux= $socioTemp->sortByString($orden);

    my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => $ordenAux,
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
                                                                            require_objects => [ 'persona' ]
     ); 

    #Obtengo la cant total de socios para el paginador
    my $socios_array_ref_count = C4::Modelo::UsrSocio::Manager->get_usr_socio_count( query => \@filtros,
                                                                               require_objects => [ 'persona' ]
                                                                     );

    if(scalar(@$socios_array_ref) > 0){
        return ($socios_array_ref_count, $socios_array_ref);
    }else{
        return (0,0);
    }
}

=item
    Verifica si el usuario llego al maximo de las resevas que puede relizar sengun la preferencia del sistema, recibe el numero de socio
=cut
sub llegoMaxReservas {

    my ($nro_socio)=@_;
    my $cant= &C4::AR::Reservas::cant_reservas($nro_socio);

    return ( $cant >= C4::AR::Preferencias->getValorPreferencia("maxreserves") );
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

=item
    Busca todos los usuarios, con sus datos, entre un par de nombres o legajo para poder crear los carnet.
=cut
sub BornameSearchForCard {

    my ($apellido1,$apellido2,$category,$branch,$orden,$regular,$legajo1,$legajo2) = @_;
    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();

    if ((C4::AR::Utilidades::validateString($category))&& ($category ne 'SIN SELECCIONAR')) {
           push (@filtros, (cod_categoria => { eq => $category }) );
    }

    if ((C4::AR::Utilidades::validateString($apellido1)) || (C4::AR::Utilidades::validateString($apellido2))){
        if ((C4::AR::Utilidades::validateString($apellido1)) && (C4::AR::Utilidades::validateString($apellido2))){
                push (@filtros, ('persona.'.apellido => { gt => $apellido1, eq => $apellido1 }) ); # >=
                push (@filtros, ('persona.'.apellido => { lt => $apellido2, eq => $apellido2 }) ); # <=

 
       }
        elsif (C4::AR::Utilidades::validateString($apellido1)){ 
                push (@filtros, ('persona.'.apellido => { like => '%'.$apellido1.'%'}) );
        }
        else {
                 push (@filtros, ('persona.'.apellido => { like => '%'.$apellido2.'%'}) );
        }
    }

    if ((C4::AR::Utilidades::validateString($legajo1)) || (C4::AR::Utilidades::validateString($legajo2))){
        if ((C4::AR::Utilidades::validateString($legajo1)) && (C4::AR::Utilidades::validateString($legajo2))){
                push (@filtros, ('persona.'.legajo => { gt => $legajo1, eq => $legajo1 }) ); # >=
                push (@filtros, ('persona.'.legajo => { lt => $legajo2, eq => $legajo2 }) ); # <=
        }
        elsif (C4::AR::Utilidades::validateString($legajo1)) {
                push (@filtros, ('persona.'.legajo => { eq => $legajo1}) );
        }
        else {
               push (@filtros, ('persona.'.legajo => { eq => $legajo2}) );
        }
    }

     push (@filtros, ('persona.'.es_socio => { eq => 1}) );
     push (@filtros, (activo => { eq => 1}) );
     my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($orden) ),
                                                                            require_objects => [ 'persona' ]
     );

    return (scalar(@$socios_array_ref), $socios_array_ref);
}

=item
    Checkea que un nro_documento junto con su tipo, no existan en la base, porque por motivos de diseño, no se puede poner restriccion en la DB.
=cut
sub isUniqueDocument {

    my ($nro_documento,$params) = @_;
    my @filtros;
    use C4::Modelo::UsrSocio::Manager;

    push (@filtros, ( 'persona.nro_documento' => {eq => $nro_documento},
                      'persona.tipo_documento' => {eq => $params->{'tipo_documento'} } ) );

    if (C4::AR::Utilidades::validateString($params->{'nro_socio'})) {
        push (@filtros, (nro_socio => {ne => $params->{'nro_socio'} }) );
    }

    my $cant = C4::Modelo::UsrSocio::Manager::get_usr_socio_count( query => \@filtros,
                                                                       require_objects => ['persona'], );

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

1;
