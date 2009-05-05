package C4::AR::Nivel3;


use strict;
require Exporter;
use C4::Context;
use C4::Date;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&detalleDisponibilidad

	&detalleNivel3MARC
	&detalleNivel3OPAC
	&detalleNivel3

	&getBarcode
	&getDataNivel3

	&disponibilidadItem
	&modificarEstadoItem
);


=item

=cut
sub modificarEstadoItem{
	my($params)=@_;
	open(A, ">>/tmp/debbug.txt");
	print  A "entro ";
	close (A);
	#avail y loan preguntar por estos campos
	my $disponible= _estaDisponible($params->{'id3'});
	my $itemActual = C4::AR::Nivel3::getDataNivel3($params->{'id3'});
	#Si {'wthdrawn'} eq 0 significa DISPONIBLE
	#Si {'wthdrawn'} mayor q 0 significa NO DISPONIBLE
	#Si {'notforloan'} eq DO significa PARA PRESTAMO
	#Si {'notforloan'} eq SA significa PARA SALA
	#Si el items esta disponible => $disponible=1
	
	# ESTE CASO ES MODIFICAR UN ITEMS NO DISPONIBLE A DISPONIBLE PARA PRESTAMO DOMICILIARIO
	if( ($disponible == 0) && ($params->{'wthdrawn'} eq 0) && ($params->{'notforloan'} eq 'DO') ){
		_modItemNoDisponibleAPrestamo($params);
	}
# 	else{
		
# 	}
	
}


=item
Esta funcion modifica el estado de un ejemplar PASA DE DISPONIBLE PARA SALA A DISPONIBLE PARA PRESTAMO, debemos ver si existen reservas para ese grupo, y reasignar la reserva para ese ejemplar
=cut
sub modItemSalaAPrestamo{
	my($params)=@_;

	C4::AR::Reservas::reasignarReservaEnEspera($params);
	#FALTARIA CAMBIAR EL ESTADO
}

=item
Esta funcion modifica el estado de un ejemplar PASA DE NO DISPONIBLE A DISPONIBLE PARA PRESTAMO, debemos ver si existen reservas para ese grupo, y reasignar la reserva para ese ejemplar
=cut
sub _modItemNoDisponibleAPrestamo{
	my($params)=@_;

	C4::AR::Reservas::reasignarReservaEnEspera($params);
	#FALTARIA CAMBIAR EL ESTADOs
}

sub _estaDisponible {
	my($id3)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" SELECT FROM cat_nivel3 WHERE id3 = ? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($id3);

	my $data=$sth->fetchrow;
	
	if($data == 0) {return 1;} #DISPONIBLE
	else {return 0;} #NO DISPONIBLE
}


=item
detalleDisponibilidad
Devuelve la disponibilidad del item que viene por paramentro.
=cut
sub detalleDisponibilidad{
        my ($id3) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM cat_detalle_disponibilidad WHERE id3 = ? ORDER BY date DESC";
        my $sth = $dbh->prepare($query);
        $sth->execute($id3);
	my @results;
	my $i=0;

	while (my $data=$sth->fetchrow_hashref){
		$results[$i]=$data; $i++; 
	}
	$sth->finish;

	return(scalar(@results),\@results);
}

=item
detalleNivel3MARC
trae el nivel3 completo (nivel3 y nivel3_repetibles), para mostrar en MARC,
segun id3 pasado por parametro
=cut
sub detalleNivel3MARC{
	my ($id3,$itemtype,$tipo)=@_;

	my $dbh = C4::Context->dbh;
	my (@nivel3)=&C4::AR::Catalogacion::buscarNivel3($id3);
	my $disponibles;
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel3');
	my $i=0;
	my $dato;
	my $campo;
	my $subcampo;
	my $librarian;
	my @marcResult;
 	foreach my $row(@nivel3){

		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			my $dato=$row->{$mapeo->{$llave}->{'campoTabla'}};
			$librarian=&C4::AR::Busquedas::getLibrarian($campo, $subcampo, $dato,$itemtype,$tipo,1);

			$marcResult[$i]->{'campo'}= $campo;
			$marcResult[$i]->{'subcampo'}= $subcampo;
			$marcResult[$i]->{'dato'}= $librarian->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};
	
			$i++;
		}
		my $query="SELECT * FROM cat_nivel3_repetible WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){

 			$librarian=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},$itemtype,$tipo,1);

			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $librarian->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		$sth->finish;
	}

	return(\@marcResult);
}


