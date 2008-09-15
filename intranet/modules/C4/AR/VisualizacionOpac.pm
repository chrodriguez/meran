package C4::AR::VisualizacionOpac;

#
#Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC
#Tambien en la carga de los items en los distintos niveles.
#

use strict;
require Exporter;
use C4::Context;

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

	&traerCampos
	&traerSubCampos
	&traerVisualizacion
	&traerKohaToMARC

	&insertarCatalogacion	
	&t_insertarEncabezado
	&insertarMapeoKohaToMARC

	&deleteCatalogacion
	&t_deleteEncabezado
	&deleteMapeoKohaToMARC
	&deleteEncabezado

	&modificarVisulizacion
	&modificarLineaEncabezado
	&modificarNombreEncabezado
	&UpdateCatalogacion

	&subirOrden
	&bajarOrden
);


sub insertarMapeoKohaToMARC{
	my ($tabla, $campoKoha, $campo, $subcampo)=@_;

	my $dbh = C4::Context->dbh;

	my $queryExiste = "	SELECT count(*) AS cant
				FROM kohaToMARC
				WHERE (campo = ?)AND(subcampo = ?)
				AND(campoTabla = ?)AND( tabla = ?) ";

	my $sth=$dbh->prepare($queryExiste);
	$sth->execute($campo, $subcampo, $campoKoha, $tabla);
	my $data= $sth->fetchrow_hashref;

	if($data->{'cant'} eq 0){

		my $query="	INSERT INTO kohaToMARC (tabla, campoTabla, campo, subcampo)
				VALUES (?, ? ,? ,?)";
	
		$sth=$dbh->prepare($query);
		$sth->execute($tabla, $campoKoha, $campo, $subcampo);
	}
}

sub deleteMapeoKohaToMARC{
	my ($id)=@_;

	my $dbh = C4::Context->dbh;
	my $query="	DELETE FROM kohaToMARC WHERE idmap = ? ";
	my $sth=$dbh->prepare($query);
        $sth->execute($id);
}

sub deleteEncabezado{
	my ($id)=@_;

	my $dbh = C4::Context->dbh;
	my $query="DELETE FROM encabezado_campo_opac WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id);
}

