package C4::AR::Reservas;

use strict;
require Exporter;

use Mail::Sendmail;
use C4::AR::Mensajes;
use C4::AR::Prestamos;
use Date::Manip;
use C4::Date;#formatdate
use C4::Modelo::CircReserva;
use C4::Modelo::CircReserva::Manager;
use C4::Modelo::CatRegistroMarcN3::Manager;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 3.0;

@ISA = qw(Exporter);

@EXPORT = qw(
    &t_reservarOPAC
    &t_cancelar_reserva
    &t_cancelar_y_reservar
    &cancelar_reservas
    &cant_reservas
    &getReservasDeGrupo
    &cantReservasPorGrupo
    &DatosReservas
    &getDatosReservaDeId3
    &cant_waiting
    &CheckWaiting
    &tiene_reservas
    &Enviar_Email
    &FindNotRegularUsersWithReserves
    &eliminarReservasVencidas
    &reasignarTodasLasReservasEnEspera
    &getReserva
    &t_realizarPrestamo
    &eliminarReservas
);

=head2  sub getNivel3ParaReserva
    Busca un nivel3 sin reservas para los prestamos y nuevas reservas.
=cut
sub getNivel3ParaReserva{
    my ($id2, $disponibilidad) = @_;

    my $diponibilidad_filtro       = 'ref_disponibilidad@1';                # 1 =  Domiciliario
    my $estado_disponible_filtro   = 'ref_estado@3';                        # 3   Disponible

    my @filtros;

    push (  @filtros, ( id2         => { eq => $id2} ) );                                   #ejemplares del grupo
    push (  @filtros, ( marc_record => { like => '%'.$diponibilidad_filtro.'%' } ) );       #con esta disponibilidad
    push (  @filtros, ( marc_record => { like => '%'.$estado_disponible_filtro.'%' } ) );   #con estado disponible

    my $nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( query => [ @filtros ] );

    foreach my $nivel3 (@$nivel3_array_ref){
        if(estaLibre($nivel3->getId3)){
            return($nivel3);
        }
    }

    
    return 0;
}

=head2  sub estaLibre 
    Devuelve si esta libre: sin prestamos ni reservas
=cut
sub estaLibre{

    my ($id3)=@_;   

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id3    => { eq => $id3}));
    push(@filtros, ( estado => { ne => undef}));
    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros);

    if ($reservas_array_ref){
        return 1;
    }else{
      return 0;
    }
}
#===================================================hasta aca revisado=======================================================================


sub t_cancelar_y_reservar {
    
    my($params)=@_;

    my $paramsReserva;
    my ($msg_object);   

    my $db = undef;
    my ($reserva) = getReserva($params->{'id_reserva'});
    if ($reserva){
        $db = $reserva->db;
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $reserva->cancelar_reserva($params);
    
            my ($msg_object)= &_verificaciones($params);
            
            if(!$msg_object->{'error'}){
    
                ($paramsReserva)= $reserva->reservar($params);
    
                #Se setean los parametros para el mensaje de la reserva SIN ERRORES
                if($paramsReserva->{'estado'} eq 'E'){
                #SE RESERVO CON EXITO UN EJEMPLAR
                    $msg_object->{'error'}= 0;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U302', 'params' => [    $paramsReserva->{'desde'}, 
                                                        $paramsReserva->{'desdeh'},
                                                        $paramsReserva->{'hasta'},
                                                        $paramsReserva->{'hastah'}
                            ]} ) ;
    
                }else{
                #SE REALIZO UN RESERVA DE GRUPO
                    my $borrowerInfo= C4::AR::Usuarios::getBorrowerInfo($params->{'borrowernumber'});
                    $msg_object->{'error'}= 0;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U303', 'params' => [$borrowerInfo->{'emailaddress'}]} ) ;
                }
            }
    
            $db->commit;    
        };
    }
    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B407',"OPAC");
        eval {$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R011', 'params' => []} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    
    return ($msg_object);
}

=item
Esta funcion elimina todas las del borrower pasado por parametro
=cut
sub eliminarReservas{
    my ($socio)=@_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(query => [ nro_socio => { eq => $socio } ]); 

    foreach my $reserva (@$reservas_array_ref){
       $reserva->delete();
    }
}


=item
Esta funcion reasigna todas las reservas de un borrower
recibe como parametro un borrowernumber y el loggedinuser
Esta funcion se utiliza por ej. cuando se elimina un usuario
=cut
sub reasignarTodasLasReservasEnEspera{
    my ($params) = @_;

    my $reservas = _getReservasAsignadas($params->{'nro_socio'});

    foreach my $reserva (@$reservas){

        $reserva->reasignarEjemplarASiguienteReservaEnEspera($reserva->{'loggedinuser'});
    }
}


