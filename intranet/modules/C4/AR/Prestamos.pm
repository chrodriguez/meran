package C4::AR::Prestamos;

#Este modulo provee funcionalidades para el prestamo de documentos
#
#Copyright (C) 2003-2008  Linti, Facultad de Informatica, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
require Exporter;
use DBI;
use C4::Date;
use C4::AR::Reservas;
use C4::Modelo::CircPrestamo;
use C4::Modelo::CircPrestamo::Manager;

use C4::Circulation::Circ2;
use C4::AR::Sanciones;
use Date::Manip;
use Time::HiRes qw(gettimeofday);
use Thread;
use Mail::Sendmail;
use C4::Auth;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 3;

@ISA = qw(Exporter);

@EXPORT = qw(

	&t_devolver
	&t_renovar
	&t_realizarPrestamo
    	&_verificarMaxTipoPrestamo
	&chequeoDeFechas
	&prestamosHabilitadosPorTipo	
	&getTipoPrestamo
	&getPrestamoDeId3
	&getPrestamosDeSocio
	&getTipoPrestamo
    	&obtenerPrestamosDeSocio
	&cantidadDePrestamosPorUsuario
	&crearTicket
    
    &t_eliminarTipoPrestamo
    &t_agregarTipoPrestamo
    &t_modificarTipoPrestamo
    &cantidadDeUsoTipoPrestamo
);

sub chequeoDeFechas(){
	my ($cantDiasRenovacion,$fechaRenovacion,$intervalo_vale_renovacion)=@_;
	# La $fechaRenovacion es la ultima fecha de renovacion o la fecha del prestamo si nunca se renovo
	my $plazo_actual=$cantDiasRenovacion;# Cuantos dias m�s se puede renovar el prestamo
	my $vencimiento=proximoHabil($plazo_actual,0,$fechaRenovacion);
	my $err= "Error con la fecha";
	my $dateformat = C4::Date::get_date_format();
	my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err),$dateformat);#se saco el 2 para que ande bien.
	my $desde=C4::Date::format_date_in_iso(DateCalc($vencimiento,"- ".$intervalo_vale_renovacion." days",\$err,2),$dateformat);#SE AGREGO EL 2 PARA QUE SALTEE LOS SABADOS Y DOMINGOS. 01/10/2007
	my $flag = Date_Cmp($desde,$hoy);
	#comparo la fecha de hoy con el inicio del plazo de renovacion	
	if (!($flag gt 0)){ 
		#quiere decir que la fecha de hoy es mayor o igual al inicio del plazo de renovacion
		#ahora tengo que ver que la fecha de hoy sea anterior al vencimiento
		my $flag2=Date_Cmp($vencimiento,$hoy);
		if (!($flag2 lt 0)){
			#la fecha esta ok
			return 1;
			
		}

	}
	return 0;
}

=item
prestamosHabilitadosPorTipo
Esta funcion devuelve los tipos de prestamos permitidos para un usuario, en un arreglo de hash.
=cut
sub prestamosHabilitadosPorTipo {
 	my ($id_disponibilidad, $nro_socio)=@_;

	#Se buscan todas las sanciones de un usuario
	my $sanciones= C4::AR::Sanciones::tieneSanciones($nro_socio);

	#Trae todos los tipos de prestamos que estan habilitados
	my $tipos_habilitados_array_ref = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo(   
																		query => [ 
																				id_disponibilidad => { eq => $id_disponibilidad },
																				habilitado    => { eq => 1}
																			], 
										);



	my @tipos;
	foreach my $tipo_prestamo (@$tipos_habilitados_array_ref){
		my $estaSancionado= 0;
		

        if($sanciones){
        #tiene sanciones
		    foreach my $sancion (@$sanciones){
			    if($sancion->getTipo_sancion){#Si no es una sancion por una reserva
			    #tipos de prestamo que afecta
			    my @tipos_prestamo_sancion=$sancion->ref_tipo_sancion->ref_tipo_prestamo_sancion;
				    foreach my $tipo_prestamo_sancion (@tipos_prestamo_sancion){
					    if ($tipo_prestamo_sancion->getId_tipo_prestamo eq $tipo_prestamo->getId_tipo_prestamo){
						    $estaSancionado= 1;
					    }
				    }
			    }
			    else{#Si es una sancion por reserva???
			    }
		    }# END foreach my $sancion (@$sanciones)
        }

		if(!$estaSancionado){
			#solo se agrega si no esta sancionado para ese tipo de prestamo
			my $tipo;
			$tipo->{'value'}=$tipo_prestamo->getId_tipo_prestamo;
			$tipo->{'label'}=$tipo_prestamo->getDescripcion;
			push(@tipos,$tipo)
		}
	}

	return(\@tipos);
}

