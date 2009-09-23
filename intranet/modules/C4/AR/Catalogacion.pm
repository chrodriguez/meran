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
	&buscarSubCampo
	&buscarCampo
	&buscarMaximoHabilitado
	&buscarNombreCampoMarc
	&actualizarCamposModificados
	&actualizarInfoReferencia
	&guardarCamposModificados
	&guardarCampoTemporal
	&obtenerCamposTablaRef
    &t_eliminarNivel1
	&t_eliminarNivel2
	&t_eliminarNivel3
);


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

=item  sub _setDatos_de_estructura
    Esta funcion setea 

    @Parametros
    $cat: es un objeto de cat_estructura_catalogacion que contiene toda la estructura que se va a setear a la HASH
=cut
sub _setDatos_de_estructura {
    my ($cat, $hash_ref, $datos_hash_ref) = @_;

    $hash_ref->{'campo'} = $cat->getCampo;
    $hash_ref->{'subcampo'} = $cat->getSubcampo;
    $hash_ref->{'dato'} = $datos_hash_ref->{'dato'};
    $hash_ref->{'datoReferencia'}= $datos_hash_ref->{'datoReferencia'};
    $hash_ref->{'Id_rep'}= $datos_hash_ref->{'Id_rep'};
    $hash_ref->{'nivel'} = $cat->getNivel;
    $hash_ref->{'visible'} = $cat->getVisible;
    $hash_ref->{'liblibrarian'} = $cat->getLiblibrarian;
    $hash_ref->{'itemtype'} = $cat->getItemType;
    $hash_ref->{'repetible'} = $cat->getRepetible;
    $hash_ref->{'tipo'} = $cat->getTipo;
    $hash_ref->{'referencia'} = $cat->getReferencia;
    $hash_ref->{'obligatorio'} = $cat->getObligatorio;
    $hash_ref->{'idCompCliente'} = $cat->getIdCompCliente;
    $hash_ref->{'intranet_habilitado'} = $cat->getIntranet_habilitado;

    C4::AR::Debug::debug("");
    if($cat->getRepetible){    
        #solo para debug
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== ES UN REPETIBLE ======== ");
        C4::AR::Debug::debug("_setDatos_de_estructura => Id_rep: ".$datos_hash_ref->{'Id_rep'});
    }
    C4::AR::Debug::debug("_setDatos_de_estructura => campo, subcampo: ".$cat->getCampo.", ".$cat->getSubcampo);
    C4::AR::Debug::debug("_setDatos_de_estructura => dato: ".$datos_hash_ref->{'dato'});
    
    if( ($cat->getReferencia) && ($cat->getTipo eq 'combo') ){
        #tiene una referencia, y es un COMBO
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== COMBO ======== ");
        _obtenerOpciones ($cat, $hash_ref);

    }elsif( ($cat->getReferencia) && ($cat->getTipo eq 'auto') ){
        #es un autocomplete
        $hash_ref->{'referenciaTabla'} = $cat->infoReferencia->getReferencia;
        #si es un autocomplete y no tengo el dato de la referencia, muestro un blanco
        if ( ($hash_ref->{'datoReferencia'} eq 0) || not defined($hash_ref->{'datoReferencia'}) ) {$hash_ref->{'dato'} = '';}
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== AUTOCOMPLETE ======== ");
        C4::AR::Debug::debug("_setDatos_de_estructura => datoReferencia: ".$hash_ref->{'datoReferencia'});
        C4::AR::Debug::debug("_setDatos_de_estructura => referenciaTabla: ".$hash_ref->{'referenciaTabla'});
    }else{
        #cualquier otra componete
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== ".$cat->getTipo." ======== ");
    }
}