=item
detalleNivel3OPAC
Trae todos los datos del nivel 3, para poder verlos en el template.
=cut
sub detalleNivel3OPAC{
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;

	my ($infoNivel3,@nivel3)= buscarNivel3PorId2YDisponibilidad($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel3');
	my @nivel3Comp;
	my @results;
	my $i=0;
	my $id3;
	my $campo;
	my $subcampo;
	my $dato;
	my $librarian;
	my $getLib;

	$results[0]->{'nivel3'}=\@nivel3;

	$results[0]->{'id2'}= $id2;
	$results[0]->{'cantParaPrestamo'}= $infoNivel3->{'cantParaPrestamo'};
	$results[0]->{'cantParaSala'}= $infoNivel3->{'cantParaSala'};
	$results[0]->{'cantResevasActual'}= $infoNivel3->{'cantReservas'};
	foreach my $row(@nivel3){

		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$nivel3Comp[$i]->{'campo'}=$campo;
			$nivel3Comp[$i]->{'subcampo'}=$subcampo;
			$dato= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$getLib= &C4::AR::Busquedas::getLibrarian($campo, $subcampo, "", $itemtype,$tipo,0);
			$nivel3Comp[$i]->{'librarian'}= $getLib->{'textPred'};
			$nivel3Comp[$i]->{'dato'}= $dato;
			$i++;
		}
		$id3=$row->{'id3'};
		my $query="SELECT * FROM cat_nivel3_repetible WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){
			$nivel3Comp[$i]->{'campo'}=$data->{'campo'};
			$nivel3Comp[$i]->{'subcampo'}=$data->{'subcampo'};
			$getLib= &C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'}, $itemtype,$tipo,0);
			$nivel3Comp[$i]->{'librarian'}= $getLib->{'textPred'};
			$nivel3Comp[$i]->{'dato'}= $getLib->{'dato'};

			$i++;
		}
		$sth->finish;
	}
	return(\@results,\@nivel3Comp);
}


=item
detalleNivel3
Trae todos los datos del nivel 3, para poder verlos en el template.
@params 
$id2, id de nivel2
=cut
sub detalleNivel3{
	my ($id2)=@_;

	my $nivel3_array_ref= &C4::AR::Nivel3::getNivel3FromId2($id2);
	my @nivel3;
	my %hash_nivel2;
			
	for(my $i=0;$i<scalar(@$nivel3_array_ref);$i++){
		my %hash_nivel3;
			$nivel3_array_ref->[$i]->load();
			$hash_nivel3{'nivel3_array'}= $nivel3_array_ref->[$i];
			$hash_nivel3{'id3'}= $nivel3_array_ref->[$i]->getId3;

			push(@nivel3, \%hash_nivel3);
	}

	$hash_nivel2{'nivel3'}= \@nivel3;
	$hash_nivel2{'disponibles'}= '0';
	$hash_nivel2{'cantReservas'}= '0';
	$hash_nivel2{'cantReservasEnEspera'}= '0';
	$hash_nivel2{'cantPrestados'}= C4::AR::Nivel2::getCantPrestados($id2);

	return (\%hash_nivel2);
}

