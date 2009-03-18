package C4::AR::Nivel2;


use strict;
require Exporter;
use C4::Context;
use C4::AR::Amazon;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(

		&getEdicion
		&getVolume
		&getVolumeDesc
		&getISBN
		&getTipoDocumento
		
		&getCantPrestados

		&getIndice
		&insertIndice

		&saveNivel2
		
		&detalleNivel2
		&detalleNivel2MARC
		&detalleNivel2OPAC

		&t_deleteGrupo
);


=item
retorna el indice del grupo con correpondiente al parametro $id2
=cut
sub getIndice{
	my ($id2)=@_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"555","a","2");
}

#para mostrar el indice del biblioitem
sub insertIndice{

	my ($biblioitemnumber, $biblionumber, $infoIndice) = @_;
	my $dbh = C4::Context->dbh;
	my $query = " 	UPDATE biblioitems 	
			SET indice = ?
			WHERE biblioitemnumber =  ?	
			AND biblionumber = ? ";
	
    	my $sth=$dbh->prepare($query);
    	$sth->execute($infoIndice, $biblioitemnumber, $biblionumber);

}

=item
Esta funcion retorna la edicion segun un id2
=cut
sub getEdicion {
	my ($id2) = @_;
	
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"250","a","2");
}

=item
Esta funcion retorna el volumen segun un id2
=cut
sub getVolume {
	my($id2)= @_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"740","n","2");
}

=item
Esta funcion retorna la descripcion del volumen segun un id2
=cut
sub getVolumeDesc {
	my($id2)= @_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"740","a","2");
}

=item
retorna el primer isbn del grupo con correpondiente al parametro $id2
=cut
sub getISBN{
	my ($id2)=@_;
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"020","a","2");
}

