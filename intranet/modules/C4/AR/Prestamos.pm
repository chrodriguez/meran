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
	&verificarParaRenovar
	&prestamosHabilitadosPorTipo	
	&getTipoPrestamo
	&getPrestamoDeId3
	&getPrestamosDeSocio
	&getTipoPrestamo
    &obtenerPrestamosDeSocio
	&cantidadDePrestamosPorUsuario
	&crearTicket

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
Se verifica que se cumplan las condiciones para poder renovar
DEPRECATED?????????????????????????????????????????????????????????????????????????
=cut
# sub verificarParaRenovar{
# 	my ($params)=@_;
# 
# 	my $msg_object= C4::AR::Mensajes::create();
# 
# 	my ($borrower, $flags) = C4::Circulation::Circ2::getpatroninformation($params->{'nro_socio'},"");
# 	$params->{'usercourse'}= $borrower->{'usercourse'};
# 
# 	#Se verifica que el usuario haya realizado el curso, simpre y cuando esta preferencia este seteada
# 	if( !($msg_object->{'error'}) && $params->{'tipo'} eq "OPAC" && (C4::AR::Preferencias->getValorPreferencia("usercourse") 
# 		&& ($params->{'usercourse'} == "NULL" ) ) ){
# 		$msg_object->{'error'}= 1;
# 		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P114', 'params' => []} ) ;
# 	}
# 
# 	return ($msg_object);
# }