=item
Genera el detalle 
=cut
sub detalleCompletoINTRA{
	my ($id1, $t_params)=@_;
	
	my $nivel1= &C4::AR::Nivel1::getNivel1FromId1($id1);
	my $nivel2_array_ref= &C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

	my @nivel2;
	
	for(my $i=0;$i<scalar(@$nivel2_array_ref);$i++){
		my $hash_nivel2;
		$nivel2_array_ref->[$i]->load();
		$hash_nivel2->{'id2'}= $nivel2_array_ref->[$i]->getId2;
		$hash_nivel2->{'tipo_documento'}= C4::AR::Referencias::getNombreTipoDocumento($nivel2_array_ref->[$i]->getTipo_documento);
		$hash_nivel2->{'nivel2_array'}= ($nivel2_array_ref->[$i])->toMARC; #arreglo de los campos fijos de Nivel 2 mapeado a MARC
		my ($totales_nivel3,@result)= detalleDisponibilidadNivel3($nivel2_array_ref->[$i]->getId2);
		$hash_nivel2->{'nivel3'}= \@result;
		$hash_nivel2->{'cantPrestados'}= $totales_nivel3->{'cantPrestados'};
		$hash_nivel2->{'cantReservas'}= $totales_nivel3->{'cantReservas'};
		$hash_nivel2->{'cantReservasEnEspera'}= $totales_nivel3->{'cantReservasEnEspera'};
		$hash_nivel2->{'disponibles'}= $totales_nivel3->{'disponibles'};
		$hash_nivel2->{'cantParaSala'}= $totales_nivel3->{'cantParaSala'};
		$hash_nivel2->{'cantParaPrestamo'}= $totales_nivel3->{'cantParaPrestamo'};
	
		push(@nivel2, $hash_nivel2);
	}

	$t_params->{'nivel1'}= $nivel1->toMARC,
	$t_params->{'id1'}	  = $id1;
	$t_params->{'nivel2'}= \@nivel2,
}

=item
Genera el detalle 
=cut
sub detalleCompletoOPAC{
	my ($id1, $t_params)=@_;
	
	my $nivel1= &C4::AR::Nivel1::getNivel1FromId1($id1);
	my $nivel2_array_ref= &C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

	my @nivel2;
	
	for(my $i=0;$i<scalar(@$nivel2_array_ref);$i++){
 		my $hash_nivel2;
		$nivel2_array_ref->[$i]->load();
		$hash_nivel2->{'id2'}= $nivel2_array_ref->[$i]->getId2;
		$hash_nivel2->{'tipo_documento'}= C4::AR::Referencias::getNombreTipoDocumento($nivel2_array_ref->[$i]->getTipo_documento);
		$hash_nivel2->{'nivel2_array'}= ($nivel2_array_ref->[$i])->toMARC; #arreglo de los campos fijos de Nivel 2 mapeado a MARC
		my ($totales_nivel3,@result)= detalleDisponibilidadNivel3($nivel2_array_ref->[$i]->getId2);
		$hash_nivel2->{'nivel3'}= \@result;
		$hash_nivel2->{'cantPrestados'}= $totales_nivel3->{'cantPrestados'};
		$hash_nivel2->{'cantReservas'}= $totales_nivel3->{'cantReservas'};
		$hash_nivel2->{'cantReservasEnEspera'}= $totales_nivel3->{'cantReservasEnEspera'};
		$hash_nivel2->{'disponibles'}= $totales_nivel3->{'disponibles'};
		$hash_nivel2->{'cantParaSala'}= $totales_nivel3->{'cantParaSala'};
		$hash_nivel2->{'cantParaPrestamo'}= $totales_nivel3->{'cantParaPrestamo'};
		$hash_nivel2->{'DivMARC'}="MARCDetail".$i;
		$hash_nivel2->{'DivDetalle'}="Detalle".$i;
	
		push(@nivel2, $hash_nivel2);
	}

	my $hash_nivel2;
	$hash_nivel2->{'nivel1'}= $nivel1->toMARC;
	push(@nivel2, $hash_nivel2);
# 	$t_params->{'nivel1'}= $nivel1->toMARC,
	$t_params->{'id1'}	  = $id1;
	$t_params->{'nivel2'}= \@nivel2,
}

