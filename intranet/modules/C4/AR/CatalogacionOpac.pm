package C4::AR::CatalogacionOpac;

#
#Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC
#Tambien en la carga de los items en los distintos niveles.
#

use strict;
require Exporter;
use C4::Context;
use C4::Database;
use C4::AR::Validaciones;

use vars qw($VERSION @EXPORT @ISA);

# set the version for version checking
$VERSION = 0.01;

@ISA=qw(Exporter);

@EXPORT=qw(
	&buscarEncabezados
	&encabezadoEnLinea
	&buscarInfoCampo
	&buscarInfoSubCampo
	&buscarTiposItemParaEncabezado
	&verificarExistenciaEncabezadoItem
	&verificarExistenciaCatalogacion
	&verificarExistenciaEncabezado
	&traerCampos
	&traerSubCampos
	&traerVisualizacion
	&insertarCatalogacion
	&UpdateCatalogacion
	&insertarEncabezadoItem
	&insertarEncabezado
	&deleteCatalogacion
	&deleteEncabezado
	&traerKohaToMARC
	&insertarMapeoKohaToMARC
	&deleteMapeoKohaToMARC
	&deleteEncabezado
	&modificarVisulizacion
	&modificarLineaEncabezado
	&modificarNombreEncabezado
	&subirOrden
	&bajarOrden
);


sub insertarMapeoKohaToMARC(){
	my ($tabla, $campoKoha, $campo, $subcampo)=@_;
	my $dbh = C4::Context->dbh;

	my $queryExiste = " SELECT count(*) as cant ";
	$queryExiste .= " FROM kohaToMARC ";
	$queryExiste .= " WHERE (campo = ?)and(subcampo = ?) ";
	$queryExiste .= " and(campoTabla = ?)and( tabla = ?) ";
	my $sth=$dbh->prepare($queryExiste);
	$sth->execute($campo, $subcampo, $campoKoha, $tabla);
	my $data= $sth->fetchrow_hashref;

	if($data->{'cant'} eq 0){

	  my $query="INSERT INTO kohaToMARC (tabla, campoTabla, campo, subcampo) ";
	  $query .= " VALUES (?, ? ,? ,?)";
	  $sth=$dbh->prepare($query);
          $sth->execute($tabla, $campoKoha, $campo, $subcampo);
	}
}

sub deleteMapeoKohaToMARC(){
	my ($id)=@_;
	my $dbh = C4::Context->dbh;
	my $query="DELETE FROM kohaToMARC ";
	$query .= " WHERE idmap = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id);
}

sub deleteEncabezado(){
	my ($id)=@_;
	my $dbh = C4::Context->dbh;
	my $query="DELETE FROM encabezado_campo_opac ";
	$query .= " WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id);
}

=item
trae el mapeo de tablas koha a MARC
=cut
sub traerKohaToMARC(){
	my ($tabla)=@_;
  	my $dbh = C4::Context->dbh;

	my $query = "SELECT ktm.idmap, ktm.tabla, ktm.campoTabla, ktm.campo, ktm.subcampo ";
	$query .= ", mse.liblibrarian ";
	$query .= " FROM kohaToMARC ktm LEFT JOIN marc_subfield_structure mse ";
	$query .= " ON (mse.tagfield = ktm.campo)and(mse.tagsubfield = ktm.subcampo) ";
	$query .= " WHERE tabla = ? ";
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);
}

=item
buscarCamposObligatorios
Busca los campos MARC de la tabla marc_subfield_structure que son obligatorios para el standar de catalogacion MARC
=cut
sub buscarInfoCampo(){
	my ($campo)=@_;
  
	my $dbh = C4::Context->dbh;
	my $query = "SELECT tagfield, liblibrarian";
	$query .=" FROM `marc_tag_structure` ";
  	$query .=" WHERE tagfield like ? OR  liblibrarian like ?";
	$query .=" ORDER BY liblibrarian";

	my $sth=$dbh->prepare($query);
        $sth->execute($campo.'%', '%'.$campo.'%');

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);
}