=item
actualizarDatosReservaEnEspera
Funcion que actualiza la reserva que estaba esperando por un ejemplar.
=cut
# FIXME DEPRECATED
=item
sub _actualizarDatosReservaEnEspera{
    my ($reservaGrupo,$loggedinuser)=@_;

    my $dateformat = C4::Date::get_date_format();
    my $hoy=C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

#Se agrega actualiza la reserva
    my ($desde,$fecha,$apertura,$cierre)=C4::Date::proximosHabiles(C4::AR::Preferencias->getValorPreferencia("reserveGroup"),1);
    $reservaGrupo->setEstado('E');
    $reservaGrupo->setFecha_reserva($desde);
    $reservaGrupo->setFecha_notificacion($hoy);
    $reservaGrupo->setFecha_recordatorio($fecha);
    $reservaGrupo->save();

# Se agrega una sancion que comienza el dia siguiente al ultimo dia que tiene el usuario para ir a retirar el libro
    my $err= "Error con la fecha";
    my $dateformat=C4::Date::get_date_format();
    my $startdate= C4::Date::DateCalc($fecha,"+ 1 days",\$err);
    $startdate= C4::Date::format_date_in_iso($startdate,$dateformat);
    my $daysOfSanctions= C4::AR::Preferencias->getValorPreferencia("daysOfSanctionReserves");
    my $enddate= C4::Date::DateCalc($startdate, "+ $daysOfSanctions days", \$err);
    $enddate= C4::Date::format_date_in_iso($enddate,$dateformat);
    C4::AR::Sanciones::insertSanction(undef, $reservaGrupo->getId ,$reservaGrupo->getNro_socio, $startdate, $enddate, undef);

    my $params;
    $params->{'cierre'}= $cierre;
    $params->{'fecha'}= $fecha;
    $params->{'desde'}= $desde;
    $params->{'apertura'}= $apertura;
    $params->{'loggedinuser'}= $loggedinuser;
    #Se envia una notificacion al usuario avisando que se le asigno una reserva
    Enviar_Email($reservaGrupo,$params);
}
=cut

sub cant_reservas{
#Cantidad de reservas totales de GRUPO y EJEMPLARES
        my ($nro_socio)=@_;
    
        use C4::Modelo::CircReserva;
        use C4::Modelo::CircReserva::Manager;
        my @filtros;
        push(@filtros, ( nro_socio  => { eq => $nro_socio}));
        push(@filtros, ( estado     => { ne => 'P'} ));

        my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count( query => \@filtros); 
        return ($reservas_count);
}

sub cantReservasPorGrupo{
#Devuelve la cantidad de reservas realizadas (SIN PRESTAR) sobre un GRUPO
    my ($id2)=@_;

        use C4::Modelo::CircReserva;
        use C4::Modelo::CircReserva::Manager;
        my @filtros;
        push(@filtros, ( id2    => { eq => $id2}));
        push(@filtros, ( estado => { ne => 'P'} ));

        my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count( query => \@filtros); 
        return ($reservas_count);
}

#cuenta las reservas pendientes del grupo
sub cantReservasPorGrupoEnEspera{
    my ($id2)=@_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2    => { eq => $id2}));
    push(@filtros, ( id3    => { eq => undef}));
    push(@filtros, ( estado => { ne => 'P'} ));

    my $reservas_count = C4::Modelo::CircReserva::Manager->get_circ_reserva_count( query => \@filtros); 

    return ($reservas_count);
}

sub _chequeoParaPrestamo {
    my($params,$msg_object)=@_;
    my $dbh=C4::Context->dbh;

    my $nro_socio= $params->{'nro_socio'};
    my $id2= $params->{'id2'};
    my $id3= $params->{'id3'};
C4::AR::Debug::debug("_chequeoParaPrestamo=> id2: ".$id2);
C4::AR::Debug::debug("_chequeoParaPrestamo=> id3: ".$id3);
C4::AR::Debug::debug("_chequeoParaPrestamo=> nro_socio: ".$nro_socio);
#Se verifica si ya se tiene la reserva sobre el grupo
    my ($reservas, $cant)= getReservasDeSocio($nro_socio, $id2);# ver lo que sigue.
#   $params->{'reservenumber'}= $reservas->[0]->getId_reserva;

# print A "reservenumber de reserva: $reservas->[0]->getId_reserva\n";

#********************************        VER!!!!!!!!!!!!!! *************************************************
# Si tiene un ejemplar prestado de ese grupo no devuelve la reserva porque en el where estado <> P, Salta error cuando se quiere crear una nueva reserva por el else de abajo. El error es el correcto, pero se puede detectar antes.
# Tendria que devolver todas las reservas y despues verificar los tipos de prestamos de cada ejemplar (notforloan)
# Si esta prestado la clase de prestamo que se quiere hacer en este momento. 
# Si no esta prestado se puede hacer lo de abajo, lo que sigue (estaba pensado para esa situacion).
# Tener en cuenta los prestamos especiales, $tipo_prestamo ==> ES ---> SA. **** VER!!!!!!
    my $disponibilidad=getDisponibilidad($id3);
    if($cant == 1 && $disponibilidad eq "Domiciliario"){
    #El usuario ya tiene la reserva, se le esta entregando un item que es <> al que se le asigno al relizar la reserva
    #Se intercambiaron los id3 de las reservas, si el item que se quiere prestar esta prestado se devuelve el error.
        if($id3 != $reservas->[0]->getId3){
        #Los ids son distintos, se intercambian.
            &intercambiarId3($nro_socio,$id2,$id3,$reservas->[0]->getId3,$msg_object);
        }
    }
    elsif($cant==1 && $disponibilidad eq "Para Sala"){
        #FALTA!!! SE PUEDE PONER EN EL ELSE???  
        #llamar a la funcion verificaciones!!
        #verificar disponibilidad del item??? ya esta prestado- hay libre para prestamo de SALA.
        #es un prestamo ES ?????? ****VER****
    }
    else{
        #Se verifca disponibilidad del item;
        my $data=getReservaDeId3($id3);
        my $sePermiteReservaGrupo=1;
        if ($data){
        #el item se encuentra reservado, y hay que buscar otro item del mismo grupo para asignarlo a la reserva del otro usuario
            my $datosNivel3= C4::AR::Reservas::getNivel3ParaReserva($params->{'id2'},$disponibilidad);
            if($datosNivel3){
                &cambiarId3($datosNivel3->getId3,$data->getId_reserva);
                # el id3 de params quedo libre para ser reservado
            }
            else{
# NO HAY EJEMPLARES LIBRES PARA EL PRESTAMO, SE PONE EL ID3 EN "" PARA QUE SE
# REALIZE UNA RESERVA DE GRUPO, SI SE PERMITE.
                $params->{'id3'}="";
                if(!C4::AR::Preferencias->getValorPreferencia('intranetGroupReserve')){
                #NO SE PERMITE LA RESERVA DE GRUPO
                    $sePermiteReservaGrupo=0;
                    #Hay error no se permite realizar una reserva de grupo en intra.
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R004', 'params' => []} ) ;
                }else{
                #SE PERMITE LA RESERVA DE GRUPO
                    #No hay error, se realiza una reserva de grupo.
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R005', 'params' => []} ) ;
                }
            }
        }
        #Se realiza una reserva
        if($sePermiteReservaGrupo){
            my ($reserva) = C4::Modelo::CircReserva->new();
            $reserva->load();
#           my $db = $reserva->db;
# # FIXME faltan devolver los parametros
#           my ($paraReservas)= reservar($params);
#           $params->{'reservenumber'}= $paraReservas->{'reservenumber'};
        }
    }
    
    if(!$msg_object->{'error'}){
    #No hay error, se realiza el pretamo
        insertarPrestamo($params);

        #se realizan las verificacioines luego de realizar el prestamo
        _verificacionesPostPrestamo($params,$msg_object);
    }
}