=item
trae el mapeo de tablas koha a MARC
=cut
sub traerKohaToMARC{
	my ($tabla)=@_;
  	my $dbh = C4::Context->dbh;

	my $query = "	SELECT ktm.idmap, ktm.tabla, ktm.campoTabla, ktm.campo, ktm.subcampo, mse.liblibrarian
			FROM kohaToMARC ktm LEFT JOIN marc_subfield_structure mse
			ON (mse.tagfield = ktm.campo) AND (mse.tagsubfield = ktm.subcampo)
			WHERE tabla = ? ";

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
sub buscarInfoCampo{
	my ($campo)=@_;
  
	my $dbh = C4::Context->dbh;
	my $query = "	SELECT tagfield, liblibrarian
			FROM `marc_tag_structure`
			WHERE tagfield like ? OR  liblibrarian like ?
			ORDER BY liblibrarian ";

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


sub buscarInfoSubCampo{
	my ($campo)=@_;
  
	my $dbh = C4::Context->dbh;

	my $query = "	SELECT tagsubfield, CONCAT_WS(' - ',tagsubfield,liblibrarian) AS subcampo
			FROM `marc_subfield_structure` 
			WHERE tagfield = ?
			ORDER BY tagsubfield, liblibrarian ";

	my $sth=$dbh->prepare($query);
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

sub buscarEncabezados{

	my ($nivel, $itemtype)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "	SELECT eco.idencabezado, eco.nombre, eco.orden, eco.linea
			FROM encabezado_campo_opac eco INNER JOIN encabezado_item_opac eio
			ON (eco.idencabezado = eio.idencabezado)
			WHERE nivel = ? and eio.itemtype = ?
			ORDER BY orden ";

	my $sth=$dbh->prepare($query);
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


sub encabezadoEnLinea{

	my ($encabezado)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "	SELECT idencabezado, nombre, orden,linea
			FROM encabezado_campo_opac 
			WHERE idencabezado = ? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($encabezado);

	my $data=$sth->fetchrow_hashref;

	$sth->finish;
	return ($data->{'linea'});
}


sub buscarTiposItemParaEncabezado{
	my ($encabezado)=@_;
	
	my $dbh = C4::Context->dbh;

	my $query = "	SELECT i.itemtype as itemtype, description
			FROM encabezado_item_opac eio INNER JOIN itemtypes i
			ON ( i.itemtype = eio.itemtype )
			WHERE eio.idencabezado = ?
			ORDER BY i.description ";

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

sub verificarExistenciaEncabezadoItem{
#se verifica la existencia de la tupla $idencabezado, $iditemtype
	my ($idencabezado, $iditemtype)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query ="	SELECT count(*)
			FROM encabezado_item_opac 
			WHERE idencabezado = ? AND itemtype = ? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado, $iditemtype);
	
	my $data=$sth->fetchrow;
	$sth->finish;
	return ($data);
}

sub verificarExistenciaCatalogacion{
#se verifica la existencia de la tupla $idencabezado, $campo, $subcampo
	my ($idencabezado, $campo, $subcampo)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "	SELECT count(*)
			FROM estructura_catalogacion_opac
			WHERE idencabezado = ? AND campo = ? AND subcampo = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado, $campo, $subcampo);
	
	my $data=$sth->fetchrow;
 	$sth->finish;
	return ($data);
}

sub verificarExistenciaEncabezado{
#se verifica la existencia de la tupla $encabezado
	my ($encabezado)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query = "	SELECT count(*)
			FROM encabezado_campo_opac
			WHERE nombre = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($encabezado);
	
	my $data=$sth->fetchrow;
 	$sth->finish;
	return ($data);
}

#insertar iditemtype, idencabezado en tabla encabezado_item_opac
sub insertarEncabezadoItem{
	my ($idencabezado, $iditemtype)=@_;

	my $dbh = C4::Context->dbh;
	my $query="	INSERT INTO encabezado_item_opac (idencabezado, itemtype)
			VALUES (?,?)";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado, $iditemtype);
}


sub insertarCatalogacion{
	my ($campo, $subcampo, $textoPred, $textoSucc, $separador, $idencabezado)=@_;

	my $dbh = C4::Context->dbh;
	my $query="	INSERT INTO estructura_catalogacion_opac
			(campo, subcampo, textpred, textsucc, separador, idencabezado)
			VALUES (?,?,?,?,?,?) ";
	my $sth=$dbh->prepare($query);
        $sth->execute($campo, $subcampo, $textoPred, $textoSucc, $separador, $idencabezado);
}

sub UpdateCatalogacion{
	my ($textoPred, $textoSucc, $separador, $idestcatopac) = @_;

	my $dbh = C4::Context->dbh;
	my $query="	UPDATE estructura_catalogacion_opac
			SET textpred = ?, textsucc = ?, separador = ?
			WHERE idestcatopac = ? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($textoPred, $textoSucc, $separador, $idestcatopac);

}

sub modificarVisulizacion{
	my ($idestcat, $visible)=@_;

	$visible= ($visible + 1) % 2;
	my $dbh = C4::Context->dbh;
	my $query="	UPDATE estructura_catalogacion_opac
			SET visible = ?
			WHERE idestcatopac = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($visible, $idestcat);
}

sub modificarLineaEncabezado{
	my ($idencabezado, $linea)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" 	UPDATE encabezado_campo_opac SET linea = ?
			WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($linea, $idencabezado);
}

sub modificarNombreEncabezado{
	my ($idencabezado, $nombre)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" 	UPDATE encabezado_campo_opac SET nombre = ? 
			WHERE idencabezado = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($nombre, $idencabezado);
}


=item
subirOrden
Sube el orden en la vista del encabezado
=cut
sub subirOrden{
	my($idencabezado, $orden, $itemtype, $action)=@_;

	$orden=$orden-1;
	&modificarOrdenEncabezado($idencabezado, $orden, $itemtype, $action);
}

=item
subirOrden
Baja el orden en la vista del encabezado.
=cut
sub bajarOrden{
	my($idencabezado, $orden, $itemtype, $action)=@_;

	$orden=$orden+1;
	&modificarOrdenEncabezado($idencabezado, $orden, $itemtype, $action);
}

=item
Modifica el orden del encabezado, ;)
=cut
sub modificarOrdenEncabezado{
	my ($idencabezado, $orden, $itemtype, $action)=@_;

	my $dbh = C4::Context->dbh;

	#obtengo el id del encabezado q se encuentra cerca
	my $query=" 	SELECT eco.idencabezado FROM encabezado_campo_opac eco
			INNER JOIN encabezado_item_opac eio ON (eco.idencabezado = eio.idencabezado)
			WHERE(eio.itemtype = ?)AND(eco.orden = ?) ";

	my $sth=$dbh->prepare($query);
        $sth->execute($itemtype ,$orden);

	#actualiza al encabezado el nuevo orden
	my $query=" 	UPDATE encabezado_campo_opac SET orden = ?
			WHERE idencabezado = ? ";
	my $sth2=$dbh->prepare($query);
	$sth2->execute($orden, $idencabezado);
	
	if($action eq "up"){
		$orden= $orden + 1;
	}else{
		$orden= $orden - 1;
	}
	$query= " 	UPDATE encabezado_campo_opac SET orden = ?
			WHERE idencabezado = ? ";
        
	if(my $data=$sth->fetchrow){
		#actualizo el orden del vecino
		$sth2=$dbh->prepare($query);
		$sth2->execute($orden, $data);
	}
}

sub insertarEncabezado{
	my ($encabezado, $nivel, $itemtypes_arrayref)=@_;

	my $dbh = C4::Context->dbh;
	my $query="	INSERT INTO encabezado_campo_opac (nombre, nivel)
			VALUES (?, ?)";

	my $sth=$dbh->prepare($query);

        $sth->execute($encabezado, $nivel);

	$query="	SELECT max(idencabezado) FROM encabezado_campo_opac ";
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

sub t_insertarEncabezado {
	
	my($encabezado, $nivel, $itemtypes_arrayref)=@_;
	my $reservaGrupo= 0;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {

		my $cant= 0;
		$cant= &verificarExistenciaEncabezado($encabezado);
	
		if($cant eq 0){

			insertarEncabezado($encabezado, $nivel, $itemtypes_arrayref);	
			$dbh->commit;
			$codMsg= 'VO800';
		}
	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B410';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'VO801';
	}
	$dbh->{AutoCommit} = 1;

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub deleteCatalogacion{
	my ($idestcatopac)=@_;

	my $dbh = C4::Context->dbh;
	my $query="	DELETE FROM estructura_catalogacion_opac
			WHERE idestcatopac = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($idestcatopac);
}

sub deleteEncabezado{
	my ($idencabezado)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" 	DELETE FROM encabezado_campo_opac
			WHERE idencabezado = ?";

	my $sth=$dbh->prepare($query);
        $sth->execute($idencabezado);

	$query=" 	DELETE FROM encabezado_item_opac
			WHERE idencabezado = ?";

	$sth=$dbh->prepare($query);
        $sth->execute($idencabezado);

	$query=" 	DELETE FROM estructura_catalogacion_opac
			WHERE idencabezado = ?";

	$sth=$dbh->prepare($query);
        $sth->execute($idencabezado);
}

sub t_deleteEncabezado {
	
	my($idencabezado)=@_;
	my $reservaGrupo= 0;

	my ($error, $codMsg,$paraMens);
	
	my $dbh = C4::Context->dbh;
	my ($paramsReserva);
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	eval {

		deleteEncabezado($idencabezado);	
		$dbh->commit;
		$codMsg= 'VO803';
	};

	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B411';
		&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'VO802';
	}
	$dbh->{AutoCommit} = 1;

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
	return ($error, $codMsg, $message);
}

sub traerCampos{
	my ($idencabezado, $campo, $nivel) =@_;
	my $dbh = C4::Context->dbh;

	my $query= "	SELECT DISTINCT ec.campo  FROM estructura_catalogacion ec  
			WHERE ec.campo LIKE '".$campo."%'"." AND ec.nivel = ?  ";

	my $sth=$dbh->prepare($query);
	$sth->execute($nivel);
	
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'campo'});
	}

	$sth->finish;
	return (@results);	
}


sub traerSubCampos{
	my ($idencabezado, $campo, $itemtype) =@_;
	my $dbh = C4::Context->dbh;

 	my $query=" 	SELECT tagsubfield as subcampo FROM marc_subfield_structure
			WHERE obligatorio = '1' and tagfield = ? UNION
			(SELECT DISTINCT subcampo FROM estructura_catalogacion
			WHERE campo = ? ) UNION
			(SELECT DISTINCT subcampo FROM estructura_catalogacion_opac
			WHERE campo = ?) ";


	my $sth=$dbh->prepare($query);
	$sth->execute($campo, $campo, $campo);
	
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data->{'subcampo'});
	}

	$sth->finish;
	return (@results);	
}

sub traerVisualizacion{
	my ($idencabezado) =@_;
	my $dbh = C4::Context->dbh;

	my $query=" 	SELECT *
			FROM estructura_catalogacion_opac
			WHERE idencabezado = ?
			ORDER BY campo, subcampo ";

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