=item sub getEstructuraSinDatos
Este funcion devuelve la estructura de catalogacion para armar los componentes en el cliente
Nivel 1, 2 y 3 y REPETIBLES, estructura SIN DATOS
=cut
sub getEstructuraSinDatos{
    my ($params) = @_;
    C4::AR::Debug::debug("getEstructuraSinDatos ============================================================================INI");

	my $nivel =     $params->{'nivel'};
	my $itemType =  $params->{'id_tipo_doc'};
	my $orden =     $params->{'orden'};
	
    #inicializo la hash de datos
    my $datos_hash_ref;
    $datos_hash_ref->{'dato'} = '';
    $datos_hash_ref->{'datoReferencia'} = 0;
    $datos_hash_ref->{'Id_rep'} = 0;

	#obtengo toda la informacion de la estructura de catalogacion del Nivel 1, 2 o 3
    my ($cant, $catalogaciones_array_ref) = getEstructuraCatalogacionFromDBCompleta($nivel, $itemType);
    C4::AR::Debug::debug("getEstructuraSinDatos => cant: ".$cant);    

    my @result;
    foreach my $cat  (@$catalogaciones_array_ref){
        my %hash_temp;
        _setDatos_de_estructura($cat, \%hash_temp, $datos_hash_ref);
        push (@result, \%hash_temp);
    }

    C4::AR::Debug::debug("getEstructuraSinDatos ============================================================================FIN");

    return (scalar(@$catalogaciones_array_ref), \@result);
}

=item sub cantNivel2
     devuelve la cantidad de Niveles 2 que tiene  relacionados el Nivel 1 con id1 pasado por parameto
=cut
sub cantNivel2 {
    my ($id1) = @_;

    my $count = C4::Modelo::CatNivel2::Manager->get_cat_nivel2_count( query => [ id1 => { eq => $id1 } ]);

    return $count;
}

=item
    Esta funcion genera la estructura de catalogacion con los datos para los REPETIBLES, al final se agregan los datos 
    y la estructura de los niveles 1, 2 y 3
=cut
sub getEstructuraConDatos{
    my ($params) = @_;

    C4::AR::Debug::debug("getEstructuraConDatos => ======================================================================");
    my $nivel = $params->{'nivel'};
    my $itemType = $params->{'id_tipo_doc'};
    #obtengo la estructura_catalogacion configurada solo de los campos REPETIBLES
     my ($cant, $catalogaciones_array_ref_objects)= getEstructuraCatalogacionFromDBRepetibles($nivel,$itemType);

    my @result;

    foreach my $cat_estructura  (@$catalogaciones_array_ref_objects){

        if($cat_estructura->getRepetible){        
            C4::AR::Debug::debug("getEstructuraConDatos => PROCESO UN REPETIBLE");
            #seteo el campo, subcampo a buscar segun el nivel $params->{'nivel'} y el ID de nivel $params->{'id'}
            $params->{'campo'} = $cat_estructura->getCampo;
            $params->{'subcampo'} = $cat_estructura->getSubcampo;
            #obtengo la estructura de catalogacion de los NIVELES REPETIBLES
            my ($cant, $catalogaciones_array_ref) = getRepetible($params);
            C4::AR::Debug::debug("getEstructuraConDatos REPETIBLES=> cant: ".$cant." NIVEL: ".$params->{'nivel'});
            C4::AR::Debug::debug("getEstructuraConDatos REPETIBLES=> campo: ".$cat_estructura->getCampo);
            C4::AR::Debug::debug("getEstructuraConDatos REPETIBLES=> subcampo: ".$cat_estructura->getSubcampo);
            my $cat;
    
            if($cant){
                $cat->{'dato'} = $catalogaciones_array_ref->getDato;
                $cat->{'Id_rep'} = $catalogaciones_array_ref->getId_rep;
                $cat->{'datoReferencia'} = $catalogaciones_array_ref->getDato;
            }else{  
                #NO EXISTE la tupla del repetible, sí la estructura, puede que se haya modificado la estructura (SE AGREGO)
                #y no se tenga la tupla repetible
                $cat->{'dato'} = '';
                $cat->{'Id_rep'} = 0;
                $cat->{'datoReferencia'} = 0;
            }
    
            my %hash_temp;
            _setDatos_de_estructura($cat_estructura, \%hash_temp, $cat);
        
            push (@result, \%hash_temp);
        }# END IF

    }# END foreach my $cat_estructura  (@$catalogaciones_array_ref_objects)
   

    #obtengo los datos de nivel 1, 2 y 3 mapeados a MARC, con su informacion de estructura de catalogacion
    my @resultEstYDatos= _getEstructuraYDatosDeNivelNoRepetible($params);
    push(@resultEstYDatos,@result);

    return (scalar(@resultEstYDatos), \@resultEstYDatos);
}

