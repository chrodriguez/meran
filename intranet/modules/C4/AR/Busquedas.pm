package C4::AR::Busquedas;

#Copyright (C) 2003-2008  Linti, Facultad de Inform�tica, UNLP
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
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;
use C4::AR::Reservas;
use C4::AR::Nivel1;
use C4::AR::Nivel2;
use C4::AR::Nivel3;
use C4::AR::PortadasRegistros;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		&busquedaAvanzada
		&busquedaCombinada

		&obtenerEdiciones
		&obtenerGrupos
		&obtenerDisponibilidadTotal

		&buscarMapeo
		&buscarMapeoTotal
		&buscarMapeoCampoSubcampo
		&buscarCamposMARC
		&buscarSubCamposMARC
		&buscarAutorPorCond
		&buscarDatoDeCampoRepetible
		&buscarTema

        &filtrarPorAutor
		&MARCDetail
	
		&getLibrarian
		&getautor
		&getLevel
		&getLevels
		&getCountry
		&getCountryTypes
		&getSupport
		&getSupportTypes
		&getLanguage
		&getLanguages
		&getItemType
		&getItemTypes
		&getborrowercategory
		&getAvail
		&getAvails
		&getTema
		&getNombreLocalidad
		&getBranches
		&getBranch

		&t_loguearBusqueda
);

=item
buscarDatoReferencia
Busca el valor del dato que viene de referencia. Es un id que apunta a una tupla de una tabla y se buscan los campos que el usuario introdujo para que se vean. Se concatenan con el separador que el mismo introdujo.
=cut
sub buscarDatoReferencia{
	my ($dato,$tabla,$campos,$separador)=@_;
	
	my $ident=C4::AR::Utilidades::obtenerIdentTablaRef($tabla);

	my $dbh = C4::Context->dbh;
	my @camposArr=split(/,/,$campos);
	my $i=0;
	my $strCampos="";
	foreach my $camp(@camposArr){
		$strCampos.=", ".$camp . " AS dato".$i." ";
		$i++;
	}
	$strCampos=substr($strCampos,1,length($strCampos));
	my $query=" SELECT ".$strCampos;
	$query .= " FROM ".$tabla;
	$query .= " WHERE ".$ident." = ?";

	my $sth=$dbh->prepare($query);
   	$sth->execute($dato);
	my $data=$sth->fetchrow_hashref;
	$strCampos="";
	my $llave;
	for(my $j=0;$j<$i;$j++){
		$llave="dato".$j;
		$strCampos.=$separador.$data->{$llave};
	}
	
	if ($separador ne ''){ #Si existe un separador quito el 1ro que esta de mas
		$strCampos=substr($strCampos,1,length($strCampos));
	}
	return($strCampos);
}

=item
getLibrarianEstCat
trae el texto para mostrar (librarian), segun campo y subcampo, sino exite, devuelve 0
=cut
sub getLibrarianEstCat{
	my ($campo, $subcampo,$dato, $itemtype)= @_;

	my $dbh = C4::Context->dbh;
	my $query = "SELECT ec.*,ir.idinforef, ir.referencia as tabla, campos, separador, orden";
	$query .= " FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ";
	$query .= " ON (ec.id = ir.idestcat) ";
	$query .= " WHERE(ec.campo = ?)and(ec.subcampo = ?)and(ec.itemtype = ?) ";

	my $sth=$dbh->prepare($query);
   	$sth->execute($campo, $subcampo, $itemtype);
	my $nuevoDato;
	my $data=$sth->fetchrow_hashref();

	if($data && $data->{'visible'}){
		if($data->{'referencia'} && $dato ne ""){
		#DA ERROR FIXME	
		#$nuevoDato=&buscarDatoReferencia($dato,$data->{'tabla'},$data->{'campos'},$data->{'separador'});
			$data->{'dato'}=$nuevoDato;
		}
		else{
			$data->{'dato'}=$dato;
		}
	}
	else{
		$data->{'liblibrarian'}=0;
		$data->{'dato'}="";
		$data->{'visible'}=0;
		
	}
#0 si no trae nada
	return $data;
}

=item
getLibrarianEstCatOpac
trae el texto para mostrar (librarian), segun campo y subcampo, sino exite, devuelve 0
=cut
sub getLibrarianEstCatOpac{
	my ($campo, $subcampo, $dato, $itemtype)= @_;

	my $dbh = C4::Context->dbh;

# open(A, ">>/tmp/debug.txt");
# print A "\n";
# print A "entro a getLibrarianEstCatOpac \n";
# print A "*************************************************************************\n";
# print A "campo: $campo \n";
# print A "subcampo: $subcampo \n";
# print A "itemtype: $itemtype \n";
# print A "dato: $dato \n";

my $query = " SELECT * ";
$query .= " FROM cat_estructura_catalogacion_opac eco INNER JOIN";
$query .= " cat_encabezado_item_opac eio ";
$query .= " ON (eco.idencabezado = eio.idencabezado) ";
$query .= " WHERE(eco.campo = ?)and(eco.subcampo = ?) and (visible = 1) ";
$query .= " and (eio.itemtype = ?)";

	my $sth=$dbh->prepare($query);
	$sth->execute($campo, $subcampo, $itemtype);
    	my $data1=$sth->fetchrow_hashref;

	my $data;
	my $textPred;
	my $textSucc;

	if($data1){

		$textPred= $data1->{'textpred'};
		$textSucc= $data1->{'textsucc'};

		my $dbh = C4::Context->dbh;
		my $query = "SELECT ec.*, ir.idinforef, ir.referencia as tabla, campos, separador, orden";
		$query .= " FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ";
		$query .= " ON (ec.id = ir.idestcat) ";
		$query .= " WHERE(ec.campo = ?)and(ec.subcampo = ?)and(ec.itemtype = ?) ";

		my $sth=$dbh->prepare($query);
   		$sth->execute($campo, $subcampo, $itemtype);
		my $nuevoDato;
		$data=$sth->fetchrow_hashref();

		if($data->{'referencia'} && $dato ne ""){
		  $nuevoDato=&buscarDatoReferencia($dato,$data->{'tabla'},$data->{'campos'},$data->{'separador'});
# print A "dato nuevo **************************************** $nuevoDato \n";
		  $data->{'dato'}= $nuevoDato;
		  $data->{'textPred'}= $textPred;
		  $data->{'textSucc'}= $textSucc;
#  		  return $textPred." ".$nuevoDato;
		  return $data;
# 		  return $nuevoDato;

		}
		else{
		  $data->{'dato'}= $dato;
		  $data->{'textPred'}= $textPred;
		  $data->{'textSucc'}= $textSucc;
# print A "dato **************************************** $dato \n";
# print A "textpred **************************************** $textPred \n";
# 		  return $textPred." ";
		  return $data;
		}
		
# 		return $textPred." ".$data->{'dato'}." ".$textSucc;
#  		return $textPred." ";

	}
	else {
		$data->{'dato'}= "";
		$data->{'textPred'}= "";
		$data->{'textSucc'}= "";
		return $data;
# 		return 0;
	}
# close(A);

#0 si no trae nada
#  	return $sth->fetchrow_hashref; 
}


=item
getLibrarianMARCSubField
trae el texto para mostrar (librarian), segun campo y subcampo, sino exite, devuelve 0
=cut
sub getLibrarianMARCSubField{
	my ($campo, $subcampo)= @_;
	my $dbh = C4::Context->dbh;

	my $query = " SELECT * ";
	$query .= " FROM pref_estructura_subcampo_marc ";
	$query .= " WHERE (campo = ? )and(subcampo = ?)";

	my $sth=$dbh->prepare($query);
   	$sth->execute($campo, $subcampo);

	return $sth->fetchrow_hashref;
}