#
# NUEVAS FUNCIONES
#




sub _verificarMaxTipoPrestamo{
	my ($nro_socio,$tipo_prestamo)=@_;

	my $error=0;

	#Obtengo la cant maxima de prestamos de ese tipo que se puede tener
	my $tipo=C4::AR::Prestamos::getTipoPrestamo($tipo_prestamo);
	my $prestamos_maximos= $tipo->getPrestamos;
	#

	#Obtengo la cant total de prestamos actuales de ese tipo que tiene el usuario
	my @filtros;
    push(@filtros, ( fecha_devolucion => { eq => undef } ));
	push(@filtros, ( nro_socio => { eq => $nro_socio}) );
	push(@filtros, ( tipo_prestamo => { eq => $tipo_prestamo}) );
	my $cantidad_prestamos= C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count( query => \@filtros);
	#
	
	if ($cantidad_prestamos >= $prestamos_maximos) {$error=1}

	return $error;
}

sub getCountPrestamosDeGrupoPorUsuario {
#devuelve la cantidad de prestamos de grupo del usuario
	my ($nro_socio, $id2, $tipo_prestamo)=@_;

    	use C4::Modelo::CircPrestamo;
    	use C4::Modelo::CircPrestamo::Manager;

    	my @filtros;
    	push(@filtros, ( id2 	=> { eq => $id2 } ));
    	push(@filtros, ( nro_socio => { eq => $nro_socio } ));
		push(@filtros, ( tipo_prestamo => { eq => $tipo_prestamo } ));
		push(@filtros, ( fecha_devolucion => { eq => undef } ));

    	my $prestamos_grupo_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
																						query => \@filtros,
																						with_objects => [ 'nivel3' ]
															);

    	return ($prestamos_grupo_count);
}


=item
Esta funcion devuelve la cantidad de prestamos por grupo
=cut
sub getCountPrestamosDelRegistro{
	my ($id1)= @_;

	use C4::Modelo::CircPrestamo;
	use C4::Modelo::CircPrestamo::Manager;

	my @filtros;
	push(@filtros, ( id1 	=> { eq => $id1 } ));
	push(@filtros, ( fecha_devolucion => { eq => undef } ));

	my $prestamos_grupo_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
																				query => \@filtros,
																				with_objects => [ 'nivel3' ]
															);

	return ($prestamos_grupo_count);
}

=item
getPrestamoDeId3
Esta funcion retorna el prestamo a partir de un id3
=cut
sub getPrestamoDeId3 {
    my ($id3)=@_;

        use C4::Modelo::CircPrestamo;
        use C4::Modelo::CircPrestamo::Manager;

        my @filtros;
        push(@filtros, ( fecha_devolucion => { eq => undef } ));
        push(@filtros, ( id3 => { eq => $id3 } ));

        my $prestamos__array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(query => \@filtros);


        return ($prestamos__array_ref->[0] || 0);
}

=item
getPrestamosDeSocio
Esta funcion retorna los prestamos actuales de un socio
=cut
sub getPrestamosDeSocio {
	my ($nro_socio,$db)=@_;

    	use C4::Modelo::CircPrestamo;
    	use C4::Modelo::CircPrestamo::Manager;

    	my @filtros;
    	push(@filtros, ( fecha_devolucion => { eq => undef } ));
    	push(@filtros, ( nro_socio => { eq => $nro_socio } ));
        
        my $prestamos__array_ref;
        if($db){ #Si viene $db es porque forma parte de una transaccion
    	    $prestamos__array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(db => $db,query => \@filtros);
        }else{
            $prestamos__array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(query => \@filtros);
        }

    	return ($prestamos__array_ref);
}

sub getTipoPrestamo {
#retorna los datos del tipo de prestamo
use C4::Modelo::CircRefTipoPrestamo;
   my ($tipo_prestamo)=@_;
   my  $circ_ref_tipo_prestamo = C4::Modelo::CircRefTipoPrestamo->new( id_tipo_prestamo => $tipo_prestamo );
   $circ_ref_tipo_prestamo->load();
   return($circ_ref_tipo_prestamo);
}

