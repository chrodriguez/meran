package C4::AR::Catalogacion;


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
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=item
Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC
Tambien en la carga de los items en los distintos niveles y de la creacion del catalogo.
=cut
use strict;
require Exporter;
use C4::Context;
use C4::AR::Busquedas;
use C4::Date;
use C4::AR::Utilidades;
use C4::Modelo::CatNivel1::Manager;
use C4::Modelo::CatNivel1;
use C4::Modelo::CatNivel2::Manager;
use C4::Modelo::CatNivel2;
use C4::Modelo::CatNivel3::Manager;
use C4::Modelo::CatNivel3;
use C4::Modelo::CatPrefMapeoKohaMarc;
use C4::Modelo::CatPrefMapeoKohaMarc::Manager;


use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&crearCatalogo
	&cantidadItem	
	&buscarCamposObligatorios
	&buscarCamposMARCdeNivel
	&buscarSubCampo
	&buscarCamposModificados
	&buscarInfoReferencia
	&buscarInfoRefCampoSubcampo
	&buscarCamposModificadosInfoReferencia
	&buscarCamposModificadosYObligatorios
	&buscarCampo
	&buscarDatosCampoMARC
	&buscarNivel1
	&buscarNivel1Completo
	&buscarNivel2
	&buscarNivel2Completo
	&buscarNivel2PorId1
	&buscarNivel2PorId1Id2
	&buscarNivel3
	&buscarNivel3Completo
	&buscarNivel3PorId2
	&buscarMaximoHabilitado
	&buscarNombreCampoMarc
	&actualizarCamposModificados
	&actualizarInfoReferencia
	&guardarCamposModificados
	&guardarCampoTemporal
	&guardarInfoReferencia
	&modificarCampo
	&modificarNivel1Completo
	&modificarNivel2Completo
	&modificarNivel3Completo
	&obtenerCamposTablaRef
	&obtenerValorTablaRef
 	&obtenerIdentTablaRef2
    &t_eliminarNivel1
	&t_eliminarNivel2
	&t_eliminarNivel3
);


=item
crearCatalogo
Busca la informacion que se tienen de los campos marc que estan catalogados para poder crear los componentes desde el cliente. Tambien sirve para la modificacion de los nivel, recibe una referencia a hash con los datos completos del nivel correspondiente para asignar el valor guardado a los campos marc recuperados.
paramtros($indice,$nivelComp,$cantMod,$itemtype,%results):
	   $indice => numero que identifica el comienzo de los id de los componentes que se van a crear.
	   $nivelComp => referencia a un arreglo de los datos de nivel que corresponda, sirve para la modificacion del nivel. Puede venir vacio (no vino por la parte de modificacion).
	   $cantMod => cantidad de campos que estan guardados en la base de datos y van a ser modificados.
	   $itemtype =>tipo de item para el cual se esta creando el catalogo, se usa en la parte de de busqueda de los campos temporales.
	   %results => hash con los datos obtenidos de la tabla estructura_catalogacion y marc_subfield_structure, son los campos que se tiene que ver para la catalogacion de los items.
return($i,@resultsdata):
	$i => cantidad de componentes creadas
	@resultsdata => arreglo con los datos de los campos marc que estan guardados en la base de datos.
=cut
sub crearCatalogo{
	my($indice,$nivelComp,$cantMod,$itemtype,%results)=@_;
	my @resultsdata;
	my $tipoComponente;
	my $i=$indice;
	my $valor="";#Valor 
	my $varios=0;
	my $idRep="";#Para guardar el id de la tabla de nivelx_repetible para la modificacion
	my @keys= keys %results;
	@keys= sort{$results{$a}->{'intranet_habilitado'} <=> $results{$b}->{'intranet_habilitado'}} @keys;
# open(B,">>/tmp/debugCrearCat.txt");
# print B "cant: $cantMod\n";
	foreach my $row (@keys){
# print B "\n\notra vuelta\n";
		$valor="";
		my $llave=$results{$row}->{'campo'}.",".$results{$row}->{'subcampo'};
		$results{$row}->{'indice'}=$i;
		$i++;
# print B "llave result: $llave\n";
		#Para la parte de modificacion de un nivel obtiene el valor del input.
		if($cantMod != 0){
			if(exists($nivelComp->{$llave})){
				$nivelComp->{$llave}->{'visto'}=1;
				$idRep=$nivelComp->{$llave}->{'idRep'};
				$valor=$nivelComp->{$llave}->{'valor'};
				$varios=$nivelComp->{$llave}->{'varios'};
# print B "valor: $valor\n";
			}
			else{
				$idRep="";
				$valor="";
				$varios=0;
			}
		}#Fin $cant
		$results{$row}->{'idRep'}=$idRep;
		$results{$row}->{'valor'}=$valor;
		$results{$row}->{'varios'}=$varios;
		$results{$row}->{'valTextArea'}="";
		$results{$row}->{'valText'}="";
# print B "referencia:     $results{$row}->{'referencia'} \n";
		if($results{$row}->{'referencia'}){
			&obtenerValoresRef($row,$valor,\%results);
		}
		push(@resultsdata,$results{$row});
	}#fin FOR @keys
# print B "\nfor de nivel completo\n";
	foreach my $datosCampo (%$nivelComp){
#PARA OBTENER LOS DATOS DE LOS CAMPOS TEMPORALES PARA LA MODIFICACION!!!!!!!!!
		if($nivelComp->{$datosCampo}->{'visto'} == 0 && $nivelComp->{$datosCampo}->{'valor'} ne ""){
# print B "entro al if\n";
			my $campo=$nivelComp->{$datosCampo}->{'campo'};
			my $subcampo=$nivelComp->{$datosCampo}->{'subcampo'};
# print B "campo: $campo ---- subcampo: $subcampo\n";
			my $campoTemp=&buscarCampoTemporal($campo,$subcampo,$itemtype);
			if($campoTemp){#El campo esta en el catalogo. Si no esta no se muestra nada.
				my $id=$campoTemp->{'id'};
				my $valor=$nivelComp->{$datosCampo}->{'valor'};
				$results{$id}=$campoTemp;
				$results{$id}->{'idRep'}=$nivelComp->{$datosCampo}->{'idRep'};
				$results{$id}->{'valor'}=$valor;
				$results{$id}->{'varios'}=$nivelComp->{$datosCampo}->{'varios'};
				if($campoTemp->{'referencia'}){
					&obtenerValoresRef($id,$valor,\%results);
				}
				$results{$id}->{'indice'}=$i;
				$i++;
				push(@resultsdata,$results{$id});
			}
		}
	}
	$nivelComp="";
# close(B);
	return($i,@resultsdata);
}

=item
buscarCampoTemporal
busca toda la informacion que se guardo para un campo temporal.
Se usa en la funcion creaCatalogo.
=cut
sub buscarCampoTemporal{
	my($campo,$subcampo,$itemtype)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_estructura_catalogacion WHERE campo=? AND subcampo=? AND itemtype =? AND intranet_habilitado = 0";
	my $sth=$dbh->prepare($query);
	$sth->execute($campo,$subcampo,$itemtype);
	my @results;
	my $data;
	if($data=$sth->fetchrow_hashref){
		if($data->{'referencia'}){
			my $ref=&buscarCamposModificadosInfoReferencia($data->{'id'});
			$data->{'tabla'}=$ref->{'tabla'};
			$data->{'idinforef'}=$ref->{'idinforef'};
			$data->{'orden'}=$ref->{'orden'};
			$data->{'campos'}=$ref->{'campos'};
			$data->{'separador'}=$ref->{'separador'};
		}
	}
	return($data);
}

=item
obtenerValoresRef
obtiene los valores de los componentes que tienen referencia a una tabla, para la edicion.
Agrega los datos obtenidos a la referencia de hash que contiene toda la info del componente.
=cut
sub obtenerValoresRef{
	my ($row,$valor,$results)=@_;
	my $campos=$results->{$row}->{'campos'};
	my $tabla=$results->{$row}->{'tabla'};
	my $orden=$results->{$row}->{'orden'};
	my $sepa=$results->{$row}->{'separador'};
	my $ident=&C4::AR::Utilidades::obtenerIdentTablaRef($tabla);
	my $tipoComponente=$results->{$row}->{'tipo'};
	if($tipoComponente eq "combo"){
		my ($opciones,$hashOp)=C4::AR::Utilidades::obtenerValoresTablaRef($tabla,$ident,$campos,$orden);
		$results->{$row}->{'opciones'}=$opciones;
	}
	elsif(($tipoComponente eq "texta" || $tipoComponente eq "texa2") && $valor ne ""){
		my @idsTablaRef= split("#",$valor);
		my $valTextArea="";
		foreach my $id (@idsTablaRef){
			my $valText=obtenerValorTablaRef($tabla,$ident,$campos,$sepa,$id);
			$valTextArea.="\n".$valText;
		}
		$valTextArea=substr($valTextArea,1,length($valTextArea));
		$results->{$row}->{'valTextArea'}=$valTextArea;
	}
	elsif($valor ne ""){
		my $valText=obtenerValorTablaRef($tabla,$ident,$campos,$sepa,$valor);
		$results->{$row}->{'valText'}=$valText;
	}
}


=item
buscarNombreCampoMarc
Busca el nombre del campo marc en la tabla marc_tag_structure.
=cut
sub buscarNombreCampoMarc{
	my ($tagField)=@_;
	my $dbh = C4::Context->dbh;
	my $nombre="";
	my $rep="";
	my $query = "SELECT liblibrarian, repeatable";
	$query .=" FROM pref_estructura_campo_marc ";
	$query .=" WHERE tagfield=?";

	my $sth=$dbh->prepare($query);
        $sth->execute($tagField);
	if (my $data=$sth->fetchrow_hashref){
		$nombre=$data->{'liblibrarian'};
		if($data->{'repeatable'}){
			$rep="(R)";
		}
		else{
			$rep="(NR)";
		}
	}
	$sth->finish;
	$nombre.=" ".$rep;
	return ($nombre);
}