=item
detalleNivel2MARC
Busca el nivel 2 segun id1 y id2, al resultado le agrega el nivel 1 y nivel 3
=cut
sub detalleNivel2MARC{
	my($id1,$id2,$id3,$tipo,$nivel1)=@_;
	my $dbh = C4::Context->dbh;
	#Busca el nivel 2 segun id1 e id2, (retorna solo uno)
	my @nivel2=&C4::AR::Catalogacion::buscarNivel2PorId1Id2($id1,$id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel2');
	my $id2;
	my $itemtype;
	my $tipoDoc;
	my $campo;
	my $subcampo;
	my @results;
	my $librarian;	
	my $j=0;

	foreach my $row(@nivel2){
		my $i=0;
		my @marcResult;
		$marcResult[0]->{'campo'}= "";
		$marcResult[0]->{'librarian'}= "";
		my @marcTags;
		my @found;
		my $indMarcTag=0;
		$id2=$row->{'id2'};
		$itemtype=$row->{'itemtype'};
		$tipoDoc=$row->{'tipo_documento'};
		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$librarian=&C4::AR::Busquedas::getLibrarian($campo, $subcampo,"" ,$itemtype,$tipo,1);

			$marcResult[$i]->{'campo'}= $campo;
			$marcResult[$i]->{'subcampo'}= $subcampo;
			$marcResult[$i]->{'dato'}= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		my $query="SELECT * FROM cat_nivel2_repetible WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		while (my $data=$sth->fetchrow_hashref){
			$librarian=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'},$itemtype,$tipo,1);
			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $librarian->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		$sth->finish;

		#Busca datos de nivel 3 solo del ID pasado por parametro
		my($marcResult3)=&C4::AR::Nivel3::detalleNivel3MARC($id3,$itemtype,$tipo);


#  		#agrego el nivel 1
		push (@marcResult, @$nivel1);
		#concateno el marcResult de nivel 2 con sus marcResult de nivel 3
 		push (@marcResult, @$marcResult3);

		@marcResult = sort {$a->{'campo'} cmp $b->{'campo'} 
						|| 
				$a->{'subcampo'} cmp $b->{'subcampo'}} (@marcResult);


		my $campoAnt;
		my $cant= scalar(@marcResult);
		my $ind= 0;
		my @marcResult2;
		my $fin= 0;
		my $i= 0;
		my $ind= 0;
		my $nombreCampo;
		my $cant= scalar(@marcResult);
#se agregan los encabezados MARC

		while ($i< $cant) {

			$campoAnt= $marcResult[$i]->{'campo'};
			$nombreCampo= &C4::AR::Catalogacion::buscarNombreCampoMarc($campoAnt);
 			$marcResult2[$ind]->{'campoMARC'}= $campoAnt;
 			$marcResult2[$ind]->{'nombreCampo'}= $nombreCampo;
			$ind++;

			while( ($campoAnt eq $marcResult[$i]->{'campo'}) && ($i < $cant) ){
				$campoAnt= @marcResult[$i]->{'campo'};

				$marcResult2[$ind]->{'campo'}= $marcResult[$i]->{'campo'};
				$marcResult2[$ind]->{'subcampo'}= $marcResult[$i]->{'subcampo'};
				$marcResult2[$ind]->{'dato'}= $marcResult[$i]->{'dato'};
				$marcResult2[$ind]->{'librarian'}= $marcResult[$i]->{'librarian'};

				$ind++;
				$i++;
			}
		}

		
		$results[$j]->{'marcResult'}= \@marcResult2;
		$results[$j]->{'id2'}=$id2;
		$results[$j]->{'itemtype'}=$itemtype;
		$results[$j]->{'tipoDoc'}=$tipoDoc;
		$j++;
	}

	return(@results);
}

=item
detalleNivel2OPAC
Busca todos los encabezados para los distintos tipo de documentos y toda la informacion de nivel2 para un id1 y devuelve el detalle de como se va a imprimir en el opac. (la visualización) 
=cut
sub detalleNivel2OPAC{
	my ($id1)=@_;
	my $n2itemtypes=&C4::AR::Busquedas::buscarItemtypes($id1);
	my ($encabezados_hash_ref)= &C4::AR::Busquedas::buscarEncabezados($n2itemtypes,2);
	my $nivel2Comp= &C4::AR::Busquedas::buscarNivel2EnMARC($id1);

	my $llave;
	my $dato;
	my $itemtype;
	my $linea;
	my $salidaLinea="";
	my @salida;
	my @salidaTMP;
	my @result;
	my $j=0;
	my $grupoInd=0;
	my $encInd= 0;
	my $id2;
	my $encabezados;


#recorro cada grupo
  	foreach my $nivel2 (@$nivel2Comp){
 		my @salidaTMP;
		
	
		$itemtype=$nivel2->{'itemtype'};
		my $infoEncabezados= $encabezados_hash_ref->{$itemtype};

		$id2= $nivel2->{'id2'};

		my $cant= scalar(@$infoEncabezados);

#proceso los encabezados
		for (my $i=0; $i < $cant; $i++){ 

			$linea= $infoEncabezados->[$i]->{'linea'};
 			my $info= $infoEncabezados->[$i]->{'result'};
			$salidaLinea= "";
			my @salida;
			$j=0;
	

#proceso un encabezado en particular
			foreach $llave (keys %$info){	
	
				$dato= $nivel2->{$llave};
				if($dato ne ""){
					$dato=~ s/\*\?\*/$info->{$llave}->{'separador'}/g;
					if($linea eq 0){
						$salida[$j]->{'librarian'}= $info->{$llave}->{'textpred'};
						$salida[$j]->{'dato'}= "<b>".$dato."</b>";
						$j++;
					}
					else{
						$salidaLinea .= $info->{$llave}->{'textpred'}." <b>".$dato." </b>".$info->{$llave}->{'textsucc'}." ".$info->{$llave}->{'separador'}." ";
					}

				}
				
			}
			
			if($linea eq 1){
				$salida[$j]->{'librarian'}= $info->{$llave}->{'textpred'};
				$salida[$j]->{'dato'}= $salidaLinea;	
				$j++;
			}

			$salidaTMP[$encInd]->{'resultado'}= \@salida;
			$salidaTMP[$encInd]->{'linea'}= $infoEncabezados->[$i]->{'linea'};
#si el encabezado no tiene info para mostrar no se muestra
			if($j != 0){$salidaTMP[$encInd]->{'encabezado'}= $infoEncabezados->[$i]->{'nombre'};}

			$encInd++;

		}#end foreach my $info_hash_ref
		$encInd=0;

		#se obtiene el detalle de nivel3 para un id2 en particular (grupo)
 		my($nivel3,$nivel3Comp)=&C4::AR::Nivel3::detalleNivel3OPAC($id2,$itemtype,'opac');
 		$result[$grupoInd]->{'loopnivel3'}=$nivel3;
 		$result[$grupoInd]->{'loopnivel3Comp'}=$nivel3Comp;	


 		$result[$grupoInd]->{'loopEncabezados'}= \@salidaTMP;
		$result[$grupoInd]->{'grupo'}= $grupoInd;
		$result[$grupoInd]->{'DivMARC'}="MARCDetail".$grupoInd;
		$result[$grupoInd]->{'DivDetalle'}="Detalle".$grupoInd;
		$grupoInd++;

	
	print A "\n";
	
  	}#end foreach my $nivel2
	return @result;
}

=item
detalleNivel2
Trae todos los datos del nivel 2, para poder verlos en el template, tambien busca el detalle del nivel 3 asociados a cada nivel 2.
@params 
$id1, id de nivel1
$tipo, INTRA/OPAC
=cut
sub detalleNivel2{
	my($id1,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my @nivel2=&C4::AR::Catalogacion::buscarNivel2PorId1($id1);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel2');
	my $id2;
	my $itemtype;
	my $tipoDoc;
	my $campo;
	my $subcampo;
	my $isbn;
	my @results;
	my $getLib;
	my $j=0;
	foreach my $row(@nivel2){
		my $i=0;
		my @nivel2Comp;
		my %llaves;
		$id2=$row->{'id2'};
		$itemtype=$row->{'itemtype'};
		$tipoDoc=$row->{'tipo_documento'};
		foreach my $llave (keys %$mapeo){

			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$getLib=&C4::AR::Busquedas::getLibrarian($campo, $subcampo,"" ,$itemtype,$tipo,0);
			$nivel2Comp[$i]->{'campo'}=$campo;
			$nivel2Comp[$i]->{'subcampo'}=$subcampo;
			$nivel2Comp[$i]->{'dato'}=$row->{$mapeo->{$llave}->{'campoTabla'}};
 			my $dato=$row->{$mapeo->{$llave}->{'campoTabla'}};
			$nivel2Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		my $query="SELECT * FROM cat_nivel2_repetible WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		my $llave2;
		while (my $data=$sth->fetchrow_hashref){
			
			#Necesito el  ISBN para recuperar la foto
			if (($data->{'campo'} eq '020' )and($data->{'subcampo'} eq 'a')) {$isbn=$data->{'dato'};}
			#

			$llave2=$data->{'campo'}.",".$data->{'subcampo'};
			$getLib=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,$tipo,0);
			if(not exists($llaves{$llave2})){
				$llaves{$llave2}=$i;
				$nivel2Comp[$i]->{'campo'}=$data->{'campo'};
				$nivel2Comp[$i]->{'subcampo'}=$data->{'subcampo'};
				$nivel2Comp[$i]->{'dato'}=$getLib->{'dato'};
				$nivel2Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
				$i++;
			}
			else{
				my $separador=" ".$getLib->{'separador'}." " ||", ";
				my $pos=$llaves{$llave2};
				$nivel2Comp[$pos]->{'dato'}.=$separador.$getLib->{'dato'};
			}
		}
		$sth->finish;
		$nivel2Comp[$i]->{'cantItems'}=$row->{'cantItems'};
		my($nivel3,$nivel3Comp)=&C4::AR::Nivel3::detalleNivel3($id2,$itemtype,$tipo);
	

		$nivel2Comp[$i]->{'loopnivel3'}=$nivel3;
		$nivel2Comp[$i]->{'loopnivel3Comp'}=$nivel3Comp;
		$results[$j]->{'resultado'}=\@nivel2Comp;
		$results[$j]->{'id2'}=$id2;
		$results[$j]->{'itemtype'}=$itemtype;
		$results[$j]->{'tipoDoc'}=$tipoDoc;
		
		#Busco si tenemos la imagen de la tapa para mostrar
		my $url = &C4::AR::Amazon::getCover($isbn,'medium');
		$results[$j]->{'amazon_cover'}="amazon_covers/".$url;
		$isbn=''; #Blanqueo la isbn
		#

		$j++;
	}
	return(@results);
}


=item
retorna la canitdad de items prestados para el grupo pasado por parametro
=cut
sub getCantPrestados{

	my ($id2)=@_;
	my $dbh = C4::Context->dbh;
	
	my $query= " 	SELECT count(*) AS cantPrestamos
			FROM  circ_prestamo i LEFT JOIN cat_nivel3 n3 ON n3.id3 = i.id3
			INNER JOIN  cat_nivel2 n2 ON n3.id2 = n2.id2
			WHERE n2.id2 = ? AND i.returndate IS NULL ";

	my $sth=$dbh->prepare($query);
	$sth->execute($id2);

	return $sth->fetchrow;
}

=item
Esta funcion restorna el tipo de documento del grupo (segun id2)
=cut
sub getTipoDocumento{
	my ($id2)=@_;
	my $dbh = C4::Context->dbh;
	
	my $query= " 	SELECT i.description
			FROM nivel2 n2 INNER JOIN cat_ref_tipo_nivel3 i
			ON (n2.tipo_documento = i.itemtype)
			WHERE id2 = ? ";

	my $sth=$dbh->prepare($query);
	$sth->execute($id2);

	return $sth->fetchrow;

}


sub t_deleteGrupo {
	my($params)=@_;

## FIXME
#se realizan las verificaciones antes de eliminar el GRUPO, reservas sobre el grupo o items
#y realizar todos los logueos necesarios luego de borrar
# FALTA VER SI TIENE EJEMPLARES RESERVADOS O PRESTADOS EN ESE CASO NO SE TIENE QUE ELIMINAR

#Ademas faltaria ver si se deben realizar borrados en cascada, por ej de historicCirculation, donde se 
#esta guardando el id2 y este ya no tiene sentido guardarlo
	
	my ($error,$codMsg,$paraMens);

	my $error= 0;
	if(!$error){
	#No hay error
		my $dbh = C4::Context->dbh;
		$dbh->{AutoCommit} = 0;  # enable transactions, if possible
		$dbh->{RaiseError} = 1;
		eval {
			deleteGrupo($params->{'id2'});	
			$dbh->commit;
	
			$codMsg= 'M902';
			$paraMens->[0]= $params->{'id2'};
	
		};

		if ($@){
			#Se loguea error de Base de Datos
			$codMsg= 'B413';
			&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'U306';
			$paraMens->[0]= $params->{'id2'};
		}
		$dbh->{AutoCommit} = 1;
		
	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}


=item
deleteGrupo
Elimina toda la informacion de un item para el nivel 2
=cut

## FIXME No se puede eliminar el grupo si se encuentra logueado en la tabla de historicCirculation
#se podria elimnar la contraint de FK...., y solo verificar q id2 no sea null, de todos modos una vez
#borrado el grupo, el id2 ya no tiene mas sentido, asi que se podria realizar un borrado en cascada

# [Tue Sep 09 15:14:07 2008] [error] [client 127.0.0.1] DBD::mysql::st execute failed: Cannot delete or update a parent row: a foreign key constraint fails (`V2/historicCirculation`, CONSTRAINT `FK_historicCirculation_id2` FOREIGN KEY (`id2`) REFERENCES `nivel2` (`id2`)) at /usr/local/koha/intranet/modules/C4/AR/Nivel2.pm line 493., referer: https://127.0.0.1/cgi-bin/koha/busquedas/detalle.pl


sub deleteGrupo{
	my($id2)=@_;

	my $dbh = C4::Context->dbh;
	
	my $query="SELECT id2,id3 FROM cat_nivel3 WHERE id2 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);
	while(my $data= $sth->fetchrow_hashref){
		my $query="DELETE FROM cat_nivel3_repetible WHERE id3 = ?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($data->{'id3'});
	}
	my $query="DELETE FROM cat_nivel3 WHERE id2 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);

	my $query="DELETE FROM cat_nivel2_repetible WHERE id2 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);
	
	my $query="DELETE FROM cat_nivel2 WHERE id2 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);

}


=item
saveNivel2
Guarda los campo del nivel 2
Los parametros que reciben son: $itemType el tipo de item que es; $id1 es el id de la fila insertada para ese item en la tabla nivel1; $ids es la referencia a un arreglo que tiene los ids de los inputs de la interface que es un string compuesto por el campo y subcampo; $valores es la referencia a un arreglo que tiene los valores de los inputs de la interface.
=cut
sub saveNivel2{
	my ($id1,$nivel2)=@_;
	my $query1="";
	my $query2="";
	my @bind1=();
	my @bind2=();
	my $query3="SELECT MAX(id2) FROM cat_nivel2";#PARA RECUPERAR LA TUPLA QUE SE INGRESA.
	my $nivelBiblio="";
	my $tipoDoc="";
	my $soporte="";
	my $fecha="";
	my $ciudad="";
	my $lenguaje="";
	my $pais="";
	foreach my $obj(@$nivel2){
		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $valor=$obj->{'valor'};
		
		if($campo eq '910' && $subcampo eq 'a'){
			$tipoDoc=$valor;
		}
		elsif($campo eq '260' && $subcampo eq 'c' && $fecha eq ""){
			#Repetibles!!!
			$fecha=$valor ;
		}
		elsif($campo eq '260' && $subcampo eq 'a' && $ciudad eq ""){
			$ciudad=$valor ;
		}
		elsif($campo eq '041' && $subcampo eq 'h' && $lenguaje eq ""){
			#Repetibles!!!
			$lenguaje=$valor ;
		}
		elsif($campo eq '043' && $subcampo eq 'c' && $pais eq ""){
			#Repetibles!!!
			$pais=$valor ;
		}
		elsif($campo eq '245' && $subcampo eq 'h'){
			$soporte=$valor ;
		}
		elsif($campo eq '900' && $subcampo eq 'b'){
			$nivelBiblio=$valor;
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
	$query1="INSERT INTO cat_nivel2 (tipo_documento,id1,nivel_bibliografico,soporte,pais_publicacion,lenguaje,ciudad_publicacion,anio_publicacion) VALUES (?,?,?,?,?,?,?,?)";
	push (@bind1,$tipoDoc,$id1,$nivelBiblio,$soporte,$pais,$lenguaje,$ciudad,$fecha);
	if($query2 ne ""){
		$query2=substr($query2,1,length($query2));
		$query2="INSERT INTO cat_nivel2_repetible (campo,subcampo,id2,dato) VALUES ".$query2;
	}
	my ($id2,$error,$codMsg) =&C4::AR::Catalogacion::transaccion($query1,\@bind1,$query2,\@bind2,$query3);
	return($id2,$tipoDoc,$error,$codMsg);

}

#=======================================================================ABM Nivel 1=======================================================


sub t_guardarNivel2 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $id2;
    my $catNivel2;

    if(!$msg_object->{'error'}){
    #No hay error
		$catNivel2= C4::Modelo::CatNivel2->new();
        my $db= $catNivel2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel2->agregar($params);  
            $db->commit;
            $id2 = $catNivel2->getId2;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U369', 'params' => [$catNivel2->getId2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B428',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U372', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $catNivel2);
}

sub t_modificarNivel2 {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();
    my $id2;
    my $catNivel2;

    if(!$msg_object->{'error'}){
    #No hay error
		$catNivel2= C4::Modelo::CatNivel2->new(id2 => $params->{'id2'});
		$catNivel2->load();
		$params->{'modificado'}=1;
        my $db= $catNivel2->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
         $db->begin_work;
    
        eval {
            $catNivel2->agregar($params);  
            $db->commit;
            $id2 = $catNivel2->getId2;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U381', 'params' => [$catNivel2->getId2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B431',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U384', 'params' => [$catNivel2->getId2]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object, $catNivel2);
}



sub t_eliminarNivel2{
   
   my($id2)=@_;
   
   my $msg_object= C4::AR::Mensajes::create();

# FIXME falta verificar si es posible eliminar el nivel 2

    if(!$msg_object->{'error'}){
    #No hay error
        my  $catNivel2= C4::Modelo::CatNivel2->new(id2 => $id2);
            $catNivel2->load;
		my $id2= $catNivel2->getId2;
        my $db= $catNivel2->dbh;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    
        eval {
            $catNivel2->eliminar;  
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U375', 'params' => [$id2]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B429',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U378', 'params' => [$id2]} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);

}

#===================================================================Fin====ABM Nivel 1====================================================