sub getTiposDePrestamos {
#retorna los datos de TODOS los tipos de prestamos
use C4::Modelo::CircRefTipoPrestamo::Manager;
   my @filtros;
   my  $circ_ref_tipo_prestamo = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo( query => \@filtros);
   return($circ_ref_tipo_prestamo);
}

sub prestarYGenerarTicket{
	my ($params)=@_;

# FIXME falta verificar

	my ($nivel3aPrestar)= C4::AR::Nivel3::getNivel3FromBarcode($params->{'barcode'});
C4::AR::Debug::debug("barcode a prestar: ".$params->{'barcode'});

	my @infoTickets;
	my @infoMessages;
	my $id3= $nivel3aPrestar->getId3;
	my $nivel3aPrestar= C4::AR::Nivel3::getNivel3FromId3($id3);
	$params->{'id1'}= $nivel3aPrestar->nivel2->nivel1->getId1;
	$params->{'id2'}= $nivel3aPrestar->nivel2->getId2;
	C4::AR::Debug::debug("id1: ".$nivel3aPrestar->nivel1->getId1);
	C4::AR::Debug::debug("id2: ".$nivel3aPrestar->nivel2->getId2);
	C4::AR::Debug::debug("id3: ".$id3);
	$params->{'id3'}= $id3;
	$params->{'id_ui'}=C4::AR::Preferencias->getValorPreferencia('defaultUI');
	$params->{'id_ui_prestamo'}=C4::AR::Preferencias->getValorPreferencia('defaultUI');
	$params->{'tipo'}="INTRA";

	my ($msg_object)= &C4::AR::Prestamos::t_realizarPrestamo($params);
	my $ticketObj=0;

	if(!$msg_object->{'error'}){
	#Se crean los ticket para imprimir.
		C4::AR::Debug::debug("SE PRESTO SIN ERROR --> SE CREA EL TICKET");
		$ticketObj=C4::AR::Prestamos::crearTicket($id3,$params->{'nro_socio'},$params->{'loggedinuser'});
	}

 	push (@infoMessages, $msg_object);

	my %infoOperacion = (
				ticket  => $ticketObj,
	);
	
	push (@infoTickets, \%infoOperacion);

	my %infoOperaciones;
	$infoOperaciones{'tickets'}= \@infoTickets;
	$infoOperaciones{'messages'}= \@infoMessages;


	return (\%infoOperaciones);
}

#funcion que realiza la transaccion del Prestamo
sub t_realizarPrestamo{
	my ($params)=@_;
		C4::AR::Debug::debug("Antes de verificar");	
	my ($msg_object)= C4::AR::Reservas::_verificaciones($params);
	if(!$msg_object->{'error'}){
		C4::AR::Debug::debug("No hay error en las verificaciones");
		my  $prestamo = C4::Modelo::CircPrestamo->new();
        my $db = $prestamo->db;
		   $db->{connect_options}->{AutoCommit} = 0;
           $db->begin_work;
		eval{
			$prestamo->prestar($params,$msg_object);
			$db->commit;
		};
		if ($@){
			C4::AR::Debug::debug("ERROR");
			#Se loguea error de Base de Datos
			C4::AR::Mensajes::printErrorDB($@, 'B401',"INTRA");
			$db->rollback;
			#Se setea error para el usuario
			$msg_object->{'error'}= 1;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P106', 'params' => []} ) ;
		}
		$db->{connect_options}->{AutoCommit} = 1;
	}

	return ($msg_object);
}

sub obtenerPrestamosDeSocio {
    
    use C4::Modelo::CircPrestamo;
    use C4::Modelo::CircPrestamo::Manager;

    my ($nro_socio)=@_;

    my $prestamos_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo( 
							query => [ fecha_devolucion  => { eq => undef }, nro_socio  => { eq => $nro_socio }]
     							); 
    return ($prestamos_array_ref);
}