=item
getLibrarianIntra
Busca para un campo y subcampo, dependiendo el itemtype, como esta catalogado para mostrar en el template. Busca en la tabla estructura_catalogacion y sino lo encuentra lo busca en marc_subfield_structure que si o si esta.
=cut
sub getLibrarianIntra{
	my ($campo, $subcampo,$dato, $itemtype,$detalleMARC) = @_;

#busca librarian segun campo, subcampo e itemtype
	my $librarian= &getLibrarianEstCat($campo, $subcampo, $dato,$itemtype);

#si no encuentra, busca para itemtype = 'ALL'
	if(!$librarian->{'liblibrarian'}){
		$librarian= &getLibrarianEstCat($campo, $subcampo, $dato,'ALL');
	}
	
	if($librarian->{'liblibrarian'} && !$librarian->{'visible'} && !$detalleMARC){
		#Si esta catalogado y pero no esta visible retorna 0 para que no se vea el dato
		$librarian->{'liblibrarian'}=0;
		$librarian->{'dato'}="";
		return $librarian;
	}
	elsif(!$librarian->{'liblibrarian'}){
		$librarian= &getLibrarianMARCSubField($campo, $subcampo);
		$librarian->{'dato'}=$dato;
	}
	return $librarian;
}

=item
getLibrarianOpac
Busca para un campo y subcampo, dependiendo el itemtype, como esta catalogado para mostrar en el template. Busca en la tabla estructura_catalogacion_opac y sino lo encuentra lo busca en marc_subfield_structure que si o si esta.
=cut
sub getLibrarianOpac{
	my ($campo, $subcampo,$dato, $itemtype,$detalleMARC) = @_;
	my $textPred;	
	my $textSucc;
#busca librarian segun campo, subcampo e itemtype
	my $librarian= &getLibrarianEstCatOpac($campo, $subcampo, $dato, $itemtype);
#si no encuentra, busca para itemtype = 'ALL'
 	if(!$librarian){
 		$librarian= &getLibrarianEstCatOpac($campo, $subcampo, $dato, 'ALL');
 	}
	elsif($detalleMARC){
		$librarian= &getLibrarianMARCSubField($campo, $subcampo);
		$librarian->{'dato'}=$dato;
	}


	return $librarian;
}

sub getLibrarian{
	my ($campo, $subcampo,$dato,$itemtype,$tipo,$detalleMARC)=@_;
	my $librarian;
	if($tipo eq "intra"){
		$librarian=&getLibrarianIntra($campo, $subcampo,$dato, $itemtype,$detalleMARC);
	}else{
		$librarian=&getLibrarianOpac($campo, $subcampo,$dato, $itemtype,$detalleMARC);
	} 
	return $librarian;
}

=item
buscarMapeo
Asocia los campos marc correspondientes con los campos de las tablas de los nivel 1, 2 y 3 (koha) correspondiente al parametro que llega.
=cut
sub buscarMapeo{
	my ($tabla)= @_;
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM cat_pref_mapeo_koha_marc WHERE tabla = ? ";
	
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla);
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		$mapeo{$llave}->{'campo'}=$data->{'campo'};
		$mapeo{$llave}->{'subcampo'}=$data->{'subcampo'};
		$mapeo{$llave}->{'tabla'}=$data->{'tabla'};
		$mapeo{$llave}->{'campoTabla'}=$data->{'campoTabla'};
	}
	return (\%mapeo);
}

=item
buscarMapeoTotal
Busca el mapeo de los campos de todas las tablas de niveles y obtiene el nombre de los campos
=cut
sub buscarMapeoTotal{
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM cat_pref_mapeo_koha_marc WHERE tabla like 'cat_nivel%' ORDER BY tabla";
	
	my $sth=$dbh->prepare($query);
	$sth->execute();
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		$mapeo{$llave}->{'campo'}=$data->{'campo'};
		$mapeo{$llave}->{'subcampo'}=$data->{'subcampo'};
		$mapeo{$llave}->{'tabla'}=$data->{'tabla'};
		$mapeo{$llave}->{'campoTabla'}=$data->{'campoTabla'};
		$mapeo{$llave}->{'nombre'}=$data->{'nombre'};
	}
	return (\%mapeo);
}

sub buscarMapeoCampoSubcampo{
	my ($campo,$subcampo,$nivel)=@_;
	my $dbh = C4::Context->dbh;
	my $tabla="nivel".$nivel;
	my $campoTabla=0;
	my $query = " SELECT campoTabla FROM cat_pref_mapeo_koha_marc WHERE tabla =? AND campo=? AND subcampo=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla,$campo,$subcampo);
	if(my $data=$sth->fetchrow_hashref){
		$campoTabla=$data->{'campoTabla'};
	}
	return $campoTabla;
}

=item
buscarSubCamposMapeo
Busca el mapeo para el subcampo perteneciente al campo que se pasa por parametro.
=cut
sub buscarSubCamposMapeo{
	my ($campo)=@_;
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM cat_pref_mapeo_koha_marc WHERE tabla like 'cat_nivel%' AND campo = ?";
	
	my $sth=$dbh->prepare($query);
	$sth->execute($campo);
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		$mapeo{$llave}->{'subcampo'}=$data->{'subcampo'};
		$mapeo{$llave}->{'tabla'}=$data->{'tabla'};
	}
	return (\%mapeo);
}


=item
obtenerEdiciones
obtiene las ediciones que pose un id de nivel 1.
=cut
sub obtenerEdiciones{
	my ($id1,$itemtype)=@_;
	my @ediciones;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel2 WHERE id1=? ";

	if($itemtype != -1 && $itemtype ne "" && $itemtype ne "ALL"){
		$query .=" and tipo_documento = '".$itemtype."'";
	}

	my $sth=$dbh->prepare($query);
	$sth->execute($id1);
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		$ediciones[$i]->{'anio_publicacion'}=$data->{'anio_publicacion'};
		$i++;
	}
	return(@ediciones);
}

=item
obtenerGrupos
Esta funcion devuelve los datos de los grupos a mostrar en una busaqueda dado un id1. Se puede filtrar por tipo de documento.
=cut
# FIXME falta pasar!!!!
sub obtenerGrupos {
	my ($id1,$itemtype,$type)=@_;
  	my $dbh = C4::Context->dbh;
  	my $query="SELECT * FROM cat_nivel2 LEFT JOIN cat_nivel1 ON cat_nivel1.id1=cat_nivel2.id1 WHERE cat_nivel2.id1=?";
	my @bind;
	push(@bind,$id1);
  	if($itemtype != -1 && $itemtype ne "" && $itemtype ne "ALL"){
		$query .=" AND cat_nivel2.tipo_documento = ?";
		push(@bind,$itemtype);
	}

  	my $sth=$dbh->prepare($query);
  	$sth->execute(@bind);
  	my @result;
  	my $res=0;
  	my $data;
	my $opacUnavail= C4::AR::Preferencias->getValorPreferencia("opacUnavail");

  	while ( $data=$sth->fetchrow_hashref){
		my $query2="SELECT COUNT(*) AS cant FROM cat_nivel3 n3 WHERE n3.id2 = ?";
#  		if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
		if (($type ne 'intra')&&($opacUnavail eq 0)){
    			$query2.=" AND (id_estado=0 OR id_estado IS NULL  OR id_estado=2)"; #wthdrawn=2 es COMPARTIDO
  		}

		my $sth2=$dbh->prepare($query2);
  		$sth2->execute($data->{'id2'});
		my $cant=($sth2->fetchrow);

		if ( $cant > 0){
        		$result[$res]->{'id2'}=$data->{'id2'};
			$result[$res]->{'cant'}=$cant;
#         		$result[$res]->{'edicion'}= &C4::AR::Nivel2::getEdicion($data->{'id2'});
        		$result[$res]->{'anio_publicacion'}=$data->{'anio_publicacion'};
#         		$result[$res]->{'volume'}= C4::AR::Nivel2::getVolume($data->{'id2'});
        		$res++;
		}
	}

	return (\@result);
}