=item
prestamosHabilitadosPorTipo
Esta funcion devuelve los tipos de prestamos permitidos para un usuario, en un arreglo de hash.
=cut
sub prestamosHabilitadosPorTipo {
 	my ($id_disponibilidad, $nro_socio)=@_;

	#Se buscan todas las sanciones de un usuario
	my $sanciones=C4::AR::Sanciones::tieneSanciones($nro_socio);

	#Trae todos los tipos de prestamos que estan habilitados
	my $tipos_habilitados_array_ref = C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo(   
																		query => [ 
																				id_disponibilidad => { eq => $id_disponibilidad },
																				habilitado    => { eq => 1}
																			], 
										);

	my @tipos;
	foreach my $tipo_prestamo (@$tipos_habilitados_array_ref){
		my $estaSancionado=0;
		
		foreach my $sancion (@$sanciones){
			if($sancion->getTipo_sancion){#Si no es una sancion por una reserva
			#tipos de prestamo que afecta
			my @tipos_prestamo_sancion=$sancion->ref_tipo_sancion->ref_tipo_prestamo_sancion;
				foreach my $tipo_prestamo_sancion (@tipos_prestamo_sancion){
					if ($tipo_prestamo_sancion->getId_tipo_prestamo eq $tipo_prestamo->getId_tipo_prestamo){
						$estaSancionado=1;
					}
				}
			}
			else{#Si es una sancion por reserva???
			}
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

=item
Esta funcion devuelve la informacion del tipo de prestamo, segun el issuecode
=cut
sub getTipoPrestamo {
    
    use C4::Modelo::CircRefTipoPrestamo;
    use C4::Modelo::CircRefTipoPrestamo::Manager;

    my ($tipo_prestamo) = @_;

    my  $tipo = C4::Modelo::CircRefTipoPrestamo->new(id_tipo_prestamo => $tipo_prestamo);
        $tipo->load();

    return ($tipo);
}

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
   my ($tipo_prestamo)=@_;
   my  $circ_ref_tipo_prestamo = C4::Modelo::CircRefTipoPrestamo->new( id_tipo_prestamo => $tipo_prestamo );
   $circ_ref_tipo_prestamo->load();
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
	$params->{'id_ui'}=C4::AR::Preferencias->getValorPreferencia('defaultbranch');
	$params->{'id_ui_prestamo'}=C4::AR::Preferencias->getValorPreferencia('defaultbranch');
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


	my $array_ids3= $params->{'datosArray'};
    my $loop=scalar(@$array_ids3);
#     my $accion= $params->{'accion'};
    my $id3;
    my $barcode;
    my $id_prestamo;
    my $ticketObj;
    my @infoTickets;
    my @infoMessages;
    my %params;
    my %messageObj;
    my $Message_arrayref;
	my $msg_object;
    my $print_renew= C4::AR::Preferencias->getValorPreferencia("print_renew");
	my $prestamo = C4::Modelo::CircPrestamo->new();
	my $db = $prestamo->db;
	$db->{connect_options}->{AutoCommit} = 0;
	$db->begin_work;

    C4::AR::Debug::debug("LOOP --> $loop");
    for(my $i=0;$i<$loop;$i++){
		$id3= $array_ids3->[$i]->{'id3'};
		$barcode= $array_ids3->[$i]->{'barcode'};
		$id_prestamo= $array_ids3->[$i]->{'id_prestamo'};
		$params{'barcode'}= $barcode;
		$params{'id_prestamo'}= $id_prestamo;
		
		my $prestamo = C4::Modelo::CircPrestamo->new(id_prestamo => $id_prestamo, db => $db);
		$prestamo->load();
		$params->{'id3'}= $prestamo->getId3;

		verificarCirculacionRapida($params, $msg_object);

		if(!$msg_object->{'error'}){

			eval {
				$prestamo->devolver($params);
				$db->commit;
				# Si la devolucion se pudo realizar
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P109', 'params' => [$prestamo->nivel3->getBarcode]} ) ;
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

	}

    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}

sub t_renovar {
  my ($params)=@_;
#   my $id3= $params->{'id3'};
#   my $tipo= $params->{'tipo'};
  my ($msg_object)= C4::AR::Mensajes::create();
  my $prestamoTEMP = C4::Modelo::CircPrestamo->new();
  my $db = $prestamoTEMP->db;
      $db->{connect_options}->{AutoCommit} = 0;
      $db->begin_work;
  foreach my $data ($params->{'datosArray'}) {
        my $prestamo = C4::Modelo::CircPrestamo->new(id_prestamo => $data->{'id_prestamo'}, db => $db);
        my $renovacion= $prestamo->sePuedeRenovar;
        if( ($renovacion) && (!$msg_object->{'error'}) ){
                eval{
                    $prestamo->renovar;
                    $db->commit;
                };
                if ($@){
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P112', 'params' => []} ) ;
                }
                $msg_object->{'error'}= 0;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P111', 'params' => [$params->{'barcode'}]} ) ;
        }else{
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P112', 'params' => []} ) ;
        }
  }
  $db->{connect_options}->{AutoCommit} = 1;
  return ($msg_object);
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


sub verificarCirculacionRapida {
	my ($params, $msg_object)=@_;

# # 	my $msg_object= C4::AR::Mensajes::create();

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
	
	if( !($msg_object->{'error'}) && $params->{'operacion'} ne 'devolver' && !C4::AR::Usuarios::existeSocio($params->{'nro_socio'})){
	#se verifica si la operacion es un prestamo, que EXISTA el USUARIO
	#si es una devolucion  no importa el usuario ya que lo tengo en el prestamo
		$msg_object->{'error'}= 1;
		C4::AR::Debug::debug("verificarCirculacionRapida => no existe el usuario");
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P116', 'params' => []} ) ;
	}

# 	return ($msg_object);
}

sub t_devolverPorBarcode {
	my ($params)=@_;

	my $msg_object= C4::AR::Mensajes::create();
	verificarCirculacionRapida($params, $msg_object);

	if(!$msg_object->{'error'}){
		$params->{'id_prestamo'}= getPrestamoPorBarcode($params->{'barcode'});
		#se hace la devolucion del prestamo pasado por parametro
		($msg_object) = C4::AR::Prestamos::t_devolver($params);	
	}

	return ($msg_object);
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

sub getHistorialPrestamos {
	my ($nro_socio,$ini,$cantR,$orden)=@_;

	use C4::Modelo::CircPrestamo;
	use C4::Modelo::CircPrestamo::Manager;

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
        
    my $prestamos_count_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count( query => \@filtros );

	my $prestamos_array_ref = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo(
																					query => \@filtros,
																					limit   => $cantR,
                                                                            		offset  => $ini,
 																					sort_by => ( $orden ),
																require_objects => [ 	'nivel3', 'nivel3.nivel1', 
																						'nivel3.nivel2.nivel1.cat_autor','nivel3.nivel2' ]
																		);

    return ($prestamos_count_array_ref, $prestamos_array_ref);
}



sub getHistorialPrestamosParaTemplate {

    my ($nro_socio,$ini,$cantR,$orden)=@_;

    my ($cant,$presmamos_array_ref) = getHistorialPrestamos($nro_socio,$ini,$cantR,$orden);
    
    my @loop_reading;
# FIXME tarda mucho!!!!
        my $count= 0;

    foreach my $prestamo (@$presmamos_array_ref){
        $count++; C4::AR::Debug::debug("COUNT HIST. PRESTAMOS: ".$count);
        my %line;
        $line{'titulo'}=$prestamo->nivel3->nivel2->nivel1->getTitulo;
    #   $line{unititle}=C4::AR::Nivel1::getUnititle($issues->[$i]->{'id1'});;
        $line{'autor'}=$prestamo->nivel3->nivel2->nivel1->cat_autor->getApellido.", ".$prestamo->nivel3->nivel2->nivel1->cat_autor->getNombre;
        $line{'idautor'}=$prestamo->nivel3->nivel2->nivel1->cat_autor->getId;
        $line{'id1'}=$prestamo->nivel3->getId1;
        $line{'id2'}=$prestamo->nivel3->getId2;
        $line{'id3'}=$prestamo->nivel3->getId3;
        $line{'signatura_topografica'}=$prestamo->nivel3->getSignatura_topografica;
        $line{'barcode'}=$prestamo->nivel3->getBarcode;
        $line{'date_due'}=$prestamo->getFecha_prestamo_formateada;
        $line{'date_fin'} = $prestamo->getFecha_vencimiento_formateada; 
        $line{'estaVencido'}= $prestamo->estaVencido;
        $line{'date_renew'}=$prestamo->getFecha_devolucion_formateada;
        if ($prestamo->getRenovaciones > 0){
            $line{'date_renew'}=$prestamo->getFecha_ultima_renovacion_formateada;
        }
        $line{'returndate'}=$prestamo->getFecha_devolucion_formateada;
        $line{'edicion'}= $prestamo->nivel3->nivel2->getEdicion;
        $line{'volume'}= $prestamo->nivel3->nivel2->getVolumenDesc;
    #   $line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
       	$line{'grupos'}= C4::AR::Busquedas::obtenerGrupos($prestamo->nivel3->getId1,'','intra');
    
        push(@loop_reading,\%line);
    }

    return ($cant,$presmamos_array_ref,\@loop_reading);

}
=item
t_renovar
Transaccion que renueva un prestamo.
@params: $params-->Hash con los datos necesarios para poder renovar un prestamo.
=cut
sub t_renovar{
    my ($params)=@_;
    my $dbh = C4::Context->dbh;
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    my $tipo=$params->{'tipo'};
    my $msg_object;
    eval{
        ($msg_object)= renovar($params);
        $dbh->commit;
    };
    if ($@){
        #Se loguea error de Base de Datos
        C4::AR::Mensajes::printErrorDB($@, 'B405',$tipo);
        eval {$dbh->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P113', 'params' => []} ) ;
    }
    $dbh->{AutoCommit} = 1;

    return ($msg_object);
}


##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############
##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############
##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############
##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############
##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############
##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############
##########DEPRECATED######################DEPRECATED######################DEPRECATED######################DEPRECATED############

=item  DEPRECATED paso a CircPrestamo
la funcion devolver recibe una hash y actualiza la tabla de prestamos,la tabla de reservas y de historicissues. Realiza las comprobaciones para saber si hay reservas esperando en ese momento para ese item, si las hay entonces realiza las actualizaciones y envia un mail a el borrower correspondiente.
=cut 

# sub devolver {
#   my ($params)=@_;
#   my $id3= $params->{'id3'};
#   my $tipo= $params->{'tipo'};
#   my $loggedinuser= $params->{'loggedinuser'};
#   my $nro_socio= $params->{'nro_socio'};
# #     my $codMsg;
# #     my $error;
# #     my $paraMens;
#   my $msg_object= C4::AR::Mensajes::create();
#   #se setea el barcode para informar al usuario en la devolucion
# #     $paraMens->[0]= $params->{'barcode'};
# 
#   my $prestamo= getDatosPrestamo($id3);
#   my $fechaVencimiento= vencimiento($id3); # tiene que estar aca porque despues ya se marco como devuelto
#   actualizarPrestamo($id3,$nro_socio);
# 
#   my $notforloan=C4::AR::Reservas::getDisponibilidad($id3);
#   
#   my $reserva=C4::AR::Reservas::getReservaDeId3($id3);
#   if($reserva->getId3){
#   #Si la reserva que voy a borrar existia realmente sino hubo un error
#       if($notforloan eq 'Domiciliario'){#si no es para sala
#           my $reservaGrupo=C4::AR::Reservas::getDatosReservaEnEspera($reserva->getId2);
#           if($reservaGrupo){
#               $reservaGrupo->{'id3'}=$id3;
#               $reservaGrupo->{'branchcode'}=$prestamo->{'branchcode'};
#               $reservaGrupo->{'loggedinuser'}=$loggedinuser;
#               C4::AR::Reservas::actualizarDatosReservaEnEspera($reservaGrupo);
#           }
#       }
#       #Haya o no uno esperando elimino el que existia porque la reserva se esta cancelando
#       C4::AR::Reservas::borrarReserva($reserva->getId_reserva);
# 
# #**********************************Se registra el movimiento en historicCirculation***************************
#       my $dataItems= C4::AR::Nivel3::getDataNivel3($id3);
#       my $id1= $dataItems->{'id1'};
# #         my $end_date= "null";
#       my $end_date= undef;
# 
#       C4::Circulation::Circ2::insertHistoricCirculation('return',$nro_socio,$loggedinuser,$id1,$reserva->getId2,$id3,$reserva->getId_ui,$prestamo->{'tipo_prestamo'},$end_date);
# 
# #*******************************Fin***Se registra el movimiento en historicCirculation*************************
# 
# ### Se sanciona al usuario si es necesario, solo si se devolvio el item correctamente
#       my $hasdebts=0;
#       my $sanction=0;
#       my $fechaFinSancion;
# 
# # Hay que ver si devolvio el biblio a termino para, en caso contrario, aplicarle una sancion  
#       my $tipo_prestamo=getTipoPrestamo($prestamo->{'tipo_prestamo'});
#       my $daysissue=$tipo_prestamo->getDias_prestamo;
#       my $dateformat = C4::Date::get_date_format();
#       my $fechaHoy = C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
#       my $categorycode=C4::AR::Usuarios::obtenerCategoriaBorrower($nro_socio);
#                 my $sanctionDays= SanctionDays($fechaHoy, $fechaVencimiento, $categorycode, $prestamo->{'tipo_prestamo'});
# 
#       if ($sanctionDays gt 0) {
# # Se calcula el tipo de sancion que le corresponde segun la categoria del prestamo devuelto tardiamente y la categoria de usuario que tenga
#           my $sanctiontypecode = getSanctionTypeCode($prestamo->{'tipo_prestamo'}, $categorycode);
#           if (tieneLibroVencido($nro_socio)) {
# # El borrower tiene libros vencidos en su poder (es moroso)
#               $hasdebts = 1;
#               insertPendingSanction($sanctiontypecode, undef, $nro_socio, $sanctionDays);
#           }
#           else{
#               my $err;
# # Se calcula la fecha de fin de la sancion en funcion de la fecha actual (hoy + cantidad de dias de sancion)
#               $fechaFinSancion= C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ ".$sanctionDays." days",\$err),$dateformat);
#               insertSanction($sanctiontypecode, undef, $nro_socio, $fechaHoy, $fechaFinSancion, $sanctionDays);
#               $sanction = 1;
# #**********************************Se registra el movimiento en historicSanction***************************
#               my $responsable= $loggedinuser;
#               logSanction('Insert',$nro_socio,$responsable,$fechaFinSancion,$sanctiontypecode);
# #**********************************Fin registra el movimiento en historicSanction***************************
# 
# #Se borran las reservas del usuario sancionado
#               C4::AR::Reservas::cancelar_reservas($loggedinuser,$nro_socio);
#           }
#       }
# ### Final del tema sanciones
#       # Si la devolucion se pudo realizar
# #         $error= 0;
# #         $codMsg= 'P109';
#       $msg_object->{'error'}= 0;
#       C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P109', 'params' => [$params->{'barcode'}]} ) ;
#   }
#   else {
#       # Si la devolucion dio error
# #         $error= 1;
# #         $codMsg= 'P110';
#       $msg_object->{'error'}= 1;
#       C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'P110', 'params' => [$params->{'barcode'}]} ) ;
#   }
# 
# #     return ($error,$codMsg, $paraMens);
#   return ($msg_object);
# }

# sub getDatosPrestamo{
#   my ($id3)=@_;
# 
#   my $dbh=C4::Context->dbh;
#   my $sth=$dbh->prepare("SELECT * FROM  circ_prestamo WHERE id3=? AND fecha_devolucion IS NULL");
#   $sth->execute($id3);
#   return ($sth->fetchrow_hashref);
# }
# 
# sub actualizarPrestamo{
#   my ($id3,$borrowernumber)=@_;
# 
#   my $dbh=C4::Context->dbh;
#   my $sth=$dbh->prepare(" UPDATE  circ_prestamo SET fecha_devolucion=NOW() 
#               WHERE id3=? AND nro_socio=? AND fecha_devolucion IS NULL");
#   $sth->execute($id3,$borrowernumber);
# }


=item
fechaDeVencimiento recibe dos parametro, un id3 y la fecha de prestamo lo que hace es devolver la fecha en que vence o vencio ese prestamo
=cut

# sub fechaDeVencimiento {
#   my ($id3,$date_due)=@_;
# 
#   my $dbh = C4::Context->dbh;
#   my $sth=$dbh->prepare("SELECT * FROM  circ_prestamo WHERE id3 = ? AND fecha_prestamo = ? ");
#   $sth->execute($id3,$date_due);
#   my $data= $sth->fetchrow_hashref;
#   if ($data){
#       my $issuetype=IssueType($data->{'issuecode'}); 
#       my $plazo_actual;
#   
#       if ($data->{'renewals'} > 0){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
#           $plazo_actual=$issuetype->{'renewdays'};
#           return (proximoHabil($plazo_actual,0,$data->{'lastreneweddate'}));
#       } 
#       else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
#           $plazo_actual=$issuetype->{'daysissues'};
#           return (proximoHabil($plazo_actual,0,$data->{'date_due'}));
#       }
# 
#   }
# }


# =item
# sepuederenovar recibe dos parametros un id3 y un borrowernumber, lo que hace es si el usario no tiene problemas de multas/sanciones, las fechas del prestamo estan en orden y no hay ninguna reserva pendiente se devuelve true, sino false
# =cut
# sub sepuederenovar{
# my ($borrowernumber,$id3)=@_;
# my $dbh = C4::Context->dbh;
# 
# my $sth=$dbh->prepare(" SELECT * FROM circ_reserva INNER JOIN  circ_prestamo ON  circ_prestamo.id3=circ_reserva.id3 
#           AND circ_reserva.nro_socio= circ_prestamo.nro_socio  WHERE circ_reserva.id3=? 
#           AND circ_reserva.nro_socio=? AND circ_reserva.estado='P' AND fecha_devolucion IS NULL");
# 
# $sth->execute($id3,$borrowernumber);
# 
# if (my $data= $sth->fetchrow_hashref){
# 
#   my $issuetype=IssueType($data->{'issuecode'});
#   
#   if ($issuetype->{'renew'} eq 0){ #Si es 0 NO SE RENUEVA NUNCA
#       return 0;
#   }
# 
#   if (!&hayReservasEsperando($data->{'id2'})){
#       #quiere decir que no hay reservas esperando por lo que podemos seguir
#       
#       if (!C4::AR::Usuarios::estaSancionado($borrowernumber, $data->{'issuecode'})){
#           #El usuario no tiene sanciones, puede seguir.
#           
#           #veo si el nro de renovaciones realizadas es mayor al nro maximo de renovaciones posibles permitidas
# 
#           my $intervalo_vale_renovacion=$issuetype->{'dayscanrenew'}; #Numero de dias en el que se puede hacer la renovacion antes del vencimiento.
#           my $plazo_actual;
# 
#           if ($data->{'renewals'}){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
#               my $maximo_de_renovaciones=$issuetype->{'renew'};
#               if ($data->{'renewals'} < $maximo_de_renovaciones) {#quiere decir que no se supero el maximo de renovaciones
#                   if(chequeoDeFechas($issuetype->{'renewdays'},$data->{'lastreneweddate'},$intervalo_vale_renovacion)){
#                       return 1;
#                   }
#                   else{ 
#                       return 0;
#                   }
#               }
#               else{ #se supero la cantidad maxima de renovaciones
#                   return 0;
#               }   
#           } 
#           else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
#               if(chequeoDeFechas($issuetype->{'daysissues'},$data->{'date_due'},$intervalo_vale_renovacion)){
#                   return 2;
#               }
#               else{
#                   return 0;
#               }
#           }
#       }
#   }
# }#if ($data-)
# return 0;
# }

# sub hayReservasEsperando(){
#   my ($id2)=@_;
# 
#   my $dbh = C4::Context->dbh;
#   my $sth1=$dbh->prepare("SELECT * FROM circ_reserva WHERE id2=? AND id3 IS NULL ORDER BY timestamp LIMIT 1;");
#   $sth1->execute($id2);
#   my $data1= $sth1->fetchrow_hashref;
#   if ($data1){
# # esto quiere decir que hay reservas esperando entonces se devuelve un false indicando que no se puede hacer la renovacion del prestamo
#       return 1;
#   }
#   else{
#       return 0;
#   }
# }


# =item DEPRECATED se paso a CircPrestamo
# vencimiento recibe un parametro, un prestamo  lo que hace es devolver la fecha en que vence el prestamo
# =cut
# sub vencimiento {
#   my ($prestamo)=@_;
#       use C4::Modelo::CircPrestamo;
#       my $plazo_actual;
#       if ($prestamo->getRenovaciones > 0){#quiere decir que ya fue renovado entonces tengo que calcular sobre los dias de un prestamo renovado para saber si estoy en fecha
#           $plazo_actual=$prestamo->tipo->getDias_renovacion;
#           return (proximoHabil($plazo_actual,0,$prestamo->getFecha_ultima_renovacion));
#       } 
#       else{#es la primer renovacion por lo tanto tengo que ver sobre los dias de un prestamo normal para saber si estoy en fecha de renovacion
#        $plazo_actual=$prestamo->tipo->getDias_prestamo;
#        return (proximoHabil($plazo_actual,0,$prestamo->getFecha_prestamo));
#       }
# }


=item
IssuesTypeEnabled DEPRECATED
Esta funcion devuelve los tipos de prestamos permitidos para un usuario, en un arreglo de hash.
=cut
# sub IssuesTypeEnabled {
#   my ($notforloan, $borrowernumber)=@_;
#   my $dbh = C4::Context->dbh;
#       my $sth;
# #Trae todos los tipos de prestamos que estan habilitados
#       my $query= " SELECT * FROM circ_ref_tipo_prestamo WHERE habilitado = 1 ";
#   $query .= " AND id_tipo_prestamo NOT IN (SELECT circ_ref_tipo_prestamo.id_tipo_prestamo FROM circ_sancion 
#   INNER JOIN circ_tipo_sancion ON circ_sancion.sanctiontypecode = circ_tipo_sancion.sanctiontypecode 
#   INNER JOIN circ_tipo_prestamo_sancion ON circ_tipo_sancion.sanctiontypecode = circ_tipo_prestamo_sancion.sanctiontypecode 
#   INNER JOIN circ_ref_tipo_prestamo ON circ_tipo_prestamo_sancion.issuecode = circ_ref_tipo_prestamo.id_tipo_prestamo 
#   WHERE nro_socio = ? AND (now() between startdate AND enddate)) ";
# 
#       if ($notforloan ne undef){
#       $query.=" AND notforloan = ? ORDER BY description";
#           $sth = $dbh->prepare($query);
#           $sth->execute($borrowernumber, $notforloan);
#       } 
#   else{
#           $query.=" ORDER BY description";
#           $sth = $dbh->prepare($query);
#           $sth->execute($borrowernumber);
#       }
# 
#       my %issueslabels;
#   my @issuesvalues;
#   my @issuesType;
#   my $i=0;
#       while (my $res = $sth->fetchrow_hashref) {
#       $issuesType[$i]->{'value'}=$res->{'id_tipo_prestamo'};
#       $issuesType[$i]->{'label'}=$res->{'descripcion'};
#       $i++;
#       
#   }
#       $sth->finish;
#   return(\@issuesType);
# }


=item
DatosPrestamos
Esta funcion retorna los datos de los prestamos de un usuario
=cut
# sub DatosPrestamos {
#   my ($borrowernumber)=@_;
#   my $dbh = C4::Context->dbh;
#   my $dateformat = C4::Date::get_date_format();
#   my $sth=$dbh->prepare("SELECT * FROM  circ_prestamo WHERE fecha_devolucion IS NULL AND nro_socio = ?");
#   $sth->execute($borrowernumber);
#   my $hoy=C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
#   my @result;
#   while (my $ref= $sth->fetchrow_hashref) {
#       my $fechaDeVencimiento= C4::AR::Prestamos::vencimiento($ref->{'id3'});
#       $ref->{'overdue'}= (Date::Manip::Date_Cmp($fechaDeVencimiento,$hoy)<0);
#       push @result, $ref;
#   }
#   $sth->finish;
#       return(scalar(@result), \@result);
# }

=item
DatosPrestamosPorTipo
Esta funcion retorna los datos de los prestamos de un usuario por tipo de prestamo
=cut
# sub DatosPrestamosPorTipo {
#   my ($borrowernumber,$issuetype_hashref)=@_;
# 
#   my $dbh = C4::Context->dbh;
#   my $dateformat = C4::Date::get_date_format();
#   my $query=" SELECT * FROM  circ_prestamo WHERE fecha_devolucion IS NULL AND nro_socio = ? AND tipo_prestamo=? ";
#   my $sth=$dbh->prepare($query);
#   $sth->execute($borrowernumber,$issuetype_hashref->{'id_tipo_prestamo'});
#   my $hoy=C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
#   my @result;
# 
#   while (my $ref= $sth->fetchrow_hashref) {
#       my $fechaDeVencimiento= C4::AR::Prestamos::vencimiento($ref->{'id3'});
#       $ref->{'overdue'}= (Date::Manip::Date_Cmp($fechaDeVencimiento,$hoy)<0);
#       push @result, $ref;
#   }
#   $sth->finish;
# 
#   return(scalar(@result), \@result);
# }

=item
Esta funcion devuelve la informacion del prestamo junto con el borrower
=cut
# sub getDatosPrestamoDeId3{
#   my ($id3)=@_;
# 
#   my $dbh = C4::Context->dbh;
#   my $query= "    SELECT * 
#           FROM  circ_prestamo iss INNER JOIN usr_socio bor ON (iss.nro_socio=bor.nro_socio)
#               INNER JOIN circ_ref_tipo_prestamo ist ON (iss.tipo_prestamo=ist.id_tipo_prestamo) 
#           WHERE id3=? AND fecha_devolucion IS  NULL ";
# 
#   my $sth=$dbh->prepare($query);
#       $sth->execute($id3);
#   
#       return $sth->fetchrow_hashref;
# }

# sub PrestamosMaximos {
#   #Esta funcion retorna los prestamos que esten en el maximo
#   my ($borrowernumber)=@_;
#   my $dbh = C4::Context->dbh;
#   
#   my $sth=$dbh->prepare("SELECT * FROM circ_ref_tipo_prestamo;");
#   $sth->execute();
#   my @result;
#   my $cant=0; 
#   my @result; 
# 
#   while (my $iss= $sth->fetchrow_hashref) {
#       my $issuetype=$iss->{'id_tipo_prestamo'};
#       my $sth1=$dbh->prepare("    SELECT count(*) AS prestamos 
#                       FROM  circ_prestamo 
#                       WHERE fecha_devolucion IS NULL AND nro_socio = ? AND tipo_prestamo=?");
#       $sth1->execute($borrowernumber,$issuetype);
#       
#       my $tot=$sth1->fetchrow;
#       if ($iss->{'maxissues'} eq $tot) {
#           $result[$cant]= $iss;
#           $cant++;
#       };
#       $sth1->finish;
#   }
#   $sth->finish;
#   
#   return($cant, @result);
# }

# =item
# mail de recordatorio envia los mails a los due�os de los items que vencen el proximo dia habil
# =cut
# 
# sub Enviar_Recordatorio{
#   my ($id3,$bor,$vencimiento)=@_;
# 
#   if ((C4::AR::Preferencias->getValorPreferencia("EnabledMailSystem"))&&(C4::AR::Preferencias->getValorPreferencia("reminderMail"))){
# 
#       my $dbh = C4::Context->dbh;
#       my $borrower= C4::AR::Usuarios::getBorrower($bor);
#       my $sth=$dbh->prepare("SELECT titulo, n1.id1 AS rid1, n2.id2 AS rid2, autor, circ_reserva.id3 AS rid3
#                   FROM circ_reserva
#                   INNER JOIN cat_nivel2 n2 ON n2.id2 = circ_reserva.id2
#                   INNER JOIN cat_nivel1 n1 ON n2.id1 = n1.id1
#                   WHERE  circ_reserva.nro_socio =? AND circ_reserva.id3= ?");
#       $sth->execute($bor,$id3);
#       my $res= $sth->fetchrow_hashref;    
# 
#       my $mailFrom=C4::AR::Preferencias->getValorPreferencia("mailFrom");
#       my $mailSubject =C4::AR::Preferencias->getValorPreferencia("reminderSubject");
#       my $mailMessage =C4::AR::Preferencias->getValorPreferencia("reminderMessage");
#       my $branchname= C4::AR::Busquedas::getBranch($borrower->{'branchcode'})->{'branchname'};
# 
#   $res->{'autor'}=(C4::AR::Busquedas::getautor($res->{'autor'}))->{'completo'};
#   my $edicion=C4::AR::Nivel2::getEdicion($res->{'rid2'});
#   $mailFrom =~ s/BRANCH/$branchname/;
#   $mailSubject =~ s/BRANCH/$branchname/;
#   $mailMessage =~ s/BRANCH/$branchname/;
#   $mailMessage =~ s/FIRSTNAME/$borrower->{'firstname'}/;
#   $mailMessage =~ s/SURNAME/$borrower->{'surname'}/;
#   my $unititle=C4::AR::Nivel1::getUnititle($res->{'id1'});
#   $mailMessage =~ s/UNITITLE/$unititle/;
#   $mailMessage =~ s/TITLE/$res->{'titulo'}/;
#   $mailMessage =~ s/AUTHOR/$res->{'autor'}/;
#   $mailMessage =~ s/EDICION/$edicion/;
#   $mailMessage =~ s/VENCIMIENTO/$vencimiento/;
# 
#   my %mail = ( To => $borrower->{'emailaddress'},
#                      From => $mailFrom,
#                      Subject => $mailSubject,
#                      Message => $mailMessage);
#   my $resultado='ok';
#   if ($borrower->{'emailaddress'} && $mailFrom ){
#       sendmail(%mail) or die $resultado='error';
#   }else {
#       $resultado='';
#   }
# 
# #**********************************Se registra el movimiento en historicCirculation***************************
#   my $dataItems= C4::AR::Nivel3::getDataNivel3($id3);
#   my $id1= $dataItems->{'id1'};
#   my $id2= $dataItems->{'id2'};
#   my $branchcode= $dataItems->{'homebranch'};
#   my $borrowernumber= $bor;
#   my $loggedinuser= $bor;
#   my $issuecode= '-';
# #     my $end_date= "null";
#   my $end_date= undef;
#       
#   C4::Circulation::Circ2::insertHistoricCirculation('reminder',$borrowernumber,$loggedinuser,$id1,$id2,$id3,$branchcode,$issuecode,$end_date);
# #*******************************Fin***Se registra el movimiento en historicCirculation**********************
# 
#   }#end if (C4::Context->preference("EnabledMailSystem"))
# }
# 


# sub enviar_recordatorios_prestamos {
#   my $dbh = C4::Context->dbh;
#   my $dateformat = C4::Date::get_date_format();
#   my $sth=$dbh->prepare("SELECT * FROM  circ_prestamo iss LEFT JOIN circ_ref_tipo_prestamo isst ON iss.tipo_prestamo=isst.id_tipo_prestamo 
#                  WHERE iss.fecha_devolucion IS NULL AND isst.id_disponibilidad = 0");
#   $sth->execute();
# 
#   while(my $data= $sth->fetchrow_hashref) {
#       my $fechaDeVencimiento=vencimiento ($data->{'id3'});
#       my $proximohabil=proximoHabil(1,0);
#       if (Date::Manip::Date_Cmp($fechaDeVencimiento,$proximohabil) == 0) {
#           Enviar_Recordatorio($data->{'id3'},$data->{'nro_socio'},&C4::Date::format_date($fechaDeVencimiento,$dateformat));
#       };
#   }
# }

# #DEPRECATED paso a CircPrestamo
# sub estaVencido{
#   my($id3,$tipoPres)=@_;
# #     my @datearr = localtime(time);
#   my $err;
#   my $dateformat=C4::Date::get_date_format();
# #     my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
#   my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err),$dateformat);
#   my $venc=vencimiento($id3);
#   if (Date_Cmp($venc, $hoy) >= 0) {
#       #Si es un prestamo especial debe devolverlo antes de una determinada hora
#           if ($tipoPres ne 'ES'){return(0,$venc);}
#           else{#Prestamo especial
#           if (Date_Cmp($venc, $hoy) == 0){#Se tiene que devolver hoy  
#               my $begin = ParseDate(C4::AR::Preferencias->getValorPreferencia("open"));
#               my $end =calc_endES();
#               my $actual=ParseDate("today");
#               if (Date_Cmp($actual, $end) <= 0){#No hay sancion se devuelve entre la apertura de la biblioteca y el limite
#                   return(0,$venc);
#               }
#           }
#           else {#Se devuelve antes de la fecha de devolucion
#               return(0,$venc);
#           }
#       }#else ES
#   }#if Date_Cmp
#   return(1,$venc);
# }


#********************************AGREGADO PARA V3******************************************************

# 
# sub prestamosPorUsuario {
#   my ($nro_socio) = @_;
#   my $dbh = C4::Context->dbh;
#   my %currentissues;
# 
#   my $select= " SELECT  iss.timestamp AS timestamp, iss.fecha_prestamo AS fecha_prestamo, iss.tipo_prestamo AS tipo_prestamo,
#                   n3.id1, n2.id2, n3.id3, n3.barcode AS barcode, signatura_topografica, nivel_bibliografico,
#           n1.titulo AS titulo, n1.autor, isst.descripcion AS issuetype
#           FROM  circ_prestamo iss INNER JOIN circ_ref_tipo_prestamo isst ON ( iss.tipo_prestamo = isst.id_tipo_prestamo )
#           INNER JOIN cat_nivel3 n3 ON ( iss.id3 = n3.id3 )
#           INNER JOIN cat_nivel1 n1 ON ( n3.id1 = n1.id1)
#           INNER JOIN cat_nivel2 n2 ON ( n2.id2 = n3.id2 )
#           INNER JOIN cat_ref_tipo_nivel3 it ON ( it.id_tipo_doc = n2.tipo_documento )
#           WHERE iss.nro_socio = ?
#           AND iss.fecha_devolucion IS NULL
#           ORDER BY iss.fecha_prestamo desc";
# 
# # FALTA!!!!!!!!!
# #         biblioitems.dewey           AS dewey,
# #         biblioitems.subclass        AS subclass,
# 
#   my $sth=$dbh->prepare($select);
#   $sth->execute($nro_socio);
#   my $counter = 0;
#   while (my $data = $sth->fetchrow_hashref) {
#       $data->{'dewey'} =~ s/0*$//;
#       ($data->{'dewey'} == 0) && ($data->{'dewey'} = '');
#       my @datearr = localtime(time());
#       my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
#       my $datedue = $data->{'date_due'};
#       $datedue =~ s/-//g;
#       if ($datedue < $todaysdate) {$data->{'overdue'} = 1;}
#       
#       $data->{'idautor'}=$data->{'autor'}; #Paso el id del author para poder buscar.
#       #Obtengo los datos del autor
#       my $autor=C4::AR::Busquedas::getautor($data->{'autor'});
#       $data->{'autor'}=$autor->{'completo'};
#       $data->{'edicion'}=C4::AR::Nivel2::getEdicion($data->{'id2'});
#       $data->{'unititle'}=C4::AR::Nivel1::getUnititle($data->{'id1'});
#       $data->{'volume'}=C4::AR::Nivel2::getVolume($data->{'id2'});
#       $data->{'volumeddesc'}=C4::AR::Nivel2::getVolumeDesc($data->{'id2'});
#       $currentissues{$counter} = $data;
#       $counter++;
#   }
#   $sth->finish;
# 
#   return(\%currentissues);
# }

# =item
# getCantidadPrestamosActuales
# Devuelve la cantidad de prestamos que tiene el usuario que se pasa por parametro.
# =cut
# sub getCantidadPrestamosActuales{
#   my ($bornum)=@_;
#       my $dbh = C4::Context->dbh;
# 
#       my $query="SELECT count(*) FROM  circ_prestamo WHERE nro_socio=? AND fecha_devolucion IS NULL";
#       my $sth=$dbh->prepare($query);
#       $sth->execute($bornum);
# 
#   my $data=$sth->fetchrow;
#   
#   $sth->finish;
#   return($data);
# }



# =item
# historialPrestamos
# Devuelve el historial de prestamos de un usuario en particular.
# =cut
# FIXME DEPRECATED
# sub historialPrestamos {
#   my ($bornum,$ini,$cantR,$orden)=@_;
#       my $dbh = C4::Context->dbh;
#       my $dateformat = C4::Date::get_date_format();
#       my $querySelectCount = " SELECT count(*) AS cant ";
# 
#       my $querySelect= "  	SELECT n1.*, a.completo, iss.fecha_prestamo , iss.fecha_devolucion, n3.id3, 
#               				signatura_topografica, lastreneweddate, barcode, iss.renovaciones ,n2.*";
# 
#       my $queryFrom = " FROM cat_nivel3 n3 INNER JOIN cat_nivel2 n2";
#       $queryFrom .= " ON (n3.id2 = n2.id2) ";
#       $queryFrom .= " INNER JOIN  circ_prestamo iss ";
#       $queryFrom .= " ON (n3.id3 = iss.id3) ";
#       $queryFrom .= " INNER JOIN cat_nivel1 n1 ";
#       $queryFrom .= " ON (n3.id1 = n1.id1) ";
#       $queryFrom .= " INNER JOIN cat_autor a ";
#       $queryFrom .= " ON (a.id = n1.autor) ";
# 
#   my $queryWhere= " WHERE nro_socio= ? ";
#       my $queryFinal= " ORDER BY $orden";
#       $queryFinal .= " limit ?,? ";
# 
#       my $consulta = $querySelectCount.$queryFrom.$queryWhere;
# 
#   #obtengo la cantidad total para el paginador
#       my $sth=$dbh->prepare($consulta);
#       $sth->execute($bornum);
#       my $data= $sth->fetchrow_hashref;
#       my $count= $data->{'cant'};
# 
#   #se realiza la consulta
#       $consulta= $querySelect.$queryFrom.$queryWhere.$queryFinal;
#       my $sth=$dbh->prepare($consulta);
#       $sth->execute($bornum,$ini,$cantR);
# 
#       my @result;
#       my $i=0;
# 
#       while (my $data=$sth->fetchrow_hashref){
#       my $df=C4::AR::Prestamos::fechaDeVencimiento($data->{'id3'},$data->{'date_due'});
#       $data->{'date_fin'}=C4::Date::format_date($df,$dateformat);
#       $data->{'date_due'}=  C4::Date::format_date($data->{'date_due'},$dateformat);
#       $data->{'returndate'}=  C4::Date::format_date($data->{'returndate'},$dateformat);
#       $data->{'lastreneweddate'}=C4::Date::format_date($data->{'lastreneweddate'},$dateformat);
#       $data->{'id'} = $data->{'autor'};
#           $data->{'autor'} = $data->{'completo'};
# 
#           $result[$i]=$data;
#           $i++;
#       }
#       $sth->finish;
# 
#       return($count,\@result);
# }

=item DEPRECATED   REHACER
renovar recibe dos parametros un id3 y un borrowernumber, lo que hace es si el usario no tiene problemas de multas/sanciones, las fechas del prestamo estan en orden y no hay ninguna reserva pendiente se renueva el prestamo de ese ejmemplar para el usuario que actualmente lo tiene.
=cut


# sub verificarTipoPrestamo {
# #retorna verdadero si se puede hacer un determinado tipo de prestamo
#   my ($issuetype,$notforloan)=@_;
#   my $dbh = C4::Context->dbh;
#   my $sth=$dbh->prepare("SELECT * FROM circ_ref_tipo_prestamo WHERE id_tipo_prestamo = ? AND id_disponibilidad = ?");
#   $sth->execute($issuetype,$notforloan);
#   return($sth->fetchrow_hashref);
# }


# sub IssueType {
# #DEPRECATED::retorna los datos del tipo de prestamo
#   my ($tipo_prestamo)=@_;
#    my  $circ_ref_tipo_prestamo = C4::Modelo::CircRefTipoPrestamo->new( id_tipo_prestamo => $tipo_prestamo );
#    $circ_ref_tipo_prestamo->load();
#   return($circ_ref_tipo_prestamo);
# }

# sub IssuesType {
# #Trae todos los tipos de Prestamos existentes
#   my $dbh = C4::Context->dbh;
#   my $sth=$dbh->prepare("SELECT id_tipo_prestamo, descripcion FROM circ_ref_tipo_prestamo ORDER BY descripcion");
#   $sth->execute();
#   my @result;
#   while (my $ref= $sth->fetchrow_hashref) {
#           push @result, $ref;
#       }
# 
#   return(@result);
# }