sub buscarInfoSubCampo(){
# 	my ($campo, $subcampo)=@_;
	my ($campo)=@_;
  
	my $dbh = C4::Context->dbh;

# 	my $query = "SELECT tagfield, CONCAT_WS(' - ',tagsubfield,liblibrarian) as subcampo, tagsubfield, liblibrarian ";
	my $query = "SELECT tagsubfield, CONCAT_WS(' - ',tagsubfield,liblibrarian) as subcampo";
	$query .=" FROM `marc_subfield_structure` ";
# 	$query .=" WHERE tagfield = ? and  tagsubfield like ? ";
	$query .=" WHERE tagfield = ? ";
	$query .=" ORDER BY tagsubfield, liblibrarian ";

	my $sth=$dbh->prepare($query);
#         $sth->execute($campo, $subcampo.'%');
	$sth->execute($campo);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);
}

sub buscarEncabezados(){

	my ($nivel, $itemtype)=@_;
	
	my $dbh = C4::Context->dbh;
=item
	my $query = "SELECT idencabezado, nombre, orden, linea";
	$query .=" FROM encabezado_campo_opac ";
	$query .=" WHERE nivel = ? ";
	$query .="ORDER BY nombre";
=cut

	my $query = " SELECT eco.idencabezado, eco.nombre, eco.orden, eco.linea ";
	$query .= " FROM encabezado_campo_opac eco INNER JOIN encabezado_item_opac eio ";
	$query .= " ON (eco.idencabezado = eio.idencabezado) ";
	$query .= " WHERE nivel = ? and eio.itemtype = ? ";
	$query .= " ORDER BY orden ";

	my $sth=$dbh->prepare($query);
#         $sth->execute();
	$sth->execute($nivel, $itemtype);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}
	$sth->finish;
	return ($cant, @results);
}


sub encabezadoEnLinea(){

	my ($encabezado)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "SELECT idencabezado, nombre, orden,linea";
	$query .=" FROM encabezado_campo_opac where idencabezado = ? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($encabezado);

	my $data=$sth->fetchrow_hashref;

	$sth->finish;
	return ($data->{'linea'});
}


sub buscarTiposItemParaEncabezado(){

	my ($encabezado)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "SELECT i.itemtype as itemtype, description";
	$query .=" FROM encabezado_item_opac eio INNER JOIN itemtypes i ";
	$query .=" ON ( i.itemtype = eio.itemtype )";
	$query .=" WHERE eio.idencabezado = ? ";
	$query .=" ORDER BY i.description";

	my $sth=$dbh->prepare($query);
        $sth->execute($encabezado);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}

	$sth->finish;
	return ($cant, @results);
}

sub verificarExistenciaEncabezadoItem(){
#se verifica la existencia de la tupla $idencabezado, $iditemtype
	my ($idencabezado, $iditemtype)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "SELECT count(*) ";
	$query .=" FROM encabezado_item_opac ";
	$query .=" WHERE idencabezado = ? AND itemtype = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado, $iditemtype);
	
	my $data=$sth->fetchrow;
	$sth->finish;
	return ($data);
}

sub verificarExistenciaCatalogacion(){
#se verifica la existencia de la tupla $idencabezado, $campo, $subcampo
	my ($idencabezado, $campo, $subcampo)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "SELECT count(*) ";
	$query .=" FROM estructura_catalogacion_opac ";
	$query .=" WHERE idencabezado = ? AND campo = ? AND subcampo = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado, $campo, $subcampo);
	
	my $data=$sth->fetchrow;
 	$sth->finish;
	return ($data);
}

sub verificarExistenciaEncabezado(){
#se verifica la existencia de la tupla $encabezado
	my ($encabezado)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "SELECT count(*) ";
	$query .=" FROM encabezado_campo_opac ";
	$query .=" WHERE nombre = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($encabezado);
	
	my $data=$sth->fetchrow;
 	$sth->finish;
	return ($data);
}

#insertar iditemtype, idencabezado en tabla encabezado_item_opac
sub insertarEncabezadoItem(){
	my ($idencabezado, $iditemtype)=@_;
	my $dbh = C4::Context->dbh;
	my $query="INSERT INTO encabezado_item_opac ";
	$query .= " (idencabezado, itemtype)";
	$query .= " VALUES (?,?)";
	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado, $iditemtype);
}


sub insertarCatalogacion(){
	my ($campo, $subcampo, $textoPred, $textoSucc, $separador, $idencabezado)=@_;
	my $dbh = C4::Context->dbh;
	my $query="INSERT INTO estructura_catalogacion_opac ";
	$query .= " (campo, subcampo, textpred, textsucc, separador, idencabezado)";
	$query .= " VALUES (?,?,?,?,?,?)";
	my $sth=$dbh->prepare($query);
        $sth->execute($campo, $subcampo, $textoPred, $textoSucc, $separador, $idencabezado);
}