#para enviar un mail cuando al usuario se le vence la reserva
sub Enviar_Email{
    my ($reserva,$params)=@_;

    my $desde= $params->{'desde'};
    my $fecha= $params->{'fecha'};
    my $apertura= $params->{'apertura'};
    my $cierre= $params->{'cierre'};
    my $loggedinuser= $params->{'loggedinuser'};

    if (C4::AR::Preferencias->getValorPreferencia("EnabledMailSystem")){

        my $dateformat = C4::Date::get_date_format();
        my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($reserva->getNro_socio);
        
        my $mailFrom=C4::AR::Preferencias->getValorPreferencia("reserveFrom");
        my $mailSubject =C4::AR::Preferencias->getValorPreferencia("reserveSubject");
        my $mailMessage =C4::AR::Preferencias->getValorPreferencia("reserveMessage");
        
        $mailSubject =~ s/BRANCH/$reserva->ui->getNombre/;
        $mailMessage =~ s/BRANCH/$reserva->ui->getNombre/;
        $mailMessage =~ s/FIRSTNAME/$socio->persona->getNombre/;
        $mailMessage =~ s/SURNAME/$socio->persona->getApellido/;
        
        my $unititle=C4::AR::Nivel1::getUnititle($reserva->nivel2->nivel1->getId1);
        $mailMessage =~ s/UNITITLE/$unititle/;
        
        $mailMessage =~ s/TITLE/$reserva->nivel2->nivel1->getTitulo/;
        $mailMessage =~ s/AUTHOR/$reserva->nivel2->nivel1->cat_autor->getCompleto/;
        
        my $edicion=C4::AR::Nivel2::getEdicion($reserva->getId2);
        $mailMessage =~ s/EDICION/$edicion/;

        $mailMessage =~ s/a2/$apertura/;
        $desde=C4::Date::format_date($desde,$dateformat);
        $mailMessage =~ s/a1/$desde/;
        $mailMessage =~ s/a3/$cierre/;
        $fecha=C4::Date::format_date($fecha,$dateformat);
        $mailMessage =~ s/a4/$fecha/;
        my %mail = (    To => $socio->persona->getEmail,
                From => $mailFrom,
                Subject => $mailSubject,
                Message => $mailMessage);

        my $resultado='ok';
        if ($socio->persona->getEmail && $mailFrom ){
            if (!sendmail(%mail))
                {$resultado='error'};
        }else {$resultado='';}

#**********************************Se registra el movimiento en rep_historial_circulacion***************************
   my $dateformat=C4::Date::get_date_format();
   $fecha= C4::Date::format_date_in_iso($fecha,$dateformat);

   my $data_hash;
   $data_hash->{'id1'}=$reserva->nivel2->nivel1->getId1;
   $data_hash->{'id2'}=$reserva->getId2;
   $data_hash->{'id3'}=$reserva->getId3;
   $data_hash->{'nro_socio'}=$reserva->getNro_socio;
   $data_hash->{'loggedinuser'}=$loggedinuser;
   $data_hash->{'end_date'}=$fecha;
   $data_hash->{'issuesType'}='-';
   $data_hash->{'id_ui'}=$reserva->getId_ui;
   $data_hash->{'tipo'}='notification';

   use C4::Modelo::RepHistorialCirculacion;
   my ($historial_circulacion) = C4::Modelo::RepHistorialCirculacion->new(db=>$reserva->db);
   $historial_circulacion->agregar($data_hash);
#*******************************Fin***Se registra el movimiento en rep_historial_circulacion*************************

    }#end if (C4::Context->preference("EnabledMailSystem"))
}


