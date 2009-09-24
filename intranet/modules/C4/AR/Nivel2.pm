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
		
		&detalleNivel2
		&detalleNivel2MARC
		&detalleNivel2OPAC
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
# FIXME DEPRECATED
sub getEdicion {
	my ($id2) = @_;
	
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"250","a","2");
}

=item
Esta funcion retorna el volumen segun un id2
=cut
# FIXME DEPRECATED
sub getVolume {
	my($id2)= @_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"740","n","2");
}

=item
Esta funcion retorna la descripcion del volumen segun un id2
=cut
# FIXME DEPRECATED
sub getVolumeDesc {
	my($id2)= @_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"740","a","2");
}

=item
retorna el primer isbn del grupo con correpondiente al parametro $id2
=cut
# FIXME DEPRECATED
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

	my $cantPrestamos_count = C4::Modelo::CircPrestamo::Manager->get_circ_prestamo_count(
                                                               	query => [ 	't2.id2' => { eq => $id2 },
 																			fecha_devolucion => { eq => undef }  
																		 ],
																require_objects => ['nivel3.nivel2'],
																with_objects => ['nivel3'],
										);

# 	C4::AR::Debug::debug("C4::AR::Nivel2::getCantPrestados ".$cantPrestamos_count);


	return $cantPrestamos_count;
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



=item
Recupero todos los nivel 2 a partir de un id1
=cut
sub getNivel2FromId1{
	my ($id1) = @_;

	my $nivel2_array_ref = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(   
															query => [ 
																		id1 => { eq => $id1 },
																], 
										);

    return $nivel2_array_ref;
}

=item
Recupero un nivel 2 a partir de un id2
retorna un objeto o 0 si no existe
=cut
sub getNivel2FromId2{
	my ($id2) = @_;

	my $nivel2_array_ref = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(   
																							query => [ 
																										id2 => { eq => $id2 },
																								], 
																);

	if( scalar(@$nivel2_array_ref) > 0){
		return ($nivel2_array_ref->[0]);
	}else{
		return (0);
	}
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

    my ($catNivel2) = getNivel2FromId2($params->{'id2'});

    if(!$catNivel2){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U403', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
		
		$params->{'modificado'} = 1;
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
            $db->rollback;
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