=item
buscarCamposMARCdeNivel
Busca los campos MARC de la tabla marc_subfield_structure de un nivel dado
=cut
sub buscarCamposMARCdeNivel{
	my ($nivel) =@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT * ";
	$query .= " FROM pref_estructura_subcampo_marc ";
	$query .= " WHERE nivel=?";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($nivel);
	
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data);
	}

	$sth->finish;
	return (@results);
}


=item
buscarSubCampo
Esta funcion busca los subcampos de los campos MARC, recibe como parametro el campo seleccionado.
Realiza la busqueda sobre 2 tablas estructura_catalogacion (estan los subcampos seleccionados por el usuario) y marc_subfield_structure (estan los subcampos propios de marc con su nombre original).
Filtra a los subcampos del usuario para que no se repitan
=cut
sub buscarSubCampo{
	#Ver posibilidad de SP!!!
	my ($tagField,$nivel,$itemType)=@_;
	my $dbh = C4::Context->dbh;
	#Busco en la tabla estructura_catalogacion por si ya esta ingresado
	my $query="SELECT subcampo as tagsubfield,liblibrarian, intranet_habilitado,obligatorio ";
	$query .= "FROM cat_estructura_catalogacion ";
	$query .= "WHERE campo = ? AND nivel=? AND itemtype=? ";
	$query .= "AND intranet_habilitado <> 0 "; 
	$query .= "ORDER BY subcampo ";

	my $sth=$dbh->prepare($query);
        $sth->execute($tagField,$nivel,$itemType);
	
	my %results;
	while(my $data=$sth->fetchrow_hashref){
		$results{$data->{'tagsubfield'}}=$data;
	}

	#Busco en la tabla marc_subfield_structure todos los subcampos
	$query="SELECT tagsubfield,liblibrarian,repeatable,obligatorio ";
	$query.=" FROM pref_estructura_subcampo_marc ";
	$query.=" WHERE tagfield = ? AND nivel=? ORDER BY tagsubfield";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($tagField,$nivel);
	my %results2;
	while(my $data=$sth->fetchrow_hashref){
		#Si no existe el subcampo en la tabla estructura_catalogacion se ingresa en la hash
		if (not exists($results{$data->{'tagsubfield'}})){
			($results2{$data->{'tagsubfield'}}=$data);
		}
		#Si esta deshabilitado se agrega para que se pueda modificar
		elsif($results{$data->{'intranet_habilitado '}}!= 0 || $data->{'repeatable'} ){
			($results2{$data->{'tagsubfield'}}=$data);
		}
	}
	$sth->finish;	
	return (\%results2);
}

=item
buscarCamposModificados
Busca los campos que se encuentran en la tabla estructura_catalogacion que estan habilitados
=cut
## FIXME DEPRECATED
sub buscarCamposModificados{
	my ($nivel,$itemType)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT * ";
	$query .= "FROM cat_estructura_catalogacion ";
	$query .= "WHERE intranet_habilitado > '0' AND nivel=? ";
	$query .= "AND itemtype=? ORDER BY intranet_habilitado ";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($nivel,$itemType);
	
	my @results;
	while(my $data=$sth->fetchrow_hashref){
		push (@results, $data);
	}
	$sth->finish;
	return (@results);
}


=item
actualizarCamposModificados
Actualiza los cambios hecho en un campo modificado; recibe como parametro el id del campo que se modifico junto con el texto nuevo para el campo y el tipo de input deseado para mostrar los datos.
Y si el campo estaba deshabilitado el parametro intra toma el ultimo lugar en el orden, si esta habilitado intra tiene el valor 0.
=cut
sub actualizarCamposModificados{
	my ($id,$textoMod,$tipoInput,$intra,$ref)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query="UPDATE cat_estructura_catalogacion ";
	$query .= "SET liblibrarian = ?,tipo=?, referencia=?";
	if($intra){
		$query.=", intranet_habilitado='".$intra."'";
	}
	$query .=" WHERE id=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($textoMod,$tipoInput,$ref,$id);
	$sth->finish;
}

=item
actualizarInfoReferencia
Actualiza los cambios hechos en la informacion de referencia de un campo, esto se hace si es que ya tenia la info de referencia.
Si no hay info de referencia del campo se inserta en la tabla.
=cut
sub actualizarInfoReferencia{
	my ($idinforef,$tabla,$orden,$campoRef,$separador)=@_;
	my $dbh = C4::Context->dbh;
	my $query="UPDATE pref_informacion_referencia ";
	$query .= "SET referencia = ?, orden= ?, campos=?, separador=? WHERE idinforef=? ";
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla,$orden,$campoRef,$separador,$idinforef);
	$sth->finish;
	
}

=item
buscarMaximoHabilitado
Busca el maximo campo para generar un nuevo maximo para generar el orden del campo.
=cut
sub buscarMaximoHabilitado{
	my($tmpl,$itemType,$nivel)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT max(".$tmpl."_habilitado) FROM cat_estructura_catalogacion WHERE itemtype=? AND nivel=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($itemType,$nivel);
	my $nuevoMax=$sth->fetchrow + 1;
	return($nuevoMax);
}

=item
modificarCampo
Actualiza los cambios hecho en un campo modificado; recibe como parametro el id del campo que se modifico junto con el texto nuevo para el campo y el tipo de input deseado para mostrar los datos.
Y si el campo estaba deshabilitado el parametro intra toma el ultimo lugar en el orden, si esta habilitado intra tiene el valor 0.
=cut
sub modificarCampo{
	my ($id,$objeto)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my $selectInput=$objeto->{'tipoInput'};
	my $textoMod=$objeto->{'lib'};
	my $tabla=$objeto->{'tabla'};
	my $ordenMod=$objeto->{'orden'};
	my $camposRefMod=$objeto->{'camposRef'};
	my $separadorMod=$objeto->{'separador'};
	my $ref=0;
	if($tabla != -1){
		$ref=1;
		&guardarInfoReferencia($id,$tabla,$ordenMod,$camposRefMod,$separadorMod);
	}
	else{
		my $query="DELETE FROM pref_informacion_referencia WHERE idestcat = ?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id);
	}
	&actualizarCamposModificados($id,$textoMod,$selectInput,0,$ref);
	$dbh->commit;
	$dbh->{AutoCommit} = 1;
}

=item
gurdarCamposModificados
Guarda un nuevo campo en la tabla estructura_catalogacion.
=cut
sub guardarCamposModificados{
	my ($nivel,$itemType,$objeto)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my $id=-1;
	my $campo=$objeto->{'campo'};
	my $subcampo=$objeto->{'subcampo'};
	my $textoLib=$objeto->{'lib'};
	my $obligatorio=$objeto->{'obligatorio'};
	my $tipoInput=$objeto->{'tipoInput'};
	my $tabla=$objeto->{'tabla'};
	my $intra=&buscarMaximoHabilitado("intranet",$itemType,$nivel);#El orden, como se van a ver en el tmpl
	my $ref =($tabla != -1);
	my $query="SELECT * FROM cat_estructura_catalogacion WHERE campo=? AND subcampo=? AND itemtype=? AND intranet_habilitado=0 ";
	my $sth=$dbh->prepare($query);
	$sth->execute($campo,$subcampo,$itemType);
	if(my $data=$sth->fetchrow_hashref){
		$id=$data->{'id'};
		&actualizarCamposModificados($data->{'id'},$textoLib,$tipoInput,$intra,$ref);
	}
	else{
		$id=&insertarCamposMod($campo,$subcampo,$itemType,$textoLib,$obligatorio,$tipoInput,$ref,$nivel,$intra);
		
	}
	if($id != -1){
		my $orden= $objeto->{'orden'};
		my $campoRef= $objeto->{'camposRef'};
		my $separador = $objeto->{'separador'};
		if($tabla!= -1 && $campoRef ne '' && $separador ne ''){
			&guardarInfoReferencia($id,$tabla,$orden,$campoRef,$separador);
		}
	}
	$dbh->commit;
	$dbh->{AutoCommit} = 1;
	$sth->finish;
	return($id);
}

=item
insertarCamposMod
Hace el insert en la tabla estructura_catalogacion.
=cut
sub insertarCamposMod{
	my ($field,$subfield,$itemType,$textoLib,$obligatorio,$tipoInput,$ref,$nivel,$intra)=@_;
	my $dbh = C4::Context->dbh;
	my $query="INSERT INTO cat_estructura_catalogacion ";
	$query .= " (campo,subcampo,itemtype,liblibrarian,tipo,referencia,nivel,obligatorio,intranet_habilitado)";
	$query .= " VALUES (?,?,?,?,?,?,?,?,?)";
	my $sth=$dbh->prepare($query);
        $sth->execute($field,$subfield,$itemType,$textoLib,$tipoInput,$ref,$nivel,$obligatorio,$intra);
	my $query2="SELECT MAX(id) FROM cat_estructura_catalogacion";
	$sth=$dbh->prepare($query2);
	$sth->execute;
	my $id=$sth->fetchrow;
	return($id);
}