=item
Esta funcion retorna si el ejemplar segun el id3 pasado por parametro esta prestado o no
=cut
sub estaPrestado {
    
    use C4::Modelo::CircPrestamo;
    use C4::Modelo::CircPrestamo::Manager;

    my ($id3)=@_;

    my $nivel3_array_ref= C4::Modelo::CircPrestamo::Manager->get_circ_prestamo( 
																query => [ fecha_devolucion  => { eq => undef }, 
																			id3  => { eq => $id3 }
																]
     							); 

    return (scalar(@$nivel3_array_ref) > 0);
}


=item
cantidadDePrestamosPorUsuario
Devuelve la cantidad de prestamos que tiene el usuario que se pasa por parametro y la cantidad de vencidos.
=cut
sub cantidadDePrestamosPorUsuario {
	my ($nro_socio)=@_;

	my $prestamos= obtenerPrestamosDeSocio($nro_socio);

  	my $prestados=0;
  	my $vencidos=0;
	foreach my $prestamo (@$prestamos){
		$prestados++;
		if($prestamo->estaVencido){$vencidos++;}
	}
	
	return($vencidos,$prestados);
}

=item
Transaccion que maneja los erroes de base de datos y llama a la funcion devolver
=cut
sub t_devolver {
    my($params)=@_;

 	my $msg_object= C4::AR::Mensajes::create();

    my $array_id_prestamos= $params->{'datosArray'};
    my $loop=scalar(@$array_id_prestamos);
    my $id_prestamo;
	my $prestamo = C4::Modelo::CircPrestamo->new();
	my $db = $prestamo->db;
	$db->{connect_options}->{AutoCommit} = 0;
	$db->begin_work;

    for(my $i=0;$i<$loop;$i++){
		$id_prestamo= $array_id_prestamos->[$i];
		$params->{'id_prestamo'}= $id_prestamo;
		C4::AR::Debug::debug("PRESTAMOS => t_devolver => id_prestamo: ".$id_prestamo);
		
		my $prestamo = C4::Modelo::CircPrestamo->new(id_prestamo => $id_prestamo, db => $db);
		$prestamo->load();
		$params->{'id3'}= $prestamo->getId3;
		$params->{'barcode'}= $prestamo->nivel3->getBarcode;

		#se realizan las verificaciones necesarias para el prestamo que se intenta devolver
		verificarCirculacionRapida($params, $msg_object);

		if(!$msg_object->{'error'}){

			eval {
				$prestamo->devolver($params);
				$db->commit;
				# Si la devolucion se pudo realizar
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P109', 'params' => [$params->{'barcode'}]} ) ;
			};
			if ($@){
				#Se loguea error de Base de Datos
				&C4::AR::Mensajes::printErrorDB($@, 'B406',"INTRA");
				$db->rollback;
				#Se setea error para el usuario
				$msg_object->{'error'}= 1;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P110', 'params' => [$params->{'barcode'}]} ) ;
			}
		}# END if(!$msg_object->{'error'})

	}# END for(my $i=0;$i<$loop;$i++)

    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}

sub t_renovar {
  my ($params)=@_;

  my $ticketObj;
  my @infoTickets;
  my @infoMessages;
  my $print_renew= C4::AR::Preferencias->getValorPreferencia("print_renew");
  my $array_id_prestamos= $params->{'datosArray'};

  my $prestamoTEMP = C4::Modelo::CircPrestamo->new();
  my $db = $prestamoTEMP->db;
     $db->{connect_options}->{AutoCommit} = 0;
     $db->begin_work;

    foreach my $data (@$array_id_prestamos){
		my ($msg_object)= C4::AR::Mensajes::create();
   		$msg_object->{'error'}= 0;
		C4::AR::Debug::debug("T_Renovar ".$data->{'barcode'});
        my $prestamo = C4::Modelo::CircPrestamo->new(id_prestamo => $data->{'id_prestamo'}, db => $db);
		$prestamo->load();
		$prestamo->_verificarParaRenovar($msg_object);

        if(!$msg_object->{'error'}){
                eval{
                    $prestamo->renovar($params->{'nro_socio'});
                    $db->commit;
				# Si la renovacion se pudo realizar
				
					if($print_renew && (!$msg_object->{'error'})){ 	
						#IF PARA LA CONDICION SI SE QUIERE O NO IMPRIMIR EL TICKET
        				$ticketObj=C4::AR::Prestamos::crearTicket($prestamo->getId3,$prestamo->getNro_socio,$params->{'nro_socio'});
						 #se genera info para enviar al cliente  
        				my %infoOperacion = (ticket  => $ticketObj,);
        				push (@infoTickets, \%infoOperacion);
      				}

		    		$msg_object->{'error'}= 0;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P111', 'params' => [$data->{'barcode'}]} ) ;
					
					push (@infoMessages, $msg_object);
                };
                if ($@){
		   		#Se loguea error de Base de Datos
		   			&C4::AR::Mensajes::printErrorDB($@, 'B405',"INTRA");
		   			$db->rollback;
		   		#Se setea error para el usuario
                   	$msg_object->{'error'}= 1;
                   	C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P112', 'params' => [$data->{'barcode'}]} ) ;
                }
        }else{
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P112', 'params' => [$data->{'barcode'}]} ) ;
        }
  }
  $db->{connect_options}->{AutoCommit} = 1;

	my %infoOperaciones;
	$infoOperaciones{'tickets'}= \@infoTickets;
	$infoOperaciones{'messages'}= \@infoMessages;

	return (\%infoOperaciones);
}

