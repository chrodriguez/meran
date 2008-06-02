package C4::AR::Busquedas;

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Catalogacion;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		&busquedaAvanzada
		&busquedaAvanzadaPaginada
		&busquedaCombinada

		&obtenerEdiciones
		&obtenerGrupos
		&obtenerDisponibilidadTotal

		&detalleNivel1
		&detalleNivel2
		&detalleOpacNivel2

		&detalleNivel1_copia

		&buscarMapeo
		&buscarMapeoTotal
		&buscarMapeoCampoSubcampo
		&buscarGrupos
		&buscarCamposMARC
		&buscarSubCamposMARC
		&buscarAutorPorCond
		&buscarDatoDeCampoRepetible
		&buscarTema

		&MARCDetailfecha
		&detalleNivel3MARC
		&detalleNivel2MARC
		&detalleNivel1MARC
	

		&getautor
		&getLevel
		&getCountry
		&getSupport
		&getLanguage
		&getItemType
		&getbranchname
		&getborrowercategory
		&getallborrowercategorys
		&getAvail
		&getTema
);

=item
buscarDatoReferencia
Busca el valor del dato que viene de referencia. Es un id que apunta a una tupla de una tabla y se buscan los campos que el usuario introdujo para que se vean. Se concatenan con el separador que el mismo introdujo.
=cut
sub buscarDatoReferencia(){
	my ($dato,$tabla,$campos,$separador)=@_;
	
	my $ident=&C4::AR::Catalogacion::obtenerIdentTablaRef($tabla);

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
sub getLibrarianEstCat(){
	my ($campo, $subcampo,$dato, $itemtype)= @_;

	my $dbh = C4::Context->dbh;
	my $query = "SELECT ec.*, idinforef, ir.referencia as tabla, campos, separador, orden";
	$query .= " FROM estructura_catalogacion ec LEFT JOIN informacion_referencias ir ";
	$query .= " ON (ec.id = ir.idestcat) ";
	$query .= " WHERE(ec.campo = ?)and(ec.subcampo = ?)and(ec.itemtype = ?) ";

	my $sth=$dbh->prepare($query);
   	$sth->execute($campo, $subcampo, $itemtype);
	my $nuevoDato;
	my $data=$sth->fetchrow_hashref();

	if($data && $data->{'visible'}){
		if($data->{'referencia'} && $dato ne ""){
			$nuevoDato=&buscarDatoReferencia($dato,$data->{'tabla'},$data->{'campos'},$data->{'separador'});
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
sub getLibrarianEstCatOpac(){
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
$query .= " FROM estructura_catalogacion_opac eco INNER JOIN";
$query .= " encabezado_item_opac eio ";
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
		my $query = "SELECT ec.*, idinforef, ir.referencia as tabla, campos, separador, orden";
		$query .= " FROM estructura_catalogacion ec LEFT JOIN informacion_referencias ir ";
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
sub getLibrarianMARCSubField(){
	my ($campo, $subcampo, $tipo)= @_;
	my $dbh = C4::Context->dbh;

	my $query = " SELECT * ";
	$query .= " FROM marc_subfield_structure ";
	$query .= " WHERE (tagfield = ? )and(tagsubfield = ?)";

	if($tipo eq "intra"){
#  		$query .= " and (obligatorio = 1 )";
	}

	my $sth=$dbh->prepare($query);
   	$sth->execute($campo, $subcampo);

	return $sth->fetchrow_hashref;
}

=item
getLibrarianIntra
Busca para un campo y subcampo, dependiendo el itemtype, como esta catalogado para mostrar en el template. Busca en la tabla estructura_catalogacion y sino lo encuentra lo busca en marc_subfield_structure que si o si esta.
=cut
sub getLibrarianIntra(){
	my ($campo, $subcampo,$dato, $itemtype) = @_;

#busca librarian segun campo, subcampo e itemtype
	my $librarian= &getLibrarianEstCat($campo, $subcampo, $dato,$itemtype);

#si no encuentra, busca para itemtype = 'ALL'
	if(!$librarian->{'liblibrarian'}){
		$librarian= &getLibrarianEstCat($campo, $subcampo, $dato,'ALL');
	}
	
	if($librarian->{'liblibrarian'} && !$librarian->{'visible'}){
		#Si esta catalogado y pero no esta visible retorna 0 para que no se vea el dato
		$librarian->{'liblibrarian'}=0;
		$librarian->{'dato'}="";
		return $librarian;
	}
	elsif(!$librarian->{'liblibrarian'}){
		$librarian= &getLibrarianMARCSubField($campo, $subcampo, 'intra');
		$librarian->{'dato'}=$dato;
	}
	return $librarian;
}

=item
getLibrarianOpac
Busca para un campo y subcampo, dependiendo el itemtype, como esta catalogado para mostrar en el template. Busca en la tabla estructura_catalogacion_opac y sino lo encuentra lo busca en marc_subfield_structure que si o si esta.
=cut
sub getLibrarianOpac(){
	my ($campo, $subcampo,$dato, $itemtype) = @_;
	my $textPred;	
	my $textSucc;
#busca librarian segun campo, subcampo e itemtype
	my $librarian= &getLibrarianEstCatOpac($campo, $subcampo, $dato, $itemtype);
#si no encuentra, busca para itemtype = 'ALL'
 	if(!$librarian){
 		$librarian= &getLibrarianEstCatOpac($campo, $subcampo, $dato, 'ALL');
 	}

#  	if(!$librarian){
#  		#Si esta catalogado y pero no esta visible retorna 0 para que no se vea el dato
#  		return 0;
#  	}

#         $textPred= $librarian->{'textpred'};
# 	$textSucc= $librarian->{'textsucc'};
# 	liblibrarian no se devuelve
# 	return $textPred." ".$textSucc;

	return $librarian;
}

sub getLibrarian(){
	my ($campo, $subcampo,$dato,$itemtype, $tipo)=@_;
	my $librarian;
	if($tipo eq "intra"){
		$librarian=&getLibrarianIntra($campo, $subcampo,$dato, $itemtype);
	}else{
		$librarian=&getLibrarianOpac($campo, $subcampo,$dato, $itemtype);
	} 
	return $librarian;
}

=item
buscarMapeo
Asocia los campos marc correspondientes con los campos de las tablas de los nivel 1, 2 y 3 (koha) correspondiente al parametro que llega.
=cut
sub buscarMapeo(){
	my ($tabla)= @_;
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM kohaToMARC WHERE tabla = ? ";
	
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
sub buscarMapeoTotal(){
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM kohaToMARC WHERE tabla like 'nivel%' ORDER BY tabla";
	
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

sub buscarMapeoCampoSubcampo(){
	my ($campo,$subcampo,$nivel)=@_;
	my $dbh = C4::Context->dbh;
	my $tabla="nivel".$nivel;
	my $campoTabla=0;
	my $query = " SELECT campoTabla FROM kohaToMARC WHERE tabla =? AND campo=? AND subcampo=?";
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
sub buscarSubCamposMapeo(){
	my ($campo)=@_;
	my $dbh = C4::Context->dbh;
	my %mapeo;
	my $llave;
	my $query = " SELECT * FROM kohaToMARC WHERE tabla like 'nivel%' AND campo = ?";
	
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
detalleNivel1
Trae todo los datos del nivel 1 para poder verlos en el template.
=cut
sub detalleNivel1(){
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my %llaves;
	my $i=0;
	my $autor= $nivel1->{'autor'};
	my $getLib=&getLibrarian('245', 'a', "",'ALL',$tipo);
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	$nivel1Comp[$i]->{'librarian'}= $getLib->{'liblibrarian'};
	$i++;

	$autor= &getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM nivel1_repetibles WHERE id1=? ORDER BY campo,subcampo";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	my $llave;
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		my $getLib=&getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},'ALL',$tipo);
		if(not exists($llaves{$llave})){
			$llaves{$llave}=$i;
			$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
			$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
			$nivel1Comp[$i]->{'dato'}= $getLib->{'dato'};
			$nivel1Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		else{
			my $pos=$llaves{$llave};
			$nivel1Comp[$pos]->{'dato'}.=", ".$getLib->{'dato'};
		}
	}
	$sth->finish;
	return @nivel1Comp;
}

=item
detalleNivel2
Trae todos los datos del nivel 2, para poder verlos en el template, tambien busca el detalle del nivel 3 asociados a cada nivel 2.
=cut
sub detalleNivel2(){
	my($id1,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my @nivel2=&buscarNivel2PorId1($id1);
	my $mapeo=&buscarMapeo('nivel2');
	my $id2;
	my $itemtype;
	my $tipoDoc;
	my $campo;
	my $subcampo;
	my @results;
	my $getLib;
# 	open(A,">/tmp/prueba.txt");
	my $j=0;
	foreach my $row(@nivel2){
		my $i=0;
		my @nivel2Comp;
		my %llaves;
		$id2=$row->{'id2'};
		$itemtype=$row->{'itemtype'};
		$tipoDoc=$row->{'tipo_documento'};
# 		print A "Entro en el for1 \n";
		foreach my $llave (keys %$mapeo){
# 			print A "Entro en el for2 \n";
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
# 			print A "llave: $llave, campo: $campo y subcampo: $subcampo\n ";
# 			my $lib=&getLibrarian($campo, $subcampo, $itemtype,$tipo);
# 			print A "lib: $lib\n";
			$getLib=&getLibrarian($campo, $subcampo,"" ,$itemtype,$tipo);
			$nivel2Comp[$i]->{'campo'}=$campo;
			$nivel2Comp[$i]->{'subcampo'}=$subcampo;
			$nivel2Comp[$i]->{'dato'}=$row->{$mapeo->{$llave}->{'campoTabla'}};
 			my $dato=$row->{$mapeo->{$llave}->{'campoTabla'}};
# 			print A "dato: $dato\n";
			$nivel2Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		my $query="SELECT * FROM nivel2_repetibles WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		my $llave2;
		while (my $data=$sth->fetchrow_hashref){
#  			print A "\n while---- $data->{'dato'} \n";
			$llave2=$data->{'campo'}.",".$data->{'subcampo'};
			$getLib=&getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,$tipo);
			if(not exists($llaves{$llave2})){
				$llaves{$llave2}=$i;
				$nivel2Comp[$i]->{'campo'}=$data->{'campo'};
				$nivel2Comp[$i]->{'subcampo'}=$data->{'subcampo'};
				$nivel2Comp[$i]->{'dato'}=$getLib->{'dato'};
# 				print A "datoLIB----$getLib->{'dato'}";
				$nivel2Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
				$i++;
			}
			else{
				my $pos=$llaves{$llave2};
				$nivel2Comp[$pos]->{'dato'}.=", ".$getLib->{'dato'};
			}
		}
		$sth->finish;
		$nivel2Comp[$i]->{'cantItems'}=$row->{'cantItems'};
		my($nivel3,$nivel3Comp)=&detalleNivel3($id2,$itemtype,$tipo);
	

		$nivel2Comp[$i]->{'loopnivel3'}=$nivel3;
		$nivel2Comp[$i]->{'loopnivel3Comp'}=$nivel3Comp;
		$results[$j]->{'resultado'}=\@nivel2Comp;
		$results[$j]->{'id2'}=$id2;
		$results[$j]->{'itemtype'}=$itemtype;
		$results[$j]->{'tipoDoc'}=$tipoDoc;
		
		$j++;
	}
#  	close(A);
	return(@results);
}

=item
detalleNivel3
Trae todos los datos del nivel 3, para poder verlos en el template.
=cut
sub detalleNivel3(){
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my ($disponibles,@nivel3)=&buscarNivel3PorId2($id2);
	my $mapeo=&buscarMapeo('nivel3');
	my @nivel3Comp;
	my %llaves;
	my @results;
	my $i=0;
	my $id3;
	my $campo;
	my $subcampo;
	my $getLib;
	$results[0]->{'nivel3'}=\@nivel3;
	$results[0]->{'disponibles'}=$disponibles;
	$results[0]->{'reservados'}=0;#FALTA !!!!! CUANDO SE EMPIEZE CON LAS RESERVAS
	$results[0]->{'prestados'}=0;#FALTA !!!!! CUANDO SE EMPIEZE CON LOS PRESTAMOS
	foreach my $row(@nivel3){
		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$getLib=&getLibrarian($campo, $subcampo, "",$itemtype,$tipo);
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
			$getLib=&getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,$tipo);
			if(not exists($llaves{$llave2})){
				$llaves{$llave2}=$i;
				$nivel3Comp[$i]->{'campo'}=$data->{'campo'};
				$nivel3Comp[$i]->{'subcampo'}=$data->{'subcampo'};
				$nivel3Comp[$i]->{'dato'}=$getLib->{'dato'};
				$nivel3Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
				$i++;
			}
			else{
				my $pos=$llaves{$llave2};
				$nivel3Comp[$pos]->{'dato'}.=", ".$getLib->{'dato'};
			}
		}
		$sth->finish;
	}
	return(\@results,\@nivel3Comp);
}

=item
buscarNivel3PorId2
Busca los datos del nivel 3 a partir de un id2 correspondiente a nivel 2.
=cut
sub buscarNivel3PorId2(){
	my ($id2)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM nivel3 WHERE id2 = ?";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);
	my @result;
	my $i=0;
	my $disponibles=0;
	my %infoNivel3;
	$infoNivel3{'cantParaSala'}=0;
	$infoNivel3{'cantParaPrestamo'}=0;
	$infoNivel3{'cantReservas'}=0;

	while(my $data=$sth->fetchrow_hashref){

		my $holdbranch= getbranchname($data->{'holdingbranch'});
		$data->{'holdbranch'}=$data->{'holdingbranch'};
		$data->{'holdingbranch'}=$holdbranch;
		
		my $homebranch= getbranchname($data->{'homebranch'});
		$data->{'hbranch'}=$data->{'homebranch'};
		$data->{'homebranch'}=$homebranch;
		
		my $wthdrawn=getAvail($data->{'wthdrawn'});
		if(!$data->{'wthdrawn'}){
		#wthdrawn = 0, Disponible
			$disponibles++;
		}

		$data->{'disponibilidad'}=$data->{'wthdrawn'};
		$data->{'wthdrawn'}=$wthdrawn->{'description'};
		
		my $issuetype=&C4::AR::Issues::IssueType($data->{'notforloan'});
		if($data->{'notforloan'} eq 'DO'){
			$data->{'forloan'}=1;
			$infoNivel3{'cantParaPrestamo'}++;
		}else{
			$infoNivel3{'cantParaSala'}++;
		}

		$data->{'issuetype'}=$data->{'notforloan'};
		$data->{'notforloan'}=$issuetype->{'description'};

		$result[$i]=$data;
		$i++;
	}

	return(\%infoNivel3,@result);
}

=item
obtenerEdiciones
obtiene las ediciones que pose un id de nivel 1.
=cut
sub obtenerEdiciones(){
	my ($id1, $itemtype)=@_;
	my @ediciones;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM nivel2 WHERE id1=? ";

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


sub obtenerGrupos {
  my ($id1,$itemtype)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from nivel2 left join nivel1 on nivel1.id1=nivel2.id1 where nivel2.id1=?";

  if($itemtype != -1 && $itemtype ne "" && $itemtype ne "ALL"){
		$query .=" and nivel2.tipo_documento = '".$itemtype."'";
	}

  my $sth=$dbh->prepare($query);
  $sth->execute($id1);
  my @result;
  my $res=0;
  my $data;
  while ( $data=$sth->fetchrow_hashref){
        $result[$res]->{'id2'}=$data->{'id2'};
        $result[$res]->{'edicion'}=buscarDatoDeCampoRepetible($data->{'id2'},"250","a","2");
        $result[$res]->{'anio_publicacion'}=$data->{'anio_publicacion'};
        $result[$res]->{'volume'}= buscarDatoDeCampoRepetible($data->{'id2'},"740","n","2");
        $res++;
        }
return (@result);
}


sub obtenerDisponibilidadTotal(){
	my ($id1,$itemtype)=@_;
	my @disponibilidad;
	my $dbh = C4::Context->dbh;
	my $query="SELECT count(*) as cant, notforloan FROM nivel3 WHERE id1=? ";
	my $sth;

	if($itemtype == -1 || $itemtype eq "" || $itemtype eq "ALL"){
	  $query .=" GROUP BY notforloan";
	
	  $sth=$dbh->prepare($query);
	  $sth->execute($id1);
	}else{#Filtro tb por tipo de item
	  $query .= " and id2 in ( SELECT id2 FROM nivel2 WHERE tipo_documento = ? )  GROUP BY notforloan";

	  $sth=$dbh->prepare($query);
	  $sth->execute($id1, $itemtype);
	}
	
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		if($data->{'notforloan'} eq 'DO'){
			$disponibilidad[$i]->{'tipoPrestamo'}="Para Domicilio:";
			$disponibilidad[$i]->{'prestados'}="Prestados: ";
			$disponibilidad[$i]->{'prestados'}.=0;#VER MAS ADELANTE!!!!!!!!!
			$disponibilidad[$i]->{'reservados'}="Reservados: ";
			$disponibilidad[$i]->{'reservados'}.=0;#VER MAS ADELANTE!!!!!!!!!
		}
		else{
			$disponibilidad[$i]->{'tipoPrestamo'}="Para Sala:";
		}
		$disponibilidad[$i]->{'cantTotal'}=$data->{'cant'};
		$i++;
	}
	return(@disponibilidad);
}


#*****************************************Prueba Miguel*******esta funcionando***********************************

sub detalleNivel1_copia(){
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my $i=0;
	my $getLib;
	my $autor= $nivel1->{'autor'};
	
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	$getLib= &getLibrarian('245', 'a',$nivel1->{'titulo'}, 'ALL',$tipo);
	$nivel1Comp[$i]->{'librarian'}= $getLib->{'textPred'};
	$i++;

	$autor= &getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM nivel1_repetibles WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data=$sth->fetchrow_hashref){
		$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
		$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
		$getLib= &getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, 'ALL',$tipo);
		$nivel1Comp[$i]->{'librarian'}= $getLib->{'textPred'};
		$nivel1Comp[$i]->{'dato'}= $getLib->{'dato'};
		$i++;
	}
	$sth->finish;
	return @nivel1Comp;
}



#*********************************************Detalle OPAC 2*******************************************



=item
detalleNivel3
Trae todos los datos del nivel 3, para poder verlos en el template.
=cut
sub detalleNivel3_Opac(){
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my ($infoNivel3,@nivel3)=&buscarNivel3PorId2($id2);
	my $mapeo=&buscarMapeo('nivel3');
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
# 	$results[0]->{'disponibles'}=$disponibles;
	$results[0]->{'reservados'}=0;#FALTA !!!!! CUANDO SE EMPIEZE CON LAS RESERVAS
	$results[0]->{'prestados'}=0;#FALTA !!!!! CUANDO SE EMPIEZE CON LOS PRESTAMOS
	foreach my $row(@nivel3){

		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$nivel3Comp[$i]->{'campo'}=$campo;
			$nivel3Comp[$i]->{'subcampo'}=$subcampo;
			$dato= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$getLib= &getLibrarian($campo, $subcampo, "", $itemtype,$tipo);
			$nivel3Comp[$i]->{'librarian'}= $getLib->{'textPred'};
			$nivel3Comp[$i]->{'dato'}= $dato;#$getLib->{'dato'};
			$i++;
		}
		$id3=$row->{'id3'};
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){
			$nivel3Comp[$i]->{'campo'}=$data->{'campo'};
			$nivel3Comp[$i]->{'subcampo'}=$data->{'subcampo'};
			$getLib= &getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'}, $itemtype,$tipo);
			$nivel3Comp[$i]->{'librarian'}= $getLib->{'textPred'};
			$nivel3Comp[$i]->{'dato'}= $getLib->{'dato'};

			$i++;
		}
		$sth->finish;
	}
	return(\@results,\@nivel3Comp);
}


#***************************************************************************************************************

#****************************************************MARC DETAIL**************************************************

sub detalleNivel1MARC(){
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my $i=0;
	my $autor= $nivel1->{'autor'};
	
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	my $librarian= &getLibrarianMARCSubField('245', 'a', 'opac');
	$nivel1Comp[$i]->{'librarian'}=  $librarian->{'liblibrarian'}; 
	$i++;

	$autor= &getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM nivel1_repetibles WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data=$sth->fetchrow_hashref){
		$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
		$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
		$nivel1Comp[$i]->{'dato'}= $data->{'dato'};
		$librarian= &getLibrarianMARCSubField($data->{'campo'}, $data->{'subcampo'},'opac');
		$nivel1Comp[$i]->{'librarian'}= $librarian->{'liblibrarian'}; 
	
		$i++;
	}
	$sth->finish;
	return @nivel1Comp;
}


=item
detalleNivel2MARC
Busca el nivel 2 segun id1 y id2, al resultado le agrega el nivel 1 y nivel 3
=cut
sub detalleNivel2MARC(){
	my($id1,$id2,$id3,$tipo,$nivel1)=@_;
	my $dbh = C4::Context->dbh;
	#Busca el nivel 2 segun id1 e id2, (retorna solo uno)
	my @nivel2=&buscarNivel2PorId1Id2($id1,$id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel2');
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
			$librarian=&getLibrarianMARCSubField($campo, $subcampo, 'opac');

			$marcResult[$i]->{'campo'}= $campo;
			$marcResult[$i]->{'subcampo'}= $subcampo;
			$marcResult[$i]->{'dato'}= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		my $query="SELECT * FROM nivel2_repetibles WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		while (my $data=$sth->fetchrow_hashref){
# my $getLib=&getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,'intra');
			$librarian=&getLibrarianMARCSubField($data->{'campo'}, $data->{'subcampo'},'opac');
			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $data->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};
# 			$marcResult[$i]->{'dato'}= $getLib->{'dato'};
# 			$marcResult[$i]->{'librarian'}= $getLib->{'liblibrarian'};

			$i++;
		}
		$sth->finish;

		#Busca datos de nivel 3 solo del ID pasado por parametro
		my($marcResult3)=&detalleNivel3MARC($id3,$itemtype,$tipo);


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
			$nombreCampo= &buscarNombreCampoMarc($campoAnt);
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
detalleNivel3MARC
trae el nivel3 completo (nivel3 y nivel3_repetibles), para mostrar en MARC,
segun id3 pasado por parametro
=cut
sub detalleNivel3MARC(){
	my ($id3,$itemtype,$tipo)=@_;

	my $dbh = C4::Context->dbh;
	my (@nivel3)=&buscarNivel3($id3);
	my $disponibles;
	my $mapeo=&buscarMapeo('nivel3');
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

			$librarian=&getLibrarianMARCSubField($campo, $subcampo, 'opac');

			$marcResult[$i]->{'campo'}= $campo;
			$marcResult[$i]->{'subcampo'}= $subcampo;
			$marcResult[$i]->{'dato'}= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};
	
			$i++;
		}
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){

 			$librarian=&getLibrarianMARCSubField($data->{'campo'}, $data->{'subcampo'}, 'opac');

			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $data->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		$sth->finish;
	}

	return(\@marcResult);
}