=item sub estaReservado
    Devuelve 1 si esta reservado el ejemplar pasado por parametro, 0 caso contrario
=cut
sub estaReservado{
    my ($id3)=@_;   

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id3    => { eq => $id3}));
#     push(@filtros, ( estado => { ne => undef}));
    my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros);

    if (scalar(@$reservas_array_ref) > 0){
        return 1;
    }else{
        return 0;
    }
}

# =item sub tieneReservas
#     Devuelve 1 si tiene ejemplares reservados en el grupo, 0 caso contrario
# =cut
# sub tieneReservas{
#     my ($id2) = @_;   
# 
#     use C4::Modelo::CircReserva;
#     use C4::Modelo::CircReserva::Manager;
#     my @filtros;
#     push(@filtros, ( id2    => { eq => $id2}));
# 
#     my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros);
# 
#     if (scalar(@$reservas_array_ref) > 0){
#         return 1;
#     }else{
#         return 0;
#     }
# }

sub _verificarHorario{
    my $end = ParseDate(C4::AR::Preferencias->getValorPreferencia("close"));
    my $begin =C4::Date::calc_beginES();
    my $actual=ParseDate("today");
    my $error=0;

    if ((Date_Cmp($actual, $begin) < 0) || (Date_Cmp($actual, $end) > 0)){
        $error=1;
    }

    return $error;
}

sub getDisponibilidad{
#Devuelve la disponibilidad del item ('Para Sala', 'Domiciliario')
    my ($id3) = @_;   
    my  $catNivel3 = C4::AR::Nivel3::getNivel3FromId3($id3);

    if ($catNivel3){
        return C4::AR::Referencias::getNombreDisponibilidad($catNivel3->getId_disponibilidad);
    }else{
      return (0);
    }
}

=item
_verificarTipoReserva
Verifica que el usuario no reserve un item y que ya tenga una reserva para el mismo grupo
=cut
sub _verificarTipoReserva {
    my ($nro_socio, $id2)=@_;
    my $error= 0;
    my ($reservas, $cant)= getReservasDeSocio($nro_socio, $id2);
    #Se intento reservar desde el OPAC sobre el mismo GRUPO
    if ($cant == 1){$error= 1;}
    return ($error);
}

sub getReservasDeSocio {
#devuelve las reservas de grupo del usuario
    my ($nro_socio,$id2)=@_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2    => { eq => $id2}));
    push(@filtros, ( nro_socio  => { eq => $nro_socio} ));
    push(@filtros, ( estado     => { ne => 'P'} ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros, require_objects => ['nivel3','nivel2']);

    return ($reservas_array_ref,scalar(@$reservas_array_ref));
}

sub getReservasDeId2 {
#devuelve las reservas de grupo
    my ($id2) = @_;
    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2    => { eq => $id2}));
    push(@filtros, ( estado     => { ne => 'P'} ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros, require_objects => ['nivel3','nivel2']); 

    return ($reservas_array_ref,scalar(@$reservas_array_ref));
}


sub obtenerReservasDeSocio {
    
    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    my ($socio,$db) = @_;
    $db = $db || C4::Modelo::CircReserva->new()->db;

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( 
                                                    db => $db,
                                                    query => [ nro_socio => { eq => $socio }, estado => {ne => 'P'}],
                                                    require_objects     => [ 'nivel3.nivel2' ], # INNER JOIN
                                                    with_objects        => [ 'nivel3' ] #LEFT JOIN
                                ); 

    if(scalar(@$reservas_array_ref) > 0){
        return ($reservas_array_ref);
    }else{
        return 0;
    }
}

=item
Dado un socio, devuelve las reservas asignadas a el
=cut
sub _getReservasAsignadas {

    my ($socio,$db)=@_;
    $db = $db || C4::Modelo::CircReserva->new()->db;
    
    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(
                                                                    db => $db,
                                                                    query => [ nro_socio => { eq => $socio }, id3 => {ne => undef} ],
                                                                    require_objects => ['nivel3','nivel2'] 
                                                    );

    return($reservas_array_ref);
}

=item
getReserva
Funcion que retorna la informacion de la reserva con el numero que se le pasa por parametro.
=cut
sub getReserva{
    my ($id,$db)=@_;
    my @filtros;

    $db = $db || C4::Modelo::CircReserva->new()->db;

    push (@filtros, (id_reserva => {eq => $id}) );

    my ($reserva) = C4::Modelo::CircReserva::Manager->get_circ_reserva( db => $db, query => \@filtros, 
                                                                        require_objects => ['nivel3','nivel2']);

    if (scalar(@$reserva)){
        return ($reserva->[0]);
    }else{
        return(0);
    }
}