sub obtenerDisponibilidadTotal{
	my ($id1,$itemtype)=@_;

	my @disponibilidad;
	my $dbh = C4::Context->dbh;
	my $query="SELECT count(*) as cant, id_disponibilidad FROM cat_nivel3 WHERE id1=? ";
	my $sth;

	if($itemtype == -1 || $itemtype eq "" || $itemtype eq "ALL"){
	  $query .=" GROUP BY id_disponibilidad";
	
	  $sth=$dbh->prepare($query);
	  $sth->execute($id1);
	}else{#Filtro tb por tipo de item
	  $query .= " AND id2 IN ( SELECT id2 FROM cat_nivel2 WHERE tipo_documento = ? )  GROUP BY id_disponibilidad";

	  $sth=$dbh->prepare($query);
	  $sth->execute($id1, $itemtype);
	}
	
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
	#DOMICILIO
		if($data->{'id_disponibilidad'} == 0){
			$disponibilidad[$i]->{'tipoPrestamo'}="Para Domicilio:";
			$disponibilidad[$i]->{'prestados'}="Prestados: ";
			$disponibilidad[$i]->{'prestados'}.= C4::AR::Prestamos::getCountPrestamosDelRegistro($id1);
			$disponibilidad[$i]->{'reservados'}="Reservados: ".C4::AR::Reservas::cantReservasPorNivel1($id1);
		}
		else{
	#PARA SALA
			$disponibilidad[$i]->{'tipoPrestamo'}="Para Sala:";
		}

		$disponibilidad[$i]->{'cantTotal'}=$data->{'cant'};
		$i++;
	}
	return(@disponibilidad);
}


#****************************************************MARC DETAIL**************************************************


=item
buscarCamposMARC
Busca los campos correspondiente a el parametro campoX, para ver en el tmpl de filtradoAvanzado.
=cut
sub buscarCamposMARC{
	my ($campoX) =@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT DISTINCT nivel,campo FROM pref_estructura_subcampo_marc ";
	$query .=" WHERE nivel > 0 AND campo LIKE ? ORDER BY nivel";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($campoX."%");
	my @results;
	my $nivel;
	while(my $data=$sth->fetchrow_hashref){
		$nivel="n".$data->{'nivel'}."r";
		push (@results,$nivel."/".$data->{'campo'});
	}
	$sth->finish;
	return (@results);
}

=item
buscarSubCamposMARC
Busca los subcampos correspondiente al parametro de campo y que no sean propios de una tabla de nivel, solo los que estan en tablas de nivel repetibles.
=cut
sub buscarSubCamposMARC{
	my ($campo) =@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT subcampo FROM pref_estructura_subcampo_marc ";
	$query .=" WHERE nivel > 0 AND campo = ? ";
	my $mapeo=&buscarSubCamposMapeo($campo);
	foreach my $llave (keys %$mapeo){
		$query.=" AND (subcampo <> '".$mapeo->{$llave}->{'subcampo'}."' ) ";
	}
	my $sth=$dbh->prepare($query);
        $sth->execute($campo);
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'subcampo'});
	}

	$sth->finish;
	return (@results);
}


=item
buscarItemtypes
Busca los distintos tipos de documentos que tiene una tupla del nivel1, se pasa como parametro el id1 de la misma.
=cut
sub buscarItemtypes{
	my ($id1)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT DISTINCT tipo_documento FROM cat_nivel2 WHERE id1=?";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	my @results;
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		$results[$i]=$data->{'tipo_documento'};
		$i++;
	}
	$sth->finish;
	return (\@results);
}

=item
buscarEncabezados
Busca los encabezados correspondientes a los tipos de documentos que llegan por parametro y para un determinado nivel.
=cut
sub buscarEncabezados{
	my ($itemtypes,$nivel)= @_;
	my %encabezados;
	my $linea;
	my $nombre;
	my $orden;
	my $llave;
open(A,">>/tmp/debug.txt");
print A "************************************************************************************************* \n";
print A "desde buscar encabezado \n";

#NO LOS TRAE EN ORDEN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
#PQ DEBERIAMOS TRAER TODOS LOS ENCABEZADOS SEGUN UN TIPO DE ITEM!!!!!!!!!!!!!!!!!!!!!1
#ordeno el resultado del arreglo por tipo de item
	my $query2="	SELECT *
			FROM cat_estructura_catalogacion_opac estco INNER JOIN cat_encabezado_campo_opac eco
			ON (estco.idencabezado = eco.idencabezado)
			WHERE estco.visible = 1 AND estco.idencabezado = ? AND nivel=? ";
# 			ORDER BY eco.orden ";

  	foreach my $itemtype (@$itemtypes){
		my @infoEncabezado;
	#busca los idencabezado para un tipo de item
		my $dbh = C4::Context->dbh;
		my $query="SELECT * FROM cat_encabezado_item_opac WHERE itemtype=?";
		my $sth=$dbh->prepare($query);
		$sth->execute($itemtype);

print A "---------------------------Encabezado para itemtype: ".$itemtype."----------------------------- \n";
	#se procesa cada idencabezado
		while(my $data=$sth->fetchrow_hashref){#while de query
			my $sth2=$dbh->prepare($query2);
			$sth2->execute($data->{'idencabezado'},$nivel);
			my %result;
			my %infoEnca;
			while(my $data2=$sth2->fetchrow_hashref){#while de query2
 				$linea= $data2->{'linea'};
 				$nombre= $data2->{'nombre'};
				$orden= $data2->{'orden'};
# print A "encabezado dentro de while: ".$nombre."\n";
# print A "linea : $linea \n";
				$llave=$data2->{'campo'}.",".$data2->{'subcampo'};
print A "llave: $llave\n";
				$result{$llave}->{'textpred'}=$data2->{'textpred'};
				$result{$llave}->{'textsucc'}=$data2->{'textsucc'};
				$result{$llave}->{'separador'}=$data2->{'separador'};
			}
			$sth2->finish;
			#Llenados de datos del encabezado.
			$infoEnca{'linea'}= $linea;
			$infoEnca{'orden'}= $orden;
# print A "encabezado q se asigna: ".$nombre."\n";
			$infoEnca{'nombre'}= $nombre;
			$infoEnca{'result'}= \%result;

			push(@infoEncabezado, \%infoEnca);
		}
		#ordeno el arreglo encabezados de tipos de items segun orden
		@infoEncabezado = sort { $a->{'orden'} cmp $b->{'orden'} } (@infoEncabezado);
# print A "guardo info para itemtype: ".$itemtype."\n";
		#se guarda el arreglo con todos los encabezados para un tipo de documento
		$encabezados{$itemtype}= \@infoEncabezado;
print A "**************************************************************************************** \n";
	}
	return \%encabezados;
close(A);
}