#devuelve toda la info en MARC de un item (id3 de nivel 3)
sub MARCDetail(){

	my ($id3)= @_;

	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM nivel3 WHERE id3=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3);

	my $data=$sth->fetchrow_hashref;

	my $id2= $data->{'id2'};
	my $id1= $data->{'id1'};

 	my $nivel1=&C4::AR::Catalogacion::buscarNivel1($id1); #C4::AR::Catalogacion;
 	my @autor=&getautor($nivel1->{'autor'});

	my @nivel1Loop= &detalleNivel1MARC($id1, $nivel1, 'opac');
	my @nivel2Loop= &detalleNivel2MARC($id1,$id2,$id3, 'opac',\@nivel1Loop);

	return @nivel2Loop;
}


=item
buscarCamposMARC
Busca los campos correspondiente a el parametro campoX, para ver en el tmpl de filtradoAvanzado.
=cut
sub buscarCamposMARC(){
	my ($campoX) =@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT DISTINCT nivel,tagfield FROM marc_subfield_structure ";
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
sub buscarSubCamposMARC(){
	my ($campo) =@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT tagsubfield FROM marc_subfield_structure ";
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
sub busquedaAvanzada(){
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
my $subcon1= "FROM nivel1 n1 INNER JOIN nivel1_repetibles n1r ON (n1.id1 = n1r.id1) WHERE ";
my @Subconsultas1;

if($nivel1 ne ""){
	$from1 = "nivel1 n1";
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
my $subcon2= "FROM nivel2 n2 INNER JOIN nivel2_repetibles n2r ON (n2.id2 = n2r.id2) WHERE ";
my @Subconsultas2;

if($nivel2 ne ""){
	
	$from2 = "nivel2 n2";
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
my $subcon3= "FROM nivel3 n3 INNER JOIN nivel3_repetibles n3r ON (n3.id3 = n3r.id3) WHERE ";
my @Subconsultas3;

if($nivel3 ne ""){
	$from3 = "nivel3 n3";
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
	#Se hizo una busqueda en el nivel1_repetibles
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
		#Se hizo una busqueda en el nivel2_repetibles
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
		#Se hizo una busqueda en el nivel3_repetibles
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
$queryCant=~ s/DISTINCT \(n.\.id1\) as id1/COUNT(*) /o;

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




sub busquedaAvanzadaPaginada(){
	my($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,$operador,$startRecord ,$numberOfRecords,$onlyCount)= @_;
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
my $subcon1= "FROM nivel1 n1 INNER JOIN nivel1_repetibles n1r ON (n1.id1 = n1r.id1) WHERE ";
my @Subconsultas1;

if($nivel1 ne ""){
	$from1 = "nivel1 n1";
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
my $subcon2= "FROM nivel2 n2 INNER JOIN nivel2_repetibles n2r ON (n2.id2 = n2r.id2) WHERE ";
my @Subconsultas2;

if($nivel2 ne ""){
	
	$from2 = "nivel2 n2";
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
my $subcon3= "FROM nivel3 n3 INNER JOIN nivel3_repetibles n3r ON (n3.id3 = n3r.id3) WHERE ";
my @Subconsultas3;

if($nivel3 ne ""){
	$from3 = "nivel3 n3";
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
	my $select1;	

	if($onlyCount){
		$select1="SELECT count(DISTINCT (n1.id1)) as cant ";
		
	}else{
		$select1="SELECT DISTINCT (n1.id1) as id1 ";
	}

	if($from1 ne ""){
		#Se hizo una busqueda en el nivel1
		$consultaN1=$select1." FROM (".$from1.") WHERE ".$where1;
		$pare1=")";
	}
	if($nivel1rep ne ""){
	#Se hizo una busqueda en el nivel1_repetibles
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

	my $select2;

	if($onlyCount){
		$select2="SELECT count(DISTINCT (n2.id1)) as cant ";
	}else{
		$select2="SELECT DISTINCT (n2.id1) as id1 ";
	}
	
	if($from2 ne ""){
		#Se hizo una busqueda en el nivel2
		$consultaN2=$select2." FROM (".$from2.") WHERE ".$where2;
		$pare2=")";
	}
	if($nivel2rep ne ""){
		#Se hizo una busqueda en el nivel2_repetibles
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

	my $select3;
	
	if($onlyCount){
		$select3="SELECT count(DISTINCT (n3.id1)) as cant ";
	}else{
		$select3="SELECT DISTINCT (n3.id1) as id1 ";
	}

	if($from3 ne ""){
		#Se hizo una busqueda en el nivel3
		$consultaN3=$select3." FROM (".$from3.") WHERE ".$where3;
		$pare3=")";
	}
	if($nivel3rep ne ""){
		#Se hizo una busqueda en el nivel3_repetibles
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

open (A, ">>/tmp/debug.txt");
print A "onlyCount $onlyCount \n";
if($onlyCount == 0){
#### Paginador ####
print A "dentro del if \n";
# 	if (defined $startRecord && defined $numberOfRecords) {
		$query.= " limit $startRecord,$numberOfRecords";
# 	}
}

print A "$query \n";
close(A);
my $sth=$dbh->prepare($query);
$sth->execute();

if($onlyCount){
	my $data=$sth->fetchrow_hashref;
	return $data->{'cant'};
}else{
	while(my $data=$sth->fetchrow_hashref){
		push(@resultsId1, $data->{'id1'});
	}

	return (\@resultsId1);
}

}#end busquedaAvanzada

=item
buscarItemtypes
Busca los distintos tipos de documentos que tiene una tupla del nivel1, se pasa como parametro el id1 de la misma.
=cut
sub buscarItemtypes(){
	my ($id1)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT DISTINCT tipo_documento FROM nivel2 WHERE id1=?";
	
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
sub buscarEncabezados(){
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
			FROM estructura_catalogacion_opac estco INNER JOIN encabezado_campo_opac eco
			ON (estco.idencabezado = eco.idencabezado)
			WHERE estco.visible = 1 AND estco.idencabezado = ? AND nivel=?";
# 			ORDER BY eco.orden ";

  	foreach my $itemtype (@$itemtypes){
		my @infoEncabezado;
	#busca los idencabezado para un tipo de item
		my $dbh = C4::Context->dbh;
		my $query="SELECT * FROM encabezado_item_opac WHERE itemtype=?";
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
sub buscarNivel2EnMARC(){
	my ($id1)=@_;
# open(A, ">>/tmp/debug.txt");
# print A "\n";
# print A "desde buscarNivel2EnMARC \n";
	my $dbh = C4::Context->dbh;
	my @nivel2=&buscarNivel2PorId1($id1);
	my $mapeo=&buscarMapeo('nivel2');
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
		my $query="SELECT * FROM nivel2_repetibles WHERE id2=?";
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

=item
detalleOpacNivel2
Busca todos los encabezados para los distintos tipo de documentos y toda la informacion de nivel2 para un id1 y devuelve el detalle de como se va a imprimir en el opac. (la visualización) 
=cut
sub detalleOpacNivel2(){
	my ($id1)=@_;
	my $n2itemtypes=&buscarItemtypes($id1);

open(A,">>/tmp/debug.txt");
print A "**************************************************************************************************\n";
print A "desde detalleOpanNivel2 \n";
	my ($encabezados_hash_ref)= &buscarEncabezados($n2itemtypes,2);
	my $nivel2Comp= &buscarNivel2EnMARC($id1);

print A "\n";
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

print A "********************************Configuracion de Visualizacion *********************************\n";
print A "itemtype desde result nivel 2 ".$itemtype."\n";
print A "id2 nivel 2 ".$nivel2->{'id2'}."\n";
		$id2= $nivel2->{'id2'};

		my $cant= scalar(@$infoEncabezados);

print A "cant: ".$cant."\n";
#proceso los encabezados
		for (my $i=0; $i < $cant; $i++){ 
print A "-------------------Encabezado: ".$infoEncabezados->[$i]->{'nombre'}."\n";

print A "grupoInd: ".$grupoInd."\n";

			$linea= $infoEncabezados->[$i]->{'linea'};
print A "-------------------linea: ".$infoEncabezados->[$i]->{'linea'}."\n";
	
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
						print A "llave: ".$llave."\n";
						print A "dato: ".$info->{$llave}->{'textpred'}." ".$dato."\n";

						print A "salida: ".$dato."\n";
						print A "\n";
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
				print A "salida: ".$salidaLinea."\n";
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
 		my($nivel3,$nivel3Comp)=&detalleNivel3_Opac($id2,$itemtype,'opac');
 		$result[$grupoInd]->{'loopnivel3'}=$nivel3;
 		$result[$grupoInd]->{'loopnivel3Comp'}=$nivel3Comp;	


 		$result[$grupoInd]->{'loopEncabezados'}= \@salidaTMP;
		$result[$grupoInd]->{'grupo'}= $grupoInd;
		$result[$grupoInd]->{'DivMARC'}="MARCDetail".$grupoInd;
		$result[$grupoInd]->{'DivDetalle'}="Detalle".$grupoInd;
		$grupoInd++;

	
	print A "\n";
	
  	}#end foreach my $nivel2
print A "**************************************************************************************************\n";
close(A);
	return @result;
}

sub buscarAutorPorCond(){
	my ($cond)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM autores WHERE completo".$cond." ORDER BY apellido";
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
	if ($nivel eq "1") {$niveln='nivel1_repetibles';$idn='id1';} elsif ($nivel eq "2"){$niveln='nivel2_repetibles';$idn='id2';} else {$niveln='nivel3_repetibles';$idn='id3';}

	my $dbh = C4::Context->dbh;
	my $query="SELECT dato FROM ".$niveln." WHERE campo = ? and subcampo = ? and ".$idn." = ?;";
	my $sth=$dbh->prepare($query);
	$sth->execute($campo,$subcampo,$id);
	my $data=$sth->fetchrow_hashref;
	return $data->{'dato'};
}


sub getautor {
    my ($idAutor) = @_;
    my @result;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select id,apellido,nombre,completo from autores where id = ?");
    $sth->execute($idAutor);
    my $data1 =$sth->fetchrow_hashref; 
    my @result;
    push(@result,$data1);
    $sth->finish();
    return($data1);
 }

sub getLevel
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from bibliolevel where code = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}



sub  getCountry
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from countries where iso = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getSupport
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from supports where idSupport = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLanguage
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from languages where idLanguage = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getItemType {
  my ($type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select description from itemtypes where itemtype=?");
  $sth->execute($type);
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  return ($dat->{'description'});
}


sub getbranchname
{
	my ($branchcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT branchname FROM branches WHERE branchcode = ?");
	$sth->execute($branchcode);
	my $branchname = $sth->fetchrow();
	$sth->finish();
	return $branchname;
} # sub getbranchname

=item getborrowercategory

  $description = &getborrowercategory($categorycode);

Given the borrower's category code, the function returns the corresponding
description for a comprehensive information display.

=cut

sub getborrowercategory
{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT description FROM categories WHERE categorycode = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	return $description;
} # sub getborrowercategory

sub getallborrowercategorys
{
	my $dbh = C4::Context->dbh;
	my %categories;
	my $sth = $dbh->prepare("SELECT description,categorycode FROM categories");
	$sth->execute();
	  while (my $cat=$sth->fetchrow_hashref) {
	  $categories{$cat->{'categorycode'}}=$cat;
	  }
	$sth->finish();
	return (\%categories);
} # sub getallorrowercategorys


sub getAvail
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from unavailable where code = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Temas, toma un id de tema y devuelve la descripcion del tema.
sub getTema(){
	my ($idTema)=@_;
	my $dbh = C4::Context->dbh;
        my $query = "SELECT * from temas where id = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($idTema);
        my $tema=$sth->fetchrow_hashref;
        $sth->finish();
	return($tema);
}


sub buscarTema
{
my ($search)=@_;

my $dbh = C4::Context->dbh;
my $query = '';
my @bind = ();
my @results;
my @key=split(' ',$search->{'tema'});
my $count=@key;
my $i=1;

	$query="Select distinct temas.id, temas.nombre from nivel1_repetibles inner join 
			temas on temas.id= nivel1_repetibles.dato  where (campo='650' and subcampo='a') and
			((temas.nombre like ? or temas.nombre like ?)";
			@bind=("$key[0]%","% $key[0]%");
			while ($i < $count){
					$query .= " and (temas.nombre like ? or temas.nombre like ?)";
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
	foreach my $field (qw(titulo autores.completo temas.nombre nivel1_repetibles.dato nivel2_repetibles.dato nivel3_repetibles.dato)){ 
		my @subclauses = ();
		foreach my $keyword (@key) { push @subclauses, "$field LIKE ? OR $field LIKE ?";}
		$condiciones[$index]= "(" . join(")\n\tOR (", @subclauses) . ")";
		$index++;
	}
	
	#CONSULTAS
	my @queries=(
		"SELECT id1 FROM nivel1 WHERE ".$condiciones[0], #TITULO
		"SELECT id1 FROM nivel1 left join autores on nivel1.autor = autores.id WHERE ".$condiciones[1], #AUTOR
		"SELECT id1 FROM nivel1_repetibles left join autores on nivel1_repetibles.dato = autores.id WHERE campo='700' and subcampo='a' and ".$condiciones[1], #Autores adicionales 700 a
		"SELECT id1 FROM nivel1_repetibles left join temas on nivel1_repetibles.dato = temas.id WHERE campo='650' and subcampo='a' and ".$condiciones[2], #Tema 650 a
		"SELECT id1 FROM nivel1_repetibles WHERE ".$condiciones[3], #nivel1_repetibles
		"SELECT nivel2.id1 FROM nivel2 right join nivel2_repetibles on nivel2.id2 = nivel2_repetibles.id2 WHERE ".$condiciones[4], #nivel2_repetibles
		"SELECT nivel3.id1 FROM nivel3 right join nivel3_repetibles on nivel3.id3 = nivel3_repetibles.id3 WHERE ".$condiciones[5], #nivel3_repetibles
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



sub buscarGrupos(){
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
		$resto="FROM nivel2_repetibles n2r INNER JOIN nivel2 n2 ON (n2r.id2=n2.id2)";
		$resto.=" INNER JOIN nivel1 n1 ON (n2.id1=n1.id1)";
		$resto.=" WHERE (campo=020 and subcampo='a' and dato=?) or (campo=022 and subcampo='a' and dato=?) ";
# 		$sth=$dbh->prepare($query);
#         	$sth->execute($isbn,$isbn);
		push(@bind,$isbn);
		push(@bind,$isbn);
	}
	else{
		$query2="SELECT DISTINCT n1.* ";
		$resto="FROM nivel1 n1 WHERE titulo like ? ";
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
		my $autor=C4::Search::getautor($data->{'autor'});
		$result[$i]{'autor'}=$autor->{'completo'};
		$result[$i]{'id1'}=$data->{'id1'};
		$result[$i]{'id2'}=$data->{'id2'};
		$result[$i]{'itemtype'}=$data->{'tipo_documento'};
		$i++;
	}
	$sth->finish;
	return($cantidad,\@result);
}