sub getPrestamoPorBarcode {

	my ($barcode)=@_;
    
    use C4::Modelo::CircPrestamo;
    use C4::Modelo::CircPrestamo::Manager;

	my @filtros;
 	push(@filtros, ( barcode => { eq => $barcode } ));
	push(@filtros, ( fecha_devolucion => { eq => undef } ) );

    my $prestamo_array_ref= C4::Modelo::CircPrestamo::Manager->get_circ_prestamo( 
																query => \@filtros,
																require_objects => [ 'nivel3' ] #INNER JOIN
     							); 

	if(scalar(@$prestamo_array_ref) > 0){
		return $prestamo_array_ref->[0]->getId_prestamo;
	}else {	
    	return 0;
	}
}


=item
Esta funcion verifica que el id_prestamo que se pasa por parametro exista y que ademas sea un prestamo, o sea q no se haya devuelto aún
=cut
sub esUnPrestamo {

	my ($id_prestamo)=@_;
    
    use C4::Modelo::CircPrestamo;
    use C4::Modelo::CircPrestamo::Manager;

	my @filtros;
 	push(@filtros, ( id_prestamo => { eq => $id_prestamo } ));
	push(@filtros, ( fecha_devolucion => { eq => undef } ) );

    my $prestamo_array_ref= C4::Modelo::CircPrestamo::Manager->get_circ_prestamo( 
																query => \@filtros,
# 																require_objects => [ 'nivel3' ] #INNER JOIN
     							); 

	if(scalar(@$prestamo_array_ref) > 0){
# 		return $prestamo_array_ref->[0]->getId_prestamo;
		return 1;
	}else {	
    	return 0;
	}
}

sub getSocioFromID_Prestamo {
	my ($prestamo)=@_;
    
    use C4::Modelo::CircPrestamo;
    use C4::Modelo::CircPrestamo::Manager;

	my @filtros;
 	push(@filtros, ( id_prestamo => { eq => $prestamo } ));
	push(@filtros, ( fecha_devolucion => { eq => undef } ) );

    my $prestamo_array_ref= C4::Modelo::CircPrestamo::Manager->get_circ_prestamo( 
																query => \@filtros,
																require_objects => [ 'socio' ] #INNER JOIN
     							); 

	if(scalar(@$prestamo_array_ref) > 0){
		return $prestamo_array_ref->[0]->socio;
	}else {	
    	return 0;
	}
}