=item
Esta funcion retorna la estructura de catalogacion con los datos de un Nivel (REPETIBLES NO).
Ademas mapea las campos fijos de nivel 1, 2 y 3 a MARC
=cut
sub _getEstructuraYDatosDeNivelNoRepetible{
	my ($params)=@_;

	my @result;
	my $nivel;
	if( $params->{'nivel'} eq '1'){
		$nivel= C4::AR::Nivel1::getNivel1FromId1($params->{'id'});
        C4::AR::Debug::debug("_getEstructuraYDatosDeNivelNoRepetible=>  getNivel1FromId1\n");
	}
	elsif( $params->{'nivel'} eq '2'){
		$nivel= C4::AR::Nivel2::getNivel2FromId2($params->{'id'});
        C4::AR::Debug::debug("_getEstructuraYDatosDeNivelNoRepetible=>  getNivel2FromId2\n");
	}
	elsif( $params->{'nivel'} eq '3'){
		$nivel= C4::AR::Nivel3::getNivel3FromId3($params->{'id3'});
        C4::AR::Debug::debug("_getEstructuraYDatosDeNivelNoRepetible=>  getNivel3FromId3");
	}

	#paso todo a MARC
	my $nivel_info_marc_array = undef;
    eval{
      $nivel_info_marc_array = $nivel->toMARC; #mapea los campos de la tabla nivel 1, 2, o 3 a MARC
    };

	#se genera la estructura de catalogacion para enviar al cliente
    if ($nivel_info_marc_array ){
      for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++){

        my $cat_estruct_array = _getEstructuraFromCampoSubCampo(	
                                                                    $nivel_info_marc_array->[$i]->{'campo'}, 
                                                                    $nivel_info_marc_array->[$i]->{'subcampo'}
                                            );
      
        my %hash;
  
        if(scalar(@$cat_estruct_array) > 0){	

            my %hash_temp;
            _setDatos_de_estructura($cat_estruct_array->[0], \%hash_temp, $nivel_info_marc_array->[$i]);
                
            push(@result, \%hash_temp);
        }
      }
    }# END for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++)

	return @result;
}


sub _obtenerOpciones{
    my ($cat_estruct_object, $hash_ref) = @_;

    C4::AR::Debug::debug('_obtenerOpciones => es un combo, se setean las opciones para => '.$cat_estruct_object->infoReferencia->getReferencia);
    my $orden = $cat_estruct_object->infoReferencia->getCampos;
    my ($cantidad, $valores) = &C4::AR::Referencias::obtenerValoresTablaRef(   
                                                                $cat_estruct_object->infoReferencia->getReferencia,  #tabla  
                                                                $cat_estruct_object->infoReferencia->getCampos,  #campo
                                                                $orden
                                                );
    $hash_ref->{'opciones'} = $valores;
}

sub _setearInfoParaAutocomplete{
# FIXME no se para q se usa
    my ($cat_estruct_object, $hash_ref) = @_;

    C4::AR::Debug::debug('setearInfoParaAutocomplete => tiene referencia y es un autocomplete');
    $hash_ref->{'referenciaTabla'} =  $cat_estruct_object->infoReferencia->getReferencia;
    my $pref_tabla_referencia = C4::Modelo::PrefTablaReferencia->new();
    my $obj_generico = $pref_tabla_referencia->getObjeto($cat_estruct_object->infoReferencia->getReferencia, $cat_estruct_object->{'dato'});
    $obj_generico = $obj_generico->getObjeto($cat_estruct_object->{'dato'});
    $hash_ref->{'dato'} = $obj_generico->toString;
    $hash_ref->{'datoReferencia'} = $cat_estruct_object->{'dato'};#sobreescribo el dato
}

=item sub getEstructuraCatalogacionFromDBCompleta
    Retorna la estructura de catalogacion del Nivel 1, 2 o 3 que se encuentra configurada en la BD
=cut
sub getEstructuraCatalogacionFromDBCompleta{
    my ($nivel,$itemType)=@_;

#     use C4::Modelo::CatEstructuraCatalogacion;
    use C4::Modelo::CatEstructuraCatalogacion::Manager;

#     my $catalogacionTemp = C4::Modelo::CatEstructuraCatalogacion->new(); ????

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
                                                                sort_by => ( 'intranet_habilitado' ),
                                                             );

    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}

=item sub getEstructuraCatalogacionFromDBRepetibles
    Retorna la estructura de catalogacion del Nivel 1, 2 o 3 que se encuentra configurada en la BD pero SOLO de los campos REPETIBLES