=item
guardarCampoTemporal
Si el campo no esta guardado en estructura_catalogacion se guardan los datos del campo temporal pero deshabilitado, si tiene referencia tambien se guardan los datos.
Si el campo ya esta guardado, primero busca si en las tabla de niveles hay datos guardados para ese campo, si es asi las modificaciones hechas (si es que las hay), no tiene efecto y se setean al obejto los campos necesesarios para que esto se cumpla, por el contrario si no hay datos, se efectuan la modificacion del campo, tanto de la parte de estructura_catalogacon como la de informacion_referencia (Se toma como si no estuviera guardado el campo)
=cut
sub guardarCampoTemporal{
	my ($objeto,$nivel,$itemtype)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my $campo=$objeto->{'campo'};
	my $subcampo=$objeto->{'subcampo'};
    #PARA VER SI YA ESTA GUARDADO!!!
	my $query="SELECT id FROM cat_estructura_catalogacion WHERE campo=? AND subcampo=? AND nivel=? AND (itemtype=? OR itemtype='ALL')"; 
	my $sth=$dbh->prepare($query);
	$sth->execute($campo,$subcampo,$nivel,$itemtype);
	my $id=$sth->fetchrow_hashref;
	my $lib=$objeto->{'liblibrarian'};
	my $tipo=$objeto->{'tipo'};
	my $ref=$objeto->{'referencia'};
	my $tabla=$objeto->{'tabla'};
	my $orden=$objeto->{'orden'};
	my $campos=$objeto->{'campos'};
	my $separador=$objeto->{'separador'};
	if(!$id){
		$id=&insertarCamposMod($campo,$subcampo,$itemtype,$lib,0,$tipo,$ref,$nivel,0);
		if($ref){
			&insertarInfoRef($id,$tabla,$orden,$campos,$separador);
		}
	}
	else{
		my $campoTemp;
		my $hayDatos=&buscarDatosCampoMARC($nivel,$campo,$subcampo,$dbh);
		$objeto->{'hayDatos'}=$hayDatos;
		if($hayDatos){
			$campoTemp=&buscarCamposModificadosInfoReferencia($id->{'id'});
			$objeto->{'tipo'}=$campoTemp->{'tipo'};
			if($campoTemp->{'referencia'}){
				$objeto->{'tabla'}=$campoTemp->{'tabla'};
				$objeto->{'orden'}=$campoTemp->{'orden'};
				$objeto->{'campos'}=$campoTemp->{'campos'};
				$objeto->{'separador'}=$campoTemp->{'separador'};
			}
			else{
				$objeto->{'referencia'}=0;
				$objeto->{'tabla'}= -1;
			}
		}
		else{
			&actualizarCamposModificados($id->{'id'},$lib,$tipo,0,$ref);
			if($ref){
				&guardarInfoReferencia($id->{'id'},$tabla,$orden,$campos,$separador);
			}
		}
		$id=1;
	}
	$dbh->commit;
	$dbh->{AutoCommit} = 1;
	$sth->finish;
	return($id);
}