sub verificarCirculacionRapida {
	my ($params, $msg_object)=@_;


# FIXME ahora no se mandan los barcodes, se mandan los id_prestamo, faltaria verificar esto!!!!!!!!!!
# verificar q el id_prestmo exista y que no se haya devuelto

=item
	if( !($msg_object->{'error'}) &&  $params->{'operacion'} eq 'devolver'){
	#se verifica si la operacion es una devolucion, que EXISTA el BARCODE
		$params->{'id_prestamo'}= getPrestamoPorBarcode($params->{'barcode'});
		if($params->{'id_prestamo'} == 0){
		#no existe el barcode
			$msg_object->{'error'}= 1;
			C4::AR::Debug::debug("verificarCirculacionRapida => no existe el barcode");
        	C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P115', 'params' => [$params->{'barcode'}]} ) ;
		}
	}
=cut
	if( !($msg_object->{'error'}) && $params->{'operacion'} ne 'devolver' && !esUnPrestamo($params->{'id_prestamo'})){
	#si la operacion es una devolucion, se verifica que exista el id_prestamo y que ademas ya no se haya devuelto
		$msg_object->{'error'}= 1;
		C4::AR::Debug::debug("verificarCirculacionRapida => no existe el prestamo o ya se devolvió anteriormente");
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P117', 'params' => []} ) ;
	}
	
	if( !($msg_object->{'error'}) && $params->{'operacion'} ne 'devolver' && !C4::AR::Usuarios::existeSocio($params->{'nro_socio'})){
	#se verifica si la operacion es un prestamo, que EXISTA el USUARIO
	#si es una devolucion  no importa el usuario ya que lo tengo en el prestamo
		$msg_object->{'error'}= 1;
		C4::AR::Debug::debug("verificarCirculacionRapida => no existe el usuario");
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P116', 'params' => []} ) ;
	}

}


sub crearTicket {
    my ($id3,$nro_socio,$loggedinuser)=@_;

    my %ticket;

    $ticket{'socio'}=$nro_socio;
    $ticket{'responsable'}=$loggedinuser;
    $ticket{'id3'}=$id3;

    return(\%ticket);
}

=item
Esta funcion obtiene el socio del ejemplar prestado
=cut
# FIXME ver si la condicion de filtro es valida (id3, nro_socio, fecha_prestamo)
sub getSocioFromPrestamo {
	my ($id3)= @_;

	my @filtros;
 	push(@filtros, ( id3 => { eq => $id3 } ));
	push(@filtros, ( fecha_devolucion => { eq => undef } ) );

	my $prestamos_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
																					query => \@filtros,
																					require_objects => ['socio']
																				);

	if(scalar(@$prestamos_array_ref) > 0){
		return ($prestamos_array_ref->[0]->socio);
	}else{
		return 0;
	}
}

=item
Esta funcion obtiene el prestamo del ejemplar prestado
=cut
sub getPrestamoActivo {
    my ($id3)= @_;

    my @filtros;
    push(@filtros, ( id3 => { eq => $id3 } ));
    push(@filtros, ( fecha_devolucion => { eq => undef } ) );

    my $prestamos_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
                                                                                    query => \@filtros,
                                                                                );

    if(scalar(@$prestamos_array_ref) > 0){
        return ($prestamos_array_ref->[0]);
    }else{
        return 0;
    }
}

# FIXME esta en ROSE, pero tarda, asi que si no hay algo milagroso que acelere esto, volarlo sin culpa
# sub getHistorialPrestamos {
#     my ($nro_socio,$ini,$cantR,$orden)=@_;
# 
#     use C4::Modelo::CircPrestamo;
#     use C4::Modelo::CircPrestamo::Manager;
# 
#     my @filtros;
#     push(@filtros, ( nro_socio => { eq => $nro_socio } ));
# 
#     if($orden eq 'autor'){
#         $orden= 'cat_autor.apellido';
#     }elsif($orden eq 'titulo'){
#         $orden= 'cat_nivel1.titulo';
#     }elsif($orden eq 'barcode'){
#         $orden= 'cat_nivel3.barcode';
#     }elsif($orden eq 'fecha_devolucion'){
#         $orden= 'circ_prestamo.fecha_devolucion';
#     }else{$orden= 'cat_nivel1.titulo';} #ordena por titulo por defecto
# 
#     my $prestamos_count_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count( query => \@filtros );
# 
#     my $prestamos_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
#                                                                                     query => \@filtros,
#                                                                                     limit   => $cantR,
#                                                                                     offset  => $ini,
#                                                                                     sort_by => ( $orden ),
#                                                                 require_objects => [    'nivel3', 'nivel3.nivel1', 
#                                                                                         'nivel3.nivel2.nivel1.cat_autor','nivel3.nivel2' ]
#                                                                 );
# 
#     return ($prestamos_count_array_ref, $prestamos_array_ref);
# }