=cut
sub getEstructuraCatalogacionFromDBRepetibles{
    my ($nivel,$itemType)=@_;

    use C4::Modelo::CatEstructuraCatalogacion::Manager;

    my $catalogaciones_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
                                                                query => [ 
                                                                                nivel => { eq => $nivel },

                                                                    or   => [   
                                                                                itemtype => { eq => $itemType },
                                                                                itemtype => { eq => 'ALL' },    
                                                                            ],

                                                                                intranet_habilitado => { gt => 0 }, 
                                                                                repetible => { eq => 1 },
                                                                        ],

                                                                with_objects => [ 'infoReferencia' ],  #LEFT OUTER JOIN
                                                                sort_by => ( 'intranet_habilitado' ),
                                                             );

    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}

=item sub getCatalogacionesConDatos
 Esta funcion retorna la estructura_catalogacion y los datos para los campos REPETIBLES
 TENER EN CUENTA QUE SI NO HAY UNA ESTRUCTURA DE CATALOGACION QUE SOPORTE (QUE GUARDE) LOS DATOS, ESTOS NO SE VERAN
=cut
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
    C4::AR::Debug::debug("getCatalogacionesConDatos => NIVEL 1");
         $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
                                                query => [ 
 															'cat_nivel1.id1' => { eq => $params->{'id'} },
                                                    ], 
#   	 										with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor','CEC' ]
                                             with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN
                                             require_objects => [ 'CEC' ] #INNER JOIN

							);
	
   }
   elsif ($nivel == 2){
    C4::AR::Debug::debug("getCatalogacionesConDatos => NIVEL 2");
         $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
                                                                              query => [ 
                                                                                          id2 => { eq => $params->{'id'} },
                                                                                    ],
                                                                require_objects => [ 'cat_nivel2', 'CEC' ]

                                                                     );
   }
   else{
    C4::AR::Debug::debug("getCatalogacionesConDatos => NIVEL 3");
         $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
                                                                              query => [ 
                                                                                           id3 => { eq => $params->{'id3'} },
                                                                                    ],
                                                                              require_objects => [ 'cat_nivel3', 'CEC' ]
                                                                     );
   }

    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}

=item sub getRepetible
    Esta funcion recupera (SI EXISTE) el objeto de un nivel repetible
    @Parametros:
    
    $params->{'nivel'} = nivel por el que se va a filtrar
    $params->{'id'} = ID correspondiente al nivel 1, 2 o 3
    $params->{'campo'} = campo MARC
    $params->{'subcampo'} = subcampo MARC
=cut
sub getRepetible{
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
    C4::AR::Debug::debug("getRepetible => NIVEL 1");
         $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
                                                query => [ 
                                                            'cat_nivel1.id1' => { eq => $params->{'id'} },
                                                            'campo' => { eq => $params->{'campo'} },
                                                            'subcampo' => { eq => $params->{'subcampo'} },        
                                                    ], 
#                                               with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor','CEC' ]
                                                with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN
                                                require_objects => [ 'CEC' ] #INNER JOIN

                            );
    
   }
   elsif ($nivel == 2){
    C4::AR::Debug::debug("getRepetible => NIVEL 2");
         $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
                                                    query => [ 
                                                                id2 => { eq => $params->{'id'} },
                                                                'campo' => { eq => $params->{'campo'} },
                                                                'subcampo' => { eq => $params->{'subcampo'} },   
                                                            ],
#                                                    require_objects => [ 'cat_nivel2', 'CEC' ]
                                                    require_objects => [ 'CEC' ],#INNER JOIN
                                                    with_objects => [ 'cat_nivel2' ], #LEFT JOIN
                                );
   }
   else{
    C4::AR::Debug::debug("getRepetible => NIVEL 3");
         $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
                                                    query => [ 
                                                                id3 => { eq => $params->{'id3'} },
                                                                'campo' => { eq => $params->{'campo'} },
                                                                'subcampo' => { eq => $params->{'subcampo'} },   
                                                        ],
#                                                     require_objects => [ 'cat_nivel3', 'CEC' ]
                                                        require_objects => [ 'CEC' ], #INNER JOIN  
                                                        with_objects => [ 'cat_nivel3' ], #LEFT JOIN
                                );
   }


    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref->[0]);
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