=item
buscarDatosCampoTemp
Busca en las tablas de niveles correspondiente al paramentro de entrada, para ver si hay algun dato para el campo y subcampo que entran como paramentros tambien para el itemtype.
Retorna 1 si hay datos y 0 si no los hay.
=cut
sub buscarDatosCampoMARC{
	my ($nivel,$campo,$subcampo,$dbh)=@_;
	if($dbh eq ""){
		$dbh = C4::Context->dbh;
	}
	my $campoTabla=C4::AR::Busquedas::buscarMapeoCampoSubcampo($campo,$subcampo,$nivel); #C4::AR::Busquedas::
	my $tabla="nivel".$nivel;
	my $query;
	my @blind;
	my $hayDatos=0;
	my $sth;
	if(!$campoTabla){
		my $tablaRep=$tabla."_repetible";
		my $id="id".$nivel;
		$query ="SELECT dato FROM ".$tabla." t INNER JOIN ".$tablaRep." tr ON (t.".$id."=tr.".$id.") ";
		$query.="WHERE campo=? AND subcampo=?";
		$sth=$dbh->prepare($query);
		$sth->execute($campo,$subcampo);
	}
	else{
		$query="SELECT ".$campoTabla." FROM ".$tabla. " WHERE ". $campoTabla . " <> '' " ;
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	
	if(my $data=$sth->fetchrow_hashref){
		$hayDatos=1;
	}
	return $hayDatos;
}

=item
guardarInfoReferencia
Guarda los datos en la tabla informacion_referencias, si ya exite la informacion de referencia para ese campo se actualiza.
=cut
sub guardarInfoReferencia{
	my ($idestcat,$tabla,$orden,$campoRef,$separador)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM pref_informacion_referencia WHERE idestcat=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($idestcat);
	
	if(my $data=$sth->fetchrow_hashref){
		&actualizarInfoReferencia($data->{'idinforef'},$tabla,$orden,$campoRef,$separador);
	}
	else{
		&insertarInfoRef($idestcat,$tabla,$orden,$campoRef,$separador);
	}
	$sth->finish;
}

=item
insertarInfoRef
Hace el insert en la tabla informacion_referencia.
=cut
sub insertarInfoRef{
	my($idestcat,$tabla,$orden,$campoRef,$separador)=@_;
	my $dbh = C4::Context->dbh;
	my $query="INSERT INTO pref_informacion_referencia ";
	$query .= "(idestcat,referencia,orden,campos,separador) VALUES (?,?,?,?,?)";
	my $sth=$dbh->prepare($query);
        $sth->execute($idestcat,$tabla,$orden,$campoRef,$separador);
}

=item
obtenerCamposTablaRef
Obtiene los campos de la tabla que se pasa como parametro y tambien devuelve un tupla como ejemplo para el usuario de la misma tabla
=cut
sub obtenerCamposTablaRef{
	my ($tabla)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SHOW FIELDS FROM $tabla";
	my $sth=$dbh->prepare("SHOW FIELDS FROM $tabla");
	$sth->execute();
	
	my %results;
	while(my $data=$sth->fetchrow_hashref){
		$results{$data->{'Field'}}=$data->{'Field'};
	}
	$sth->finish;
	
	#Para mostrar un ejemplo de la tabla a la cual se hizo referencia
	$sth=$dbh->prepare("SELECT * FROM $tabla LIMIT 1");
	$sth->execute();
	my $data2=$sth->fetchrow_hashref();
	my $ejemplo="( - ";
	foreach my $campo (keys %results){
		$ejemplo .= $campo.": ".$data2->{$campo}." - ";
	}
	$ejemplo.=")";
	$sth->finish;
	return ($ejemplo, %results);
}

# creo q no se usa!!!!!!!!!!!!!!!!!!!!!!!
sub obtenerIdentTablaRef2{
	my ($tabla)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT nomcamporeferencia,camporeferente FROM pref_tabla_referencia WHERE referencia=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($tabla);
	return($sth->fetchrow_hashref());
}


=item
obtenerValorTablaRef
Obtiene el valor del los campos correspondientes al id que viene como paramentro.
=cut
sub obtenerValorTablaRef{
	my ($tabla,$ident,$campos,$sepa,$id)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT ".$ident." as id,".$campos;
	$query .=" FROM ".$tabla;
	$query .= " WHERE ".$ident." = ?";
	my $sth=$dbh->prepare($query);
	$sth->execute($id);
	my @arrayCampos=split(",",$campos);
	if(scalar(@arrayCampos) == 1 ){$sepa="";}
	my $valor="";
	if(my $data=$sth->fetchrow_hashref){
		foreach my $dato (@arrayCampos){
			$valor.=$sepa.$data->{$dato};
		}
	}
	return ($valor);
}

=item
buscarInfoReferencia
Busca la informacion de referecia de un campo marc determinado (campo, subcampo), para un tipo de item (itemtype)
=cut
sub buscarInfoReferencia{
	my($idestcat)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT referencia AS tabla, campos, orden,separador "; 
	$query .= "FROM pref_informacion_referencia "; 
	$query .= "WHERE idestcat=? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($idestcat);
	return($sth->fetchrow_hashref());
}

sub buscarInfoRefCampoSubcampo{
	my($campo,$subcampo,$itemtype)=@_;
	my $dbh = C4::Context->dbh;
	my $tabla=-1;
	my $habilitado=0;
	my @bind;
	my $query="SELECT id,ir.referencia AS tabla,intranet_habilitado FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ON (ec.id=ir.idestcat) WHERE ec.campo=? AND ec.subcampo=?";
	push(@bind,$campo);
	push(@bind,$subcampo);
	if($itemtype ne "" && $itemtype ne "ALL"){
		$query.=" AND ec.itemtype <> ?";
		push(@bind,$itemtype);
	}
	my $ok=0;
	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	while(my $data=$sth->fetchrow_hashref()){
		if($data->{'tabla'} ne "" && !$ok){
			$tabla=$data->{'tabla'};
			$habilitado=$data->{'intranet_habilitado'};
			$ok=1;
		}
	}
	return($tabla,$habilitado);
}

=item
buscarCamposModificadosInfoReferencia
Busca la informacion de catalogacion y referencia de un campo marc determinado (campo, subcampo), para un tipo de item (itemtype)
=cut
sub buscarCamposModificadosInfoReferencia{
	my($idestcat)=@_;
	my $dbh = C4::Context->dbh;

	my $query="SELECT ec.*, ir.referencia AS tabla, idinforef, campos, orden,separador "; 
	$query .= "FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ";
	$query .= "ON (ec.id=ir.idestcat) WHERE ec.id=? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($idestcat);
	return($sth->fetchrow_hashref());
}

=item
buscarCamposModificadosYObligatorios
Busca los campos modificados y los obligatorios, si estos ultimos no estan modificados se agregan a la hash a devolver, de esta manera los campos obligatorios estaran siempre en la catalogacion
=cut
sub buscarCamposModificadosYObligatorios{
	my($nivel,$itemtype)=@_;
	my $dbh = C4::Context->dbh;
	my %results;
	my %llaves;
	my $orden=1;
	my $query;
	#Busco en la tabla estructura_catalogacion por si ya esta ingresado
	$query = "SELECT ec.*, ir.referencia AS tabla, idinforef, campos, orden,separador "; 
	$query.= "FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ";
	$query.= "ON (ec.id=ir.idestcat) ";
	$query.= "WHERE nivel=? AND itemtype=? AND intranet_habilitado > '0' ORDER BY intranet_habilitado ";
	my $sth=$dbh->prepare($query);
        $sth->execute($nivel,$itemtype);
	
	while(my $data=$sth->fetchrow_hashref){
		$data->{'nivel'}=$nivel;
		my $llave=$data->{'campo'}.",".$data->{'subcampo'};
		$results{$data->{'id'}}=$data;
		$llaves{$llave}=$llave;#Hash que tiene los campos y subcampos
		$orden=$data->{'intranet_habilitado'};
	}
	$query="(SELECT campo FROM cat_estructura_catalogacion ";
	$query .="WHERE nivel=? AND itemtype=? AND intranet_habilitado > '0' ";
	$query .="AND campo = c AND subcampo = s) ORDER BY intranet_habilitado";


	my $query2="SELECT id,campo AS c, subcampo AS s,liblibrarian,intranet_habilitado, ec.referencia, tipo, ";
	$query2 .= "ec.itemtype, ec.obligatorio , ir.referencia AS tabla, idinforef, campos, orden,separador ";
	$query2 .= "FROM cat_estructura_catalogacion ec LEFT JOIN pref_informacion_referencia ir ON (ec.id=ir.idestcat) ";
	$query2 .= "WHERE nivel=? AND itemtype='ALL' AND intranet_habilitado > '0' AND campo NOT IN ";
	$query2 .=$query;
	
	my $sth2=$dbh->prepare($query2);
        $sth2->execute($nivel,$nivel,$itemtype);
	while(my $data=$sth2->fetchrow_hashref){
		my $llave=$data->{'c'}.",".$data->{'s'};
		$data->{'nivel'}=$nivel;
		$data->{'campo'}=$data->{'c'};
		$data->{'subcampo'}=$data->{'s'};
		$data->{'intranet_habilitado'}=++$orden;
		$results{$data->{'id'}}=$data;
		$llaves{$llave}=$llave;#Hash que tiene los campos y subcampos
	}

	#Busco en la tabla marc_subfield_structure todos los campos obligatorios
	$query ="SELECT tagfield,tagsubfield,liblibrarian, obligatorio ";
	$query.=" FROM pref_estructura_subcampo_marc ";
	$query.=" WHERE obligatorio = '1' AND nivel=? ";

	my $sth=$dbh->prepare($query);
        $sth->execute($nivel);
	my %results2;
	while(my $data=$sth->fetchrow_hashref){
		$data->{'nivel'}=$nivel;
		#Si no existe el subcampo en la tabla estructura_catalogacion se ingresa en la hash
		my $llave2=$data->{'tagfield'}.",".$data->{'tagsubfield'};
		if (not exists($llaves{$llave2})){
			$data->{'id'}=$llave2;
			$data->{'itemtype'}=$itemtype;
			$data->{'referencia'}=0;
			$data->{'campo'}=$data->{'tagfield'};
			$data->{'subcampo'}=$data->{'tagsubfield'};
			$data->{'tipo'}='text';
			#PRUEBA (EL IF y ELSIF) VER SI SIRVE CREO QUE PUEDE SER!!!!!!!
			if($llave2 eq "910,a"){
				$data->{'referencia'}=1;
				$data->{'tipo'}='combo';
				$data->{'tabla'}='cat_ref_tipo_nivel3';
				$data->{'campos'}='description';
				$data->{'orden'}="'description'";
			}
			elsif($llave2 eq "995,c" || $llave2 eq "995,d"){
				$data->{'referencia'}=1;
				$data->{'tipo'}='combo';
				$data->{'tabla'}='pref_unidad_informacion';
				$data->{'campos'}='branchname';
				$data->{'orden'}="'branchname'";
			}
			elsif($llave2 eq "995,e"){
				$data->{'referencia'}=1;
				$data->{'tipo'}='combo';
				$data->{'tabla'}='ref_disponibilidad';
				$data->{'campos'}='description';
				$data->{'orden'}="'code'";
			}
			elsif($llave2 eq "995,o"){
				$data->{'referencia'}=1;
				$data->{'tipo'}='combo';
				$data->{'tabla'}='circ_ref_tipo_prestamo';
				$data->{'campos'}='descripcion';
				$data->{'orden'}="'id_tipo_prestamo'";
			}
			($results{$llave2}=$data);
		}
	}
	$sth->finish;
	$sth2->finish;
	return (%results);
}

=item
buscarCampo
Busca toda la informacion que hay de un campo en particular, que fue modificado por el usuario.
=cut
sub buscarCampo{
	my($id)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM cat_estructura_catalogacion WHERE id=?");
	$sth->execute($id);
	my @results;
	if(my $data=$sth->fetchrow_hashref){
		if($data->{'referencia'}){
			my @ref=&buscarCamposModificadosInfoReferencia($id);
			push(@results,@ref);
		}
		else{
			push(@results,$data);
		}
	}
	return(\@results);
}


=item
transaccion
Funcion interna al pm
Realiza el guardado en la base de datos de los campos de los niveles 1 y 2, por medio de una transaccion.
los paramentros que recibe son: $query1 es el insert a la tabla del nivel que corresponda; $query2 es el insert en la tabla repetibles del nivel correspondiente; $query3 es la consulta que devuelve el id de la fila insertada en la tabla nivel.
=cut
sub transaccion{
	my($query1,$bind1,$query2,$bind2,$query3)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my $error=0;
	my $ident;
	my $codMsg;
	eval{
		my $sth=$dbh->prepare($query1);
		$sth->execute(@$bind1);
	
		$sth=$dbh->prepare($query3);
		$sth->execute;
		$ident=$sth->fetchrow;

		if ($query2 ne ""){
		#Reemplaza el caracter ? por el id de la nueva fila en la tabla nivel
			$query2=~ s/\*\?\*/$ident/g; 
			$sth=$dbh->prepare($query2);
        		$sth->execute(@$bind2);
		}
		$dbh->commit;
		$codMsg='C500';
	};
	if($@){
			#Se loguea error de Base de Datos
			my $codMsg= 'B402';
			C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'C501';
	}
	$dbh->{AutoCommit} = 1;
	return($ident,$error,$codMsg);
}


=item
buscarNivel1
Busca la informacion de nivel 1 de un item. solo de la tabla nivel1
=cut
# FIXME DEPRECATED borrar
sub buscarNivel1{
	my($id1)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel1 WHERE id1 = ?";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	return($sth->fetchrow_hashref());
}

=item
buscarNivel1Completo
Busca la informacion de nivel 1 de un item, tanto de la tabla nivel1 como de la tabla nivel1_repetible
=cut
sub buscarNivel1Completo{
	my($id1)=@_;
	my $dbh = C4::Context->dbh;
	my $nivel1=&buscarNivel1($id1);
	my %nivel1Comp;
	my $i=0;
	my $llave="245,a";
	my $autor=$nivel1->{'autor'};
	$nivel1Comp{$llave}->{'campo'}="245";
	$nivel1Comp{$llave}->{'subcampo'}="a";
	$nivel1Comp{$llave}->{'valor'}=$nivel1->{'titulo'};
	$nivel1Comp{$llave}->{'idRep'}="";
	$nivel1Comp{$llave}->{'visto'}=0;
	$i++;
	my $query="SELECT * FROM cat_nivel1_repetible WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while (my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		if(exists($nivel1Comp{$llave})){
			$nivel1Comp{$llave}->{'valor'}.="#".$data->{'dato'};
			$nivel1Comp{$llave}->{'idRep'}.="#".$data->{'rep_n1_id'};
			$nivel1Comp{$llave}->{'varios'}=1;
		}
		else{
			$nivel1Comp{$llave}->{'campo'}=$data->{'campo'};
			$nivel1Comp{$llave}->{'subcampo'}=$data->{'subcampo'};
			$nivel1Comp{$llave}->{'valor'}=$data->{'dato'};
			$nivel1Comp{$llave}->{'varios'}=0;
			$nivel1Comp{$llave}->{'visto'}=0;
			$nivel1Comp{$llave}->{'idRep'}=$data->{'rep_n1_id'};
		}
		$i++;
	}
	return($i,\%nivel1Comp);
}

=item
buscarNivel2
Busca la informacion de nivel 2 de un item.
=cut
sub buscarNivel2{
	my($id2)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel2 WHERE id2 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);
	my $data;
	if($data=$sth->fetchrow_hashref){
		$data->{'itemtypeN2'}=C4::AR::Busquedas::getItemType($data->{'tipo_documento'});
		my $nivelBiblio= C4::AR::Busquedas::getLevel($data->{'nivel_bibliografico'});
		$data->{'nivelBiblio'}=$nivelBiblio->{'description'};
		my $soporte=C4::AR::Busquedas::getSupport($data->{'soporte'});
		$data->{'sopDescripcion'}=$soporte->{'description'};
		my $pais=C4::AR::Busquedas::getCountry($data->{'pais_publicacion'});
		$data->{'paisNombre'}=$pais->{'printable_name'};
		my $idioma=C4::AR::Busquedas::getLanguage($data->{'lenguaje'});
		$data->{'lengDescripcion'}=$idioma->{'description'};
	}
	return($data);
}