=item
disponibilidadItem
Esta funcion busca el estado en el que se encuentra el item con id3 que viene por parametro, si esta prestado o reservado trae la info del usuario al cual fue asignado.
=cut
sub disponibilidadItem{
	my ($datosItem)=@_;

	my $dbh=C4::Context->dbh;
	my $borrowernumber="";
	my $clase;
	my $disponibilidad;
	my $dateformat = C4::Date::get_date_format();
	$datosItem->{'sePuedeBorrar'}=1;
	$datosItem->{'sePuedeEditar'}=1;

	my $data= &C4::AR::Prestamos::getDatosPrestamoDeId3($datosItem->{'id3'});

	if ($data){
    	#el item esta prestado, obtengo la informacion
		$datosItem->{'prestado'}=1;
		$datosItem->{'clase'}="";
		$datosItem->{'sePuedeBorrar'}=0; #no se permite borrar un item prestado
		$datosItem->{'sePuedeEditar'}=0; #no se permite editar un item prestado
		$datosItem->{'borrowernumber'}=$data->{'borrowernumber'};
		$datosItem->{'usuarioNombre'}=$data->{'surname'}.", ".$data->{'firstname'};
		$datosItem->{'disponibilidad'}="Prestado a ";
		$datosItem->{'usuario'}="<a href='../usuarios/reales/datosUsuario.pl?bornum=".$data->{'borrowernumber'}."'>".$data->{'firstname'}." ".$data->{'surname'}."</a><br>".$data->{'description'};
     	#DEPRECATED REHACER
# 		my ($vencido,$df)= &C4::AR::Prestamos::estaVencido($data->{'id3'},$data->{'issuecode'});
# 		my $returndate=format_date($df,$dateformat);
# 		$datosItem->{'vencimiento'}=$returndate;
# 		if($vencido){
# 			$datosItem->{'claseFecha'}="fechaVencida";
# 		}
#       		$datosItem->{'renew'} = C4::AR::Prestamos::sepuederenovar($data->{'borrowernumber'}, $data->{'id3'});
	}

	my $data= &C4::AR::Reservas::getDatosReservaDeId3($datosItem->{'id3'});

	if($data){
	#Se encuentra reservado, obtengo la informacion de la reserva	
		$datosItem->{'clase'}="";
		$datosItem->{'borrowernumber'}=$data->{'borrowernumber'};
		$datosItem->{'usuarioNombre'}=$data->{'surname'}.", ".$data->{'firstname'};
		my $reminderdate=format_date($data->{'reminderdate'},$dateformat);
		$datosItem->{'vencimiento'}=$reminderdate;
		$datosItem->{'disponibilidad'}="Reservado a ";
      		$datosItem->{'usuario'}="<a href='../usuarios/reales/datosUsuario.pl?bornum=".$data->{'borrowernumber'}."'>".$data->{'firstname'}." ".$data->{'surname'}."</a>";
	}
}


sub getBarcode{
	my($id3)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" 	SELECT barcode
			FROM cat_nivel3
			WHERE id3 = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($id3);

	return $sth->fetchrow;
}