=item
buscarNivel2EnMARC
Busca los datos de la tabla nivel2 y nivel2_repetibles y los devuelve en formato MARC (campo,subcampo,dato).
=cut
sub buscarNivel2EnMARC{
	my ($id1)=@_;
# open(A, ">>/tmp/debug.txt");
# print A "\n";
# print A "desde buscarNivel2EnMARC \n";
	my $dbh = C4::Context->dbh;
	my @nivel2=&buscarNivel2PorId1($id1);
	my $mapeo=&buscarMapeo('cat_nivel2');
	my $id2;
	my $itemtype;
	my $llave;
	my $i=0;
	my $dato;
	my @nivel2Comp;
	foreach my $row(@nivel2){
		$id2=$row->{'id2'};
		$itemtype=$row->{'itemtype'};
		$nivel2Comp[$i]->{'id2'}=$id2;
# print A "			fila: ".$i."\n";
# print A "			id2: ".$id2."\n";
# print A "			itemtype: ".$itemtype."\n";
		$nivel2Comp[$i]->{'itemtype'}=$itemtype;
		foreach my $llave (keys %$mapeo){
			$dato= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$nivel2Comp[$i]->{$llave}=$dato;
# print A "llave ".$llave."\n";
# print A "dato ".$dato."\n";
			$nivel2Comp[$i]->{'campo'}= $mapeo->{$llave}->{'campo'};
			$nivel2Comp[$i]->{'subcampo'}= $mapeo->{$llave}->{'subcampo'};
# 			$i++;
		}
		my $query="SELECT * FROM cat_nivel2_repetible WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		while (my $data=$sth->fetchrow_hashref){
			$llave=$data->{'campo'}.",".$data->{'subcampo'};

			$nivel2Comp[$i]->{'campo'}= $data->{'campo'};
			$nivel2Comp[$i]->{'subcampo'}= $data->{'subcampo'};

			if(not exists($nivel2Comp[$i]->{$llave})){
				$nivel2Comp[$i]->{$llave}= $data->{'dato'};#FALTA BUSCAR REFERENCIA SI ES QUE TIENE!!!!
			}
			else{
				$nivel2Comp[$i]->{$llave}.= " *?* ".$data->{'dato'};
			}
# 			$i++;
# print A "llave ".$llave."\n";
# print A "dato ".$data->{'dato'}."\n";
		}
 		$i++;
# print A "*****************************************Otra HASH********************************************** \n"
	}
	return \@nivel2Comp;
}

sub buscarAutorPorCond{
	my ($cond)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_autor WHERE completo".$cond." ORDER BY apellido";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	my @autores;
	while(my $data=$sth->fetchrow_hashref){
		push(@autores,$data);
	}
	return @autores;
}


sub buscarTodosLosDatosDeCampoRepetibleN1 {
    my ($campo,$subcampo)=@_;

    use C4::Modelo::CatNivel1Repetible;
    use C4::Modelo::CatNivel1Repetible::Manager;

    my @filtros;
    push(@filtros, ( campo    => { eq => $campo}));
    push(@filtros, ( subcampo    => { eq => $subcampo}));

    my $repetibles_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible( query => \@filtros);
    return $repetibles_array_ref;
}

sub buscarTodosLosDatosDeCampoRepetibleN2 {
    my ($campo,$subcampo)=@_;

    use C4::Modelo::CatNivel2Repetible;
    use C4::Modelo::CatNivel2Repetible::Manager;

    my @filtros;
    push(@filtros, ( campo    => { eq => $campo}));
    push(@filtros, ( subcampo    => { eq => $subcampo}));

    my $repetibles_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible( query => \@filtros);
    return $repetibles_array_ref;
}

sub buscarTodosLosDatosDeCampoRepetibleN3 {
    my ($campo,$subcampo)=@_;

    use C4::Modelo::CatNivel3Repetible;
    use C4::Modelo::CatNivel3Repetible::Manager;

    my @filtros;
    push(@filtros, ( campo    => { eq => $campo}));
    push(@filtros, ( subcampo    => { eq => $subcampo}));

    my $repetibles_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( query => \@filtros);
    return $repetibles_array_ref;
}





sub buscarDatoDeCampoRepetible {
	my ($id,$campo,$subcampo,$nivel)=@_;
	
	my $niveln;
	my $idn;
	if ($nivel eq "1") {$niveln='cat_nivel1_repetible';$idn='id1';} elsif ($nivel eq "2"){$niveln='cat_nivel2_repetible';$idn='id2';} else {$niveln='cat_nivel3_repetible';$idn='id3';}

	my $dbh = C4::Context->dbh;
	my $query="SELECT dato FROM ".$niveln." WHERE campo = ? and subcampo = ? and ".$idn." = ?;";
	my $sth=$dbh->prepare($query);
	$sth->execute($campo,$subcampo,$id);
	my $data=$sth->fetchrow_hashref;
	return $data->{'dato'};
}

