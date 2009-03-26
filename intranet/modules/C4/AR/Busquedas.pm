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
		&buscarGrupos
		&buscarCamposMARC
		&buscarSubCamposMARC
		&buscarAutorPorCond
		&buscarDatoDeCampoRepetible
		&buscarTema

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
	$query .= " WHERE (tagfield = ? )and(tagsubfield = ?)";

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
        		$result[$res]->{'edicion'}= &C4::AR::Nivel2::getEdicion($data->{'id2'});
        		$result[$res]->{'anio_publicacion'}=$data->{'anio_publicacion'};
        		$result[$res]->{'volume'}= C4::AR::Nivel2::getVolume($data->{'id2'});
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
	#	if($data->{'notforloan'} eq 'DO'){
		if($data->{'id_disponibilidad'} == 0){
			$disponibilidad[$i]->{'tipoPrestamo'}="Para Domicilio:";
			$disponibilidad[$i]->{'prestados'}="Prestados: ";
			$disponibilidad[$i]->{'prestados'}.=0;#VER MAS ADELANTE!!!!!!!!!
			$disponibilidad[$i]->{'reservados'}="Reservados: ".C4::AR::Reservas::cantReservasPorNivel1($id1);
		}
		else{
			$disponibilidad[$i]->{'tipoPrestamo'}="Para Sala:";
		}
		$disponibilidad[$i]->{'cantTotal'}=$data->{'cant'};
		$i++;
	}
	return(@disponibilidad);
}


#****************************************************MARC DETAIL**************************************************


#devuelve toda la info en MARC de un item (id3 de nivel 3)
sub MARCDetail{

	my ($id3,$tipo)= @_;

	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel3 WHERE id3=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3);

	my $data=$sth->fetchrow_hashref;

	my $id2= $data->{'id2'};
	my $id1= $data->{'id1'};

 	my $nivel1=&C4::AR::Catalogacion::buscarNivel1($id1); #C4::AR::Catalogacion;
 	my @autor=&getautor($nivel1->{'autor'});

	my @nivel1Loop= &C4::AR::Nivel1::detalleNivel1MARC($id1, $nivel1,$tipo);
	my @nivel2Loop= &C4::AR::Nivel2::detalleNivel2MARC($id1,$id2,$id3,$tipo,\@nivel1Loop);

	return @nivel2Loop;
}


=item
buscarCamposMARC
Busca los campos correspondiente a el parametro campoX, para ver en el tmpl de filtradoAvanzado.
=cut
sub buscarCamposMARC{
	my ($campoX) =@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT DISTINCT nivel,tagfield FROM pref_estructura_subcampo_marc ";
	$query .=" WHERE nivel > 0 AND tagfield LIKE ? ORDER BY nivel";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($campoX."%");
	my @results;
	my $nivel;
	while(my $data=$sth->fetchrow_hashref){
		$nivel="n".$data->{'nivel'}."r";
		push (@results,$nivel."/".$data->{'tagfield'});
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
	my $query="SELECT tagsubfield FROM pref_estructura_subcampo_marc ";
	$query .=" WHERE nivel > 0 AND tagfield = ? ";
	my $mapeo=&buscarSubCamposMapeo($campo);
	foreach my $llave (keys %$mapeo){
		$query.=" AND (tagsubfield <> '".$mapeo->{$llave}->{'subcampo'}."' ) ";
	}
	my $sth=$dbh->prepare($query);
        $sth->execute($campo);
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'tagsubfield'});
	}

	$sth->finish;
	return (@results);
}