sub getDataNivel3{
	my ($id3)= @_;

	my $dbh = C4::Context->dbh;
# 	my $sth=$dbh->prepare("	SELECT id1, homebranch, id2, barcode
	my $sth=$dbh->prepare("	SELECT *
				FROM cat_nivel3
				WHERE(id3 = ?)");
	$sth->execute($id3);
	my $dataNivel3= $sth->fetchrow_hashref;
	return $dataNivel3;
}



=item
generaCodigoBarra
Funcion interna al pm
Genera el codigo de barras del item automanticamente por medio de una consulta a la base de datos, esta funcion es llamada desde una transaccion.
Los parametros son el manejador de la base de datos y los parametros que necesita para generar el codigo de barra.
=cut
sub generaCodigoBarra{
	#VER COMO SE GENERA EL BARCODE!!! VER SI ESTA BIEN!!!!!!!!
# FIXME si cambia el itemtype de nivel 2 esto se deberia ver reflejado en todos los barcode del grupo, lo mismo si cambia el homebranch
	my($dbh,$parametros)=@_;
	my $barcode;
	my @estructurabarcode=split(',',C4::AR::Preferencias->getValorPreferencia("barcodeFormat"));
        my $like='';

	for (my $i=0; $i<@estructurabarcode; $i++){
		if (($i % 2) ==0){
			$like.=%$parametros->{$estructurabarcode[$i]};
		}
		else{
			$like.=$estructurabarcode[$i];
		}
	}

	my $sth2=$dbh->prepare("SELECT MAX(CAST(substring(barcode,INSTR(barcode,?)+?,100) AS SIGNED)) AS maximo 
				FROM cat_nivel3 
				WHERE barcode LIKE (?) ");

	$sth2->execute($like.'%',length($like)+1,$like.'%');
	my $data2= $sth2->fetchrow_hashref;
	$barcode="'".$like.($data2->{'maximo'}+1)."'";
	return($barcode);
}


=item
buscarNiveles3PorDisponibilidad
Busca los datos del nivel 3 a partir de un id3, respetando su disponibilidad
=cut
sub buscarNivel3PorDisponibilidad{
	my ($nivel3aPrestar)=@_;
	
	my ($nivel3_array_ref)= getNivel3FromId2($nivel3aPrestar->getId2);
	my @items;
	my $j=0;
	foreach my $n3 (@$nivel3_array_ref){
		my $item;

		if((!$n3->estaPrestado)&&($n3->estadoDisponible)&&($nivel3aPrestar->getId_disponibilidad eq $n3->getId_disponibilidad)){
		#Si no esta prestado, esta en estado disponmible y tiene la misma disponibilidad que el novel 3 que intento prestar se agrega al combo
				$item->{'label'}=$n3->getBarcode;
				$item->{'value'}=$n3->getId3;
				push (@items,$item);
			}
	}

	return(\@items);
}




=item
detalleDisponibilidadNivel3
Busca los datos del nivel 3 a partir de un id2 correspondiente a nivel 2.
=cut
sub detalleDisponibilidadNivel3{
	my ($id2)=@_;
	my $nivel3_array_ref= &C4::AR::Nivel3::getNivel3FromId2($id2);
	my @result;
	my %hash_nivel2;

	my $i=0;
	my $cantDisponibles=0;
	my %infoNivel3;
	$infoNivel3{'cantParaSala'}= 0;
	$infoNivel3{'cantParaPrestamo'}= 0;
	$infoNivel3{'disponibles'}= 0;
	$infoNivel3{'cantPrestados'}= C4::AR::Nivel2::getCantPrestados($id2);
	$infoNivel3{'cantReservas'}= C4::AR::Reservas::cantReservasPorGrupo($id2);
	$infoNivel3{'cantReservasEnEspera'}= C4::AR::Reservas::cantReservasPorGrupoEnEspera($id2);
			
	for(my $i=0;$i<scalar(@$nivel3_array_ref);$i++){
		my %hash_nivel3;
		$nivel3_array_ref->[$i]->load();
		$hash_nivel3{'nivel3_obj'}= $nivel3_array_ref->[$i];
		$hash_nivel3{'id3'}= $nivel3_array_ref->[$i]->getId3;

		my $UI_poseedora= C4::AR::Referencias::getNombreUI($hash_nivel3{'id_ui_poseedora'});
		$hash_nivel3{'UI_poseedora'}= $UI_poseedora;

		my $UI_origen= C4::AR::Referencias::getNombreUI($hash_nivel3{'id_ui_origen'});
		$hash_nivel3{'UI_origen'}= $UI_origen;
# FIXME falta esto no se para q es		
# 		my $wthdrawn=getAvail($data->{'wthdrawn'});
# 		$data->{'wthdrawnDescrip'}=$wthdrawn->{'description'};

		if($nivel3_array_ref->[$i]->estadoDisponible){
		#Disponible
			$hash_nivel3{'disponibilidad'}= $nivel3_array_ref->[$i]->getEstado;
			$hash_nivel3{'clase'}= "fechaVencida";
			$cantDisponibles++;
		}
		
		if( ($nivel3_array_ref->[$i]->estadoDisponible) && (!$nivel3_array_ref->[$i]->esParaSala) ){
		#esta DISPONIBLE y es PARA PRESTAMO
			$hash_nivel3{'paraPrestamo'}= 1;
			$hash_nivel3{'disponibilidad'}= "PRESTAMO";
			$hash_nivel3{'clase'}= "prestamo";
			$infoNivel3{'cantParaPrestamo'}++;
		}elsif($nivel3_array_ref->[$i]->esParaSala){
		#es PARA SALA
			$infoNivel3{'cantParaSala'}++;
			$hash_nivel3{'disponibilidad'}= "SALA DE LECTURA";
			$hash_nivel3{'clase'}= "salaLectura";
		}

		my $socio= C4::AR::Prestamos::getSocioFromPrestamo($hash_nivel3{'id3'});

		if($socio){
			$hash_nivel3{'nro_socio'}= $socio->getNro_socio;
			$hash_nivel3{'usuarioNombre'}= $socio->persona->getApellido.", ".$socio->persona->getNombre;
		}
	
 		$result[$i]= \%hash_nivel3;
		$i++;

# 		push(@result, \%infoNivel3);
	}

 	$infoNivel3{'disponibles'}= $infoNivel3{'cantParaPrestamo'} + $infoNivel3{'cantParaSala'};

	return(\%infoNivel3,@result);
}



sub _verificarDeleteItem {
	my($params)=@_;
# FIXME falta implementar
	
	my $msg_object= C4::AR::Mensajes::create();

	my $tipo= $params->{'tipo'}; #INTRA
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $barcode= $params->{'barcode'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $codMsg= '000';
	my @paraMens;
	my $dateformat=C4::Date::get_date_format();
	$msg_object->{'error'}= 0;


	return ($msg_object);
}



=item
Recupero todos los nivel 3 a partir de un id2
=cut
sub getNivel3FromId2{
	my ($id2) = @_;

	my $nivel3_array_ref = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(   
																		query => [ 
																					id2 => { eq => $id2 },
																			], 
										);

	return ($nivel3_array_ref);
}


=item
Recupero un nivel 3 a partir de un id3
retorna un objeto o 0 si no existe
=cut
sub getNivel3FromId3{
	my ($id3) = @_;

	my $nivel3_array_ref = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(   
																			query => [ 
																					id3 => { eq => $id3},
																				], 
																);

	if( scalar(@$nivel3_array_ref) > 0){
		return ($nivel3_array_ref->[0]);
	}else{
		return 0;
	}
}

=item
Recupero un nivel 3 a partir de un barcode
=cut
sub getNivel3FromBarcode{
	my ($barcode) = @_;

	my $nivel3_array_ref = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(   
																							query => [ 
																										barcode => { eq => $barcode
 },
																								], 
																);

	return ($nivel3_array_ref);
}

=item
Verifica si existe el barcode pasado por parametro
=cut
sub existeBarcode{
	my($barcode)=@_;

	my $nivel_array_ref= C4::AR::Nivel3::getNivel3FromBarcode($barcode);
	
	return ( scalar(@$nivel_array_ref) > 0);
}
#=======================================================================ABM Nivel 3======================================================

sub t_guardarNivel3 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $catNivel3;
	my $db;

    if(!$msg_object->{'error'}){
    #No hay error
		my	$catNivel2= C4::Modelo::CatNivel2->new();
		my	$db= $catNivel2->db;
			# enable transactions, if possible
			$db->{connect_options}->{AutoCommit} = 0;
	
        eval {

			my ($barcodes_para_agregar)= _verificarBarcodes($params, $msg_object);
	
			my $cant= scalar(@$barcodes_para_agregar);

			for(my $i=0;$i<$cant;$i++){
				my $catNivel3;
		
				if($params->{'agregarPorBarcodes'} == 1){
					$params->{'barcode'}= $barcodes_para_agregar->[$i];	
				}
				
				$catNivel3= C4::Modelo::CatNivel3->new(db => $db);
				$catNivel3->agregar($params);  
				
				#se cambio el permiso con exito
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U370', 'params' => [$catNivel3->getBarcode]} ) ;
			}

			$db->commit;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U373', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

	return ($msg_object);
}

=item
Lo que hace la funcion es verificar cada barcode y devolver un arreglo de barcodes permitidos para agregar junto con sus
respectivos mensajes, ya sea que se AGREGO con EXITO o NO se pudo AGREGAR (por algun motivo)

Tiene PRIORIDAD la carga multiple de varios barcodes sobre la carga multiple de varios ejemplares

Si el barcode ES obligatorio:

	- No puede ser blanco
	- No puede Existir

Si el barcode NO es obligatorio:
	
	- Se permite barcode en blanco
	- Si se ingresa un barcode, NO PUEDE EXISTIR

=cut
sub _verificarBarcodes{
	
	my($params, $msg_object)=@_;
 
	my $cant= $params->{'cantEjemplares'}; #recupero la cantidad de ejemplares a agregar, 1 o mas
	my $barcodes_array = $params->{'BARCODES_ARRAY'}; #se esta agregando por barcodes 
	my @barcodes_para_agregar;
	$params->{'agregarPorBarcodes'}= 0;
	my $existe;
	#obtengo la info de la estructura de catalogacion del barcode
	my $cat_estruct_info_array= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo('995', 'f');

	if(scalar(@$barcodes_array) > 0){
		$cant= scalar(@$barcodes_array);
		#se intentan agregar varios BARCODES
		$params->{'agregarPorBarcodes'}= 1;
	}else{
		$cant= $params->{'cantEjemplares'}; #recupero la cantidad de ejemplares a agregar, 1 o mas
	}# END if(scalar(@$barcodes_array) > 0)

	for(my $b;$b<$cant;$b++){
		$existe= 0;
		
		if($cat_estruct_info_array->[0]->getObligatorio){
		#el barcode es OBLIGATORIO
		#no puede existir, y no puede ser blanco	

			if($barcodes_array->[$b] eq ''){
			#no puede ser blanco
				$msg_object->{'error'}= 1;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U387', 'params' => [$barcodes_array->[$b]]} ) ;
			}else{
				#verifico si el BARCODE EXISTE
				if( existeBarcode($barcodes_array->[$b]) ){
					#se cambio el permiso con exito
					$msg_object->{'error'}= 1;
					$existe= 1;
					C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcodes_array->[$b]]} ) ;
				}
			}

		}else{	
		#el barcode NO es OBLIGATORIO
			#verifico si el BARCODE EXISTE en la base de datos, puede ser blanco
			if( existeBarcode($barcodes_array->[$b]) && ($barcodes_array->[$b] ne '') ){
				#se cambio el permiso con exito
				$msg_object->{'error'}= 1;
				$existe= 1;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcodes_array->[$b]]} ) ;
			}
		}# END if($cat_estruct_info_array->[0]->getObligatorio)

		if(_existeBarcodeEnArray($barcodes_array->[$b], $barcodes_array)){
		#se envió desde el cliente dos o mas BARCODES IGUALES
		#el barcode que se esta intentando agregar ya existe en el arreglo de barcodes enviado desde el cliente
			$msg_object->{'error'}= 1;
			$existe= 1;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcodes_array->[$b]]} ) ;
		}

		if(!$existe){
		#si no existe, lo agrego al arreglo de barcodes para insertar
				push (@barcodes_para_agregar, $barcodes_array->[$b]);
		}
		
	}# END for(my $b;$b<$cant;$b++)	
	return (\@barcodes_para_agregar);
}