=item
reservasVencidas
Devuele una referencia a un arreglo con todas las reservas que esta vencidas al dia de la fecha.
=cut
sub reservasVencidas{

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    my $dateformat = C4::Date::get_date_format();
    my $hoy=C4::Date::format_date_in_iso(ParseDate("today"), $dateformat);

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(
                            query => [ fecha_recordatorio => { lt => $hoy }, 
                                   estado => {ne => 'P'}, 
                                   id3 => {ne => undef}],
                            require_objects => ['nivel3','nivel2']
                                ); 
    return ($reservas_array_ref);

}




=item
reservasEnEspera
Funcion que trae las reservas en espera de un grupo
=cut
sub reservasEnEspera {
    my($id2)=@_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;

    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2 => { eq => $id2}));
    push(@filtros, ( id3 => undef ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros, sort_by => 'timestamp',
                                                                                  require_objects => ['nivel3','nivel2']);

  if (scalar(@$reservas_array_ref) == 0){
        return 0;
  }else{
    return(\@$reservas_array_ref);
  }
}


#VERIFICACIONES PREVIAS tanto para reservas desde el OPAC como para PRESTAMO de la INTRANET
sub _verificaciones {
    my($params)=@_;

    my $tipo= $params->{'tipo'}; #INTRA u OPAC
    my $id2= $params->{'id2'};
    my $id3= $params->{'id3'};
    my $barcode= $params->{'barcode'};
    my $nro_socio= $params->{'nro_socio'};
    my $loggedinuser= $params->{'loggedinuser'};
    my $tipo_prestamo= $params->{'tipo_prestamo'};
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}=$tipo;

    my $dateformat=C4::Date::get_date_format();
    my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

    if ($socio){
    
C4::AR::Debug::debug("tipo: $tipo\n");
C4::AR::Debug::debug("id2: $id2\n");
C4::AR::Debug::debug("id3: $id3\n");
C4::AR::Debug::debug("socio: $nro_socio\n");
C4::AR::Debug::debug("tipo_prestamo: $tipo_prestamo\n");
        
    #Se verifica que el usuario sea Regular
        if( !$socio->esRegular ){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U300', 'params' => []} ) ;
C4::AR::Debug::debug("Entro al if de regularidad\n");
        }
    }else{
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U321', 'params' => [$nro_socio]} ) ;
    }

#Se verifica que el usuario halla realizado el curso, segun preferencia del sistema.
    if( !($msg_object->{'error'}) && ($tipo eq "OPAC") && (C4::AR::Preferencias->getValorPreferencia("usercourse")) && 
        (!$socio->getCumple_requisito) ){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U304', 'params' => []} ) ;
C4::AR::Debug::debug("Entro al if de si cumple o no requisito\n");
    }

#Se verifica que el usuario no tenga el maximo de prestamos permitidos para el tipo de prestamo.
#SOLO PARA INTRA, ES UN PRESTAMO INMEDIATO.
    if( !($msg_object->{'error'}) && $tipo eq "INTRA" &&  C4::AR::Prestamos::_verificarMaxTipoPrestamo($nro_socio, $tipo_prestamo) ){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P101', 'params' => [$params->{'descripcionTipoPrestamo'}, $barcode]} ) ;
C4::AR::Debug::debug("Entro al if que verifica la cantidad de prestamos");
    }

#Se verifica si es un prestamo especial este dentro de los horarios que corresponde.
#SOLO PARA INTRA, ES UN PRESTAMO ESPECIAL.
    if(!$msg_object->{'error'} && $tipo eq "INTRA" && $tipo_prestamo eq 'ES' && _verificarHorario()){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P102', 'params' => []} ) ;
C4::AR::Debug::debug("Entro al if de prestamos especiales");
    }
#Se verfica si el usuario esta sancionado
    my ($sancionado,$fechaFin)= C4::AR::Sanciones::permisoParaPrestamo($nro_socio, $tipo_prestamo);
C4::AR::Debug::debug("sancionado: $sancionado ------ fechaFin: $fechaFin\n");
    if( !($msg_object->{'error'}) && ($sancionado||$fechaFin) ){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'S200', 'params' => [C4::Date::format_date($fechaFin,$dateformat)]} ) ;
C4::AR::Debug::debug("Entro al if de sanciones");
    }
#Se verifica que el usuario no intente reservar desde el OPAC un item para SALA
# FIXME que es esto??????????????????????????????????????????????????????????????????????????????????????????
#     if(!$msg_object->{'error'} && $tipo eq "OPAC" && getDisponibilidadGrupo($id2) eq 'SA'){
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'R007', 'params' => []} ) ;
# C4::AR::Debug::debug("Entro al if de prestamos de sala");
#     }

#Se verifica que el usuario no tenga dos reservas sobre el mismo grupo
    if( !($msg_object->{'error'}) && ($tipo eq "OPAC") && (&_verificarTipoReserva($nro_socio, $id2)) ){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'R002', 'params' => []} ) ;
C4::AR::Debug::debug("Entro al if de reservas iguales, sobre el mismo grupo y tipo de prestamo");
    }