=item
buscarNivel2Completo
Busca la informacion de nivel 2 de un item, tanto de la tabla nivel2 como de la tabla nivel2_repetible
=cut
sub buscarNivel2Completo{
	my($id2)=@_;
	my $dbh = C4::Context->dbh;
	my $nivel2=&buscarNivel2($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel2');
	my %nivel2Comp;
	my $i=0;
	my $llave="";
	my $itemtype=$nivel2->{'tipo_documento'};
	foreach my $llave (keys %$mapeo){
		$nivel2Comp{$llave}->{'campo'}=$mapeo->{$llave}->{'campo'};
		$nivel2Comp{$llave}->{'subcampo'}=$mapeo->{$llave}->{'subcampo'};
		$nivel2Comp{$llave}->{'visto'}=0;
		$nivel2Comp{$llave}->{'valor'}=$nivel2->{$mapeo->{$llave}->{'campoTabla'}};
		$nivel2Comp{$llave}->{'idRep'}="";
		$nivel2Comp{$llave}->{'visto'}=0;
		$i++;
	}
	my $query="SELECT * FROM cat_nivel2_repetible WHERE id2=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);
	while (my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		if(exists($nivel2Comp{$llave})){
			$nivel2Comp{$llave}->{'valor'}.="#".$data->{'dato'};
			$nivel2Comp{$llave}->{'idRep'}.="#".$data->{'rep_n2_id'};
			$nivel2Comp{$llave}->{'varios'}=1;
		}
		else{
			$nivel2Comp{$llave}->{'campo'}=$data->{'campo'};
			$nivel2Comp{$llave}->{'subcampo'}=$data->{'subcampo'};
			$nivel2Comp{$llave}->{'valor'}=$data->{'dato'};
			$nivel2Comp{$llave}->{'varios'}=0;
			$nivel2Comp{$llave}->{'visto'}=0;
			$nivel2Comp{$llave}->{'idRep'}=$data->{'rep_n2_id'};
		}
		$i++;
	}
	return($itemtype,$i,\%nivel2Comp);
}



=item
buscarNivel2PorId1
Busca la informacion de nivel 2 de un item. para un  id1 de la tabla nivel 1
=cut

sub buscarNivel2PorId1{

	my($id1)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel2 WHERE id1 = ?";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	my @result;
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		$data->{'itemtype'}=$data->{'tipo_documento'};
		$data->{'tipo_documento'}=C4::AR::Busquedas::getItemType($data->{'tipo_documento'});
		my $nivelBiblio= C4::AR::Busquedas::getLevel($data->{'nivel_bibliografico'});
		$data->{'biblioLevel'}=$data->{'nivel_bibliografico'};
		$data->{'nivel_bibliografico'}=$nivelBiblio->{'description'};
		
		my $soporte=C4::AR::Busquedas::getSupport($data->{'soporte'});
		$data->{'support'}=$data->{'soporte'};
		$data->{'soporte'}=$soporte->{'description'};
		
		my $pais=C4::AR::Busquedas::getCountry($data->{'pais_publicacion'});
		$data->{'pais'}=$data->{'pais_publicacion'};
		$data->{'pais_publicacion'}=$pais->{'printable_name'};
		
		my $idioma=C4::AR::Busquedas::getLanguage($data->{'lenguaje'});
		$data->{'idioma'}=$data->{'lenguaje'};
		$data->{'lenguaje'}=$idioma->{'description'};

		my $cantItems=&cantidadItem(2,$data->{'id2'});
		$data->{'cantItems'}=$cantItems;
		$result[$i]=$data;
		$i++;
	}
	return(@result);
}


=item
AGREGADO MIGUEL, VER SI QUEDA

buscarNivel2PorId1Id2 
Busca la informacion de nivel 2 de un item. para un  id1 de la tabla nivel 1 e id2
=cut
sub buscarNivel2PorId1Id2{
	my($id1, $id2)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel2 WHERE id1 = ? and id2 = ?";
	
	my $sth=$dbh->prepare($query);
        $sth->execute($id1, $id2);
	my @result;
	my $i=0;
	while(my $data=$sth->fetchrow_hashref){
		$data->{'itemtype'}=$data->{'tipo_documento'};
		$data->{'tipo_documento'}=C4::AR::Busquedas::getItemType($data->{'tipo_documento'});
		
		my $nivelBiblio= C4::AR::Busquedas::getLevel($data->{'nivel_bibliografico'});
		$data->{'biblioLevel'}=$data->{'nivel_bibliografico'};
		$data->{'nivel_bibliografico'}=$nivelBiblio->{'description'};
		
		my $soporte=C4::AR::Busquedas::getSupport($data->{'soporte'});
		$data->{'support'}=$data->{'soporte'};
		$data->{'soporte'}=$soporte->{'description'};
		
		my $pais=C4::AR::Busquedas::getCountry($data->{'pais_publicacion'});
		$data->{'pais'}=$data->{'pais_publicacion'};
		$data->{'pais_publicacion'}=$pais->{'printable_name'};
		
		my $idioma=C4::AR::Busquedas::getLanguage($data->{'lenguaje'});
		$data->{'idioma'}=$data->{'lenguaje'};
		$data->{'lenguaje'}=$idioma->{'description'};

		my $cantItems=&cantidadItem(2,$data->{'id2'});
		$data->{'cantItems'}=$cantItems;
		$result[$i]=$data;
		$i++;
	}
	return(@result);
}

=item
cantidadItem
Cuenta la cantidad de item que exiten en el nivel 3 dependiendo el nivel y el id que le llegan como parametros, si el nivel es 1 cuenta los item para que exiten para ese nivel y si es 2 cuenta los item que exiten para ese grupo.
=cut
sub cantidadItem{
	my($nivel,$id)=@_;
	my $dbh = C4::Context->dbh;
	my $cant=0;
	my $query="SELECT COUNT(*) as cant FROM cat_nivel3 WHERE ";
	if($nivel==1){
		$query.="id1=?";
	}
	else{
		$query.="id2=?";
	}
	my $sth=$dbh->prepare($query);
         $sth->execute($id);
	if(my $data=$sth->fetchrow_hashref){
		$cant=$data->{'cant'};
	}
	return($cant);
}

=item
buscarNivel3
Busca la informacion del nivel 3 perteneciente a un documento por su id3.
=cut
sub buscarNivel3{
	my ($id3)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel3 WHERE id3 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id3);
	my $data;

	if($data=$sth->fetchrow_hashref){

		my $holdbranch= C4::AR::Busquedas::getBranch($data->{'holdingbranch'});
		$data->{'holdbranch'}=$holdbranch->{'branchname'};
		
		my $homebranch= &C4::AR::Busquedas::getBranch($data->{'homebranch'});
		$data->{'hbranch'}=$homebranch->{'branchname'};
		
		my $wthdrawn=&C4::AR::Busquedas::getAvail($data->{'wthdrawn'});
		$data->{'disponibilidad'}=$wthdrawn->{'description'};
		
		my $issuetype=&C4::AR::Prestamos::IssueType($data->{'notforloan'});
		if($data->{'notforloan'}=='DO'){
			$data->{'forloan'}=1;
		}
		$data->{'issuetype'}=$issuetype->{'description'};
	}

	return($data);
}

=item
buscarNivel3Completo
Busca toda la informacion asosiada a un id3 de la tabla nivel3
=cut
sub buscarNivel3Completo{
	my($id3)=@_;
	my $dbh = C4::Context->dbh;
	my $nivel3=&buscarNivel3($id3);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('cat_nivel3');
	my %nivel3Comp;
	my $i=0;
	my $llave="";
	foreach my $llave (keys %$mapeo){
		$nivel3Comp{$llave}->{'campo'}=$mapeo->{$llave}->{'campo'};
		$nivel3Comp{$llave}->{'subcampo'}=$mapeo->{$llave}->{'subcampo'};
		$nivel3Comp{$llave}->{'valor'}=$nivel3->{$mapeo->{$llave}->{'campoTabla'}};
		$nivel3Comp{$llave}->{'idRep'}="";
		$nivel3Comp{$llave}->{'visto'}=0;
		$i++;
	}
	my $query="SELECT * FROM cat_nivel3_repetible WHERE id3=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id3);
	while (my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		if(exists($nivel3Comp{$llave})){
			$nivel3Comp{$llave}->{'valor'}.="#".$data->{'dato'};
			$nivel3Comp{$llave}->{'idRep'}.="#".$data->{'rep_n3_id'};
			$nivel3Comp{$llave}->{'varios'}=1;
		}
		else{
			$nivel3Comp{$llave}->{'campo'}=$data->{'campo'};
			$nivel3Comp{$llave}->{'subcampo'}=$data->{'subcampo'};
			$nivel3Comp{$llave}->{'valor'}=$data->{'dato'};
			$nivel3Comp{$llave}->{'varios'}=0;
			$nivel3Comp{$llave}->{'visto'}=0;
			$nivel3Comp{$llave}->{'idRep'}=$data->{'rep_n3_id'};
		}
		$i++;
	}
	return($i,\%nivel3Comp);
	
}

=item
buscarNivel3PorId2
Busca los datos de los ejemplares (tabla nivel3) que corresponde con el id2 que viene como parametro.
Se usa en editarEjemplar, Se llama igual que en Busquedas.pm ver cual queda. (Sacar esta y dejar la de busquedas)
=cut
sub buscarNivel3PorId2{
	my ($id2)=@_;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM cat_nivel3 WHERE id2 = ?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id2);
	my @result;
	while (my $data=$sth->fetchrow_hashref){
		my $holdbranch= &C4::AR::Busquedas::getBranch($data->{'holdingbranch'});
		$data->{'holdbranch'}=$holdbranch->{'branchname'};
		
		my $homebranch= &C4::AR::Busquedas::getBranch($data->{'homebranch'});
		$data->{'hbranch'}=$homebranch->{'branchname'};
		
		my $wthdrawn=&C4::AR::Busquedas::getAvail($data->{'wthdrawn'});
		$data->{'disponibilidad'}=$wthdrawn->{'description'};
		
		my $issuetype=&C4::AR::Prestamos::IssueType($data->{'notforloan'});
		$data->{'issuetype'}=$issuetype->{'description'};
		push(@result,$data);
	}
	return(@result);
	
}