sub UpdateCatalogacion(){
	my ($textoPred, $textoSucc, $separador, $idestcatopac) = @_;

	my $dbh = C4::Context->dbh;
	my $query="UPDATE estructura_catalogacion_opac ";
	$query .= " SET textpred = ?, textsucc = ?, separador = ? ";
	$query .= " WHERE idestcatopac = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($textoPred, $textoSucc, $separador, $idestcatopac);

}

sub modificarVisulizacion(){
	my ($idestcat, $visible)=@_;
	$visible= ($visible + 1) % 2;
	my $dbh = C4::Context->dbh;
	my $query=" UPDATE estructura_catalogacion_opac ";
	$query .= " SET visible = ? ";
	$query .= " WHERE idestcatopac = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($visible, $idestcat);
}

sub modificarLineaEncabezado(){
	my ($idencabezado, $linea)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" UPDATE encabezado_campo_opac SET linea = ? ";
	$query .= " WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($linea, $idencabezado);
}

sub modificarNombreEncabezado(){
	my ($idencabezado, $nombre)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" UPDATE encabezado_campo_opac SET nombre = ? ";
	$query .= " WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($nombre, $idencabezado);
}


=item
subirOrden
Sube el orden en la vista del encabezado
=cut
sub subirOrden(){
	my($idencabezado, $orden, $itemtype, $action)=@_;

	$orden=$orden-1;
	&modificarOrdenEncabezado($idencabezado, $orden, $itemtype, $action);
}

=item
subirOrden
Baja el orden en la vista del encabezado.
=cut
sub bajarOrden(){
	my($idencabezado, $orden, $itemtype, $action)=@_;

	$orden=$orden+1;
	&modificarOrdenEncabezado($idencabezado, $orden, $itemtype, $action);
}

=item
Modifica el orden del encabezado, ;)
=cut
sub modificarOrdenEncabezado(){
	my ($idencabezado, $orden, $itemtype, $action)=@_;

	my $dbh = C4::Context->dbh;

	#obtengo el id del encabezado q se encuentra cerca
	my $query=" SELECT eco.idencabezado FROM encabezado_campo_opac eco ";
	$query .= " INNER JOIN encabezado_item_opac eio ON (eco.idencabezado = eio.idencabezado) ";
	$query .= " WHERE(eio.itemtype = ?)AND(eco.orden = ?) ";

	my $sth=$dbh->prepare($query);
        $sth->execute($itemtype ,$orden);

	#actualiza al encabezado el nuevo orden
	my $query=" UPDATE encabezado_campo_opac SET orden = ? ";
	$query .= " WHERE idencabezado = ? ";
	my $sth2=$dbh->prepare($query);
	$sth2->execute($orden, $idencabezado);
	
	if($action eq "up"){
		$orden= $orden + 1;
	}else{
		$orden= $orden - 1;
	}
	$query= " UPDATE encabezado_campo_opac SET orden = ? ";
	$query .= " WHERE idencabezado = ? ";
        
	if(my $data=$sth->fetchrow){
		#actualizo el orden del vecino
		$sth2=$dbh->prepare($query);
		$sth2->execute($orden, $data);
	}
}

sub insertarEncabezado(){
	my ($encabezado, $nivel, $itemtypes_arrayref)=@_;
	my $dbh = C4::Context->dbh;
	my $query="INSERT INTO encabezado_campo_opac ";
	$query .= " (nombre, nivel)";
	$query .= " VALUES (?, ?)";
	my $sth=$dbh->prepare($query);

        $sth->execute($encabezado, $nivel);

	$query="SELECT max(idencabezado) FROM encabezado_campo_opac ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	my $data=$sth->fetchrow;	

	my $idencabezado= $data;
	my $itemtype;
	my $cant= @$itemtypes_arrayref;
 	for (my $i=0;$i<$cant;$i++){
		$itemtype= $itemtypes_arrayref->[$i]->{'ID'};
 		&insertarEncabezadoItem($idencabezado, $itemtype);
 	}
}

sub deleteCatalogacion(){
	my ($idestcatopac)=@_;
	my $dbh = C4::Context->dbh;
	my $query="DELETE FROM estructura_catalogacion_opac ";
	$query .= " WHERE idestcatopac = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($idestcatopac);
}

