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

	&disponibilidadItem

	&t_deleteItem
);


=item
deleteItem
Elimina todo la informacion de un item para el nivel 3
=cut
sub deleteItem{
	my($params)=@_;

	my $dbh = C4::Context->dbh;

	my $query=" DELETE FROM nivel3_repetibles WHERE id3 = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($params->{'id3'});

	my $query=" DELETE FROM nivel3 WHERE id3 = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($params->{'id3'});
}

sub t_deleteItem {
	my($params)=@_;

#se realizan las verificaciones antes de eliminar el item
# FALTA VER SI TIENE EJEMPLARES RESERVADOS O PRESTADOS EN ESE CASO NO SE TIENE QUE ELIMINAR
	
	my ($error,$codMsg,$paraMens);
	my $barcode= getBarcode($params->{'id3'});
	my $error= 0;
	if(!$error){
	#No hay error
		my $dbh = C4::Context->dbh;
		$dbh->{AutoCommit} = 0;  # enable transactions, if possible
		$dbh->{RaiseError} = 1;
		eval {
			deleteItem($params);	
			$dbh->commit;
	
			$codMsg= 'M901';
			$paraMens->[0]= $barcode;
	
		};

		if ($@){
			#Se loguea error de Base de Datos
			$codMsg= 'B412';
			&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'U305';
			$paraMens->[0]= $barcode;
		}
		$dbh->{AutoCommit} = 1;
		
	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

=item
detalleDisponibilidad
Devuelve la disponibilidad del item que viene por paramentro.
=cut
sub detalleDisponibilidad{
        my ($id3) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM availability WHERE id3 = ? ORDER BY date DESC";
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
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel3');
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
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
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

	my ($infoNivel3,@nivel3)=&C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel3');
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
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
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
$itemtype, tipo del item
$tipo, INTRA/OPAC
=cut
sub detalleNivel3{
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my ($infoNivel3,@nivel3)=&C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel3');
	my @nivel3Comp;
	my %llaves;
	my @results;
	my $i=0;
	my $id3;
	my $campo;
	my $subcampo;
	my $getLib;
	$results[0]->{'nivel3'}=\@nivel3;
 	$results[0]->{'disponibles'}= $infoNivel3->{'disponibles'};
	$results[0]->{'cantReservas'}= $infoNivel3->{'cantReservas'};
	$results[0]->{'cantReservasEnEspera'}= $infoNivel3->{'cantReservasEnEspera'};
	$results[0]->{'cantPrestados'}= $infoNivel3->{'cantPrestados'};
	foreach my $row(@nivel3){
		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$getLib=&C4::AR::Busquedas::getLibrarian($campo, $subcampo, "",$itemtype,$tipo,0);
			$nivel3Comp[$i]->{'campo'}=$campo;
			$nivel3Comp[$i]->{'subcampo'}=$subcampo;
			$nivel3Comp[$i]->{'dato'}=$row->{$mapeo->{$llave}->{'campoTabla'}};
			$nivel3Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		$id3=$row->{'id3'};
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		my $llave2;
		while (my $data=$sth->fetchrow_hashref){
			$llave2=$data->{'campo'}.",".$data->{'subcampo'};
			$getLib=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,$tipo,0);
			if(not exists($llaves{$llave2})){
				$llaves{$llave2}=$i;
				$nivel3Comp[$i]->{'campo'}=$data->{'campo'};
				$nivel3Comp[$i]->{'subcampo'}=$data->{'subcampo'};
				$nivel3Comp[$i]->{'dato'}=$getLib->{'dato'};
				$nivel3Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
				$i++;
			}
			else{
				my $separador=" ".$getLib->{'separador'}." " ||", ";
				my $pos=$llaves{$llave2};
				$nivel3Comp[$pos]->{'dato'}.=$separador.$getLib->{'dato'};
			}
		}
		$sth->finish;
	}
	return(\@results,\@nivel3Comp);
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

	my $data= &C4::AR::Issues::getDatosPrestamoDeId3($datosItem->{'id3'});

	if ($data){
    		#el item esta prestado, obtengo la informacion
		$datosItem->{'prestado'}=1;
		$datosItem->{'clase'}="";
		$datosItem->{'sePuedeBorrar'}=0;
		$datosItem->{'sePuedeEditar'}=0;
		$datosItem->{'borrowernumber'}=$data->{'borrowernumber'};
		$datosItem->{'usuarioNombre'}=$data->{'surname'}.", ".$data->{'firstname'};
		$datosItem->{'disponibilidad'}="Prestado a ";
		$datosItem->{'usuario'}="<a href='../members/moremember.pl?bornum=".$data->{'borrowernumber'}."'>".$data->{'firstname'}." ".$data->{'surname'}."</a><br>".$data->{'description'};
     	
		my ($vencido,$df)= &C4::AR::Issues::estaVencido($data->{'id3'},$data->{'issuecode'});
		my $returndate=format_date($df,$dateformat);
		$datosItem->{'vencimiento'}=$returndate;
		if($vencido){
			$datosItem->{'claseFecha'}="fechaVencida";
		}
      		$datosItem->{'renew'} = C4::AR::Issues::sepuederenovar($data->{'borrowernumber'}, $data->{'id3'});
	}

	my $data= &C4::AR::Reservas::getDatosReservaDeId3($datosItem->{'id3'});

	if($data){
	#Se encuentra resrevado, obtengo la informacion de la reserva	
		$datosItem->{'sePuedeBorrar'}=0;
		$datosItem->{'clase'}="";
		$datosItem->{'borrowernumber'}=$data->{'borrowernumber'};
		$datosItem->{'usuarioNombre'}=$data->{'surname'}.", ".$data->{'firstname'};
		my $reminderdate=format_date($data->{'reminderdate'},$dateformat);
		$datosItem->{'vencimiento'}=$reminderdate;
		$datosItem->{'disponibilidad'}="Reservado a ";
      		$datosItem->{'usuario'}="<a href='../members/moremember.pl?bornum=".$data->{'borrowernumber'}."'>".$data->{'firstname'}." ".$data->{'surname'}."</a>";
	}
}


sub getBarcode{
	my($id3)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" 	SELECT barcode
			FROM nivel3
			WHERE id3 = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($id3);

	return $sth->fetchrow;
}