#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema desde OPAC
    if( !($msg_object->{'error'}) && ($tipo eq "OPAC") && (C4::AR::Usuarios::llegoMaxReservas($nro_socio))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'R001', 'params' => [C4::AR::Preferencias->getValorPreferencia("maxreserves")]} ) ;
C4::AR::Debug::debug("Entro al if de maximo de reservas desde OPAC");
    }


#Se verifica que el usuario no tenga dos prestamos sobre el mismo grupo para el mismo tipo prestamo
    if( !($msg_object->{'error'}) && (&C4::AR::Prestamos::getCountPrestamosDeGrupoPorUsuario($nro_socio, $id2, $tipo_prestamo)) ){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=>  'P100', 'params' => []} ) ;
C4::AR::Debug::debug("Entro al if de prestamos iguales, sobre el mismo grupo y tipo de prestamo");
    }

C4::AR::Debug::debug("FIN ".$msg_object->{'error'}." !!!\n\n");
C4::AR::Debug::debug("FIN VERIFICACION !!!\n\n");

    return ($msg_object);
}

#funcion que realiza la transaccion de la RESERVA
sub t_reservarOPAC {
    
    my($params)=@_;
    my $reservaGrupo= 0;
    C4::AR::Debug::debug("Antes de verificar");
    my ($msg_object)= &_verificaciones($params);
    
    if(!$msg_object->{'error'}){
    #No hay error
        C4::AR::Debug::debug("No hay error");
        my ($paramsReserva);
        my  $reserva = C4::Modelo::CircReserva->new();
        my $db = $reserva->db;
           $db->{connect_options}->{AutoCommit} = 0;
           $db->begin_work;

        eval {
            ($paramsReserva)= $reserva->reservar($params);
            $db->commit;
            #Se setean los parametros para el mensaje de la reserva SIN ERRORES
            if($paramsReserva->{'estado'} eq 'E'){
            C4::AR::Debug::debug("SE RESERVO CON EXITO UN EJEMPLAR!!! codMsg: U302");
            #SE RESERVO CON EXITO UN EJEMPLAR
                $msg_object->{'error'}= 0;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U302', 'params' => [    $paramsReserva->{'desde'},
                                                    $paramsReserva->{'desdeh'},
                                                    $paramsReserva->{'hasta'},
                                                    $paramsReserva->{'hastah'}
                                ]} ) ;
            }else{
            #SE REALIZO UN RESERVA DE GRUPO
                C4::AR::Debug::debug("SE REALIZO UN RESERVA DE GRUPO codMsg: U303");
                my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});
                $msg_object->{'error'}= 0;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U303', 'params' => [$socio->persona->getEmail]} ) ;
            }   
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B400',"OPAC");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R009', 'params' => []} ) ;
        }
        $db->{connect_options}->{AutoCommit} = 1;
        
    }

    return ($msg_object);
}