# FIXME DEPRECATED
sub getautor {
    my ($idAutor) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("	SELECT id,apellido,nombre,completo 
				FROM cat_autor WHERE id = ?");
    $sth->execute($idAutor);
    my $data=$sth->fetchrow_hashref; 
    $sth->finish();
    return($data);
 }

sub getLevel{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from ref_nivel_bibliografico where code = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Nivel bibliografico
sub getLevels {
 	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("select * from ref_nivel_bibliografico");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
   		$resultslabels{$data->{'code'}}= $data->{'description'};
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getlevels

sub  getCountry{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM ref_pais WHERE iso = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getCountryTypes{
  	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM ref_pais ");
 	 my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
  		$resultslabels{$data->{'iso'}}= $data->{'printable_name'};	
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getcountrytypes

sub getSupport{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from ref_soporte where idSupport = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}


sub getSupportTypes{
  	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM ref_soporte");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$resultslabels{$data->{'idSupport'}}= $data->{'description'};	
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getsupporttypes

sub getLanguage{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM ref_idioma WHERE idLanguage = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLanguages{
 	 my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM ref_idioma");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$resultslabels{$data->{'idLanguage'}}= $data->{'description'};	
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getlanguages

sub getItemType {
 	my ($type)=@_;
  	my $dbh = C4::Context->dbh;
  	my $sth=$dbh->prepare("SELECT nombre FROM cat_ref_tipo_nivel3 WHERE id_tipo_doc=?");
  	$sth->execute($type);
  	my $dat=$sth->fetchrow_hashref;
  	$sth->finish;

  	return ($dat->{'nombre'});
}

## FIXME DEPRECATED
sub getItemTypes {
 	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("SELECT * FROM cat_ref_tipo_nivel3 ORDER BY nombre");
  	my $count = 0;
  	my @results;

  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$results[$count] = $data;
    		$count++;
  	}

  	$sth->finish;
  	return($count, @results);
} # sub getitemtypes

=item getborrowercategory
  $description = &getborrowercategory($categorycode);
Given the borrower's category code, the function returns the corresponding
description for a comprehensive information display.
=cut
## FIXME DEPRECATEDDDDDDDDDDDDDDDDDD C4::AR::Busquedas::getborrowercategory
sub getborrowercategory{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT description FROM usr_ref_categoria_socio WHERE categorycode = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	return $description;
} # sub getborrowercategory

sub getAvail{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from ref_disponibilidad where codigo = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Disponibilidad
sub getAvails {
  	my $dbh   = C4::Context->dbh;
  	my $sth   = $dbh->prepare("select * from ref_disponibilidad");
  	my %resultslabels;
  	$sth->execute;
  	while (my $data = $sth->fetchrow_hashref) {
    		$resultslabels{$data->{'codigo'}}= $data->{'nombre'};
  	}
  	$sth->finish;
  	return(%resultslabels);
} # sub getavails


#Temas, toma un id de tema y devuelve la descripcion del tema.
sub getTema{
	my ($idTema)=@_;
	my $dbh = C4::Context->dbh;
        my $query = "SELECT * from cat_tema where id = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($idTema);
        my $tema=$sth->fetchrow_hashref;
        $sth->finish();
	return($tema);
}


sub buscarTema{
	my ($search)=@_;

	my $dbh = C4::Context->dbh;
	my $query = '';
	my @bind = ();
	my @results;
	my @key=split(' ',$search->{'tema'});
	my $count=@key;
	my $i=1;

	$query="Select distinct cat_tema.id, cat_tema.nombre from cat_nivel1_repetible inner join 
			cat_tema on cat_tema.id= cat_nivel1_repetible.dato  where (campo='650' and subcampo='a') and
			((cat_tema.nombre like ? or cat_tema.nombre like ?)";
	@bind=("$key[0]%","% $key[0]%");
	while ($i < $count){
		$query .= " and (cat_tema.nombre like ? or cat_tema.nombre like ?)";
		push(@bind,"$key[$i]%","% $key[$i]%");
		$i++;
	}
	$query .= ")";

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);

	my $i=0;
  	while (my $data=$sth->fetchrow_hashref){
    		push @results, $data;
    		$i++;
  	}
	my $count=$i;
	$sth->finish;

	return($count,@results);
}


=item
getNombreLocalidad
Devuelve el nombre de la localidad que se pasa por parametro.
=cut
## FIXME DEPRECATEDDDDDDDDDDDDDDDDDD   C4::AR::Busquedas::getNombreLocalidad
sub getNombreLocalidad{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT nombre FROM ref_localidad WHERE localidad = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	if ($description) {return $description;}
	else{return "";}
}

# sub loguearBusqueda{
# 	my ($borrowernumber,$type,$search_array)=@_;
# 
# 	my $dbh = C4::Context->dbh;
# 
# 	my $query = "	INSERT INTO rep_busqueda ( `id_socio` , `fecha` )
# 			VALUES ( ?, NOW( ));";
# 	my $sth=$dbh->prepare($query);
# 	$sth->execute($borrowernumber);
# 
# 	my $query2= "SELECT MAX(idBusqueda) as idBusqueda FROM rep_busqueda";
# 	$sth=$dbh->prepare($query2);
# 	$sth->execute();
# 
# 	my $id=$sth->fetchrow;
# 
# 	my $query3;
# 	my $campo;
# 	my $valor;
# 
# 	my $desde= "INTRA";
# 	if($type eq "opac"){
# 		$desde= "OPAC";
# 	}
# 
# 	$query3= "	INSERT INTO rep_historial_busqueda (`idBusqueda` , `campo` , `valor`, `tipo`)
# 			VALUES (?, ?, ?, ?);";
# 
# 	$sth=$dbh->prepare($query3);
# 
# 	foreach my $search (@$search_array){
# 
# 
# 		if($search->{'keyword'} ne ""){
# 			$sth->execute($id, 'keyword', $search->{'keyword'}, $desde);
# 		}
# 	
# 		if($search->{'dictionary'} ne ""){
# 			$sth->execute($id, 'dictionary', $search->{'dictionary'}, $desde);
# 		}
# 	
# 		if($search->{'virtual'} ne ""){
# 			$sth->execute($id, 'virtual', $search->{'virtual'}, $desde);
# 		}
# 	
# 		if($search->{'signature'} ne ""){
# 			$sth->execute($id, 'signature', $search->{'signature'}, $desde);
# 		}	
# 	
# 		if($search->{'analytical'} ne ""){
# 			$sth->execute($id, 'analytical', $search->{'analytical'}, $desde);
# 		}
# 	
# 		if($search->{'id3'} ne ""){
# 			$sth->execute($id, 'id3', $search->{'id3'}, $desde);
# 		}
# 	
# 		if($search->{'class'} ne ""){
# 			$sth->execute($id, 'class', $search->{'class'}, $desde);
# 		}
# 	
# 		if($search->{'subjectitems'} ne ""){
# 			$sth->execute($id, 'subjectitems', $search->{'subjectitems'}, $desde);
# 		}
# 	
# 		if($search->{'isbn'} ne ""){
# 			$sth->execute($id, 'isbn', $search->{'isbn'}, $desde);
# 		}
# 	
# 		if($search->{'subjectid'} ne ""){
# 			$sth->execute($id, 'subjectid', $search->{'subjectid'}, $desde);
# 		}
# 	
# 		if($search->{'autor'} ne ""){
# 			$sth->execute($id, 'autor', $search->{'autor'}, $desde);
# 		}
# 	
# 		if($search->{'titulo'} ne ""){
# 			$sth->execute($id,'titulo', $search->{'titulo'}, $desde);
# 		}
# 	
# 		if($search->{'tipo_documento'} ne ""){
# 			$sth->execute($id,'tipo_documento', $search->{'tipo_documento'}, $desde);
# 		}
# 
# 		if($search->{'barcode'} ne ""){
# 			$sth->execute($id,'barcode', $search->{'barcode'}, $desde);
# 		}
# 	}
# 
# }

=item
getBranches
Devuelve una hash con todas bibliotecas y sus relaciones.
=cut

sub getBranches {
# returns a reference to a hash of references to branches...
	my %branches;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT pref_unidad_informacion.*,categorycode 
				FROM pref_unidad_informacion INNER JOIN pref_relacion_unidad_informacion 
				ON pref_unidad_informacion.id_ui=pref_relacion_unidad_informacion.branchcode");
	$sth->execute;
	while (my $branch=$sth->fetchrow_hashref) {
		$branches{$branch->{'id_ui'}}=$branch;
	}
	return (\%branches);
}

=item
getBranch
=cut
sub getBranch{
    my($branch) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT * FROM pref_unidad_informacion WHERE id_ui=?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($branch);
    return $sth->fetchrow_hashref;
}


########################################################## NUEVOS!!!!!!!!!!!!!!!!!!!!!!!!!! #################################################

# sub busquedaAvanzada_newTemp{
# 
#    my ($ini,$cantR,$params_obj,$session) = @_;
#    
#    my @filtros;
# 
#    if ( C4::AR::Utilidades::trim($params_obj->{'autor'}) ){
#       push(@filtros, ( 'nivel1.cat_autor.nombre' => { like => '%'.$params_obj->{'autor'}.'%' }) );
#    }
#    
#    if ( C4::AR::Utilidades::trim($params_obj->{'signatura'}) ){
#       push(@filtros, ( 'signatura_topografica' => { like => '%'.$params_obj->{'signatura'}.'%' }) );
#    }
# 
#    if ( C4::AR::Utilidades::trim($params_obj->{'tipo_nivel3_name'}) ){
#       push(@filtros, ( 'nivel2.tipo_documento' => { eq => $params_obj->{'tipo_nivel3_name'} }) );
#    }
#    
#    if ( C4::AR::Utilidades::trim($params_obj->{'titulo'}) ){
#       if ( C4::AR::Utilidades::trim($params_obj->{'tipo'} eq "normal") ){
#          push(@filtros, ( 'nivel1.titulo' => { like => '%'.$params_obj->{'titulo'}.'%' }) );
#       }else{
#          push(@filtros, ( 'nivel1.titulo' => { eq => $params_obj->{'titulo'} }) );
#       }
#    }
# 
#    use C4::Modelo::CatNivel3::Manager;
# 
#    my $nivel3_result = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(
#                                                                         query => \@filtros,
#                                                                         require_objects => ['nivel1','nivel2','nivel1.cat_autor'],
#                                                                         limit => $cantR,
#                                                                         offset => $ini,
#   						                  												select => ['cat_nivel3.id1'],
#                                                                         distinct => 1,
#                                                                      );
# 
#    my $nivel3_result_count = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(
#                                                                         query => \@filtros,
#                                                                         select => ['COUNT(DISTINCT(t2.id1)) AS agregacion_temp'],
#                                                                         require_objects => ['nivel1','nivel2','nivel1.cat_autor'],
#                                                                      );
# 
#    my @id1_array;
#    
#    foreach my $nivel3 (@$nivel3_result){
#       if (!C4::AR::Utilidades::existeInArray($nivel3->getId1,@id1_array)){
#          push(@id1_array,$nivel3->getId1);
#       }
#    }
# 
# 
#    C4::AR::Debug::debug("INI: ".$ini);
#    C4::AR::Debug::debug("CantR: ".$cantR);
#    C4::AR::Debug::debug("Cant del arreglo filtrado: ".scalar(@id1_array));
#    $params_obj->{'cantidad'}= scalar(@id1_array);
# 
#    C4::AR::Busquedas::logBusqueda($params_obj, $session);
# 
# 
# 
# 	return ($nivel3_result_count->[0]->agregacion_temp,@id1_array);
# }


sub busquedaAvanzada_newTemp{
	my ($params_obj,$session) = @_;

	my $dbh = C4::Context->dbh;
	my @searchstring_array;
	
	my $body_string = "	SELECT DISTINCT (t1.id1), t2.titulo, t2.autor, t4.completo  \n";
	$body_string .=	"	FROM cat_nivel3 t1 JOIN (cat_nivel1 t2  JOIN cat_autor t4 ON (t2.autor = t4.id)) ON (t1.id1 = t2.id1)  \n";
	$body_string .=	"	JOIN cat_nivel2 t3 ON (t1.id2 = t3.id2) \n";
	$body_string .=	"	WHERE ";
	
	my $filtros = "";
	
	my @bind;
	
	if ( C4::AR::Utilidades::trim($params_obj->{'autor'}) ){
		$filtros.= "(t4.completo LIKE ?) AND ";
		push(@bind,"%".$params_obj->{'autor'}."%");
		push(@searchstring_array, $params_obj->{'autor'});
	}
	if ( C4::AR::Utilidades::trim($params_obj->{'signatura'}) ){
		$filtros.= "(t1.signatura_topografica LIKE ?) AND ";
		push(@bind,"%".$params_obj->{'signatura'}."%");
		push(@searchstring_array, $params_obj->{'signatura'});
	}
	
	if ( C4::AR::Utilidades::trim($params_obj->{'tipo_nivel3_name'}) ){
		$filtros.= "(t3.tipo_documento = ?) AND ";
		push(@bind,$params_obj->{'tipo_nivel3_name'});
	}
	
	if ( C4::AR::Utilidades::trim($params_obj->{'titulo'}) ){
		if ( C4::AR::Utilidades::trim($params_obj->{'tipo'} eq "normal") ){
			$filtros.= "(t2.titulo LIKE ?) AND ";
			push(@bind,"%".$params_obj->{'titulo'}."%");
			push(@searchstring_array, $params_obj->{'titulo'});
		}else{
			$filtros.= "(t2.titulo = ?) AND ";
			push(@bind,$params_obj->{'titulo'});
			push(@searchstring_array, $params_obj->{'titulo'});
		}
	}
	
	$filtros.= " TRUE ";
	my $sth = $dbh->prepare($body_string.$filtros);
	$sth->execute(@bind);
	
	my @id1_array;
	
	while(my $data = $sth->fetchrow_hashref){
		push (@id1_array,$data);
	}
	#arma y ordena el arreglo para enviar al cliente
   	 my ($cant_total, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params_obj,@id1_array);
	#se loquea la busqueda
   	C4::AR::Busquedas::logBusqueda($params_obj, $session);
	
	return ($cant_total,$resultsarray);
}

sub callStoredProcedure{
  my $dbh = C4::Context->dbh;

  my $SQL_Text = "call r3() " ;
  my $sth= $dbh->prepare($SQL_Text);
  $sth->execute();

  my $tt;
  while ( ($tt) = $sth->fetchrow_array( ) ) { 
      C4::AR::Debug::debug("tt: ".$tt); 
  }
}

sub _getMatchMode{
  my ($tipo) = @_;
  use Sphinx::Search;

  #por defecto se setea este match_mode
  my $tipo_match = SPH_MATCH_ANY;

  if($tipo eq 'SPH_MATCH_ANY'){
    #Match any words
    $tipo_match = SPH_MATCH_ANY;
  }elsif($tipo eq 'SPH_MATCH_PHRASE'){
    #Exact phrase match
    $tipo_match = SPH_MATCH_PHRASE;
  }elsif($tipo eq 'SPH_MATCH_BOOLEAN'){
    #Boolean match, using AND (&), OR (|), NOT (!,-) and parenthetic grouping
    $tipo_match = SPH_MATCH_BOOLEAN;
  }elsif($tipo eq 'SPH_MATCH_EXTENDED'){
    #Extended match, which includes the Boolean syntax plus field, phrase and proximity operators
    $tipo_match = SPH_MATCH_EXTENDED;
  }elsif($tipo eq 'SPH_MATCH_ALL'){
    #Match all words
    $tipo_match = SPH_MATCH_ALL;
  }

  return ($tipo_match);
}

sub index_update{
  system('indexer --rotate --all');
}

sub busquedaCombinada_newTemp{
    my ($string,$session,$obj_for_log) = @_;

    my @searchstring_array = C4::AR::Utilidades::obtenerBusquedas($string);
  

    use Sphinx::Search;

    my $sphinx = Sphinx::Search->new();
    my $query = '';

    #se arma el query string
    foreach $string (@searchstring_array){
      $query .=  " ".$string."*";
    }

    C4::AR::Debug::debug("query string ".$query);
    my $tipo = $obj_for_log->{'match_mode'}||'SPH_MATCH_ANY';
    my $tipo_match = _getMatchMode($tipo);

    C4::AR::Debug::debug("MATCH MODE ".$tipo);

    my $results = $sphinx->SetMatchMode($tipo_match)
                                    ->SetSortMode(SPH_SORT_RELEVANCE)
#                                     ->SetSelect("*")
                                    ->SetLimits($obj_for_log->{'ini'}, $obj_for_log->{'cantR'})
                                    ->Query($query);


    my @id1_array;
    my $matches = $results->{'matches'};
    my $total_found = $results->{'total_found'};
    $obj_for_log->{'total_found'} = $total_found;
    C4::AR::Utilidades::printHASH($results);
    C4::AR::Debug::debug("total_found: ".$total_found);
    C4::AR::Debug::debug("LAST ERROR: ".$sphinx->GetLastError());
    foreach my $hash (@$matches){
      my %hash_temp = {};
      $hash_temp{'id1'} = $hash->{'doc'};
      $hash_temp{'hits'} = $hash->{'weight'};
#        C4::AR::Utilidades::printHASH($hash);

      push (@id1_array, \%hash_temp);
    }
    my ($total_found_paginado, $resultsarray);
    #arma y ordena el arreglo para enviar al cliente
    ($total_found_paginado, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($obj_for_log, @id1_array);
    #se loquea la busqueda
    C4::AR::Busquedas::logBusqueda($obj_for_log, $session);

    return ($total_found, $resultsarray);
}

=item
Realiza una busqueda simpel por autor sobre nivel 1
=cut
sub busquedaSimplePorAutor{
	my ($params,$session) = @_;

	$params->{'nomCompleto'}= $params->{'autor'};
	my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($params->{'autor'});	
	my @id1_array;

	my $dbh = C4::Context->dbh;
	my $sql_string_c1;
	
	$sql_string_c1 = "	SELECT DISTINCT(c1.id1), c1.titulo, c1.autor, a.completo \n";
	$sql_string_c1 .= " FROM cat_nivel1 c1 LEFT JOIN cat_autor a ON (c1.autor = a.id) \n";
	$sql_string_c1 .=" 	WHERE (a.completo LIKE ?) \n";
	my $sth = $dbh->prepare($sql_string_c1);

	$sth->execute("%".$params->{'autor'}."%");
			
	while(my $data = $sth->fetchrow_hashref){
 			push (@id1_array,$data);
	}

	#arma y ordena el arreglo para enviar al cliente
   	my ($cant_total, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params, @id1_array);
	#se loquea la busqueda
   	C4::AR::Busquedas::logBusqueda($params, $session);

   	return ($cant_total, $resultsarray);
}

=item
Realiza una busqueda simple por titulo sobre nivel 1
=cut
sub busquedaSimplePorTitulo{
	my ($params,$session) = @_;

	my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($params->{'titulo'});	
	my @id1_array;

	my $dbh = C4::Context->dbh;
	my $sql_string_c1;
	
	$sql_string_c1 = "	SELECT DISTINCT(c1.id1), c1.titulo, c1.autor, a.completo \n";
	$sql_string_c1 .= "	FROM cat_nivel1 c1 LEFT JOIN cat_autor a ON (c1.autor = a.id) \n";
	$sql_string_c1 .= " WHERE (c1.titulo LIKE ?)\n ";

	my $sth = $dbh->prepare($sql_string_c1);
	$sth->execute("%".$params->{'titulo'}."%");
			
	while(my $data = $sth->fetchrow_hashref){
 			push (@id1_array,$data);
	}

	#arma y ordena el arreglo para enviar al cliente
   	my ($cant_total, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params, @id1_array);
	#se loquea la busqueda
   	C4::AR::Busquedas::logBusqueda($params, $session);

   	return ($cant_total, $resultsarray);
}

sub filtrarPorAutor{
    my ($params_obj)=@_;

    my $dbh = C4::Context->dbh;
# FIXME para que se hace el join con nivel 3??????
=item
    my $query=" SELECT DISTINCT(c1.id1), c1.titulo, c1.autor
                FROM cat_nivel1 c1 INNER JOIN cat_nivel2 c2 ON c1.id1 = c2.id1 INNER JOIN cat_nivel3 c3 ON c1.id1 = c3.id1
                WHERE c1.autor = ?";
=cut
	my $query=" SELECT DISTINCT(c1.id1), c1.titulo, c1.autor
				FROM cat_nivel1 c1 INNER JOIN cat_nivel2 c2 ON (c1.id1 = c2.id1)
				WHERE c1.autor = ? ";

    my $sth=$dbh->prepare($query);
    $sth->execute($params_obj->{'idAutor'});

    my @id1_array;
    my @searchstring_array;
    my $autor = getautor($params_obj->{'idAutor'});
# FIXME para que es esto?????????????
    while(my $data=$sth->fetchrow_hashref){
        $data->{'completo'} = $autor->{'completo'};
        push(@id1_array,$data);
    }

	$params_obj->{'filtrarPorAutor'}= $autor->{'completo'};
    push (@searchstring_array, "AUTOR: ".$autor->{'completo'});


    my ($cant_total, $resultsarray) = C4::AR::Busquedas::armarInfoNivel1($params_obj,@id1_array);
    #se loquea la busqueda
    C4::AR::Busquedas::logBusqueda($params_obj, $params_obj->{'session'});

    return ($cant_total,$resultsarray);
}


sub t_loguearBusqueda {
    my($loggedinuser,$desde,$http_user_agent,$search_array)=@_;

    my $msg_object= C4::AR::Mensajes::create();
    $desde = $desde || 'SIN_TIPO';
    my $historial = C4::Modelo::RepHistorialBusqueda->new();
    my $db = $historial->db;
    my $msg_object= C4::AR::Mensajes::create();
    $db->{connect_options}->{AutoCommit} = 0;
    eval {
        $historial->agregar($loggedinuser,$desde,$http_user_agent,$search_array);
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        #Se setea error para el usuario
        &C4::AR::Mensajes::printErrorDB($@, 'B407',"INTRA");
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R011', 'params' => []} ) ;        
        $db->rollback;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}


sub logBusqueda{
	my ($params,$session) = @_;
	#esta funcion loguea las busquedas relizadas desde la INTRA u OPAC si:
	#la preferencia del OPAC es 1 y estoy buscando desde OPAC  
	#la preferencia de la INTRA es 1 y estoy buscando desde la INTRA

	my @search_array;

   $params->{'loggedinuser'}= $session->param('nro_socio');
	my $valorOPAC= C4::AR::Preferencias->getValorPreferencia("logSearchOPAC");
	my $valorINTRA= C4::AR::Preferencias->getValorPreferencia("logSearchINTRA");
   C4::AR::Debug::debug($params->{'type'});
	if( (($valorOPAC == 1)&&($params->{'type'} eq 'OPAC')) || (($valorINTRA == 1)&&($params->{'type'} eq 'INTRA')) ){
		if($params->{'codBarra'} ne ""){
			my $search;
			$search->{'barcode'}= $params->{'codBarra'};
			push (@search_array, $search);
		}

		if($params->{'autor'} ne ""){
			my $search;
			$search->{'autor'}= $params->{'autor'};
			push (@search_array, $search);
		}
	
		if($params->{'titulo'} ne ""){
			my $search;
			$search->{'titulo'}= $params->{'titulo'};
			push(@search_array, $search);
		}
	
		if($params->{'tipo_nivel3_name'} != -1 && $params->{'tipo_nivel3_name'} ne ""){
			my $search;
			$search->{'tipo_documento'}= $params->{'tipo_nivel3_name'};
			push (@search_array, $search);
		}

      
		if($params->{'keyword'} != -1 && $params->{'keyword'} ne ""){
			my $search;
			$search->{'keyword'}= $params->{'keyword'};
			push (@search_array, $search);
		}

		if($params->{'filtrarPorAutor'} ne ""){
			my $search;
			$search->{'filtrarPorAutor'}= $params->{'filtrarPorAutor'};
			push(@search_array, $search);
		}
	}

	my ($error, $codMsg, $message)= C4::AR::Busquedas::t_loguearBusqueda(
																			$params->{'loggedinuser'},
																			$params->{'type'},
                                                         					$session->param('browser'),
																			\@search_array
														);
}


=item
Esta funcion arma el string para mostrar en el cliente lo que a buscado, 
ademas escapa para evitar XSS
=cut
sub armarBuscoPor{
	my ($params) = @_;
	
	my $buscoPor="";
	
	if($params->{'keyword'} ne ""){
		$buscoPor.="Busqueda combinada: ".C4::AR::Utilidades::verificarValor($params->{'keyword'})."&";
	}
	
	if( $params->{'tipo_nivel3_name'} != -1 &&  $params->{'tipo_nivel3_name'} ne ""){
		$buscoPor.="Tipo de documento: ".C4::AR::Utilidades::verificarValor($params->{'tipo_nivel3_name'})."&";
	}

	if( $params->{'titulo'} ne "" ){
		$buscoPor.="Titulo: ".C4::AR::Utilidades::verificarValor($params->{'titulo'})."&";
	}
	
	if( $params->{'autor'} ne "" ){
		$buscoPor.="Autor: ".C4::AR::Utilidades::verificarValor($params->{'autor'})."&";
	}

	if( $params->{'signatura'} ne "" ){
		$buscoPor.="Signatura: ".C4::AR::Utilidades::verificarValor($params->{'signatura'})."&";
	}

	if( $params->{'isbm'} ne "" ){
		$buscoPor.="ISBN: ".C4::AR::Utilidades::verificarValor($params->{'isbn'})."&";
	}		

	if( $params->{'codBarra'} ne "" ){
		$buscoPor.="Código de Barra: ".C4::AR::Utilidades::verificarValor($params->{'codBarra'})."&";
	}		

	my @busqueda=split(/&/,$buscoPor);
	$buscoPor="";
	
	foreach my $str (@busqueda){
		$buscoPor.=", ".$str;
	}
	
	$buscoPor= substr($buscoPor,2,length($buscoPor));

	return $buscoPor;
}


sub armarInfoNivel1{
#   my ($params,$searchstring_array, @resultId1) = @_;
   my ($params, @resultId1) = @_;

  my $tipo_nivel3_name= $params->{'tipo_nivel3_name'};

#   my $fin = $params->{'ini'} + $params->{'cantR'};
#   $params->{'cantR'} = $fin;  
#   if($fin > $params->{'total_found'}){
#     $params->{'cantR'} = $params->{'total_found'};
#   } 
# 
#   
#   C4::AR::Debug::debug("INI??? ".$params->{'ini'}); 
#   C4::AR::Debug::debug("FIN??? ".$params->{'cantR'});
  
  
  #se corta el arreglo segun lo que indica el paginador
# TODO si se usa el setLimit en el objeto indexador no es necesario hacer esto
#   my ($cant_total,@result_array_paginado) = C4::AR::Utilidades::paginarArreglo($params->{'ini'},$params->{'cantR'},@resultId1);

my @result_array_paginado = @resultId1;
my $cant_total = scalar(@resultId1);


# FIXME Miguel uso un arreglo temporal para guardar solo los id1 que me recuperan un objeto de nivel1_object
# puede pasar q el indice este desactualizado y no recupere un id1 que ya no existe en la base
my @result_array_paginado_temp;
  
  for(my $i=0;$i<scalar(@result_array_paginado);$i++ ) {
    my $nivel1 = C4::AR::Nivel1::getNivel1FromId1(@result_array_paginado[$i]->{'id1'});
    if($nivel1){
  # TODO ver si esto se puede sacar del resultado del indice asi no tenemos q ir a buscarlo
      @result_array_paginado[$i]->{'titulo'} = $nivel1->getTitulo();
      @result_array_paginado[$i]->{'nomCompleto'} = $nivel1->getAutorObject->getCompleto();
      @result_array_paginado[$i]->{'idAutor'} = $nivel1->getAutorObject->getId();
      #aca se procesan solo los ids de nivel 1 que se van a mostrar
      #se generan los grupos para mostrar en el resultado de la consulta
      my $ediciones=&C4::AR::Busquedas::obtenerGrupos(@result_array_paginado[$i]->{'id1'}, $tipo_nivel3_name,"INTRA");
      @result_array_paginado[$i]->{'grupos'}= 0;
      if(scalar(@$ediciones) > 0){
        @result_array_paginado[$i]->{'grupos'}=$ediciones;
      }
  
      @result_array_paginado[$i]->{'portada_registro'}=  C4::AR::PortadasRegistros::getImageForId1(@result_array_paginado[$i]->{'id1'},'S');
      #se obtine la disponibilidad total 
      my @disponibilidad=&C4::AR::Busquedas::obtenerDisponibilidadTotal(@result_array_paginado[$i]->{'id1'}, $tipo_nivel3_name);  
      @result_array_paginado[$i]->{'disponibilidad'}= 0;
  
      if(scalar(@disponibilidad) > 0){
        @result_array_paginado[$i]->{'disponibilidad'}=\@disponibilidad;
      }

      push (@result_array_paginado_temp, @result_array_paginado[$i]);
    }
  }

$cant_total = scalar(@result_array_paginado_temp);
@result_array_paginado = @result_array_paginado_temp;

  return ($cant_total, \@result_array_paginado);
}

#*****************************************Soporte MARC************************************************************************
#devuelve toda la info en MARC de un item (id3 de nivel 3)
sub MARCDetail{
	my ($id3,$tipo)= @_;

	my @MARC_result;
	my $marc_array_nivel1;
	my $marc_array_nivel2;
	my $marc_array_nivel3;

	my ($nivel3_object)= C4::AR::Nivel3::getNivel3FromId3($id3);
	if($nivel3_object ne 0){
		C4::AR::Debug::debug('recupero el nivel3');
		($marc_array_nivel3)= $nivel3_object->nivel3CompletoToMARC;
	}

	my ($nivel2_object)= C4::AR::Nivel2::getNivel2FromId2($nivel3_object->getId2);
	
	if($nivel2_object ne 0){
		C4::AR::Debug::debug('recupero el nivel2');
		($marc_array_nivel2)= $nivel2_object->nivel2CompletoToMARC;
		C4::AR::Debug::debug('MARCDetail => cant '.scalar(@$marc_array_nivel2));
	}
	my ($nivel1_object)= C4::AR::Nivel1::getNivel1FromId1($nivel2_object->getId1);
	if($nivel1_object ne 0){
		C4::AR::Debug::debug('recupero el nivel1');
		($marc_array_nivel1)= $nivel1_object->nivel1CompletoToMARC;
	}

	my @result;
	push(@result, @$marc_array_nivel1);
	push(@result, @$marc_array_nivel2);
	push(@result, @$marc_array_nivel3);
	
	my @MARC_result_array;
# FIXME no es muy eficiente pero funciona, ver si se puede mejorar, orden cuadrado
	
	for(my $i=0; $i< scalar(@result); $i++){
		my %hash;	
		my $campo= @result[$i]->{'campo'};
		my @info_campo_array;
		C4::AR::Debug::debug("Proceso todos los subcampos del campo: ".$campo);
		if(!_existeEnArregloDeCampoMARC(\@MARC_result_array, $campo) ){
			#proceso todos los subcampos del campo
			for(my $j=$i;$j < scalar(@result);$j++){
				my %hash_temp;
				$hash_temp{'subcampo'}= @result[$j]->{'subcampo'};
				$hash_temp{'liblibrarian'}= @result[$j]->{'liblibrarian'};
				$hash_temp{'dato'}= @result[$j]->{'dato'};
	
				if(@result[$j]->{'campo'} eq $campo){
					push(@info_campo_array, \%hash_temp);
# 					C4::AR::Debug::debug("agrego el subcampo: ".@result[$j]->{'subcampo'});
				}

        C4::AR::Debug::debug("campo, subcampo, dato: ".@result[$j]->{'campo'}.", ".@result[$j]->{'subcampo'}." : ".@result[$j]->{'dato'});
			}
		
			$hash{'campo'}= $campo;
			$hash{'header'}= @result[$i]->{'header'};
			$hash{'info_campo_array'}= \@info_campo_array;
		
			push(@MARC_result_array, \%hash);
# 			C4::AR::Debug::debug("campo: ".$campo);
			C4::AR::Debug::debug("cant subcampos: ".scalar(@info_campo_array));
		}
	}

	return (\@MARC_result_array);
}


=item
Verifica si existe en el arreglo de campos el campo pasado por parametro
=cut
sub _existeEnArregloDeCampoMARC{
	my ($array, $campo)= @_;

	for(my $j=0;$j < scalar(@$array);$j++){

		if(@$array->[$j]->{'campo'} eq $campo){
			return 1;
		}
	}

	return 0;
}

sub getHeader{
	my ($campo) = @_;
	use C4::Modelo::PrefEstructuraCampoMarc;
	use C4::Modelo::PrefEstructuraCampoMarc::Manager;

	my ($pref_estructura_campo_marc_array) = C4::Modelo::PrefEstructuraCampoMarc::Manager->get_pref_estructura_campo_marc( 
																					query => [ campo => { eq => $campo } ]
																	);

	if(scalar(@$pref_estructura_campo_marc_array) > 0){
		return $pref_estructura_campo_marc_array->[0]->getLiblibrarian;
	}else{
		return 0;
	}
}

sub getLiblibrarian{
	my ($campo, $subcampo)= @_;

	use C4::Modelo::PrefEstructuraSubcampoMarc;
	use C4::Modelo::PrefEstructuraSubcampoMarc::Manager;
	#primero busca en estructura_catalogacion
	my $estructura_array= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);


	if($estructura_array){
		return $estructura_array->getLiblibrarian;
	}else{
		my ($pref_estructura_sub_campo_marc_array) = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc( 
																					query => [  campo => { eq => $campo },
																								      subcampo => { eq => $subcampo }
																							 ]
																	);
		#si no lo encuentra en estructura_catalogacion, lo busca en estructura_sub_campo_marc
		if(scalar(@$pref_estructura_sub_campo_marc_array) > 0){
			return  $pref_estructura_sub_campo_marc_array->[0]->getLiblibrarian
		}else{
			return 0;
		}
	}
}
#***************************************Fin**Soporte MARC*********************************************************************

1;
__END__