=item
modificarNivel1Completo
Modifica los datos del nivel 1 y sus repetibles.
=cut
sub modificarNivel1Completo{
	my($id1,$idAutor,$nivel1)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my @blind=();
	my $titulo="";
	my $query="UPDATE cat_nivel1 SET titulo=?, autor=? WHERE id1=?";
	my $query2="UPDATE cat_nivel1_repetible SET dato=? WHERE campo=? AND subcampo=? AND id1=? AND rep_n1_id=?";
	my $query3="DELETE FROM cat_nivel1_repetible WHERE rep_n1_id=?";
	my $query4="INSERT INTO cat_nivel1_repetible (dato,campo,subcampo,id1) VALUES (?,?,?,?)";
# open(A,">>/tmp/pruebaMod.txt");
	foreach my $obj(@$nivel1){
		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $idRep=$obj->{'idRep'};
		my $valor=$obj->{'valor'};
		if($campo eq '245' && $subcampo eq 'a'){
			$titulo=$valor;
		}
		else{
# print A "campo: $campo subcampo: $subcampo valor: $valor idRep: $idRep  \n ";
			my $sth;
# print A "simple: $obj->{'simple'}\n";
			if($obj->{'simple'}){
				if($valor eq "" && $idRep ne ""){
					$sth=$dbh->prepare($query3);
					$sth->execute($idRep);
				}
				elsif($valor ne "" && $idRep eq ""){
					#Se agrego un campo que antes no estaba en el catalogo. Por lo tanto el rep_n1_id esta en blanco ya que no exite en la tabla nivel1_repetibles
					$sth=$dbh->prepare($query4);
					$sth->execute($valor,$campo,$subcampo,$id1);
				}
				else{
					$sth=$dbh->prepare($query2);
					$sth->execute($valor,$campo,$subcampo,$id1,$idRep);
				}
			}
			else{
				my $cantIdR=scalar(@$idRep);
				my $cantValores=scalar(@$valor);
# print A "cantIdR: $cantIdR \n";
# print A "cantValores: $cantValores\n";
				if($cantIdR >= $cantValores && $cantIdR > 0){
					my $idR="";
					my $val="";
					for(my $i=0;$i < scalar(@$idRep);$i++){
						$idR=@$idRep->[$i];
						$val=@$valor->[$i];
						if($val eq ""){
							$sth=$dbh->prepare($query3);
							$sth->execute($idR);
						}
						else{
							$sth=$dbh->prepare($query2);
							$sth->execute($val,$campo,$subcampo,$id1,$idR);
						}
					}
				}
				elsif($cantValores > 0){
					my $idR="";
					my $val="";
					for(my $i=0;$i < $cantValores;$i++){
						my $val=@$valor->[$i];
						my $idR=@$idRep->[$i];
# print A "idR: @$idRep->[$i]\n";
# print A "cantIdR: $cantIdR \n";
						if( $idR ne ""){
							$sth=$dbh->prepare($query2);
							$sth->execute($val,$campo,$subcampo,$id1,$idR);
						}
						else{
						#Se agrego un campo que antes no estaba en el catalogo. Por lo tanto el rep_n1_id esta en blanco ya que no exite en la tabla nivel1_repetibles
							$sth=$dbh->prepare($query4);
							$sth->execute($val,$campo,$subcampo,$id1);
						}
					}
				}
			}
		}
	}
# close(A);
	my $sth=$dbh->prepare($query);
        $sth->execute($titulo,$idAutor,$id1);
	$dbh->commit;
	$dbh->{AutoCommit} = 1;
}

=item
modificarNivel2Completo
Modifica los datos del nivel 2 y sus repetibles.
=cut
sub modificarNivel2Completo{
	my($id2,$nivel2)=@_;
	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
	$dbh->{RaiseError} = 1;
	my @campos;
	my $tipoDoc="";
	my $fecha="";
	my $ciudad="";
	my $lenguaje="";
	my $pais="";
	my $soporte="";
	my $nivelBiblio="";
	my $query="UPDATE cat_nivel2 SET tipo_documento=?, nivel_bibliografico=?, soporte=?, pais_publicacion=?, ciudad_publicacion=?, anio_publicacion=?, lenguaje=? WHERE id2=?";
	my $query2="UPDATE cat_nivel2_repetible SET dato=? WHERE campo=? AND subcampo=? AND id2=? AND rep_n2_id=?";
	my $query3="DELETE FROM cat_nivel2_repetible WHERE rep_n2_id=?";
	my $query4="INSERT INTO cat_nivel2_repetible (dato,campo,subcampo,id2) VALUES (?,?,?,?)";
	foreach my $obj(@$nivel2){
		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $idRep=$obj->{'idRep'};
		my $valor=$obj->{'valor'};
		if($campo eq '910' && $subcampo eq 'a'){
			$tipoDoc=$valor;
		}
		elsif($campo eq '260' && $subcampo eq 'c' && $fecha eq ""){
			#Repetibles!!!
			$fecha=$valor ;
		}
		elsif($campo eq '260' && $subcampo eq 'a' && $ciudad eq ""){
			#Repetibles!!!
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
			my $sth;
			if($obj->{'simple'}){
				if($valor eq "" && $idRep ne ""){
					$sth=$dbh->prepare($query3);
					$sth->execute($idRep);
				}
				elsif($valor ne "" && $idRep eq ""){
					#Se agrego un campo que antes no estaba en el catalogo. Por lo tanto el rep_n1_id esta en blanco ya que no exite en la tabla nivel1_repetibles
					$sth=$dbh->prepare($query4);
					$sth->execute($valor,$campo,$subcampo,$id2);
				}
				else{
					$sth=$dbh->prepare($query2);
					$sth->execute($valor,$campo,$subcampo,$id2,$idRep);
				}
			}
			else{
				my $cantIdR=scalar(@$idRep);
				my $cantValores=scalar(@$valor);
				if($cantIdR >= $cantValores && $cantIdR > 0){
					my $idR="";
					my $val="";
					for(my $i=0;$i < scalar(@$idRep);$i++){
						$idR=@$idRep->[$i];
						$val=@$valor->[$i];
						if($val eq ""){
							$sth=$dbh->prepare($query3);
							$sth->execute($idR);
						}
						else{
							$sth=$dbh->prepare($query2);
							$sth->execute($val,$campo,$subcampo,$id2,$idR);
						}
					}
				}
				elsif($cantValores > 0){
					my $idR="";
					my $val="";
					for(my $i=0;$i < $cantValores;$i++){
						my $val=@$valor->[$i];
						my $idR=@$idRep->[$i];
						if($idR ne ""){
							$sth=$dbh->prepare($query2);
							$sth->execute($val,$campo,$subcampo,$id2,$idR);
						}
						else{
						#Se agrego un campo que antes no estaba en el catalogo. Por lo tanto el rep_n1_id esta en blanco ya que no exite en la tabla nivel1_repetibles
							$sth=$dbh->prepare($query4);
							$sth->execute($val,$campo,$subcampo,$id2);
						}
					}
				}
			}
		}
	}
	my $sth=$dbh->prepare($query);
        $sth->execute($tipoDoc,$nivelBiblio,$soporte,$pais,$ciudad,$fecha,$lenguaje,$id2);
	$dbh->commit;
	$dbh->{AutoCommit} = 1;
}