=item
t_cancelar_reserva
Transaccion que cancela una reserva.
@params: $params-->Hash con los datos necesarios para poder cancelar la reserva.
=cut
sub t_cancelar_reserva{
    my ($params)=@_;
        
    my $tipo=$params->{'tipo'};
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}=$tipo;
    my $db = undef;
    my ($reserva) = getReserva($params->{'id_reserva'});
    if ($reserva){
        $db = $reserva->db;
        $db->{connect_options}->{AutoCommit} = 0;
            $db->begin_work;
    
        eval{
            C4::AR::Debug::debug("VAMOS A CANCELAR LA RESERVA");
            $reserva->cancelar_reserva($params);
            $db->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U308', 'params' => []} ) ;
            C4::AR::Debug::debug("LA RESERVA SE CANCELO CON EXITO");
        };
    }else{
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R010', 'params' => []} ) ;
    }

    if ($@){
        C4::AR::Debug::debug("ERROR");
        #Se loguea error de Base de Datos
        C4::AR::Mensajes::printErrorDB($@, 'B404',$tipo);
        eval {$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R010', 'params' => []} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}

# ## FIXME reservas por Nivel 1 ?????????????, SE ESTA USANDO ARREGLAR O PASAR
sub cantReservasPorNivel1{
#Devuelve la cantidad de reservas realizadas (SIN PRESTAR) sobre el nivel1
    my ($id1)=@_;
    
    my @filtros;
    
    push (@filtros, ('nivel2.id1' => {eq => $id1}));    
    my ($count) = C4::Modelo::CircReserva::Manager->get_circ_reserva_count(query => \@filtros, require_objects => ['nivel2']);
    return $count;
}


#===================================================================================================================================

=item sub reasignarNuevoEjemplarAReserva
    Esta funcion intenta reasignar un ejemplar disponible del mismo grupo a la reserva, ya que el ejemplar que tenia asignado
    no se encuentra mas disponible   

    @Parametros

        $params->{'id3'}:
        $params->{'id2'}:
        $params->{'db'}:
=cut
sub reasignarNuevoEjemplarAReserva{
    my ($db, $params, $msg_object) = @_;

    C4::AR::Debug::debug("reasignarNuevoEjemplarAReserva => id3: ".$params->{'id3'});
    #se verifca si el ejemplar que se esta modificado tiene o no un reserva asignada
    my ($reserva_asignada) = C4::AR::Reservas::getReservaDeId3($db, $params->{'id3'});

    if($reserva_asignada){
        C4::AR::Debug::debug("reasignarNuevoEjemplarAReserva => tiene reserva asignada ");
        #si TIENE RESERVA ASIGNADA hay q buscar un ejemplar disponible para asignarlo a la reserva
        my ($nuevoId3) = getEjemplarDeGrupoParaReserva($params->{'id2'});
    
        if($nuevoId3){
            C4::AR::Debug::debug("reasignarNuevoEjemplarAReserva => EXISTE ejemplar disponible");
            #EXISTE un ejemplar disponible
            $reserva_asignada->intercambiarId3 ($db, $nuevoId3, $msg_object);
        }else{
            C4::AR::Debug::debug("reasignarNuevoEjemplarAReserva => NO EXISTE");
            #si NO EXISTE un ejemplar disponible del grupo
            #a la reserva se la pasa a reserva en  espera (id3 = null) por DEFECTO, debido a q en la funcion manejoDeDisponibilidadDomiciliaria
            # se va a eliminar si es q no existe disponibilidad en la biblioteca.
            $reserva_asignada->pasar_a_espera();
        }
    }else{
        #no tiene reserva asiganada, NO SE HACE NADA
    }

    #verifico la disponibilidad del grupo
    manejoDeDisponibilidadDomiciliaria($db, $params);
}


=item sub manejoDeDisponibilidadDomiciliaria
    Esta funcion se encarga de "manejar" la disponibilidad para reservas domiciliarias

    @Parametros

        $params->{'id2'}: grupo con el que se esta trabajando
=cut
sub manejoDeDisponibilidadDomiciliaria{
    my ($db, $params) = @_;

    #verifico la disponibilidad del grupo
    my ($cant) = getDisponibilidadDeGrupoParaPrestamoDomiciliario($db, $params->{'id2'});
    if($cant == 0){
        C4::AR::Debug::debug("manejoDeDisponibilidadDomiciliaria => NO hay disponibilidad para el grupo id2: ".$params->{'id2'});
        #si no hay disponibilidad, (el grupo ahora NO TIENE mas ejemplares para prestamo), 
        #elimino TODAS las reservas en espera y la asignada del GRUPO, tambien elimino las sanciones y las reservas
        #retorna las reserva en espera (SI EXISTEN) del grupo
        my ($reservas_en_espera_array_ref) = getReservasEnEsperaById2($db, $params->{'id2'}); 

        if($reservas_en_espera_array_ref){
          foreach my $r (@$reservas_en_espera_array_ref) {
              C4::AR::Debug::debug("manejoDeDisponibilidadDomiciliaria => elimino la reserva con id_reserva: ".$r->getId_reserva);
          #elimino todas las sanciones y las reservas
              $r->borrar_sancion_de_reserva($params->{'db'});
              $r->delete();
          }
        }
    }
}

# sub conseguirEjemplarParaAsignarReserva{
# 
#     #buscar un ejemplar libre (del mismo grupo) para reserva 
#     my ($nuevoId3) = getEjemplarDeGrupoParaReserva($params->{'id2'});
# 
#     if($nuevoId3){
#         #EXISTE un ejemplar disponible
#         $reserva_asignada->intercambiarId3 ($nuevoId3, $msg_object, $params->{'db'});
#     }else{
#     #si no existe ejemplar  
#     #verificamos si hay disponibilidad en el grupo
#         #a la reserva se la pasa a reserva en  espera (id3 = null) por DEFECTO
#         #porque si no hay mas disponibilidad en el grupo, se van a eliminar todas las reservas y sanciones del grupo
#         $reserva->pasar_a_espera();
#         $params->{'id_reserva'} = $reserva_asignada->getId_reserva;
#         manejoDeDisponibilidadDomiciliaria($params);
#     }
# }

=item sub asignarEjemplarASiguienteReservaEnEspera

    Esta funcion asgina el ejemplar a una reserva (SI EXISTE) que se encontraba en la cola de espera para un grupo determinado

    @Parametros:
        $params->{'id2'}: 
        $params->{'id3'}:
        $params->{'loggedinuser'}: el usuario logueado
=cut
sub asignarEjemplarASiguienteReservaEnEspera{
    my ($params) = @_;

    my ($reservaGrupo) = getReservaEnEsperaById2($params->{'id2'}); #retorna la primer reserva en espera (SI EXISTE) del grupo

    if($reservaGrupo){
        #Si hay al menos un ejemplar esperando se reasigna
        $reservaGrupo->setId3($params->{'id3'});
        $reservaGrupo->setId_ui($params->{'id_ui'});
        $reservaGrupo->actualizarDatosReservaEnEspera($params->{'loggedinuser'});
    }
}

=item sub getDisponibilidadDeGrupoParaPrestamoDomiciliario
    Indica si tiene o no (el grupo) disponibilidad para prestamo DOMICILIARIO
=cut
sub getDisponibilidadDeGrupoParaPrestamoDomiciliario{
    my ($db, $id2) = @_;

    my @filtros;
    push(@filtros, ( id2                => { eq => $id2 }) );
    push(@filtros, ( id_disponibilidad  => { eq => 1 }) );    # Es Prestamo Domiciliario
    push(@filtros, ( id_estado          => { eq => 0 }) );    # Esta Disponible

    my $cant = C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count( db => $db, query => \@filtros);

    if($cant > 0){
        return $cant;
    }else{
        return 0;
    }
}

=item sub getDisponibilidadDeGrupoParaPrestamoSala
    Indica si tiene o no (el grupo) disponibilidad para prestamo PARA SALA
=cut
sub getDisponibilidadDeGrupoParaPrestamoSala{
    my ($id2) = @_;

    my @filtros;
    push(@filtros, ( id2 => { eq => $id2}) );
    push(@filtros, ( id_disponibilidad => { eq => 2}) );    # Es Prestamo PARA SALA
    push(@filtros, ( id_estado => { eq => 0}) );            # Esta Disponible

    my $cant = C4::Modelo::CatNivel3::Manager->get_cat_nivel3_count( query => \@filtros);

    if($cant > 0){
        return $cant;
    }else{
        return 0;
    }
}


=item sub getEjemplarDeGrupoParaReserva
    Busca los ejemplares del grupo disponibles para reserva.
=cut
# TODO no se como hacer el NOT IN con Rose::DB
sub getEjemplaresDeGrupoParaReserva{
    my ($id2) = @_;
    my $dbh = C4::Context->dbh;

    #n3.id_disponibilidad   = 1   DISPONIBILIDAD => PRESTAMO
    #n3.id_estado           = 1   ESTADO => DISPONIBLE

    #esta consulta devuelve todos los ejemplares del grupo q no estan la tabla reservas
    my $query= "    SELECT id3 
                    FROM cat_nivel3 n3 WHERE n3.id2 = ? AND n3.id_disponibilidad = 1 AND n3.id_estado = 0 
                    AND n3.id3 NOT IN ( SELECT cr.id3 
                                        FROM circ_reserva cr 
                                        WHERE cr.id2 = ? AND cr.id3 IS NOT NULL)";

    #el 2do SELECT devuelve todas las reservas asigandas del grupo

    my $sth=$dbh->prepare($query);
    $sth->execute($id2, $id2);
    
    my @array_id3;

    while (my $data = $sth->fetchrow_hashref){
        push (@array_id3, $data->{'id3'});
    }

    return @array_id3;

}


=item sub getEjemplarDeGrupoParaReserva
    Devuelve el primer el ejemplar (si existe) del grupo disponible para reserva.
    Si no hay ejemplar retorna 0
=cut
sub getEjemplarDeGrupoParaReserva {
    my ($id2) = @_;
    my (@ejemplares_array_ref) = getEjemplaresDeGrupoParaReserva($id2);

    if(scalar(@ejemplares_array_ref) > 0){
        return @ejemplares_array_ref->[0];
    }else{
        return 0;
    }
}

=item sub getReservaDeId3
    Devuelve la reserva del item

    @Parametros
    $id3 = id3 del ejemplar del cual se intenta recuperar la reserva
=cut
sub getReservaDeId3{
    my ($db, $id3) = @_;

    use C4::Modelo::CircReserva;
    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id3        => { eq => $id3}));
    push(@filtros, ( estado     => { ne => 'P'} ));

    my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( db => $db, query => \@filtros, require_objects => ['nivel3','nivel2']); 

    if(scalar(@$reservas_array_ref) > 0){
        return ($reservas_array_ref->[0]);
    }else{
        #el ejemplar NO TIENE reserva
        return 0;
    }
}