=item
sub deleteEncabezadoItem(){
	my ($idestcatopac, $itemtype)=@_;
	my $dbh = C4::Context->dbh;
	my $query="DELETE FROM encabezado_item_opac ";
	$query .= " WHERE idencabezado = ?";
	$query .= " AND itemtype = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($idestcatopac, $itemtype);
}
=cut

sub deleteEncabezado(){
	my ($idencabezado)=@_;
	my $dbh = C4::Context->dbh;
	my $query=" DELETE FROM encabezado_campo_opac ";
	$query .= " WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado);

	$query=" DELETE FROM encabezado_item_opac ";
	$query .= " WHERE idencabezado = ?";
	$sth=$dbh->prepare($query);
        $sth->execute($idencabezado);

	$query=" DELETE FROM estructura_catalogacion_opac ";
	$query .= " WHERE idencabezado = ?";
	$sth=$dbh->prepare($query);
        $sth->execute($idencabezado);
#esto deberia ser una transaccion!!!!!!!!!!!!!!!!!
}

sub traerCampos(){
	my ($idencabezado, $campo, $nivel) =@_;
	my $dbh = C4::Context->dbh;

=item
	my $query=" SELECT tagfield as campo FROM marc_subfield_structure ";
	$query .=" WHERE obligatorio = '1' and tagfield like '".$campo."%'";
  	$query .=" UNION ( ";
	$query .=" SELECT DISTINCT campo FROM estructura_catalogacion  ";
	$query .=" WHERE campo like '".$campo."%'"." and nivel = ? and (campo,subcampo) not in ";
	$query .=" (SELECT DISTINCT campo, subcampo FROM estructura_catalogacion_opac ";
	$query .=" WHERE campo like '".$campo."%'".") )";
=cut

	my $query=" SELECT tagfield as campo FROM marc_subfield_structure ";
	$query .=" WHERE obligatorio = '1' and tagfield like '".$campo."%'";
  	$query .=" UNION ( ";
	$query .=" SELECT DISTINCT eco.campo ";
	$query .=" FROM estructura_catalogacion ec INNER JOIN estructura_catalogacion_opac eco ";
	$query .=" ON (ec.campo = eco.campo) ";
	$query .=" WHERE ec.campo like '".$campo."%'"." and ec.nivel = ? )";


	my $sth=$dbh->prepare($query);
# 	$sth->execute($nivel, $nivel);
	$sth->execute($nivel);
	
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'campo'});
	}

	$sth->finish;
	return (@results);	
}


sub traerSubCampos(){
	my ($idencabezado, $campo, $itemtype) =@_;
	my $dbh = C4::Context->dbh;

=item
my $query=" SELECT tagsubfield as subcampo FROM marc_subfield_structure ";
	$query .=" WHERE obligatorio = '1' and tagfield = ?";
  	$query .=" and tagsubfield not in ( SELECT DISTINCT subcampo FROM estructura_catalogacion ";
	$query .=" WHERE campo = ?) "; 
	$query .=" UNION SELECT DISTINCT subcampo FROM estructura_catalogacion ";
	$query .=" WHERE campo = ? "; 
=cut

 	my $query=" SELECT tagsubfield as subcampo FROM marc_subfield_structure  ";
 	$query .=" WHERE obligatorio = '1' and tagfield = ? union ";
	$query .=" (SELECT DISTINCT subcampo FROM estructura_catalogacion  ";
	$query .=" WHERE campo = ? ) UNION ";
	$query .=" (SELECT DISTINCT subcampo FROM estructura_catalogacion_opac ";
	$query .=" WHERE campo = ?) ";


	my $sth=$dbh->prepare($query);
	$sth->execute($campo, $campo, $campo);
# 	$sth->execute($campo, $campo);		
	
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'subcampo'});
	}

	$sth->finish;
	return (@results);	
}

sub traerVisualizacion(){
	my ($idencabezado) =@_;
	my $dbh = C4::Context->dbh;

	my $query=" SELECT * ";
	$query .=" FROM estructura_catalogacion_opac ";
	$query .=" WHERE idencabezado = ?";
	$query .=" ORDER BY campo, subcampo ";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado);
	
	my $cant= 0;
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data);
		$cant++;
	}

	$sth->finish;
	return ($cant, @results);	
}