=item
busquedaAvanzada
Busca los id1 dependiendo de los strings que viene desde el pl.
=cut
sub busquedaAvanzada{
	my($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,$operador,$ini,$cantR)= @_;
	my $dbh = C4::Context->dbh;
#Se hace para despues sacar los primeros operadores del string que no van. Se AND u OR, los dos ocupan 4 lugares.
	if($operador eq "AND"){
		$operador=$operador." ";
	}
	else{
		$operador=$operador."  ";
	}

#*********************************** busqueda NIVEL 1****************************************
my $from1 = "";
my $where1 = "";
my $subcon1= "FROM cat_nivel1 n1 INNER JOIN cat_nivel1_repetible n1r ON (n1.id1 = n1r.id1) WHERE ";
my @Subconsultas1;

if($nivel1 ne ""){
	$from1 = "cat_nivel1 n1";
	my @array1= split(/#/,$nivel1);
	
	for(my $i;$i<scalar(@array1);$i++){
		$where1.= $operador.$array1[$i]." ";
	}
}
	
if($nivel1rep ne ""){
	my @array1rep= split(/#/,$nivel1rep);
	for(my $i;$i<scalar(@array1rep);$i++){
		push(@Subconsultas1, $subcon1.$array1rep[$i]);
	}
}

if($where1 ne ""){
	#se saca el primir AND
	$where1= substr($where1,3,length($where1));
}

#*********************************** busqueda NIVEL 2****************************************
my $from2 = "";
my $where2 = "";
my $subcon2= "FROM cat_nivel2 n2 INNER JOIN cat_nivel2_repetible n2r ON (n2.id2 = n2r.id2) WHERE ";
my @Subconsultas2;

if($nivel2 ne ""){
	
	$from2 = "cat_nivel2 n2";
	my @array2= split(/#/,$nivel2);
	
	for(my $i;$i<scalar(@array2);$i++){
		$where2.= $operador.$array2[$i]." ";
	}
}
	
if($nivel2rep ne ""){
	my @array2rep= split(/#/,$nivel2rep);
	for(my $i;$i<scalar(@array2rep);$i++){
		push(@Subconsultas2, $subcon2.$array2rep[$i]);
	}
}

if($where2 ne ""){
	#se saca el primir AND
	$where2= substr($where2,3,length($where2));
}

#*********************************** busqueda NIVEL 3****************************************
my $from3 = "";
my $where3 = "";
my $subcon3= "FROM cat_nivel3 n3 INNER JOIN cat_nivel3_repetible n3r ON (n3.id3 = n3r.id3) WHERE ";
my @Subconsultas3;

if($nivel3 ne ""){
	$from3 = "cat_nivel3 n3";
	my @array3= split(/#/,$nivel3);
	
	for(my $i;$i<scalar(@array3);$i++){
		$where3.= $operador.$array3[$i]." ";
	}
}
	
if($nivel3rep ne ""){

	my @array3rep= split(/#/,$nivel3rep);
	for(my $i;$i<scalar(@array3rep);$i++){
		push(@Subconsultas3, $subcon3.$array3rep[$i]);
	}
}

if($where3 ne ""){
	#se saca el primir AND
	$where3= substr($where3,3,length($where3));
}

my $strSubCons1Rep="";
my $pare1="";
my $consultaN1;
if($from1 ne "" || $nivel1rep ne ""){
	my $select1="SELECT DISTINCT (n1.id1) as id1 ";
	if($from1 ne ""){
		#Se hizo una busqueda en el nivel1
		$consultaN1=$select1." FROM (".$from1.") WHERE ".$where1;
		$pare1=")";
	}
	if($nivel1rep ne ""){
	#Se hizo una busqueda en el nivel1_repetible
		if(scalar(@Subconsultas1)>1){
			$pare1=")";
		}
		foreach my $cons (@Subconsultas1){
			$strSubCons1Rep.= $operador."n1.id1 IN (".$select1.$cons;
		}
		if($from1 eq ""){
			#SACO el operador y n1.id1. IN ( si es que no si hizo una consulta por nivel1
			$strSubCons1Rep= substr($strSubCons1Rep,15,length($strSubCons1Rep));
		}
		$consultaN1=$consultaN1.$strSubCons1Rep.$pare1;
	}
}

my $strSubCons2Rep="";
my $pare2="";
my $consultaN2;
if($from2 ne "" || $nivel2rep ne ""){
	my $select2="SELECT DISTINCT (n2.id1) as id1 ";
	if($from2 ne ""){
		#Se hizo una busqueda en el nivel2
		$consultaN2=$select2." FROM (".$from2.") WHERE ".$where2;
		$pare2=")";
	}
	if($nivel2rep ne ""){
		#Se hizo una busqueda en el nivel2_repetible
		if(scalar(@Subconsultas2)>1){
			$pare1=")";
		}
		foreach my $cons (@Subconsultas2){
			$strSubCons2Rep.= $operador."n2.id1 IN (".$select2.$cons;
		}
		if($from2 eq ""){
			#SACO el operador y n2.id1. IN ( si es que no si hizo una consulta por nivel2
			$strSubCons2Rep= substr($strSubCons2Rep,15,length($strSubCons2Rep));
		}
		$consultaN2=$consultaN2.$strSubCons2Rep.$pare2;
	}
}

my $strSubCons3Rep="";
my $pare3="";
my $consultaN3;
if($from3 ne "" || $nivel3rep ne ""){
	my $select3="SELECT DISTINCT (n3.id1) as id1 ";
	if($from3 ne ""){
		#Se hizo una busqueda en el nivel3
		$consultaN3=$select3." FROM (".$from3.") WHERE ".$where3;
		$pare3=")";
	}
	if($nivel3rep ne ""){
		#Se hizo una busqueda en el nivel3_repetible
		if(scalar(@Subconsultas3)>1){
			$pare3=")";
		}
		foreach my $cons (@Subconsultas3){
			$strSubCons3Rep.= $operador."n3.id1 IN (".$select3.$cons;
		}
		if($from3 eq ""){
			#SACO el operador y n3.id1. IN ( si es que no si hizo una consulta por nivel3
			$strSubCons3Rep= substr($strSubCons3Rep,15,length($strSubCons3Rep));
		}
		$consultaN3=$consultaN3.$strSubCons3Rep.$pare3;
	}
}

my @resultsId1;
my $query="";
my $queryCant="";
my $n="";
# Se concatenan todas las consultas.
if($consultaN1 ne ""){
	$n="n1.id1";
	$query=$consultaN1;
}
if($consultaN2 ne ""){
	if($query ne ""){
		$query.=" ".$operador."*?* IN (".$consultaN2.")";
	}
	else{
		$n="n2.id1";
		$query=$consultaN2;
	}
}
if($consultaN3 ne ""){
	if($query ne ""){
		$query.=" ".$operador."*?* IN (".$consultaN3.")";
	}
	else{
		$n="n3.id1";
		$query=$consultaN3;
	}
}

$query=~ s/\*\?\*/$n/g; #Se reemplaza la subcadena (*?*) por el nX.id1 donde X es la primera tabla que se hace la consulta.
$queryCant=$query;
#Se reemplaza la 1� subcadena (DISTINCT (n1.id1) as id1) por COUNT(*) para saber el total de documentos que hay con la consulta que se hizo, sirve para el paginador.
$queryCant=~ s/DISTINCT \(n.\.id1\) as id1/COUNT(DISTINCT(*?*)) /o;

#Se reemplaza la subcadena (*?*) por el nX.id1 donde X es la primera tabla que se hace la
$queryCant=~ s/\*\?\*/$n/g; 

if (defined $ini && defined $cantR) {
	$query.= " limit $ini,$cantR";
}

my $sth=$dbh->prepare($query);
$sth->execute();
while(my $data=$sth->fetchrow_hashref){
	push(@resultsId1, $data->{'id1'});
}

$sth=$dbh->prepare($queryCant);
$sth->execute();
my $cantidad=$sth->fetchrow;

$sth->finish;

return ($cantidad,\@resultsId1);

}#end busquedaAvanzada

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


sub busquedaCombinada {

	my ($search, $ini, $cantR)=@_;

  	my $dbh = C4::Context->dbh;
  	$search->{'keyword'}=~ s/ +$//;
	my @key=split(' ',$search->{'keyword'});
  
  	my $count=0;
  	my @returnvalues= ();
  
  	my @bind = ();
  	my @condiciones=(); 
  	my $index=0;

	#Se arma el bind
	foreach my $keyword (@key) {push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");}

	#Campos para las condiciones, se tienen que corresponder con las queries
	foreach my $field (qw(titulo cat_autor.completo cat_tema.nombre cat_nivel1_repetible.dato cat_nivel2_repetible.dato cat_nivel3_repetible.dato)){ 
		my @subclauses = ();
		foreach my $keyword (@key) { push @subclauses, "$field LIKE ? OR $field LIKE ?";}
		$condiciones[$index]= "(" . join(")\n\tOR (", @subclauses) . ")";
		$index++;
	}
	
	#CONSULTAS
	my @queries=(
		"SELECT id1 FROM cat_nivel1 WHERE ".$condiciones[0], #TITULO
		"SELECT id1 FROM cat_nivel1 left join cat_autor on cat_nivel1.autor = cat_autor.id WHERE ".$condiciones[1], #AUTOR
		"SELECT id1 FROM cat_nivel1_repetible left join cat_autor on cat_nivel1_repetible.dato = cat_autor.id WHERE campo='700' and subcampo='a' and ".$condiciones[1], #Autores adicionales 700 a
		"SELECT id1 FROM cat_nivel1_repetible left join cat_tema on cat_nivel1_repetible.dato = cat_tema.id WHERE campo='650' and subcampo='a' and ".$condiciones[2], #Tema 650 a
		"SELECT id1 FROM cat_nivel1_repetible WHERE ".$condiciones[3], #nivel1_repetible
		"SELECT cat_nivel2.id1 FROM cat_nivel2 right join cat_nivel2_repetible on cat_nivel2.id2 = cat_nivel2_repetible.id2 WHERE ".$condiciones[4], #nivel2_repetible
		"SELECT cat_nivel3.id1 FROM cat_nivel3 right join cat_nivel3_repetible on cat_nivel3.id3 = cat_nivel3_repetible.id3 WHERE ".$condiciones[5], #nivel3_repetible
	) ;

	#Realizamos las consultas
	foreach my $query (@queries){
		my $sth=$dbh->prepare($query);
		$sth->execute(@bind);
		while (my ($id1) = $sth->fetchrow) {
			#Se agrega solo si no es repetido
			my $found=0;
			foreach my $ret ( @returnvalues ) {
			if( $ret == $id1 ) { $found = 1; last }
			} 
	
			if ($found == 0){
				push(@returnvalues,$id1);
				$count++;
			}
		}
	}

	my $i;
	my $cantidad= scalar(@returnvalues);
	my $fin= $ini + $cantR;
	my @returnvalues2;

# 	Se pagina el resultado
	for($i=$ini;$i<$fin;$i++){
		push(@returnvalues2, $returnvalues[$i]);
	}

	return($cantidad, @returnvalues2);
}



sub buscarGrupos{
	my ($isbn,$titulo,$ini,$cantR)=@_;
	my $dbh = C4::Context->dbh;
	my $limit=" limit ?,?";
	my @bind;
	my $query="SELECT COUNT(*) ";
	my $query2;
	my $resto;
	if($isbn ne ""){
		#issn 022a
		#isbn 020a
		$query2="SELECT * ";
		$resto="FROM cat_nivel2_repetible n2r INNER JOIN cat_nivel2 n2 ON (n2r.id2=n2.id2)";
		$resto.=" INNER JOIN cat_nivel1 n1 ON (n2.id1=n1.id1)";
		$resto.=" WHERE (campo=020 and subcampo='a' and dato=?) or (campo=022 and subcampo='a' and dato=?) ";
# 		$sth=$dbh->prepare($query);
#         	$sth->execute($isbn,$isbn);
		push(@bind,$isbn);
		push(@bind,$isbn);
	}
	else{
		$query2="SELECT DISTINCT n1.* ";
		$resto="FROM cat_nivel1 n1 WHERE titulo like ? ";
		$titulo.="%";
		push(@bind,$titulo);
# 		$sth=$dbh->prepare($query);
#         	$sth->execute($titulo."%");
	}
	$query.=$resto;
	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my $cantidad=$sth->fetchrow;

	$query2.=$resto.$limit;
	push(@bind,$ini);
	push(@bind,$cantR);
	$sth=$dbh->prepare($query2);
	$sth->execute(@bind);
	
	my @result;
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		$result[$i]{'titulo'}=$data->{'titulo'};
		my $autor=C4::AR::Busquedas::getautor($data->{'autor'});
		$result[$i]{'autor'}=$autor->{'completo'};
		$result[$i]{'id1'}=$data->{'id1'};
		$result[$i]{'id2'}=$data->{'id2'};
		$result[$i]{'itemtype'}=$data->{'tipo_documento'};
		$i++;
	}
	$sth->finish;
	return($cantidad,\@result);
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


=item
loguearBusqueda
Guarda en la base de datos el tipo de busqueda que se realizo y que se busco.
=cut
=item
sub loguearBusqueda{
	my ($borrowernumber,$env,$type,$search)=@_;

	my $dbh = C4::Context->dbh;

	my $old_pe = $dbh->{PrintError}; # save and reset
	my $old_re = $dbh->{RaiseError}; # error-handling
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
  	$dbh->{RaiseError} = 0; #si lo dejo, para la aplicacion y muestra error

	#comienza la transaccion
	{

	my $query = "	INSERT INTO rep_busqueda ( `borrower` , `fecha` )
			VALUES ( ?, NOW( ));";
	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber);

	my $query2= "SELECT MAX(idBusqueda) as idBusqueda FROM rep_busqueda";
	$sth=$dbh->prepare($query2);
	$sth->execute();

	my $id=$sth->fetchrow;

	my $query3;
	my $campo;
	my $valor;

	my $desde= "INTRA";
	if($type eq "opac"){
		$desde= "OPAC";
	}

	$query3= "	INSERT INTO rep_historial_busqueda (`idBusqueda` , `campo` , `valor`, `tipo`)
			VALUES (?, ?, ?, ?);";

	$sth=$dbh->prepare($query3);


	if($search->{'keyword'} ne ""){
		$sth->execute($id, 'keyword', $search->{'keyword'}, $desde);
	}

	if($search->{'dictionary'} ne ""){
		$sth->execute($id, 'dictionary', $search->{'dictionary'}, $desde);
	}

	if($search->{'virtual'} ne ""){
		$sth->execute($id, 'virtual', $search->{'virtual'}, $desde);
	}

	if($search->{'signature'} ne ""){
		$sth->execute($id, 'signature', $search->{'signature'}, $desde);
	}	

	if($search->{'analytical'} ne ""){
		$sth->execute($id, 'analytical', $search->{'analytical'}, $desde);
	}

	if($search->{'id3'} ne ""){
		$sth->execute($id, 'id3', $search->{'id3'}, $desde);
	}

	if($search->{'class'} ne ""){
		$sth->execute($id, 'class', $search->{'class'}, $desde);
	}

	if($search->{'subjectitems'} ne ""){
		$sth->execute($id, 'subjectitems', $search->{'subjectitems'}, $desde);
	}

	if($search->{'isbn'} ne ""){
		$sth->execute($id, 'isbn', $search->{'isbn'}, $desde);
	}

	if($search->{'subjectid'} ne ""){
		$sth->execute($id, 'subjectid', $search->{'subjectid'}, $desde);
	}

	if($search->{'autor'} ne ""){
		$sth->execute($id, 'autor', $search->{'autor'}, $desde);
	}

	if($search->{'titulo'} ne ""){
		$sth->execute($id,'titulo', $search->{'title'}, $desde);
	}

	if($search->{'tipo_documento'} ne ""){
		$sth->execute($id,'tipo_documento', $search->{'tipo_documento'}, $desde);
	}
		

	$dbh->commit ();
	};
	$dbh->rollback () if $@;    # rollback if transaction failed
	$dbh->{AutoCommit} = 1;    # restore auto-commit mode

	#falta ver bien el tema de la transaccion, pq si no se dispara el error y la segunda consulta falla
	#se hace rollback solo de la segunda
}
=cut

sub t_loguearBusqueda {
	
	my($loggedinuser,$env,$desde,$search_array)=@_;

	my $dbh = C4::Context->dbh;
	my $paramsReserva;
	my ($error, $codMsg,$paraMens);
	
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {
		($error,$codMsg,$paraMens)=loguearBusqueda($loggedinuser,$env,$desde,$search_array);
		$dbh->commit;	
	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B407';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"OPAC");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R011';
	}
	$dbh->{AutoCommit} = 1;
	

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"OPAC",$paraMens);
	return ($error, $codMsg, $message);
}

sub loguearBusqueda{
	my ($borrowernumber,$env,$type,$search_array)=@_;

	my $dbh = C4::Context->dbh;

	my $query = "	INSERT INTO rep_busqueda ( `borrower` , `fecha` )
			VALUES ( ?, NOW( ));";
	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber);

	my $query2= "SELECT MAX(idBusqueda) as idBusqueda FROM rep_busqueda";
	$sth=$dbh->prepare($query2);
	$sth->execute();

	my $id=$sth->fetchrow;

	my $query3;
	my $campo;
	my $valor;

	my $desde= "INTRA";
	if($type eq "opac"){
		$desde= "OPAC";
	}

	$query3= "	INSERT INTO rep_historial_busqueda (`idBusqueda` , `campo` , `valor`, `tipo`)
			VALUES (?, ?, ?, ?);";

	$sth=$dbh->prepare($query3);

	foreach my $search (@$search_array){


		if($search->{'keyword'} ne ""){
			$sth->execute($id, 'keyword', $search->{'keyword'}, $desde);
		}
	
		if($search->{'dictionary'} ne ""){
			$sth->execute($id, 'dictionary', $search->{'dictionary'}, $desde);
		}
	
		if($search->{'virtual'} ne ""){
			$sth->execute($id, 'virtual', $search->{'virtual'}, $desde);
		}
	
		if($search->{'signature'} ne ""){
			$sth->execute($id, 'signature', $search->{'signature'}, $desde);
		}	
	
		if($search->{'analytical'} ne ""){
			$sth->execute($id, 'analytical', $search->{'analytical'}, $desde);
		}
	
		if($search->{'id3'} ne ""){
			$sth->execute($id, 'id3', $search->{'id3'}, $desde);
		}
	
		if($search->{'class'} ne ""){
			$sth->execute($id, 'class', $search->{'class'}, $desde);
		}
	
		if($search->{'subjectitems'} ne ""){
			$sth->execute($id, 'subjectitems', $search->{'subjectitems'}, $desde);
		}
	
		if($search->{'isbn'} ne ""){
			$sth->execute($id, 'isbn', $search->{'isbn'}, $desde);
		}
	
		if($search->{'subjectid'} ne ""){
			$sth->execute($id, 'subjectid', $search->{'subjectid'}, $desde);
		}
	
		if($search->{'autor'} ne ""){
			$sth->execute($id, 'autor', $search->{'autor'}, $desde);
		}
	
		if($search->{'titulo'} ne ""){
			$sth->execute($id,'titulo', $search->{'titulo'}, $desde);
		}
	
		if($search->{'tipo_documento'} ne ""){
			$sth->execute($id,'tipo_documento', $search->{'tipo_documento'}, $desde);
		}

		if($search->{'barcode'} ne ""){
			$sth->execute($id,'barcode', $search->{'barcode'}, $desde);
		}
	}

}

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



1;
__END__