=item
modificarNivel3Completo
Modifica los datos del nivel 3 y sus repetibles.
=cut
sub modificarNivel3Completo{
	my($id3,$nivel3,$todos)=@_;
#aca hacer consulta para obtener el esatdo anterior de un item
       # my ($estadoAnterior,$disponibilidadAnterior) =  C4::AR::Nivel3::getEstado($id3);
        my $datosNivel3= C4::AR::Nivel3::getDataNivel3($id3);
#fin consulta
	my $dbh = C4::Context->dbh;
 	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
 	$dbh->{RaiseError} = 1;
	my $homebranch="";
	my $holdingbranch="";
	my $bulk="";
	my $wthdrawn="";
	my $notforloan="";
	my $query="UPDATE cat_nivel3 SET holdingbranch=?, homebranch=?, signatura_topografica=?, wthdrawn=?, notforloan=? WHERE id3=?";
	my $query2="UPDATE cat_nivel3_repetible SET dato=? WHERE campo=? AND subcampo=? AND id3=? AND rep_n3_id=?";
	my $query3="DELETE FROM cat_nivel3_repetible WHERE rep_n3_id=?";
	my $query4="INSERT INTO cat_nivel3_repetible (dato,campo,subcampo,id3) VALUES (?,?,?,?)";
	my %repetibles;

	foreach my $obj(@$nivel3){

		my $campo=$obj->{'campo'};
		my $subcampo=$obj->{'subcampo'};
		my $idRep=$obj->{'idRep'};
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
		#Estado
			$wthdrawn=$valor ;
		}
		elsif($campo eq '995' && $subcampo eq 'o'){
		#Disponibilidad
			$notforloan=$valor ;
		}
		else{
			my $sth;
			if($obj->{'simple'}){
				if($idRep eq "" && $todos){
					#Se quieren modificar todos los ejemplares a la vez. (idRep="" siempre)
					$idRep=&dameIdReptible($dbh,$id3,$campo,$subcampo,\%repetibles);
				}
				if($valor eq "" && $idRep ne ""){
					$sth=$dbh->prepare($query3);
					$sth->execute($idRep);
				}
				elsif($valor ne "" && $idRep eq ""){
					#Se agrego un campo que antes no estaba en el catalogo. Por lo tanto el rep_n1_id esta en blanco ya que no exite en la tabla nivel1_repetibles
					$sth=$dbh->prepare($query4);
					$sth->execute($valor,$campo,$subcampo,$id3);
				}
				else{
					$sth=$dbh->prepare($query2);
					$sth->execute($valor,$campo,$subcampo,$id3,$idRep);
				}
			}
			else{
				my $cantIdR=scalar(@$idRep);
				my $cantValores=scalar(@$valor);
				if($cantIdR >= $cantValores && $cantIdR > 0){
					my $idR="";
					my $val="";
					for(my $i=0;$i < scalar(@$idRep);$i++){
						$idR=@$idRep->[$i];
						$val=@$valor->[$i];
						if($val eq ""){
							$sth=$dbh->prepare($query3);
							$sth->execute($idR);
						}
						else{
							$sth=$dbh->prepare($query2);
							$sth->execute($val,$campo,$subcampo,$id3,$idR);
						}
					}
				}
				elsif($cantValores > 0){
					my $idR="";
					my $val="";
					for(my $i=0;$i < $cantValores;$i++){
						my $val=@$valor->[$i];
						my $idR=@$idRep->[$i];
						if($idR ne ""){
							$sth=$dbh->prepare($query2);
							$sth->execute($val,$campo,$subcampo,$id3,$idR);
						}
						else{
						#Se agrego un campo que antes no estaba en el catalogo. Por lo tanto el rep_n1_id esta en blanco ya que no exite en la tabla nivel1_repetibles
							$sth=$dbh->prepare($query4);
							$sth->execute($val,$campo,$subcampo,$id3);
						}
					}
				}
			}
		}

	}

	close(A);
	#si cambio se modifica el estado del item
	#DEBEMOS ARMAR LA HASH PARA PASARLE A LA FUNCION, ID3, WTHDRAWN, NOTFORLOAN, BORROWER, LOGGEDINUSER,ID2
        $datosNivel3->{'branchcode'}= $datosNivel3->{'homebranch'}; #?????????????
        #$detalleNivel3->{'loggedinuser'}= $params->{'loggedinuser'}; FALTA PASARLO

	C4::AR::Nivel3::modificarEstadoItem($datosNivel3);

	#
	my $sth=$dbh->prepare($query);
        $sth->execute($holdingbranch,$homebranch,$bulk,$wthdrawn,$notforloan,$id3);
 	$dbh->commit;
 	$dbh->{AutoCommit} = 1;
}

=item
dameIdReptible
Devuelve el id de repetibles para un campo y subcampo que no halla sido modificado en uno de los pasos anteriores
Sirve para cuando se quieren modificar varios ejemplares a la vez, el idRep de la funcion modificarNivel3Completo siempre = "", por lo tanto no se tiene el rep_n3_id para hacer el update.
=cut
sub dameIdReptible{
	my ($dbh,$id3,$campo,$subcampo,$repModificados)=@_;
	my $llave=$campo.",".$subcampo;
	my $query="SELECT rep_n3_id FROM cat_nivel3_repetible WHERE id3 = ? AND campo=? AND subcampo=? ";
	my $sth=$dbh->prepare($query);
	$sth->execute($id3,$campo,$subcampo);
	my $idRep="";
	my $nocorte=1;
	while((my $data=$sth->fetchrow_hashref) && $nocorte){
		my $id=$data->{'rep_n3_id'};
		$llave.=",".$id;
		if(not exists($repModificados->{$llave})){
			$repModificados->{$llave}=1;
			$idRep=$id;
			$nocorte=1;
		}
	}
	return $idRep;
}



################################################### NUEVAS NUEVAS FRESQUITAS ##############################################################
=item
Esta funcion sube el orden como se va a mostrar del campo, subcampo catalogado
=cut
sub subirOrden{
    my ($id,$itemtype) = @_;

    my $catAModificar = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catAModificar->load();

    $catAModificar->subirOrden($itemtype);
}

=item
Esta funcion baja el orden como se va a mostrar del campo, subcampo catalogado
=cut
sub bajarOrden{
    my ($id,$itemtype) = @_;

    my $catAModificar = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catAModificar->load();

    #verifico que no sea el ultimo en la lista, si es el ulitmo no puede bajar mas
        $catAModificar->bajarOrden($itemtype);
}


sub getCamposXLike{

    use C4::Modelo::PrefEstructuraSubcampoMarc::Manager;
    use C4::Modelo::PrefEstructuraSubcampoMarc;
    my ($nivel,$campoX) = @_;

    my @filtros;

    push(@filtros, ( tagfield => { like => $campoX.'%'} ) );
    push(@filtros, ( nivel => { eq => $nivel } ) );

    my $db_campos_MARC = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                                        query => \@filtros,
                                                                                        sort_by => ('tagfield'),
                                                                                        select   => [ 'tagfield', 'liblibrarian'],
                                                                                        group_by => [ 'tagfield'],
                                                                       );
    return($db_campos_MARC);
}

sub getSubCamposLike{

    use C4::Modelo::PrefEstructuraSubcampoMarc::Manager;
    use C4::Modelo::PrefEstructuraSubcampoMarc;
    my ($nivel,$campo) = @_;

    my @filtros;

    push(@filtros, ( tagfield => { eq => $campo} ) );
    push(@filtros, ( nivel => { eq => $nivel } ) );

    my $db_campos_MARC = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                query => \@filtros,
                                                                sort_by => ('tagsubfield'),
                                                                select   => [ 'tagsubfield', 'liblibrarian' ],
                                                                group_by => [ 'tagsubfield'],
                                                            );
    return($db_campos_MARC);
}

