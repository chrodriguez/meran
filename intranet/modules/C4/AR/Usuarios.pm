package C4::AR::Usuarios;

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

    &t_delPersons
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
    &t_updateBorrower
    &getSocioInfo
    &getSocioInfoPorNroSocio
    &existeSocio
    &getPersonaLike
    &getSocioLike
    &llegoMaxReservas
    &estaSancionado
    &BornameSearchForCard
    &isUniqueDocument
    &esRegular

);


sub t_delPersons {  
    my($persons_array_ref)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();

    # enable transactions, if possible
    $dbh->{AutoCommit} = 0;  
    $dbh->{RaiseError} = 1;

    eval {
        _delPersons($persons_array_ref, $msg_object);   
        $dbh->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
        eval {$dbh->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => []} ) ;
    }
    $dbh->{AutoCommit} = 1;

    return ($msg_object);
}

sub agregarAutorizado{
    my ($params)=@_;
    C4::AR::Debug::debug("NRO_SOCIO: ".$params->{'nro_socio'});
    my $msg_object= C4::AR::Mensajes::create();
    my ($socio) = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});
    if ($socio){
        my $db = $socio->db;
        if (!($msg_object->{'error'})){
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
    }
    else{
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U353', 'params' => []} ) ;
    }
    return ($msg_object);
}

