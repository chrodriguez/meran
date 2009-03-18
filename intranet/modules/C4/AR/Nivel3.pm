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
	&getEstado
	&t_deleteItem
	&modificarEstadoItem
);


=item
funcion q recibe el id de un item (nivel3) y devuelve el estado
=cut
sub getEstado {

        my ($id3) = @_;
	my $dbh = C4::Context->dbh;
	my $query = " SELECT wthdrawn,notforloan FROM cat_nivel3 WHERE id3 =  ? ";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3);
	my $result = $sth->fetchrow_hashref;
	return ($result->{'wthdrawn'},$result->{'notforloan'});
}


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
deleteItem
Elimina todo la informacion de un item para el nivel 3
=cut
sub deleteItem{
	my($params)=@_;

	my $dbh = C4::Context->dbh;

	my $query=" DELETE FROM cat_nivel3_repetible WHERE id3 = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($params->{'id3'});

	my $query=" DELETE FROM cat_nivel3 WHERE id3 = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($params->{'id3'});
}


sub verificarDeleteItem {
	my($params)=@_;

	my $tipo= $params->{'tipo'}; #INTRA
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $barcode= $params->{'barcode'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $error= 0;
	my $codMsg= '000';
	my @paraMens;
	my $dateformat=C4::Date::get_date_format();

open(A,">>/tmp/debugVerif.txt");#Para debagear en futuras pruebas para saber por donde entra y que hace.
print A "tipo: $tipo\n";
print A "id2: $id2\n";
print A "id3: $id3\n";

#Se verifica que el item no se encuentre prestado

=item
Deje este codigo a modo de ejemplo para que se hagan las verificaciones que sean necesarias
	if( !&C4::AR::Usuarios::esRegular($borrowernumber) ){
		$error= 1;
		$codMsg= 'U300';
print A "Entro al if de regularidad\n";
	}
=cut

close(A);

	return ($error, $codMsg,\@paraMens);
}


sub t_deleteItem {
	my($params)=@_;

#se realizan las verificaciones antes de eliminar el item
# FALTA VER SI TIENE EJEMPLARES RESERVADOS O PRESTADOS EN ESE CASO NO SE TIENE QUE ELIMINAR
	
	my ($error,$codMsg,$paraMens)= &verificarDeleteItem($params);

	my $barcode= getBarcode($params->{'id3'});
	my $error= 0;
	if(!$error){
	#No hay error
		my $dbh = C4::Context->dbh;
		$dbh->{AutoCommit} = 0;  # enable transactions, if possible
		$dbh->{RaiseError} = 1;
		eval {

			my $dataNivel3_hashref= getDataNivel3($params->{'id3'});
			### Si tenia reservas hay que reasignarlas!! antes de eliminar
			if (	($dataNivel3_hashref->{'notforloan'} eq 'DO') && 
				($dataNivel3_hashref->{'wthdrawn'} eq 0) ) {

				C4::AR::Reservas::cambiarReservaEnEspera(
										$params->{'id2'},
										$params->{'id3'},
										$params->{'responsable'}
									);
			}
			###
			#Se elimina el item
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

	my ($infoNivel3,@nivel3)=&C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($id2);
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
$itemtype, tipo del item
$tipo, INTRA/OPAC
=cut
sub detalleNivel3{
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my ($infoNivel3,@nivel3)=&C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel3');
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
		my $query="SELECT * FROM cat_nivel3_repetible WHERE id3=?";
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
		$datosItem->{'sePuedeBorrar'}=0; #no se permite borrar un item prestado
		$datosItem->{'sePuedeEditar'}=0; #no se permite editar un item prestado
		$datosItem->{'borrowernumber'}=$data->{'borrowernumber'};
		$datosItem->{'usuarioNombre'}=$data->{'surname'}.", ".$data->{'firstname'};
		$datosItem->{'disponibilidad'}="Prestado a ";
		$datosItem->{'usuario'}="<a href='../usuarios/reales/datosUsuario.pl?bornum=".$data->{'borrowernumber'}."'>".$data->{'firstname'}." ".$data->{'surname'}."</a><br>".$data->{'description'};
     	
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
saveNivel3
Guarda los campos del nivel 3
Los parametros que reciben son: $id1 es el id de la fila insertada para ese item en la tabla nivel1; $id2 es el id de la fila insertada para ese item en la tabla nivel2; $ids es la referencia a un arreglo que tiene los ids de los inputs de la interface que es un string compuesto por el campo y subcampo; $valores es la referencia a un arreglo que tiene los valores de los inputs de la interface.
=cut

sub saveNivel3{
	my ($id1,$id2,$barcodes,$cantItems,$itemType,$nivel3)=@_;

	my $query1="";
	my $query2="";
	my @bind1=();
	my @bind2=();
	my $query3="SELECT MAX(id3) FROM cat_nivel3";
	my %parametros;
	my $homebranch="";
	my $holdingbranch="";
	my $bulk="";
	my $wthdrawn="";
	my $notforloan="";
	my $error=0;
	my $codMsg;
	foreach my $obj(@$nivel3){
		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $valor=$obj->{'valor'};
		if($campo eq '995' && $subcampo eq 'd'){
			$homebranch=$valor;
		}
		elsif($campo eq '995' && $subcampo eq 'c'){
			$holdingbranch=$valor ;
		}
		elsif($campo eq '995' && $subcampo eq 't'){
			$bulk=$valor ;
		}
		elsif($campo eq '995' && $subcampo eq 'e'){
			$wthdrawn=$valor ;
		}
		elsif($campo eq '995' && $subcampo eq 'o'){
			$notforloan=$valor ;
		}
		else{
			if($valor ne ""){
				if($obj->{'simple'}){
					$query2.=",(?,?,*?*,?)";
					push (@bind2,$campo,$subcampo,$valor);
				}
				else{
					foreach my $val (@$valor){
						$query2.=",(?,?,*?*,?)";
						push (@bind2,$campo,$subcampo,$val);
					}
				}
			}
		}
	}
	$query1= "INSERT INTO cat_nivel3 (id1,id2,barcode,";
	$query1.="signatura_topografica,holdingbranch,homebranch,wthdrawn,notforloan) ";
	$query1.="VALUES (?,?,*?*,?,?,?,?,?) ";
	push (@bind1,$id1,$id2,$bulk,$holdingbranch,$homebranch,$wthdrawn,$notforloan);

	if($query2 ne ""){
		$query2=substr($query2,1,length($query2));
		$query2="INSERT INTO cat_nivel3_repetible (campo,subcampo,id3,dato) VALUES ".$query2;
	}
	$parametros{'homebranch'}=$homebranch;
	$parametros{'itemtype'}=$itemType;
	for(my $i=1; $i<=$cantItems;$i++){
		$parametros{'indice'}=$i;
	($error,$codMsg)=transaccionNivel3($barcodes,$query1,\@bind1,$query2,\@bind2,$query3,\%parametros);
		if($error){
			return($error,$codMsg);
		}
	}

## FIXME esto viene de V2 ultimo parche...
=item	
###Si el ejemplar que se agrego esta disponible hay que chequear si no existian reservas en espera!!!!
# item->{'notforloan'} eq 0 => PARA SALA

if (($item->{'notforloan'} eq 0)&&($item->{'wthdrawn'} eq 0))
	{C4::AR::Reserves::asignarReservaEnEspera($item->{'biblioitemnumber'},$itemnumber,$responsable);}
=cut

	return($error,$codMsg);
}

=item
transaccionNivel3
Funcion interna al pm
Realiza el guardado en la base de datos de los campos del nivel 3, por medio de una transaccion.
los paramentros que recibe son: $barcodes es un string con los barcodes para los items, este string puede estar en blanco, de ser asi se autogeneran en la transaccion; $query1 es el insert a la tabla del nivel 3; $query2 es el insert en la tabla repetibles del nivel 3; $query3 es la consulta que devuelve el id de la fila insertada en la tabla nivel3.
=cut
sub transaccionNivel3{
	my($barcodes,$query1,$bind1,$query2,$bind2,$query3,$parametros)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my $barcode="";
	my $error=0;
	my $codMsg='C500';
	my $ident=-1;
	eval{
		if($barcodes eq ""){$barcode=&generaCodigoBarra($dbh,$parametros);}
		else{
		#EL BARCODE VIENE DESDE LA INTERFACE - separados por "," se utiliza el barcode asosiado al indice que corresponde al item que se va agregar.
			my @barcodes2=split(/,/,$barcodes);
			$barcode="'".$barcodes2[%$parametros->{'indice'}-1]."'";
			my $query="SELECT * FROM cat_nivel3 WHERE barcode= ?";
			my $sth=$dbh->prepare($query);
			$sth->execute($barcode);
			if($sth->fetchrow_hashref){
				$error=1;
				$codMsg='C502';
			}
		}
		if(!$error){
	#reemplaza el string *?* por el barcode generado
			$query1=~ s/\*\?\*/$barcode/g;
			my $sth=$dbh->prepare($query1);
			$sth->execute(@$bind1);
	
			$sth=$dbh->prepare($query3);
			$sth->execute;
			$ident=$sth->fetchrow;

			if ($query2 ne ""){
			#Reemplaza el string *?* por el id de la nueva fila en la tabla nivel
				$query2=~ s/\*\?\*/$ident/g; 
				$sth=$dbh->prepare($query2);
        			$sth->execute(@$bind2);
			}
			$dbh->commit;
		}
	};
	if($@){
			#Se loguea error de Base de Datos
			my $codMsg= 'B403';
			C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'C501';
	}
	$dbh->{AutoCommit} = 1;

	return($error,$codMsg);
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
Recupero un nivel 3 a partir de un id3
=cut
sub getNivel3FromId3{
	my ($id3) = @_;

	my $nivel3_array_ref = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(   
																							query => [ 
																										id3 => { eq => $id3
 },
																								], 
																);

	return ($nivel3_array_ref);
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
			#ID3_ARRAY
			#$params->{'cantEjemplares'} agregar tantos ejemplares como $params->{'cantEjemplares'} indique
			#$params->{'BARCODE_'}
			#modificar los ejemplates que se encuentren en NIVEL3_ARRAY (puede)

			my $nivel_array_ref;
			my $cant= $params->{'cantEjemplares'}; #recupero la cantidad de ejemplares a agregar, 1 o mas
			my $barcodes_array = $params->{'BARCODES_ARRAY'}; #se esta agregando por barcodes 
			my @barcodes_para_agregar;
			$params->{'agregarPorBarcodes'}= 0;
			my $existe;
			my $esBlanco;
			#obtengo la info de la estructura de catalogacion del barcode
			my $cat_estruct_info_array= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo('995', 'f');

			if(scalar(@$barcodes_array) > 0){
				$cant= scalar(@$barcodes_array);
				#se intentan agregar varios BARCODES
				$params->{'agregarPorBarcodes'}= 1;
			}else{
				$cant= $params->{'cantEjemplares'}; #recupero la cantidad de ejemplares a agregar, 1 o mas
			}# END if(scalar(@$barcodes_array) > 0)
		
# 			if(scalar(@$barcodes_array) > 0){
			
				
				for(my $b;$b<$cant;$b++){
					$esBlanco= 0;
					$msg_object->{'error'}= 0;
					
					if($cat_estruct_info_array->[0]->getObligatorio){
					#el barcode es obligatorio
					#no puede existir, y no puede ser blanco	
			
						if($barcodes_array->[$b] eq ''){
						#no puede ser blanco
							$esBlanco= 1;
							$msg_object->{'error'}= 1;
							C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U387', 'params' => [$barcodes_array->[$b]]} ) ;
						}else{
							#verifico si el BARCODE EXISTE
							if( existeBarcode($barcodes_array->[$b]) ){
								#se cambio el permiso con exito
								$msg_object->{'error'}= 1;
								C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcodes_array->[$b]]} ) ;
							}
						}

					}else{	
						#verifico si el BARCODE EXISTE
						if( existeBarcode($barcodes_array->[$b]) ){
							#se cambio el permiso con exito
							$msg_object->{'error'}= 1;
							C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U386', 'params' => [$barcodes_array->[$b]]} ) ;
						}
					}# END if($cat_estruct_info_array->[0]->getObligatorio)
		
					if(!$msg_object->{'error'}){
							push (@barcodes_para_agregar, $barcodes_array->[$b]);
					}
					
				}# END for(my $b;$b<$cant;$b++)	
	
# 			if($params->{'agregarPorBarcodes'}){
				$cant= scalar(@barcodes_para_agregar);
# 			}
# 			}# END if(scalar(@$barcodes_array) > 0)

			for(my $i=0;$i<$cant;$i++){
				my $catNivel3;
		
				if($params->{'agregarPorBarcodes'} == 1){
					$params->{'barcode'}= @barcodes_para_agregar[$i];	
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


sub t_modificarNivel3 {
    my($params)=@_;

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
   
   	my $msg_object= C4::AR::Mensajes::create();
	my $barcode;

# FIXME falta verificar si es posible eliminar el nivel 3
	
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