# sub getHistorialPrestamosParaTemplate {
# 
#     my ($nro_socio,$ini,$cantR,$orden)=@_;
# 
#     my ($cant,$presmamos_array_ref) = getHistorialPrestamos($nro_socio,$ini,$cantR,$orden);
# 
#     my @loop_reading;
# 
# # FIXME tarda mucho!!!!
#     foreach my $prestamo (@$presmamos_array_ref){
#         my %line;
#         $line{'titulo'}=$prestamo->nivel3->nivel2->nivel1->getTitulo;
#     #   $line{unititle}=C4::AR::Nivel1::getUnititle($issues->[$i]->{'id1'});;
#         $line{'autor'}=$prestamo->nivel3->nivel2->nivel1->cat_autor->getApellido.", ".$prestamo->nivel3->nivel2->nivel1->cat_autor->getNombre;
#         $line{'idautor'}=$prestamo->nivel3->nivel2->nivel1->cat_autor->getId;
#         $line{'id1'}=$prestamo->nivel3->getId1;
#         $line{'id2'}=$prestamo->nivel3->getId2;
#         $line{'id3'}=$prestamo->nivel3->getId3;
#         $line{'signatura_topografica'}=$prestamo->nivel3->getSignatura_topografica;
#         $line{'barcode'}=$prestamo->nivel3->getBarcode;
#         $line{'date_due'}=$prestamo->getFecha_prestamo_formateada;
#         $line{'date_fin'} = $prestamo->getFecha_vencimiento_formateada; 
#         $line{'estaVencido'}= $prestamo->estaVencido;
#         $line{'date_renew'}=$prestamo->getFecha_devolucion_formateada;
#         if ($prestamo->getRenovaciones > 0){
#             $line{'date_renew'}=$prestamo->getFecha_ultima_renovacion_formateada;
#         }
#         $line{'returndate'}=$prestamo->getFecha_devolucion_formateada;
#         $line{'edicion'}= $prestamo->nivel3->nivel2->getEdicion;
#         $line{'volume'}= $prestamo->nivel3->nivel2->getVolumenDesc;
#     #   $line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
#           $line{'grupos'}= C4::AR::Busquedas::obtenerGrupos($prestamo->nivel3->getId1,'','intra');
#     
#         push(@loop_reading,\%line);
#     }
# 
#     return ($cant,$presmamos_array_ref,\@loop_reading);
# 
# }


sub getHistorialPrestamos {
    my ($nro_socio,$ini,$cantR,$orden)=@_;

    my @filtros;
    push(@filtros, ( nro_socio => { eq => $nro_socio } ));

    if($orden eq 'autor'){
        $orden= 'cat_autor.apellido';
    }elsif($orden eq 'titulo'){
        $orden= 'cat_nivel1.titulo';
    }elsif($orden eq 'barcode'){
        $orden= 'cat_nivel3.barcode';
    }elsif($orden eq 'fecha_devolucion'){
        $orden= 'circ_prestamo.fecha_devolucion';
    }else{$orden= 'cat_nivel1.titulo';} #ordena por titulo por defecto

    my $select = "SELECT *\n";

    my $from = "FROM circ_prestamo CP INNER JOIN cat_nivel3 CN3 ON CP.id3 = CN3.id3\n
                                 INNER JOIN cat_nivel1 CN1 ON CN3.id1 = CN1.id1\n
                                 INNER JOIN cat_autor CA ON CN1.autor = CA.id\n" ;

    my $where = "WHERE (CP.nro_socio = ? )\n";
    my $limit = "LIMIT ".$ini.", ".$cantR."\n";
    my $query = $select.$from.$where.$limit;
C4::AR::Debug::debug("SQL HISTORIAL: ".$query);
 
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($nro_socio);
    my @prestamos_array;
    while(my $data=$sth->fetchrow_hashref){
        push(@prestamos_array,$data);
    }

    my $query_count = "SELECT COUNT(*) AS cantidad\n".$from.$where;
    $sth = $dbh->prepare($query_count);
    $sth->execute($nro_socio);
    my $cantidad= $sth->fetchrow_hashref;
    #CONTANDO EL TOTAL

    
    
    return ($cantidad->{'cantidad'}, \@prestamos_array);
}


