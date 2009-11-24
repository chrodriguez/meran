package C4::AR::Catalogacion;

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
use C4::AR::EstructuraCatalogacionBase;


use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&crearCatalogo
	&buscarCamposObligatorios
	&buscarCampo
	&guardarCamposModificados
	&guardarCampoTemporal
);


################################################################ 06/11/10 ##############################################################

=item sub getNivel1RepetibleSinEstrucutra
  Esta funcion retorn un arreglo de objetos, donde los mismos no tiene configurada la estructura de catalogacion, o sea
  no se van a poder mostrar en el sistema
=cut
sub getNivel1RepetibleSinEstrucutra{
    my ($nivel, $ini, $cantR) = @_;

    my $dbh   = C4::Context->dbh;

    my $sth = $dbh->prepare(" SELECT count(*) as cant
                              FROM cat_nivel1_repetible n1r
                              WHERE (n1r.campo, n1r.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) ");
    $sth->execute($nivel);
    my $data = $sth->fetchrow_hashref;
    my $cant = $data->{'cant'};

    my $sth = $dbh->prepare(" SELECT *
                              FROM cat_nivel1_repetible n1r
                              WHERE (n1r.campo, n1r.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) LIMIT ?, ?");

    $sth->execute($nivel, $ini, $cantR);
    my @array_objects;

    while (my $data = $sth->fetchrow_hashref) {
        my $nivel_repetible = C4::AR::Nivel1::getNivel1RepetibleFromId1Repetible($data->{'rep_n1_id'});

        if($nivel_repetible){
            push (@array_objects, $nivel_repetible);
        }
    } # while

    return ($cant, @array_objects);
}

=item sub getNivel1RepetibleSinEstrucutra
  Esta funcion retorn un arreglo de objetos, donde los mismos no tiene configurada la estructura de catalogacion, o sea
  no se van a poder mostrar en el sistema
=cut
sub getNivel2RepetibleSinEstrucutra{
    my ($nivel, $ini, $cantR) = @_;

    my $dbh   = C4::Context->dbh;

    my $sth = $dbh->prepare(" SELECT count(*) as cant
                              FROM cat_nivel2_repetible n2r
                              WHERE (n2r.campo, n2r.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) ");
    $sth->execute($nivel);
    my $data = $sth->fetchrow_hashref;
    my $cant = $data->{'cant'};

    my $sth = $dbh->prepare(" SELECT *
                              FROM cat_nivel2_repetible n2r
                              WHERE (n2r.campo, n2r.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) LIMIT ?, ?");

    $sth->execute($nivel, $ini, $cantR);
    my @array_objects;

    while (my $data = $sth->fetchrow_hashref) {
        my $nivel_repetible = C4::AR::Nivel2::getNivel2RepetibleFromId2Repetible($data->{'rep_n2_id'});

        if($nivel_repetible){
            push (@array_objects, $nivel_repetible);
        }
    } # while

    return ($cant, @array_objects);
}

=item sub getNivel1RepetibleSinEstrucutra
  Esta funcion retorn un arreglo de objetos, donde los mismos no tiene configurada la estructura de catalogacion, o sea
  no se van a poder mostrar en el sistema
=cut
sub getNivel3RepetibleSinEstrucutra{
    my ($nivel, $ini, $cantR) = @_;

    my $dbh   = C4::Context->dbh;

    my $sth = $dbh->prepare(" SELECT count(*) as cant
                              FROM cat_nivel3_repetible n3r
                              WHERE (n3r.campo, n3r.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) ");
    $sth->execute($nivel);
    my $data = $sth->fetchrow_hashref;
    my $cant = $data->{'cant'};

    my $sth = $dbh->prepare(" SELECT *
                              FROM cat_nivel3_repetible n3r
                              WHERE (n3r.campo, n3r.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) LIMIT ?, ?");

    $sth->execute($nivel, $ini, $cantR);
    my @array_objects;

    while (my $data = $sth->fetchrow_hashref) {
        my $nivel_repetible = C4::AR::Nivel3::getNivel3RepetibleFromId3Repetible($data->{'rep_n3_id'});

        if($nivel_repetible){
            push (@array_objects, $nivel_repetible);
        }
    } # while

    return ($cant, @array_objects);
}

=item sub getImportacionSinEstructura
  Retorna un arreglo de objetos, campo, subcampo y dato, los cuales no se encuentran en la cat_estructura_catalogacion
=cut
sub getImportacionSinEstructura{
    my ($params) = @_;

    my $nivel = $params->{'nivel'};
    my $ini = $params->{'ini'};
    my $cantR = $params->{'cantR'};

    my @nivel_repetible_array_ref;
    my $cant;

    if($nivel eq '1'){
      ($cant, @nivel_repetible_array_ref) = getNivel1RepetibleSinEstrucutra($nivel, $ini, $cantR);
    }elsif($nivel eq '2'){
      ($cant, @nivel_repetible_array_ref) = getNivel2RepetibleSinEstrucutra($nivel, $ini, $cantR);
    }elsif($nivel eq '3'){
      ($cant, @nivel_repetible_array_ref) = getNivel3RepetibleSinEstrucutra($nivel, $ini, $cantR);
    }



    if(scalar(@nivel_repetible_array_ref) > 0){
        C4::AR::Debug::debug("Catalogacion => getImportacionSinEstructura => cant: ".scalar(@nivel_repetible_array_ref));
        return ($cant, @nivel_repetible_array_ref);
    }else{
        return 0;
    }
}

=item sub t_eliminarNivelRepetible
Esta funcion elimina un "campo", de uno de los niveles repetibles segun el nivel indicado por parametro y segun el id del nivel repetible
=cut
sub t_eliminarNivelRepetible{
    my ($params) = @_;
    
    if($params->{'nivel'} eq '1'){
        C4::AR::Nivel1::t_eliminarNivel1Repetible($params);
    }elsif($params->{'nivel'} eq '2'){
        C4::AR::Nivel2::t_eliminarNivel2Repetible($params);
    }elsif($params->{'nivel'} eq '3'){
        C4::AR::Nivel3::t_eliminarNivel3Repetible($params);
    }else{
#         ERROR
    }
}

















################################################### NUEVAS NUEVAS FRESQUITAS ##############################################################
=item sub subirOrden
Esta funcion sube el orden como se va a mostrar del campo, subcampo catalogado
=cut
sub subirOrden{
    my ($id,$itemtype) = @_;

    my $catAModificar = getEstructuraCatalogacionById($id);

    if($catAModificar){
        $catAModificar->subirOrden($itemtype);
    }else{
        C4::AR::Debug::debug("Catalogacion => subirOrden => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
    }
}

=item sub bajarOrden
Esta funcion baja el orden como se va a mostrar del campo, subcampo catalogado
=cut
sub bajarOrden{
    my ($id,$itemtype) = @_;

    my $catAModificar = getEstructuraCatalogacionById($id);

    if($catAModificar){
        $catAModificar->bajarOrden($itemtype);
     }else{
        C4::AR::Debug::debug("Catalogacion => subirOrden => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
    }
}

=item sub cambiarVisibilidad
Esta funcion cambia la visibilidad de la estructura de catalogacion que se indica segun parametro ID
=cut
sub cambiarVisibilidad{
    my ($id) = @_;

    my $catalogacion = getEstructuraCatalogacionById($id);

    if($catalogacion){
        $catalogacion->cambiarVisibilidad();
     }else{
        C4::AR::Debug::debug("Catalogacion => cambiarVisibilidad => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
    }
}

=item sub eliminarCampo
Esta funcion elimina un "campo", estructura de catalogacion, segun parametro ID
=cut
sub eliminarCampo{
    my ($id) = @_;

    my $catalogacion = getEstructuraCatalogacionById($id);

    if($catalogacion){
        $catalogacion->delete();
     }else{
        C4::AR::Debug::debug("Catalogacion => eliminarCampo => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
    }
}


=item t_guardarEnEstructuraCatalogacion
Esta transaccion guarda una estructura de catalogacion configurada por el bibliotecario 
=cut
sub t_guardarEnEstructuraCatalogacion {
    my($params) = @_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
        my  $estrCatalogacion = C4::Modelo::CatEstructuraCatalogacion->new();
        my $db = $estrCatalogacion->db;
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
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U365', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}


=item t_agruparCampos
Esta transaccion agrupa las configuraciones de campo, subcampo pasados por parametro 
=cut
sub t_agruparCampos {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
        my  $estrCatalogacion = C4::Modelo::CatEstructuraCatalogacion->new();
        my $db = $estrCatalogacion->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
        my $grupo = $estrCatalogacion->getNextGroup;
    
        eval {
#             $estrCatalogacion->agrupar($params, $db);  
            my $array_grupos = $params->{'array_grupos'};
        
            foreach my $id (@$array_grupos){
                my ($cat_estructura_catalogacion) = C4::AR::Catalogacion::getEstructuraCatalogacionById($id, $db);
                if($cat_estructura_catalogacion){
                    $cat_estructura_catalogacion->setGrupo($grupo);
                    $cat_estructura_catalogacion->save();
                }
            }

            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U410', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B448',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U411', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}


sub verificarModificarEnEstructuraCatalogacion {
    my($params, $msg_object) = @_;

#     if( !($msg_object->{'error'}) && ( $params->{'newpassword'} ne $params->{'newpassword1'} ) ){
    #verifico si se cambia el validador, que no tenga referencia
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U315', 'params' => [$params->{'cardnumber'}]} ) ;
#     }

}

=item sub t_modificarEnEstructuraCatalogacion
Esta transaccion guarda una estructura de catalogacion configurada por el bibliotecario 
=cut
sub t_modificarEnEstructuraCatalogacion {
    my($params) = @_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object = C4::AR::Mensajes::create();
    
    my $estrCatalogacion = getEstructuraCatalogacionById($params->{'id'});
    
    if(!$estrCatalogacion){
        #Se setea error para el usuario
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U405', 'params' => []} ) ;
    }

    if(!$msg_object->{'error'}){
    #No hay error
        my $db = $estrCatalogacion->db;
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
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U367', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}


#======================================================SOPORTE PARA ESTRUCTURA CATALOGACION====================================================


sub getDatoFromReferencia{
  my ($campo, $subcampo, $id_tabla) = @_;
  
  my $valor_referencia = '';

  if(($id_tabla ne '')&&($campo ne '')&&($subcampo ne '')){

      my $estructura = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
      
      if($estructura){
        if($estructura->getReferencia){
          #tiene referencia
          my $pref_tabla_referencia = C4::Modelo::PrefTablaReferencia->new();
          my $obj_generico = $pref_tabla_referencia->getObjeto($estructura->infoReferencia->getReferencia);
                                                                            #campo_tabla,                   id_tabla
          $valor_referencia = $obj_generico->obtenerValorCampo($estructura->infoReferencia->getCampos, $id_tabla);
          C4::AR::Debug::debug("getDatoFromReferencia => getReferencia: ".$estructura->infoReferencia->getReferencia);
          C4::AR::Debug::debug("getDatoFromReferencia => Tabla: ".$obj_generico->getTableName);
          C4::AR::Debug::debug("getDatoFromReferencia => Modulo: ".$obj_generico->toString);
          C4::AR::Debug::debug("getDatoFromReferencia => Valor referencia: ".$valor_referencia);
        }
      }
  }

  return $valor_referencia;
}

=item  sub _setDatos_de_estructura
    Esta funcion setea 

    @Parametros
    $cat: es un objeto de cat_estructura_catalogacion que contiene toda la estructura que se va a setear a la HASH
=cut
sub _setDatos_de_estructura {
    my ($cat, $datos_hash_ref) = @_;
    my %hash_ref_result;

    $hash_ref_result{'campo'} =                  $cat->getCampo;
    $hash_ref_result{'subcampo'} =               $cat->getSubcampo;
    $hash_ref_result{'dato'} =                   $datos_hash_ref->{'dato'};
    $hash_ref_result{'datoReferencia'}=          $datos_hash_ref->{'datoReferencia'};
    $hash_ref_result{'Id_rep'} =                 $datos_hash_ref->{'Id_rep'};
    $hash_ref_result{'tiene_estructura'}=        $datos_hash_ref->{'tiene_estructura'};
    $hash_ref_result{'ayuda_subcampo'} =         $datos_hash_ref->{'ayuda_subcampo'};
    $hash_ref_result{'descripcion_subcampo'} =   $datos_hash_ref->{'descripcion_subcampo'};
    $hash_ref_result{'nivel'} =                  $cat->getNivel;
    $hash_ref_result{'visible'} =                $cat->getVisible;
    $hash_ref_result{'liblibrarian'} =           $cat->getLiblibrarian;
    $hash_ref_result{'itemtype'} =               $cat->getItemType;
    $hash_ref_result{'repetible'} =              $cat->subCamposBase->getRepetible;
    $hash_ref_result{'tipo'} =                   $cat->getTipo;
    $hash_ref_result{'referencia'} =             $cat->getReferencia;
    $hash_ref_result{'obligatorio'} =            $cat->getObligatorio;
    $hash_ref_result{'idCompCliente'} =          $cat->getIdCompCliente;
    $hash_ref_result{'intranet_habilitado'} =    $cat->getIntranet_habilitado;
    $hash_ref_result{'rules'} =                  $cat->getRules;    
    $hash_ref_result{'fijo'} =                   $cat->getFijo;  

    C4::AR::Debug::debug("");
    if($cat->subCamposBase->getRepetible){    
        #solo para debug
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== ES UN REPETIBLE ======== ");
        C4::AR::Debug::debug("_setDatos_de_estructura => Id_rep: ".$datos_hash_ref->{'Id_rep'});
    }
    C4::AR::Debug::debug("_setDatos_de_estructura => campo, subcampo: ".$cat->getCampo.", ".$cat->getSubcampo);
    C4::AR::Debug::debug("_setDatos_de_estructura => dato: ".$datos_hash_ref->{'dato'});
    
    if( ($cat->getReferencia) && ($cat->getTipo eq 'combo') ){
        #tiene una referencia, y es un COMBO
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== COMBO ======== ");
        _obtenerOpciones ($cat, \%hash_ref_result);

    }elsif( ($cat->getReferencia) && ($cat->getTipo eq 'auto') ){
        #es un autocomplete
        $hash_ref_result{'referenciaTabla'} = $cat->infoReferencia->getReferencia;
        #si es un autocomplete y no tengo el dato de la referencia, muestro un blanco
        if ( ($hash_ref_result{'datoReferencia'} eq 0) || ($hash_ref_result{'dato'} eq 0) || not defined($hash_ref_result{'datoReferencia'}) ) {
          $hash_ref_result{'dato'} = 'NO TIENE';
        }
  
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== AUTOCOMPLETE ======== ");
        C4::AR::Debug::debug("_setDatos_de_estructura => datoReferencia: ".$hash_ref_result{'datoReferencia'});
        C4::AR::Debug::debug("_setDatos_de_estructura => referenciaTabla: ".$hash_ref_result{'referenciaTabla'});
#         if($cat->subCamposBase->getRepetible){
            #obtengo el dato de la referencia solo si es un repetible, los campos fijos recuperan de otra forma el dato de la referencia 
#             my $valor_referencia = getDatoFromReferencia($cat->getCampo, $cat->getSubcampo, $datos_hash_ref->{'dato'});
            my $valor_referencia = getDatoFromReferencia($cat->getCampo, $cat->getSubcampo, $datos_hash_ref->{'datoReferencia'});
            $hash_ref_result{'dato'} = $valor_referencia;
#         }
    }else{
        #cualquier otra componete
        C4::AR::Debug::debug("_setDatos_de_estructura => ======== ".$cat->getTipo." ======== ");
    }

    return (\%hash_ref_result);
}

#para los datos q no tienen estructura
sub _setDatos_de_estructura2 {
    my ($cat, $datos_hash_ref) = @_;

    my %hash_ref_result;

    $hash_ref_result{'campo'} =                  $cat->getCampo;
    $hash_ref_result{'subcampo'} =               $cat->getSubcampo;
    $hash_ref_result{'Id_rep'} =                 $datos_hash_ref->{'Id_rep'};
    $hash_ref_result{'tiene_estructura'}=        $datos_hash_ref->{'tiene_estructura'};
    $hash_ref_result{'dato'}=                    $datos_hash_ref->{'dato'};
    $hash_ref_result{'nivel'} =                  '';#$cat->getNivel;
    $hash_ref_result{'visible'} =                '';#$cat->getVisible;
    $hash_ref_result{'liblibrarian'} =           $cat->getLiblibrarian;
    $hash_ref_result{'itemtype'} =               '';#$cat->getItemType;
    $hash_ref_result{'repetible'} =              '';#$cat->subCamposBase->getRepetible;
    $hash_ref_result{'tipo'} =                   '';#$cat->getTipo;
    $hash_ref_result{'referencia'} =             '';#$cat->getReferencia;
    $hash_ref_result{'obligatorio'} =            $cat->getObligatorio;
    $hash_ref_result{'idCompCliente'} =          '';#$cat->getIdCompCliente;
    $hash_ref_result{'intranet_habilitado'} =    '';#$cat->getIntranet_habilitado;
    $hash_ref_result{'rules'} =                  '';#$cat->getRules;    

    C4::AR::Debug::debug("_setDatos_de_estructura2 => campo, subcampo: ".$cat->getCampo.", ".$cat->getSubcampo);
    C4::AR::Debug::debug("_setDatos_de_estructura2 => dato: ".$datos_hash_ref->{'dato'});

    return (\%hash_ref_result);
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
	
	#obtengo toda la informacion de la estructura de catalogacion del Nivel 1, 2 o 3
    my ($cant, $catalogaciones_array_ref) = getEstructuraCatalogacionFromDBCompleta($nivel, $itemType);

    C4::AR::Debug::debug("getEstructuraSinDatos => cant: ".$cant);    

    my @result;
    my @result_total;
    my $campo = '';
    my $campo_ant = '';
    foreach my $c  (@$catalogaciones_array_ref){
        my %hash;

        $campo = $c->getCampo;
        if($campo ne $campo_ant){
        #agrego la informacion del campo segun la estructura base pref_estructura_campo_marc    
            my %hash_campos;

            $hash_campos{'descripcion_campo'}  = $c->camposBase->getDescripcion.' - '.$c->getCampo;
            $hash_campos{'ayuda_campo'}        = 'esta es la ayuda del campo '.$c->getCampo;
#             $hash_campos{'subcampos_array'}    = \@result;
#             undef @result;
#             push (@result_total, \%hash_campos);
        }
        
        $hash{'tiene_estructura'}  = '1';
        $hash{'dato'}              = '';
        $hash{'datoReferencia'}    = 0;
        $hash{'Id_rep'}            = 0;
        
        my ($hash_temp) = _setDatos_de_estructura($c, \%hash);
        $campo_ant = $campo;
        
        push (@result, $hash_temp);

    }

    C4::AR::Debug::debug("getEstructuraSinDatos ============================================================================FIN");

    return (scalar(@$catalogaciones_array_ref), \@result);
#     return (scalar(@$catalogaciones_array_ref), \@result_total);
}

=item sub cantNivel2
     devuelve la cantidad de Niveles 2 que tiene  relacionados el Nivel 1 con id1 pasado por parameto
=cut
sub cantNivel2 {
    my ($id1) = @_;

    my $count = C4::Modelo::CatNivel2::Manager->get_cat_nivel2_count( query => [ id1 => { eq => $id1 } ]);

    return $count;
}

#########################################################PROBANDO######################################################################
=item sub getDatosRepetibleFromNivel 
    esta funcion trae toda la info del nivel pasado por parametro segun el id
=cut
sub getDatosRepetibleFromNivel{
    my ($params) = @_;

    my $nivel = $params->{'nivel'};

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
    C4::AR::Debug::debug("getDatosRepetibleFromNivel => NIVEL 1");
         $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
                                                    query => [ 
                                                                'cat_nivel1.id1' => { eq => $params->{'id'} },
                                                        ], 
                                                    with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN

                            );
    
   }
   elsif ($nivel == 2){
    C4::AR::Debug::debug("getDatosRepetibleFromNivel => NIVEL 2");
         $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
                                                    query => [ 
                                                                id2 => { eq => $params->{'id'} },
                                                            ],
                                                    with_objects => [ 'cat_nivel2' ], #LEFT JOIN
                                );
   }
   else{
    C4::AR::Debug::debug("getDatosRepetibleFromNivel => NIVEL 3");
         $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
                                                    query => [ 
                                                                id3 => { eq => $params->{'id3'} },
                                                        ],
                                                     with_objects => [ 'cat_nivel3' ], #LEFT JOIN
                                );
   }


    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}


sub getDatosFromNivel{
    my ($params) = @_;

    C4::AR::Debug::debug("getDatosFromNivel => ======================================================================");
    my $nivel       = $params->{'nivel'};
    my $itemType    = $params->{'id_tipo_doc'};

    C4::AR::Debug::debug("getDatosFromNivel => tipo de documento: ".$itemType);
    #obtengo los datos de alguno de los niveles SOLO REPETIBLES, cat_nivel1_repetible, cat_nivel2_repetible o cat_nivel3_repetible
    my ($cant, $catalogaciones_array_ref_objects) = getDatosRepetibleFromNivel($params);

    my @result;
    my $campo;
    my $campo_ant;

    foreach my $c  (@$catalogaciones_array_ref_objects){

        C4::AR::Debug::debug("getDatosFromNivel => campo, subcampo, dato => ".$c->getCampo.", ".$c->getSubcampo.": ".$c->getDato);
        my $hash_temp;
        #verifico si existe la estructura para el campo subcampo que se va a intentar mostrar, si no existe se lo imprime
        my $estructura = _getEstructuraFromCampoSubCampo( $c->getCampo, $c->getSubcampo );
        if($estructura){

            my %hash;
            $hash{'tiene_estructura'}  = '1';
            $hash{'dato'}              = $c->getDato;
            $hash{'datoReferencia'}    = $c->getDato;
            $hash{'Id_rep'}            = $c->getId_rep;

            $campo = $c->getCampo;

            if($campo ne $campo_ant){
            #agrego la informacion del campo segun la estructura base pref_estructura_campo_marc    
                $hash{'descripcion_campo'} = 'esta es la descripcion del campo '.$c->getCampo;
                $hash{'ayuda_campo'} = 'esta es la ayuda del campo '.$c->getCampo;
            }

            C4::AR::Debug::debug("getDatosFromNivel => Id_rep => ".$c->getId_rep);
    
            ($hash_temp) = _setDatos_de_estructura($estructura, \%hash);

        }else{      
        #no tiene estructura, se imprime
            my $estructura = &C4::AR::EstructuraCatalogacionBase::getEstructuraBaseFromCampoSubCampo( $c->getCampo, $c->getSubcampo );
            C4::AR::Debug::debug("getDatosFromNivel => NO EXISTE ESTRUCTURA PARA ");
            C4::AR::Debug::debug("getDatosFromNivel => campo, subcampo, dato => ".$c->getCampo.", ".$c->getSubcampo.": ".$c->getDato);
            C4::AR::Debug::debug("getDatosFromNivel => NO EXISTE ESTRUCTURA PARA Liblibrarian: ".$estructura->getLiblibrarian);    

            my %hash;

            $hash{'tiene_estructura'}  = '0';
            my $dato = $c->getDato;
            if($c->getDato eq ''){
                $dato = " SIN DATO ";
            }

            $hash{'dato'}              = $c->getCampo.", ".$c->getSubcampo.": ".$dato;
            $hash{'datoReferencia'}    = 0;

            ($hash_temp) = _setDatos_de_estructura2($estructura, \%hash);

        }
    
        push (@result, $hash_temp);
      

    }# END foreach my $cat_estructura  (@$catalogaciones_array_ref_objects)

    #obtengo los datos de nivel 1, 2 y 3 mapeados a MARC, con su informacion de estructura de catalogacion
    my @resultEstYDatos = _getEstructuraYDatosDeNivelNoRepetible($params);
    push(@resultEstYDatos,@result);
    my @sorted = sort { $a->{campo} cmp $b->{campo} } @resultEstYDatos; # alphabetical sort 

#     return (scalar(@resultEstYDatos), \@resultEstYDatos);
    return (scalar(@resultEstYDatos), \@sorted);
}

###################################################FIN PROBANDO######################################################################

=item
Esta funcion retorna la estructura de catalogacion con los datos de un Nivel (NO REPETIBLES).
Ademas mapea las campos fijos de nivel 1, 2 y 3 a MARC
=cut
sub _getEstructuraYDatosDeNivelNoRepetible{
	my ($params) = @_;

	my @result;
	my $nivel;
	if( $params->{'nivel'} eq '1'){
		$nivel = C4::AR::Nivel1::getNivel1FromId1($params->{'id'});
        C4::AR::Debug::debug("_getEstructuraYDatosDeNivelNoRepetible=>  getNivel1FromId1\n");
	}
	elsif( $params->{'nivel'} eq '2'){
		$nivel = C4::AR::Nivel2::getNivel2FromId2($params->{'id'});
        C4::AR::Debug::debug("_getEstructuraYDatosDeNivelNoRepetible=>  getNivel2FromId2\n");
	}
	elsif( $params->{'nivel'} eq '3'){
		$nivel = C4::AR::Nivel3::getNivel3FromId3($params->{'id3'});
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
      
  
        if($cat_estruct_array){	

            my %hash_temp;
            my $estructura = _getEstructuraFromCampoSubCampo( 
                                                                $nivel_info_marc_array->[$i]->{'campo'},
                                                                $nivel_info_marc_array->[$i]->{'subcampo'}     
                                                    );

            if($estructura){
                $hash_temp{'tiene_estructura'}  = '1';
            }else{
                $hash_temp{'tiene_estructura'}  = '0';
            }

            $hash_temp{'dato'} = $nivel_info_marc_array->[$i]->{'dato'};
            $hash_temp{'datoReferencia'} = $nivel_info_marc_array->[$i]->{'datoReferencia'};

            my $hash_result = _setDatos_de_estructura($cat_estruct_array, \%hash_temp);
                
            push(@result, $hash_result);
        }
      }
    }# END for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++)

	return @result;
}


sub _obtenerOpciones{
    my ($cat_estruct_object, $hash_ref) = @_;

    C4::AR::Debug::debug('_obtenerOpciones => es un combo, se setean las opciones para => '.$cat_estruct_object->infoReferencia->getReferencia);
    C4::AR::Debug::debug('_obtenerOpciones => getCampos => '.$cat_estruct_object->infoReferencia->getCampos);
    my $orden = $cat_estruct_object->infoReferencia->getCampos;
    my ($cantidad, $valores) = &C4::AR::Referencias::obtenerValoresTablaRef(   
                                                                $cat_estruct_object->infoReferencia->getReferencia,  #tabla  
                                                                $cat_estruct_object->infoReferencia->getCampos,  #campo
                                                                $orden
                                                );
    $hash_ref->{'opciones'} = $valores;

    C4::AR::Debug::debug("_obtenerOpciones => opciones => ".$valores);
}


=item sub getEstructuraCatalogacionFromDBCompleta
    Retorna la estructura de catalogacion del Nivel 1, 2 o 3 que se encuentra configurada en la BD
=cut
sub getEstructuraCatalogacionFromDBCompleta{
    my ($nivel, $itemType) = @_;

    use C4::Modelo::CatEstructuraCatalogacion::Manager;

    my $catalogaciones_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
                                                                query => [ 
                                                                                nivel => { eq => $nivel },

                                                                    or   => [ 	
                                                                                itemtype => { eq => $itemType },
                                                                            	itemtype => { eq => 'ALL' },    
                                                                            ],

                                                                        		intranet_habilitado => { gt => 0 }, 
                                                                        ],

                                                                with_objects    => [ 'infoReferencia' ],  #LEFT OUTER JOIN
                                                                require_objects => [ 'camposBase', 'subCamposBase' ],
#                                                                 sort_by => ( 'intranet_habilitado' ),
                                                                sort_by => ( 'campo' ),
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
                                                                query   => [ 
                                                                                nivel => { eq => $nivel },

                                                                    or  => [   
                                                                                itemtype => { eq => $itemType },
                                                                                itemtype => { eq => 'ALL' },    
                                                                            ],

                                                                                intranet_habilitado => { gt => 0 }, 
                                                                                repetible => { eq => 1 },
                                                                        ],

                                                                with_objects    => [ 'infoReferencia' ],  #LEFT OUTER JOIN
                                                                require_objects => [ 'subCamposBase' ], #INNER JOIN
                                                                sort_by         => ( 'intranet_habilitado' ),
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
    my ($params) = @_;

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
                                                            'cat_nivel1.id1'    => { eq => $params->{'id'} },
                                                            'campo'             => { eq => $params->{'campo'} },
                                                            'subcampo'          => { eq => $params->{'subcampo'} },        
                                                    ], 
                                                with_objects        => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN
                                                require_objects     => [ 'CEC' ] #INNER JOIN

                            );
    
   }
   elsif ($nivel == 2){
    C4::AR::Debug::debug("getRepetible => NIVEL 2");
         $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
                                                    query => [ 
                                                                id2         => { eq => $params->{'id'} },
                                                                'campo'     => { eq => $params->{'campo'} },
                                                                'subcampo'  => { eq => $params->{'subcampo'} },   
                                                            ],
                                                    require_objects     => [ 'CEC' ],#INNER JOIN
                                                    with_objects        => [ 'cat_nivel2' ], #LEFT JOIN
                                );
   }
   else{
    C4::AR::Debug::debug("getRepetible => NIVEL 3");
         $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
                                                    query => [ 
                                                                id3         => { eq => $params->{'id3'} },
                                                                'campo'     => { eq => $params->{'campo'} },
                                                                'subcampo'  => { eq => $params->{'subcampo'} },   
                                                        ],
                                                        require_objects     => [ 'CEC' ], #INNER JOIN  
                                                        with_objects        => [ 'cat_nivel3' ], #LEFT JOIN
                                );
   }


    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref->[0]);
}

=item sub _getEstructuraFromCampoSubCampo
Este funcion devuelve la configuracion de la estructura de catalogacion de un campo, subcampo, realizada por el usuario
=cut
# FIXME una estructura para un campo, subcampo varia segun el tipo de documento
sub _getEstructuraFromCampoSubCampo{
    my ($campo, $subcampo) = @_;

#     C4::AR::Debug::debug("_getEstructuraFromCampoSubCampo ????????????????????????????????????????");

	my $cat_estruct_info_array = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
																				query => [ 
																							campo       => { eq => $campo },
																							subcampo    => { eq => $subcampo },
																					], 
                                                                                with_objects    => ['infoReferencia'],#LEFT JOIN
                                                                                require_objects => [ 'subCamposBase' ] #INNER JOIN

										);	


  if(scalar(@$cat_estruct_info_array) > 0){
    return $cat_estruct_info_array->[0];
  }else{
    return 0;
  }
}

=item sub getEstructuraCatalogacionById
Este funcion devuelve la configuracion de la estructura de catalogacion segun id pasado por parametro
=cut
sub getEstructuraCatalogacionById{
    my ($id, $db) = @_;
    
    $db = $db || C4::Modelo::PermCatalogo->new()->db;   

    my $cat_estructura_catalogacion_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
                                                                                db      => $db,
                                                                                query   => [ 
                                                                                            id => { eq => $id },
                                                                                    ], 

                                        );  

    if(scalar(@$cat_estructura_catalogacion_array_ref) > 0){
        return $cat_estructura_catalogacion_array_ref->[0];
    }else{
        return 0;
    }
}

#====================================================FIN==SOPORTE PARA ESTRUCTURA CATALOGACION==================================================