sub agregarPersona{
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
   
sub habilitarPersona{

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

sub deshabilitarPersona{

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

sub resetPassword {
    
    my($params)=@_;
    my $id_socio = $params->{'id_socio'};
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = getSocioInfo($id_socio);
    
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

# Esta función es el manejador de transacción para eliminarUsuario. Recibe una hash conteniendo los campos:
#  borrowernumber y usuario.
sub eliminarUsuario {
    
    my($nro_socio)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = getSocioInfoPorNroSocio($nro_socio);
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

# Esta función verifica que un usuario exista en la DB. Recibe una hash conteneniendo: borrowernumber y  usuario.
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
# FIXME fijarse que aca no se checkea nada, por ejemplo si tiene reservas, libros en su poder, etc...

sub _verficarEliminarUsuario {
    my($params,$msg_object)=@_;

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

# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
sub t_cambiarPermisos {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
		my $socio= getSocioInfoPorNroSocio($params->{'nro_socio'});
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

#  Funcion que recibe una hash con newpassword y  newpassword1, para checkear que sean iguales. Retortan 0 en caso de exito y 1 en error.
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
sub _verificarPassword {
    my($params)=@_;

    my ($msg_object)= &C4::AR::Validator::checkPassword($params->{'newpassword'});


    if( !($msg_object->{'error'}) && ( $params->{'newpassword'} ne $params->{'newpassword1'} ) ){
    #las password no coinciden
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U315', 'params' => [$params->{'cardnumber'}]} ) ;
    }

    if ( !($msg_object->{'error'}) && ( C4::Auth::getSessionIdSocio($params->{'session'}) != $params->{'id_socio'} ) ){
    #no coincide el usuario logueado con el usuario al que se le va a cambiar la password
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U362', 'params' => [$params->{'nro_socio'}]} ) ;
    }

    return ($msg_object);
}

sub cambiarPassword {
    my($params)=@_;

    my ($msg_object)= _verificarPassword($params);
   
    if(!$msg_object->{'error'}){
    #No hay error
        my  $socio = C4::Modelo::UsrSocio->new(id_socio => $params->{'id_socio'});
        if ($socio->load()){
            my $actualPassword = $socio->getPassword;
            my $cambioDePasswordForzado= 1;
            if( ($params->{'changePassword'} eq 1)&&($socio->getChange_password) ){$cambioDePasswordForzado= 1;}

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
            else
                {
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U361', 'params' => [$params->{'nro_socio'}]} ) ;
                }
        }
        else
        {
                #Se setea error para el usuario
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U313', 'params' => [$params->{'nro_socio'}]} ) ;
            }
    }

    return ($msg_object);
}

# Como todos los manejadores de transacciones
# Esta funcion se utiliza para validar todos los datos de un borrower nuevo o modificación de uno existente.
# Recibe un hash con todos sus datos.
# Retorna $error (como siempre, al reves {1 true}) y un $codMsg, en ese orden
sub _verificarDatosBorrower{

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
}

sub actualizarSocio {
    use C4::Modelo::UsrSocio::Manager;
    my($params)=@_;
    $params->{'actionType'} = "update";
    my $dbh = C4::Context->dbh;

    my $msg_object= C4::AR::Mensajes::create();

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

sub t_updateBorrower {
    
    my($params)=@_;
    $params->{'actionType'} = "update";
    my $dbh = C4::Context->dbh;

    my $msg_object= C4::AR::Mensajes::create();

    _verificarDatosBorrower($params, $msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;
    
        eval {
            updateBorrower($params);        
            $dbh->commit;
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
Esta funcion devuelve la informacion del socio, segun el id_socio
=cut
sub getSocioInfo {
    
    use C4::Modelo::UsrSocio;
    use C4::Modelo::UsrSocio::Manager;

    my ($id_socio) = @_;

    my  $socio = C4::Modelo::UsrSocio->new(id_socio => $id_socio);
    
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
sub getSocioInfoPorNroSocio{

    use C4::Modelo::UsrSocio;

    my ($nro_socio)= @_;

    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( query => [ nro_socio => { eq => $nro_socio } ]);

	if($socio_array_ref){
		return ($socio_array_ref->[0]);
	}else{
		return 0;
	}
}

=item
Este funcion devuelve 1 si existe el socio y 0 si no existe
=cut
sub existeSocio{

    use C4::Modelo::UsrSocio;

    my ($nro_socio)= @_;

    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio_count( query => [ nro_socio => { eq => $nro_socio } ]);

	return $socio_array_ref;
}

# FIXME parece q no se usa???????????????????
sub getPersonaLike {
    
    use C4::Modelo::UsrPersona;
    use C4::Modelo::UsrPersona::Manager;

    my ($persona,$orden,$ini,$cantR,$habilitados) = @_;
    my  $personas_array_ref;
    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();
 
    if (($habilitados == 1)){
        push(@filtros, ( activo=> { eq => 0}) );
     }

    if($persona ne 'TODOS'){
        push(@filtros, ( apellido=> { like => $persona.'%' } ) );
    }
    
    $personas_array_ref = C4::Modelo::UsrPersona::Manager->get_usr_persona( query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($orden) ),
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
     ); 

    #Obtengo la cant total de socios para el paginador
    my $personas_array_ref_count= C4::Modelo::UsrPersona::Manager->get_usr_persona_count( query => \@filtros);
# FIXME aca hay algo raro!!
    return ($personas_array_ref_count, $personas_array_ref);
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
			    push (	@filtros, ( or   => [ 	apellido => { like => '%'.$s.'%'}, 
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
# C4::AR::Debug::debug('habilitado: '.$habilitados);
    push(@filtros, ( activo => { eq => $habilitados}));
    push(@filtros, ( es_socio => { eq => $habilitados}));
	my $ordenAux= $socioTemp->sortByString($orden);

# PATCH ADAMS, si queda con apellido solo se rompe porque quiere ordenar por t1.apellido, donde t1 es usr_socio
#     if ($ordenAux == "apellido"){
#         $ordenAux = "persona.apellido";
#     }
    my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => $ordenAux,
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
                                                                            require_objects => [ 'persona' ]
     ); 

# 	C4::AR::Debug::debug("getSocioLike=> orden: ".$orden);
# 	C4::AR::Debug::debug("getSocioLike=> sortByString: ".$ordenAux);

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

#Verifica si el usuario llego al maximo de las resevas que puede relizar sengun la preferencia del sistema
sub llegoMaxReservas {

    my ($usr_socio)=@_;

    my $cant= &C4::AR::Reservas::cant_reservas($usr_socio);

    return $cant >= C4::AR::Preferencias->getValorPreferencia("maxreserves");
}

#Verifica si un usuario esta sancionado segun un tipo de prestamo
sub estaSancionado {

    my ($borrowernumber,$issuecode)=@_;
    my $sancionado= 0;

    my @sancion= C4::AR::Sanciones::permitionToLoan($borrowernumber, $issuecode);

    if (($sancion[0]||$sancion[1])) { 
        $sancionado= 1;
    }

    return $sancionado;
}

# Busca todos los usuarios, con sus datos, entre un par de nombres o legajo para poder crear los carnet.
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

sub isUniqueDocument {

    my ($nro_documento,$params) = @_;
    
    use C4::Modelo::UsrSocio::Manager;
    my @filtros;

    push (@filtros, ( 'persona.nro_documento' => {eq => $nro_documento},
                      'persona.tipo_documento' => {eq => $params->{'tipo_documento'} } ) );

    if (C4::AR::Utilidades::validateString($params->{'nro_socio'})) {
        push (@filtros, (nro_socio => {ne => $params->{'nro_socio'} }) );
    }

    my $cant = C4::Modelo::UsrSocio::Manager::get_usr_socio_count( query => \@filtros,
                                                                       require_objects => ['persona'], );
    
    return ($cant == 0); # SE USA 0 PARA SABER QUE NADIE TIENE ESE DOCUMENTO, Y 1 PARA SABER QUE LO TIENE UNO SOLO, SIRVE PARA MODIFICAR
}

sub esRegular{

    my ($nro_socio) = @_;

    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

    return ($socio->esRegular);
}

1;