=item sub getReservaEnEspera
Funcion que trae los datos de la primer reserva de la cola que estaba esperando que se desocupe un ejemplar del grupo de esta misma reserva.
=cut
sub getReservaEnEsperaById2{
    my ($db, $id2) = @_;

    my $reservas_array_ref = getReservasEnEsperaById2($db, $id2);

    if(scalar(@$reservas_array_ref) > 0){
        return ($reservas_array_ref->[0]);
    }else{
        #NO hay reservas en espera para este grupo
        return 0;
    }
}


=item sub getReservasEnEsperaById2
Funcion que trae las reservas en espera sobre un grupo.
=cut
sub getReservasEnEsperaById2{
    my ($db, $id2) = @_;

    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id2 => { eq => $id2 }));
    push(@filtros, ( id3 => undef ));

    my $reservas_array_ref = C4::Modelo::CircReserva::Manager->get_circ_reserva(    db      => $db,
                                                                                    query   => \@filtros,
                                                                                    sort_by => 'timestamp',
                                                                ); 

    if(scalar(@$reservas_array_ref) > 0){
        return ($reservas_array_ref);
    }else{
        #NO hay reservas en espera para este grupo
        return 0;
    }
}

=item sub getReservaById
    Esta funcion recupera la reserva segun id_reserva pasado por parametros
    retorna la reserva o 0 si no existe
=cut
sub getReservaById{
    my ($id_reserva) = @_;

    use C4::Modelo::CircReserva::Manager;
    my @filtros;
    push(@filtros, ( id_reserva => { eq => $id_reserva }));

    my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva(    
                                                                                    query   => \@filtros,
                                                                ); 

    if(scalar(@$reservas_array_ref) > 0){
        return ($reservas_array_ref->[0]);
    }else{
        #NO EXISTE la reserva con id_reserva pasado por parametro
        return 0;
    }
}

1;