sub getHistorialPrestamosParaTemplate {

    my ($nro_socio,$ini,$cantR,$orden)=@_;

    my ($cant,$presmamos_array_ref) = getHistorialPrestamos($nro_socio,$ini,$cantR,$orden);

    my @loop_reading;
    my $dateformat = C4::Date::get_date_format();

# FIXME tarda mucho!!!!
    foreach my $prestamo (@$presmamos_array_ref){
        my %line;
        $line{'titulo'}=$prestamo->{'titulo'};
    #   $line{unititle}=C4::AR::Nivel1::getUnititle($issues->[$i]->{'id1'});;
        $line{'autor'}=$prestamo->{'apellido'}.", ".$prestamo->{'nombre'};
        $line{'idAutor'}=$prestamo->{'autor'};
        $line{'id1'}=$prestamo->{'id1'};
        $line{'id2'}=$prestamo->{'id2'};
        $line{'id3'}=$prestamo->{'id3'};
        $line{'signatura_topografica'}=$prestamo->{'signatura_topografica'};
        $line{'barcode'}=$prestamo->{'barcode'};
        $line{'date_due'}=C4::Date::format_date($prestamo->{'fecha_prestamo'},$dateformat);
        $line{'date_fin'} = C4::Date::format_date($prestamo->{'fecha_devolucion'},$dateformat);
#         $line{'estaVencido'}= $prestamo->estaVencido;
#         $line{'date_renew'}=$prestamo->{'fecha_ultima_renovacion'};
        if ($prestamo->{'renovaciones'} > 0){
            $line{'date_renew'}=C4::Date::format_date($prestamo->{'fecha_ultima_renovacion'},$dateformat);
        }
#         $line{'returndate'}=$prestamo->getFecha_devolucion_formateada;
#         $line{'edicion'}= $prestamo->nivel3->nivel2->getEdicion;
#         $line{'volume'}= $prestamo->nivel3->nivel2->getVolumenDesc;
    #   $line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
#           $line{'grupos'}= C4::AR::Busquedas::obtenerGrupos($prestamo->nivel3->getId1,'','intra');

        push(@loop_reading,\%line);
    }

    return ($cant,$presmamos_array_ref,\@loop_reading);
}


sub t_agregarTipoPrestamo {
    my ($params)=@_;

    my $msg_object = C4::AR::Mensajes::create();
    my $tipo_prestamo = C4::Modelo::CircRefTipoPrestamo->new();
    my $db = $tipo_prestamo->db;

C4::AR::Debug::debug("AGREGAR TIPO DE PRESTAMO ".$params->{'id_tipo_prestamo'});

    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval {
        $tipo_prestamo->modificar($params);
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP011', 'params' => []} ) ;
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'SP009','INTRA');
        eval{$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP009', 'params' => []} ) ;
    }

    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}

sub t_modificarTipoPrestamo {
    my ($params)=@_;

    my $msg_object = C4::AR::Mensajes::create();
C4::AR::Debug::debug("MODIFICAR TIPO DE PRESTAMO ".$params->{'id_tipo_prestamo'});

    my $tipo_prestamo=C4::AR::Prestamos::getTipoPrestamo($params->{'id_tipo_prestamo'});
    my $db = $tipo_prestamo->db;  

    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval {
        $tipo_prestamo->modificar($params);
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP010', 'params' => []} ) ;
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'SP008','INTRA');
        eval{$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP008', 'params' => []} ) ;
    }

    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}

sub t_eliminarTipoPrestamo {
    my ($id_tipo_prestamo)=@_;

    my $msg_object = C4::AR::Mensajes::create();
    my $cantidad_prestamos=C4::AR::Prestamos::cantidadDeUsoTipoPrestamo($id_tipo_prestamo);
    if($cantidad_prestamos == 0) {

    C4::AR::Debug::debug("ELIMINAR TIPO DE PRESTAMO ".$id_tipo_prestamo);
    my $tipo_prestamo=C4::AR::Prestamos::getTipoPrestamo($id_tipo_prestamo);
    my $db = $tipo_prestamo->db;  

    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval {
        $tipo_prestamo->delete();
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP006', 'params' => []} ) ;
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'SP007','INTRA');
        eval{$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP007', 'params' => []} ) ;
    }

    $db->{connect_options}->{AutoCommit} = 1;
    }
    else{
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP012', 'params' => [$cantidad_prestamos]} ) ;
    }
    return ($msg_object);
}



sub cantidadDeUsoTipoPrestamo {
    my ($id_tipo_prestamo)=@_;
    my @filtros;
    push(@filtros, (tipo_prestamo => { eq => $id_tipo_prestamo}));
    my $cantidad_prestamos= C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count( query => \@filtros);
    return $cantidad_prestamos;
    }
1;