=item
Esta transaccion guarda una estructura de catalogacion configurada por el bibliotecario 
=cut
sub t_guardarEnEstructuraCatalogacion {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
        my  $estrCatalogacion = C4::Modelo::CatEstructuraCatalogacion->new();
        my $db= $estrCatalogacion->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
    
        eval {
            $estrCatalogacion->agregar($params);  
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U364', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B426',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U365', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}

=item
Esta transaccion guarda una estructura de catalogacion configurada por el bibliotecario 
=cut
sub t_modificarEnEstructuraCatalogacion {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
        my  $estrCatalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $params->{'id'});
        $estrCatalogacion->load();
        my $db= $estrCatalogacion->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
    
        eval {
            $estrCatalogacion->modificar($params);  
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U366', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B426',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U367', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}


#======================================================SOPORTE PARA ESTRUCTURA CATALOGACION====================================================

=item
Este funcion devuelve la estructura de catalogacion para armar los componentes en el cliente
=cut
sub getHashCatalogaciones{
    my ($params)=@_;

	my $nivel= $params->{'nivel'};
	my $itemType= $params->{'id_tipo_doc'};
	my $orden= $params->{'orden'};
	
	#obtengo toda la informacion de la estructura de catalogacion
    my ($cant, $catalogaciones_array_ref)= getCatalogaciones($nivel,$itemType);
    

    my @result;
    foreach my $cat  (@$catalogaciones_array_ref){

        my %hash_temp;
        $hash_temp{'campo'}= $cat->getCampo;
        $hash_temp{'subcampo'}= $cat->getSubcampo;
		$hash_temp{'dato'}= '';
        $hash_temp{'nivel'}= $cat->getNivel;
        $hash_temp{'visible'}= $cat->getVisible;
        $hash_temp{'liblibrarian'}= $cat->getLiblibrarian;
        $hash_temp{'itemtype'}= $cat->getItemType;
        $hash_temp{'repetible'}= $cat->getRepetible;
#         $hash_temp{'fijo'}= $cat->getFijo;
        $hash_temp{'tipo'}= $cat->getTipo;
        $hash_temp{'referencia'}= $cat->getReferencia;
        $hash_temp{'obligatorio'}= $cat->getObligatorio;
		$hash_temp{'idCompCliente'}= $cat->getIdCompCliente;
        $hash_temp{'intranet_habilitado'}= $cat->getIntranet_habilitado;

		if( ($cat->getReferencia) && ($cat->getTipo eq 'combo') ){
        #tiene una referencia, y no es un autocomplete			
			C4::AR::Debug::debug('tiene referencia y es un combo');
            $cat->{'infoReferencia'}->{'campos'}; 
			my $orden= $cat->infoReferencia->getCampos;
            my ($cantidad,$valores)=&C4::AR::Referencias::obtenerValoresTablaRef(   
																						$cat->infoReferencia->getReferencia,  #tabla  
                                                                                        $cat->infoReferencia->getCampos,  #campo
																						$orden
                                                                                );
            $hash_temp{'opciones'}= $valores;
        }

		if( ($cat->getReferencia) && ($cat->getTipo eq 'auto') ){
		#es un autocomplete
			C4::AR::Debug::debug('tiene referencia y es un autocomplete');
			$hash_temp{'referenciaTabla'}= $cat->infoReferencia->getReferencia;
			$hash_temp{'datoReferencia'}= '';
		}

        push (@result, \%hash_temp);
    }

    return (scalar(@$catalogaciones_array_ref), \@result);
}


sub getHashCatalogacionesConDatos{
    my ($params)=@_;

	#obtengo la estructura de catalogacion de los NIVELES REPETIBLES
    my ($cant, $catalogaciones_array_ref)= getCatalogacionesConDatos($params);

    
# MAPEO Y FILTRO DE INFO AL CLIENTE
    my @result;
    foreach my $cat  (@$catalogaciones_array_ref){
		
		#busco la informacion de estructura de catalogacion
		my $cat_estruct_array = _getEstructuraFromCampoSubCampo(	
																	$cat->getCampo, 
																	$cat->getSubcampo
											);

C4::AR::Debug::debug("BUSCO ESTRUCTURA PARA DATO: ".$cat->getDato);
C4::AR::Debug::debug("campo: ".$cat->getCampo);
C4::AR::Debug::debug("sub campo: ".$cat->getSubcampo);

		if(scalar(@$cat_estruct_array) > 0){	
	
			my %hash_temp;
			$hash_temp{'campo'}= $cat->getCampo;
			$hash_temp{'subcampo'}= $cat->getSubcampo;
			$hash_temp{'dato'}= $cat->{'dato'};
			$hash_temp{'nivel'}=  $cat_estruct_array->[0]->getNivel;
			$hash_temp{'visible'}=  $cat_estruct_array->[0]->getVisible;
			$hash_temp{'liblibrarian'}=  $cat_estruct_array->[0]->getLiblibrarian;
			$hash_temp{'itemtype'}=  $cat_estruct_array->[0]->getItemType;
			$hash_temp{'id_rep'}=  $catalogaciones_array_ref->[0]->getId_rep; #obtengo el id_repetible del nivel repetible 1, 2 o 3
			$hash_temp{'repetible'}=  $cat_estruct_array->[0]->getRepetible;
	#         $hash_temp{'fijo'}=  $cat_estruct_array->[0]->getFijo; #no es necesario enviar al cliente
			$hash_temp{'tipo'}=  $cat_estruct_array->[0]->getTipo;
			$hash_temp{'referencia'}=  $cat_estruct_array->[0]->getReferencia;
			$hash_temp{'obligatorio'}=  $cat_estruct_array->[0]->getObligatorio;
			$hash_temp{'idCompCliente'}=  $cat_estruct_array->[0]->getIdCompCliente;
			$hash_temp{'intranet_habilitado'}=  $cat_estruct_array->[0]->getIntranet_habilitado;
	
			if( ( $cat_estruct_array->[0]->getReferencia) && ( $cat_estruct_array->[0]->getTipo eq 'combo') ){
			#tiene una referencia, y no es un autocomplete			
				C4::AR::Debug::debug('tiene referencia y no es auto');
				$cat->{'infoReferencia'}->{'campos'}; 
				my $orden= $cat_estruct_array->[0]->infoReferencia->getCampos;
				my ($cantidad,$valores)=&C4::AR::Referencias::obtenerValoresTablaRef(   
																	$cat_estruct_array->[0]->infoReferencia->getReferencia,  #tabla  
																	$cat_estruct_array->[0]->infoReferencia->getCampos,  #campo
																	$orden
																					);
				$hash_temp{'opciones'}= $valores;
			}
	
			if( ( $cat_estruct_array->[0]->getReferencia) && ( $cat_estruct_array->[0]->getTipo eq 'auto') && ($cat->getDato ne '') ){
			#es un autocomplete
				C4::AR::Debug::debug('tiene referencia y es un autocomplete');
				$hash_temp{'referenciaTabla'}=  $cat_estruct_array->[0]->infoReferencia->getReferencia;
				my $pref_tabla_referencia = C4::Modelo::PrefTablaReferencia->new();
				my $obj_generico= $pref_tabla_referencia->getObjeto($cat_estruct_array->[0]->infoReferencia->getReferencia, $cat->{'dato'});
				$obj_generico= $obj_generico->getObjeto($cat->{'dato'});
				$hash_temp{'dato'}= $obj_generico->toString;
				$hash_temp{'datoReferencia'}= $cat->{'dato'};#sobreescribo el dato
			}
	
	
			push (@result, \%hash_temp);
		}
	
	}

	#obtengo los datos de nivel 1, 2 y 3 mapeados a MARC, con su informacion de estructura de catalogacion
	my @resultEstYDatos= _obtenerEstructuraYDatos($params);
	push(@resultEstYDatos,@result);

	return (scalar(@resultEstYDatos), \@resultEstYDatos);
}

=item
Esta funcion retorna la estructura de catalogacion con los datos de un Nivel.
Ademas mapea las campos fijos de nivel 1, 2 y 3 a MARC
=cut
sub _obtenerEstructuraYDatos{
	my ($params)=@_;

	my @result;
	my $nivel;
	if( $params->{'nivel'} eq '1'){
		$nivel= C4::AR::Nivel1::getNivel1FromId1($params->{'id'});
C4::AR::Debug::debug("_obtenerEstructuraYDatos=>  getNivel1FromId1\n");
	}
	elsif( $params->{'nivel'} eq '2'){
		$nivel= C4::AR::Nivel2::getNivel2FromId2($params->{'id'});
C4::AR::Debug::debug("_obtenerEstructuraYDatos=>  getNivel2FromId2\n");
	}
	elsif( $params->{'nivel'} eq '3'){
		$nivel= C4::AR::Nivel3::getNivel3FromId3($params->{'id3'});
C4::AR::Debug::debug("_obtenerEstructuraYDatos=>  getNivel3FromId3\n");
	}

	#paso todo a MARC
    
	my $nivel_info_marc_array = undef;
    eval{
      $nivel_info_marc_array = $nivel->toMARC;
    };

	#se genera la estructura de catalogacion para envia al cliente
    if ($nivel_info_marc_array ){
      for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++){
  
          my $cat_estruct_array = _getEstructuraFromCampoSubCampo(	
                                                                      $nivel_info_marc_array->[$i]->{'campo'}, 
                                                                      $nivel_info_marc_array->[$i]->{'subcampo'}
                                              );
      
          my %hash;
  
          if(scalar(@$cat_estruct_array) > 0){		
  
              $hash{'campo'}= $nivel_info_marc_array->[$i]->{'campo'};
              $hash{'subcampo'}= $nivel_info_marc_array->[$i]->{'subcampo'};
              $hash{'dato'}= $nivel_info_marc_array->[$i]->{'dato'};
  
              if($cat_estruct_array->[0]->getReferencia){
                  $hash{'datoReferencia'}= $nivel_info_marc_array->[$i]->{'datoReferencia'};
              }
      
              $hash{'idCompCliente'}= $cat_estruct_array->[0]->getIdCompCliente;	 
              $hash{'nivel'}= $cat_estruct_array->[0]->getNivel;
              $hash{'liblibrarian'}= $cat_estruct_array->[0]->getLiblibrarian;
              $hash{'itemtype'}= $cat_estruct_array->[0]->getItemType;
              $hash{'repetible'}= $cat_estruct_array->[0]->getRepetible;
              $hash{'fijo'}= $cat_estruct_array->[0]->getFijo;
              $hash{'tipo'}= $cat_estruct_array->[0]->getTipo;
              $hash{'referencia'}= $cat_estruct_array->[0]->getReferencia;
              $hash{'obligatorio'}= $cat_estruct_array->[0]->getObligatorio;
                  
              push(@result, \%hash);
          }
      }
    }
	return @result;
}


=item
Este funcion devuelve la informacion del usuario segun un nro_socio
=cut
sub getCatalogaciones{
    my ($nivel,$itemType)=@_;

    use C4::Modelo::CatEstructuraCatalogacion;
    use C4::Modelo::CatEstructuraCatalogacion::Manager;

    my $catalogacionTemp = C4::Modelo::CatEstructuraCatalogacion->new();

    my $catalogaciones_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
                                                                query => [ 
                                                                                nivel => { eq => $nivel },

                                                                    or   => [ 	
																				itemtype => { eq => $itemType },
                                                                            	itemtype => { eq => 'ALL' },    
                                                                            ],

                                                                        		intranet_habilitado => { gt => 0 }, 
                                                                        ],

                                                                with_objects => [ 'infoReferencia' ],  #LEFT OUTER JOIN

                                                                #sort_by => ( $catalogacionTemp->sortByString($orden) ),
                                                                sort_by => ( 'intranet_habilitado' ),
                                                             );

    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}



sub getCatalogacionesConDatos{
    my ($params)=@_;

	my $nivel= $params->{'nivel'};

	use C4::Modelo::CatNivel1;
    use C4::Modelo::CatNivel1::Manager;

    use C4::Modelo::CatNivel1Repetible;
    use C4::Modelo::CatNivel1Repetible::Manager;
      
    use C4::Modelo::CatNivel2Repetible;
    use C4::Modelo::CatNivel2Repetible::Manager;

    use C4::Modelo::CatNivel3Repetible;
    use C4::Modelo::CatNivel3Repetible::Manager;
    my $catalogaciones_array_ref;
	my $nivel1_array_ref;

   if ($nivel == 1){

         $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
                                                query => [ 
 															'cat_nivel1.id1' => { eq => $params->{'id'} },
                                                    ], 
 	 										with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor','CEC' ]

							);
	
   }
   elsif ($nivel == 2){
         $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
                                                                              query => [ 
                                                                                          id2 => { eq => $params->{'id'} },
                                                                                    ],
                                                                require_objects => [ 'cat_nivel2', 'CEC' ]

                                                                     );
   }
   else{
         $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
                                                                              query => [ 
                                                                                           id3 => { eq => $params->{'id3'} },
                                                                                    ],
                                                                              require_objects => [ 'cat_nivel3', 'CEC' ]
                                                                     );
   }

    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}


=item
Este funcion devuelve la informacion de la estructura de catalogacion de un campo, subcampo
=cut
sub _getEstructuraFromCampoSubCampo{
    my ($campo, $subcampo)=@_;

	my $cat_estruct_info_array = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
																				query => [ 
																							campo => { eq => $campo },
																							subcampo => { eq => $subcampo },
																					], 

										);	

	return $cat_estruct_info_array;
}

#====================================================FIN==SOPORTE PARA ESTRUCTURA CATALOGACION==================================================