=item
Esta funcion verifica si en el arreglo de barcodes no existe 1 o mas barcodes iguales
=cut
sub _existeBarcodeEnArray{
	my ($barcode, $barcodes_array)= @_;

	my $cant=0;
	my $existe= 0;

	for(my $i=0;$i<scalar(@$barcodes_array);$i++){
C4::AR::Debug::debug("_existeBarcodeEnArray=> cmp ".$barcodes_array->[$i]." con ".$barcode."\n");
		if(C4::AR::Utilidades::trim($barcodes_array->[$i]) eq C4::AR::Utilidades::trim($barcode) ){
			$cant++;
			if($cant gt 1){
C4::AR::Debug::debug("_existeBarcodeEnArray=> EXISTE: ".$barcodes_array->[$i]."\n");
				#el barcode ya existe en el arreglo de barcodes que se esta intentando agregar
 				return 1;
				$existe= 1;
			}
		}
	}
	#no existe el barcode en el arreglo de barcodes
	return 0;
}

sub t_modificarNivel3 {
    my ($params)= @_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $catNivel3;
	my $db;

    if(!$msg_object->{'error'}){
    #No hay error
		my	$catNivel2= C4::Modelo::CatNivel2->new();
		my	$db= $catNivel2->db;
		$params->{'modificado'}=1;
			# enable transactions, if possible
			$db->{connect_options}->{AutoCommit} = 0;
	
        eval {
			my $id3_array= $params->{'ID3_ARRAY'}; 
			my $cant= scalar(@$id3_array);
C4::AR::Debug::debug("t_modificarNivel3 => cant de items a modificar / agregar: ".$cant);
			for(my $i=0;$i<$cant;$i++){
				my $catNivel3;

				$catNivel3= C4::Modelo::CatNivel3->new(
																db => $db,
																id3 => $params->{'ID3_ARRAY'}->[$i]
												);

				$catNivel3->load();
				$catNivel3->agregar($params);  
				
				#se cambio el permiso con exito
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U382', 'params' => [$catNivel3->getBarcode]} ) ;
			}
			$db->commit;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B432',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U385', 'params' => [$catNivel3->getBarcode]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

	return ($msg_object);
}

sub t_eliminarNivel3{
   
   	my($params)=@_;
	my $barcode;

	my ($msg_object)= _verificarDeleteItem($params);
	
    if(!$msg_object->{'error'}){
    #No hay error

		my	$catNivel2= C4::Modelo::CatNivel2->new();
		my	$db= $catNivel2->db;
			# enable transactions, if possible
			$db->{connect_options}->{AutoCommit} = 0;
		my $id3_array= $params->{'id3_array'};

        eval {
			for(my $i=0;$i<scalar(@$id3_array);$i++){
				my $catNivel3;
				
				$catNivel3= C4::Modelo::CatNivel3->new(
														db => $db,
														id3 => $id3_array->[$i]
													);

				$catNivel3->load();
				my $barcode= $catNivel3->getBarcode;	
				$catNivel3->eliminar;  
				
				#se cambio el permiso con exito
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U376', 'params' => [$barcode]} ) ;
			}
			$db->commit;
        };

        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B435',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U379', 'params' => [$barcode]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}

#===================================================================Fin====ABM Nivel 3====================================================
