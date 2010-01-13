package C4::AR::Catalogacion;

use strict;
require Exporter;
use C4::Context;
use C4::AR::Busquedas;
use C4::Date;
use C4::AR::Utilidades;
use MARC::Record;
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

=head1 NAME

C4::AR::Catalogacion - Funciones que manipulan datos del catálogo

=head1 SYNOPSIS

  use C4::AR::Catalogacion;

=head1 DESCRIPTION

  Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC, también en la carga de los items en los distintos niveles y de la creacion del catálogo.

=head1 FUNCTIONS

=over 2
=cut


=head2
sub meran_to_marc 

Funcion auxiliar que toma datos desde json con formato de entrada de la interfaz web de meran y devuelve un marc_record, se utiliza en los tres niveles de catalogacion de MARC.
El formato es el siguiente [dato], cada dato es un hash con los siguientes campos (campo->'950',identificador_1->'1', indentificador2->'2',[subcampo]) y cada subcampo es un hash con ('subcampo'->'contenido, ej 'a'->'Mikaela es del rojo')
=cut
sub _meran_to_marc{
    my ($infoArrayNivel, $campos_autorizados, $itemtype) = @_;

    my $marc_record = MARC::Record->new();
    my $cant_campos = scalar(@$infoArrayNivel);
    my %autorizados;

    #armo el arreglo de campo => [subcampos] autorizados
    foreach my $autorizado (@$campos_autorizados){
       push(@{$autorizados{$autorizado->getCampo()}},$autorizado->getSubcampo());
    }

    my $field;
    for (my $i=0;$i<$cant_campos;$i++){
        my %hash_campos             = $infoArrayNivel->[$i];
        my $indentificador_1        = C4::AR::Utilidades::ASCIItoHEX($infoArrayNivel->[$i]->{'indicador_primario'});
        my $indentificador_2        = C4::AR::Utilidades::ASCIItoHEX($infoArrayNivel->[$i]->{'indicador_secundario'});
        my $campo                   = $infoArrayNivel->[$i]->{'campo'};
        my $subcampos_hash          = $infoArrayNivel->[$i]->{'subcampos_hash'};
        my $cant_subcampos          = $infoArrayNivel->[$i]->{'cant_subcampos'};

        my @subcampos_array;
        #se verifica si el campo esta autorizado para el nivel que se estra procesando
        for(my $j=0;$j<$cant_subcampos;$j++){
            my $subcampo= $subcampos_hash->{$j};
            #C4::AR::Debug::debug("CAMPO => ".$campo);
            #C4::AR::Utilidades::printHASH($subcampo);
            while ( my ($key, $value) = each(%$subcampo) ){
                #C4::AR::Utilidades::printARRAY($autorizados{$campo});
                $value = _procesar_referencia($campo, $key, $value, $itemtype);
                if ( ($value ne '')&&(C4::AR::Utilidades::existeInArray($key, @{$autorizados{$campo}} ) )) {
                #el subcampo $key, esta autorizado para el campo $campo
                    push(@subcampos_array, ($key => $value));
#                     C4::AR::Debug::debug("ACEPTADO clave = ".$key." valor: ".$value);
                }else{
#                     $msg_object->{'error'} = 1;
#                     C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U412', 'params' => [$campo.", ".$key." valor: ".$value]} ) ;
                }
            }
        }

        if(scalar(@subcampos_array) > 0){
# TODO, el indicador undefined # (numeral) debe ser reemplazado por blanco el asci correspondiente
#             C4::AR::Debug::debug("indicador_primario    ".C4::AR::Utilidades::HEXtoASCII($indentificador_1)." del campo ".$campo);
#             C4::AR::Debug::debug("indicador_secundario  ".C4::AR::Utilidades::HEXtoASCII($indentificador_2)." del campo ".$campo);

#             C4::AR::Debug::debug("blanco 2 ". C4::AR::Utilidades::dec2hex(32));

            $field = MARC::Field->new($campo, $indentificador_1, $indentificador_2, @subcampos_array);
            #C4::AR::Utilidades::printHASH($field);
            #C4::AR::Debug::debug("field  warnings: ".$field->warnings());
            
            $marc_record->add_fields($field);
            #C4::AR::Debug::debug("meran_nivel_to_meran => COMPLETO => as_formatted ".$field->as_formatted());
        }
    }

    C4::AR::Debug::debug("_meran_to_marc => SALIDA => as_formatted ".$marc_record->as_formatted());
    
    return($marc_record);
}

=head2
sub meran_nivel1_to_meran 

Toma una estructura que proviene de la interface de catalogación de meran con un formato establecido y genera un Marc:Record que se va a enviar para guardar teniendo en cuenta los campos que estan habilitados para este nivel.
Se apoya en la funcion _meran_to_marc que entiende el formato.
=cut
sub meran_nivel1_to_meran{
    my ($data_hash) = @_;

    my $campos_autorizados          = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel(1);
    $data_hash->{'tipo_ejemplar'}   = 'ALL';
    my $marc_record                 = _meran_to_marc($data_hash->{'infoArrayNivel1'},$campos_autorizados,$data_hash->{'tipo_ejemplar'});

    return($marc_record);
}

=head2
sub meran_nivel2_to_meran 

Funciona de manera similar a meran_nivel1_to_meran pero para el nivel 2

=cut
sub meran_nivel2_to_meran{
    my ($data_hash) = @_;

    my $campos_autorizados          = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel(2);
    my $marc_record                 = _meran_to_marc($data_hash->{'infoArrayNivel2'},$campos_autorizados,$data_hash->{'tipo_ejemplar'});

    return($marc_record);
}



=head2
sub meran_nivel3_to_meran

Funciona de manera similar a meran_nivel1_to_meran pero para el nivel 3

=cut
sub meran_nivel3_to_meran{
    my ($data_hash) = @_;

    my $campos_autorizados  = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel(3);
    my $marc_record         = _meran_to_marc($data_hash->{'infoArrayNivel3'},$campos_autorizados,$data_hash->{'tipo_ejemplar'});

    return($marc_record);

}


=head2
sub Z3950_to_meran

Recibe los datos de la importacion z3950 y los guarda en la base de meran, teniendo en cuenta tablas de referencia  
=cut
sub Z3950_to_meran{
    my($marc_record) = @_;

    my ($msg_object) = C4::AR::Mensajes::create();
    my $id1;
    my $id2;
    my $id3;

# FIXME QUE ES ESTO???
#     $msg_object->{'tipo'}="INTRA";
    
    my ($marc_record_limpio1,$marc_record_limpio2,$marc_record_limpio3,$marc_record_campos_sin_definir)=_procesar_referencias($marc_record);
    if (scalar($marc_record_limpio1->fields())>0){
    	C4::AR::Debug::debug("Z3950 marc_nivel1 => SALIDA => as_formatted ".$marc_record_limpio1->as_formatted());
        ($msg_object,$id1)=C4::AR::Nivel1::guardarRealmente($msg_object,$marc_record_limpio1); }
    if (scalar($marc_record_limpio2->fields())>0){
    	C4::AR::Debug::debug("Z3950 marc_nivel2 => SALIDA => as_formatted ".$marc_record_limpio2->as_formatted());
    	($msg_object,$id1,$id2)=C4::AR::Nivel2::guardarRealmente($msg_object,$id1,$marc_record_limpio2); }
    if (scalar($marc_record_limpio3->fields())>0){
    	C4::AR::Debug::debug("Z3950 marc_nivel3 => ERROR en la estrcutura => as_formatted ".$marc_record_limpio3->as_formatted());
    }
    if (scalar($marc_record_campos_sin_definir->fields())>0){
    	C4::AR::Debug::debug("Z3950 WARNING campos no definidos en la biblia!!  => SALIDA => as_formatted ".$marc_record_campos_sin_definir->as_formatted());
    }
    return($msg_object);
    
}


=head2
sub _procesar_referencias

lo que hace esta funcion es recibir un objeto marc y procesarlo para procesar aquellos campos que son referencia, lo que hace es recorrer todos los campos del objeto y aquellos que estan configurados como referencia en la tabla CatEstructuraCatalogacion los modifica, cambiando el dato por su referencia en el marc_record y agregando la referencia a la tabla correspondiente en caso de no estar en ella
=cut
sub _procesar_referencias{
    my($marc_record)=@_;
    my $campos_referenciados = C4::Modelo::CatEstructuraCatalogacion::getCamposConReferencia();
    my %referenciados;
    my @subcampos1_array;
    my @subcampos2_array;
    my @subcampos3_array;
    my $marc_record_limpio1=MARC::Record->new();
    my $marc_record_limpio2=MARC::Record->new();
    my $marc_record_limpio3=MARC::Record->new();
    my $marc_record_campos_sin_definir=MARC::Record->new();
    my $ref_campos_nivel1 = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel(1);
    my %campos_nivel1;
    foreach my $campo_nivel1 (@$ref_campos_nivel1){
       push(@{$campos_nivel1{$campo_nivel1->getCampo()}},$campo_nivel1->getSubcampo());
    }
    my $ref_campos_nivel2 = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel(2);
    my %campos_nivel2;
    foreach my $campo_nivel2 (@$ref_campos_nivel2){
       push(@{$campos_nivel2{$campo_nivel2->getCampo()}},$campo_nivel2->getSubcampo());
    }
    my $ref_campos_nivel3 = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel(3);
    my %campos_nivel3;
    foreach my $campo_nivel3 (@$ref_campos_nivel3){
       push(@{$campos_nivel3{$campo_nivel3->getCampo()}},$campo_nivel3->getSubcampo());
    }
    foreach my $referenciado (@$campos_referenciados){
       push(@{$referenciados{$referenciado->getCampo()}},$referenciado->getSubcampo());
    }
    foreach my $field ($marc_record->fields) {
        if(! $field->is_control_field){
            my $campo = $field->tag;
            my @subcampos1_array;
            my @subcampos2_array;
            my @subcampos3_array;
            my @subcampos_sin_definir_array;
            foreach my $subfield ($field->subfields()) {
                my $subcampo                = $subfield->[0];
                my $dato                    = $subfield->[1];
                if (($referenciados{$campo})&&(C4::AR::Utilidades::existeInArray($subcampo, @{$referenciados{$campo}}))){
                    #si entre aca quiere decir q el campo esta referenciado;
#                    C4::AR::Debug::debug("ACA ESTAMOS".$campo.$subcampo.$dato);
                   $dato=_procesar_referencia($campo,$subcampo,$dato);
#                    C4::AR::Debug::debug("ACA ESTAMOS".$campo.$subcampo."NUEVO DATO".$dato);
                }
                if ( ($dato ne '')&&(C4::AR::Utilidades::existeInArray($subcampo, @{$campos_nivel1{$campo}} ) )) { 
                    push(@subcampos1_array, ($subcampo => $dato));
                } elsif ( ($dato ne '')&&(C4::AR::Utilidades::existeInArray($subcampo, @{$campos_nivel2{$campo}} ) )) { 
                        push(@subcampos2_array, ($subcampo => $dato));
                        } elsif ( ($dato ne '')&&(C4::AR::Utilidades::existeInArray($subcampo, @{$campos_nivel3{$campo}} ) )) { 
                            push(@subcampos3_array, ($subcampo => $dato));
                            } elsif ($dato ne '') { 
                                push(@subcampos_sin_definir_array, ($subcampo => $dato));
                            }
            }
        if (scalar(@subcampos1_array)>0){
        	my $field_limpio1 = MARC::Field->new($campo, $field->indicator(1), $field->indicator(2), @subcampos1_array);
        	$marc_record_limpio1->add_fields($field_limpio1);}
        if (scalar(@subcampos2_array)>0){
        	my $field_limpio2 = MARC::Field->new($campo, $field->indicator(1), $field->indicator(2), @subcampos2_array);
        	$marc_record_limpio2->add_fields($field_limpio2);}
        if (scalar(@subcampos3_array)>0){
        	my $field_limpio3 = MARC::Field->new($campo, $field->indicator(1), $field->indicator(2), @subcampos3_array);
        	$marc_record_limpio3->add_fields($field_limpio3);}
        if (scalar(@subcampos_sin_definir_array)>0){
        	my $field_sin_definir = MARC::Field->new($campo, $field->indicator(1), $field->indicator(2), @subcampos_sin_definir_array);
        	$marc_record_campos_sin_definir->add_fields($field_sin_definir);}
        }
    }
#     C4::AR::Debug::debug("meran_nivel_to_meran => COMPLETO => as_formatted ".$marc_record_limpio1->as_formatted());
    return($marc_record_limpio1,$marc_record_limpio2,$marc_record_limpio3,$marc_record_campos_sin_definir);
}



=head2
sub importacion_to_meran
    Esta funcion la idea es que sea llamada desde las distintas fuentes de ingreso de datos que existen, ej: aguapey, bibun, biblo, etc
=cut
sub importacion_to_meran{

}


=head2
sub koha2_to_meran

 Esta funcion la idea es que sea llamada desde las distintas fuentes de ingreso de datos que existen, ej: aguapey, bibun, biblo, etc
=cut
sub koha2_to_meran{

}

sub detalleMARC {
    my ($marc_record) = @_;

    my ($MARC_result_array) = marc_record_to_meran($marc_record);

    return ($MARC_result_array);
}


=head2
    sub marc_record_to_meran_por_nivel

    @params
    $params->{'nivel'}
    $params->{'id_tipo_doc'}
    $marc_record datos del nivel del registro
=cut
sub marc_record_to_meran_por_nivel {
    my ($marc_record, $params) = @_;
    
    #obtengo la estructura y se verifica si falta agregar un campo, subcampo a la estructura de los datos    
    my ($cant, $catalogaciones_array_ref) = getEstructuraSinDatos($params);
    agregarCamposVacios($marc_record, $catalogaciones_array_ref);

    my ($MARC_result_array) = marc_record_to_meran($marc_record, $params->{'id_tipo_doc'});
        
    return $MARC_result_array;
}

=head2
    sub marc_record_to_opac_view
=cut
sub marc_record_to_opac_view {
    my ($marc_record, $params) = @_;

    $params->{'tipo'} = 'OPAC';
    #obtengo los campo, subcampo que se pueden mostrar
    my ($marc_record_salida) = filtrarVisualizacion($marc_record, $params);

    #se procesa el marc_record filtrado
    my ($MARC_result_array) = marc_record_to_meran($marc_record_salida);

    return $MARC_result_array;
}

=head2
    sub marc_record_to_intra_view
=cut
sub marc_record_to_intra_view {
    my ($marc_record, $params) = @_;

    
    $params->{'tipo'} = 'INTRA';
    #obtengo los campo, subcampo que se pueden mostrar
    my ($marc_record_salida) = filtrarVisualizacion($marc_record, $params);

    #se procesa el marc_record filtrado
    my ($MARC_result_array) = marc_record_to_meran($marc_record_salida);

    return $MARC_result_array;
}


=head2
    sub filtrarVisualizacion
    filtra la visualizacion del opac, se muestra lo indicado en cat_visualizacion_opac
=cut
sub filtrarVisualizacion{
    my ($marc_record, $params) = @_;

    my $visulizacion_array_ref;

    use C4::AR::VisualizacionOpac;
    use C4::AR::VisualizacionIntra;
    use C4::AR::VisualizacionOpac;
    if($params->{'tipo'} eq 'OPAC'){
        ($visulizacion_array_ref) = C4::AR::VisualizacionOpac::getConfiguracion();
    } else {
        ($visulizacion_array_ref) = &C4::AR::VisualizacionIntra::getConfiguracion($params->{'tipo_ejemplar'});
    }

    my %autorizados;
    my $marc_record_salida = MARC::Record->new();
    #se genera el arreglo de campo, subcampos autorizados para mostrar
    foreach my $autorizado (@$visulizacion_array_ref){
       push(@{$autorizados{$autorizado->getCampo()}},$autorizado->getSubCampo());
    }

    foreach my $field ($marc_record->fields) {
        if(! $field->is_control_field){
            #se verifica si el campo esta autorizado para el nivel que se estra procesando
                my @subcampos_array = ();
                foreach my $subfield ($field->subfields()){
                    my $dato = $subfield->[1];
                    my $sub_campo = $subfield->[0];
                    if ( ($sub_campo ne '')&&(C4::AR::Utilidades::existeInArray($sub_campo, @{$autorizados{$field->tag}} ) )) {
                        #el subcampo $sub_campo, esta autorizado para el campo $field
                        push(@subcampos_array, ($sub_campo => $dato));
                        #C4::AR::Debug::debug("ACEPTADO clave = ".$key." valor: ".$value);
                    }else{
    #                     $msg_object->{'error'} = 1;
    #                     C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U412', 'params' => [$campo.", ".$key." valor: ".$value]} ) ;
                    }
                }
                if (scalar(@subcampos_array)){
                    my $marc_record_salida_temp = MARC::Field->new($field->tag, $field->indicator(1), $field->indicator(2), @subcampos_array);
                    $marc_record_salida->add_fields($marc_record_salida_temp);
                }
        }
    }

    return $marc_record_salida;
}


=head2
    sub marc_record_to_meran
    
    pasa la informacion de un marc_record a una estructura para utilizar en el cliente

    campo => "campo"
    indicador_primario =>
    indicador_secundario => 
    subcampos_array => [ {subcampo => 'a', dato => 'dato'}, {subcampo => 'b', dato => 'dato'}, ...]
=cut
sub marc_record_to_meran {
    my ($marc_record, $itemtype) = @_;

    C4::AR::Debug::debug("Catalogacion => marc_record_to_meran ");
    my @MARC_result_array;

    foreach my $field ($marc_record->fields) {
     if(! $field->is_control_field){
        my %hash;
        my $campo                       = $field->tag;
        my $indicador_primario_dato     = $field->indicator(1);
        my $indicador_secundario_dato   = $field->indicator(2);
        my @subcampos_array;
#         C4::AR::Debug::debug("Proceso todos los subcampos del campo: ".$campo);
        #proceso todos los subcampos del campo
        foreach my $subfield ($field->subfields()) {
            my %hash_temp;

            my $subcampo                        = $subfield->[0];
            my $dato                            = $subfield->[1];
            C4::AR::Debug::debug("Catalogacion => detalleMARC => campo: ".$campo);
            C4::AR::Debug::debug("Catalogacion => detalleMARC => subcampo: ".$subcampo);
            C4::AR::Debug::debug("Catalogacion => detalleMARC => dato: ".$dato);
            $hash_temp{'subcampo'}              = $subcampo;
            $hash_temp{'liblibrarian'}          = C4::AR::Catalogacion::getLiblibrarian($campo, $subcampo, $itemtype);
            $dato                               = getRefFromStringConArrobasByCampoSubcampo($campo, $subcampo, $dato, $itemtype);
            $hash_temp{'datoReferencia'}        = $dato;
            C4::AR::Debug::debug("Catalogacion => detalleMARC => dato despues de getRefFromStringConArrobasByCampoSubcampo: ".$dato);
            my $valor_referencia                = getDatoFromReferencia($campo, $subcampo, $dato, $itemtype);
            $hash_temp{'dato'}                  = $valor_referencia;
            C4::AR::Debug::debug("Catalogacion => marc_record_to_meran => dato despues de getDatoFromReferencia: ".$hash_temp{'dato'});

            push(@subcampos_array, \%hash_temp);
        }
            $hash{'campo'}                      = $campo;
            $hash{'indicador_primario_dato'}    = $indicador_primario_dato;
            $hash{'indicador_secundario_dato'}  = $indicador_secundario_dato;
            $hash{'header'}                     = C4::AR::Catalogacion::getHeader($campo);
            $hash{'subcampos_array'}            = \@subcampos_array;

            push(@MARC_result_array, \%hash);
        }
    }

    return (\@MARC_result_array);
}

=item sub getCatRegistroMarcN1SinEstructura
  Esta funcion retorn un arreglo de objetos, donde los mismos no tiene configurada la estructura de catalogacion, o sea
  no se van a poder mostrar en el sistema
=cut
# FIXME DEPRECATEDDDDDDDDDDD
sub getCatRegistroMarcN1SinEstructura{
    my ($nivel, $ini, $cantR) = @_;

    my $dbh   = C4::Context->dbh;

    my $sth = $dbh->prepare(" SELECT count(*) as cant
                              FROM cat_registro_marc_n1 crmn1
                              WHERE (crmn1.campo, crmn1.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) ");
    $sth->execute($nivel);
    my $data = $sth->fetchrow_hashref;
    my $cant = $data->{'cant'};

    my $sth = $dbh->prepare(" SELECT *
                              FROM cat_registro_marc_n1 crmn1
                              WHERE (crmn1.campo, crmn1.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) LIMIT ?, ?");

    $sth->execute($nivel, $ini, $cantR);
    my @array_objects;

    while (my $data = $sth->fetchrow_hashref) {
        my $nivel_array_ref = C4::AR::Nivel1::getNivel1FromId1($data->{'id'});

        if($nivel_array_ref){
            push (@array_objects, $nivel_array_ref);
        }
    } # while

    return ($cant, @array_objects);
}

=item sub getCatRegistroMarcN2SinEstructura
  Esta funcion retorn un arreglo de objetos, donde los mismos no tiene configurada la estructura de catalogacion, o sea
  no se van a poder mostrar en el sistema
=cut
# FIXME DEPRECATEDDDDDDDDDDD
sub getCatRegistroMarcN2SinEstructura{
    my ($nivel, $ini, $cantR) = @_;

    my $dbh   = C4::Context->dbh;

    my $sth = $dbh->prepare(" SELECT count(*) as cant
                              FROM cat_registro_marc_n2 crmn2
                              WHERE (crmn2.campo, crmn2.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) ");
    $sth->execute($nivel);
    my $data = $sth->fetchrow_hashref;
    my $cant = $data->{'cant'};

    my $sth = $dbh->prepare(" SELECT *
                              FROM cat_registro_marc_n2 crmn2
                              WHERE (crmn2.campo, crmn2.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) LIMIT ?, ?");

    $sth->execute($nivel, $ini, $cantR);
    my @array_objects;

    while (my $data = $sth->fetchrow_hashref) {
        my $nivel_array_ref = C4::AR::Nivel2::getNivel2FromId2($data->{'id'});

        if($nivel_array_ref){
            push (@array_objects, $nivel_array_ref);
        }
    } # while

    return ($cant, @array_objects);
}


=item sub getCatRegistroMarcN3SinEstructura
  Esta funcion retorn un arreglo de objetos, donde los mismos no tiene configurada la estructura de catalogacion, o sea
  no se van a poder mostrar en el sistema
=cut
# FIXME DEPRECATEDDDDDDDDDDD
sub getCatRegistroMarcN3SinEstructura{
    my ($nivel, $ini, $cantR) = @_;

    my $dbh   = C4::Context->dbh;

    my $sth = $dbh->prepare(" SELECT count(*) as cant
                              FROM cat_registro_marc_n3 crmn3
                              WHERE (crmn3.campo, crmn3.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) ");
    $sth->execute($nivel);
    my $data = $sth->fetchrow_hashref;
    my $cant = $data->{'cant'};

    my $sth = $dbh->prepare(" SELECT *
                              FROM cat_registro_marc_n3 crmn3
                              WHERE (crmn3.campo, crmn3.subcampo) NOT IN 

                              (SELECT cec.campo, cec.subcampo
                              FROM cat_estructura_catalogacion cec
                              WHERE cec.nivel = ?) LIMIT ?, ?");

    $sth->execute($nivel, $ini, $cantR);
    my @array_objects;

    while (my $data = $sth->fetchrow_hashref) {
        my $nivel_array_ref = C4::AR::Nivel3::getNivel3FromId3($data->{'id'});

        if($nivel_array_ref){
            push (@array_objects, $nivel_array_ref);
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

    my @nivel_array_ref;
    my $cant;

    if($nivel eq '1'){
      ($cant, @nivel_array_ref) = getCatRegistroMarcN1SinEstructura($nivel, $ini, $cantR);
    }elsif($nivel eq '2'){
      ($cant, @nivel_array_ref) = getCatRegistroMarcN2SinEstructura($nivel, $ini, $cantR);
    }elsif($nivel eq '3'){
      ($cant, @nivel_array_ref) = getCatRegistroMarcN3SinEstructura($nivel, $ini, $cantR);
    }



    if(scalar(@nivel_array_ref) > 0){
        C4::AR::Debug::debug("Catalogacion => getImportacionSinEstructura => cant: ".scalar(@nivel_array_ref));
        return ($cant, @nivel_array_ref);
    }else{
        return 0;
    }
}


=head2
    sub getDatoFromReferencia

    Esta funcion recibe campo, subcampo y dato, donde dato puede ser el dato en si mismo, un string o la referencia a un dato.
    Si es la referencia a un dato, se obtiene el dato de la referencia, y dato era un "dato" (string) se retorna y no se hace nada.
    Siempre devuelve el dato.
=cut
sub getDatoFromReferencia{
    my ($campo, $subcampo, $dato, $itemtype) = @_;
    
    my $valor_referencia = '';
    #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => campo:                    ".$campo);
    #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => subcampo:                 ".$subcampo);
    #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => dato:                     ".$dato);
    
    if(($dato ne '')&&($campo ne '')&&($subcampo ne '')&&($dato ne '')&&($dato ne '0')){

        my ($estructura) = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo, $itemtype);
        
        if($estructura){

            if($estructura->getReferencia){
                #tiene referencia

                my $pref_tabla_referencia = C4::Modelo::PrefTablaReferencia->new();
                my $obj_generico = $pref_tabla_referencia->getObjeto($estructura->infoReferencia->getReferencia);
                                                                                #campo_tabla,                   id_tabla
                $valor_referencia = $obj_generico->obtenerValorCampo($estructura->infoReferencia->getCampos, $dato);
                #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => getReferencia:       ".$estructura->infoReferencia->getReferencia);
                #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => dato entrada:        ".$dato);
                #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => Tabla:               ".$obj_generico->getTableName);
                #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => Modulo:              ".$obj_generico->toString);
                #C4::AR::Debug::debug("Catalogacion => getDatoFromReferencia => Valor referencia:    ".$valor_referencia);


                return $valor_referencia;
            }
        }

    }#END if(($dato ne '')&&($campo ne '')&&($subcampo ne '')&&($dato != 0)&&($dato ne ''))

   return $dato;
}


=head2
    sub getRefFromStringConArrobas
    esta funcion devuelve el dato (referencia) a partir de un string
    @tabla@dato
=cut
sub getRefFromStringConArrobas{
    my ($dato) = @_;

    my @datos_array = split(/@/,$dato);
=item
    @datos_array[0]; #nada
    @datos_array[1]; #tabla
    @datos_array[2]; #dato
=cut

#     C4::AR::Debug::debug("Catalogacion => getRefFromStringConArrobas => dato: ".$dato);
#     C4::AR::Debug::debug("Catalogacion => getRefFromStringConArrobas => dato despues del split 2: ".@datos_array[2]);

    return @datos_array[1];
}

=head2
    sub getRefFromStringConArrobasByCampoSubcampo
    Esta funcion llama getRefFromStringConArrobas, solo q antes verifica si el dato es una referencia
    Si es una referencia, devuelve el dato (referencia) sin las @
    Si no es una referencia, se devuelve el dato pasado por parametro
=cut
sub getRefFromStringConArrobasByCampoSubcampo{
    my ($campo, $subcampo, $dato, $itemtype) = @_;

    my $estructura = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo, $itemtype);

    if($estructura){
        if($estructura->getReferencia){
        #tiene referencia
            return getRefFromStringConArrobas($dato);
        }
    }

    return $dato;
}
=head2
sub _procesar_referencia

Esta funcion recibe un campo, un subcampo y un dato y busca en la tabla de referencia correspondinte en valor que se corresponde con el dato, en el caso de no encontrarlo lo agrega en la tabla de referencia correspondiente y devuelve el id del nuevo elemento
=cut
sub _procesar_referencia{
    my ($campo, $subcampo, $dato, $itemtype) = @_;

#     C4::AR::Debug::debug("Catalogacion => _procesar_referencia");

    my $estructura = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo, $itemtype);
    if($estructura){
       if($estructura->getReferencia){
            #tiene referencia
            my $pref_tabla_referencia = C4::Modelo::PrefTablaReferencia->new();
            my $obj_generico = $pref_tabla_referencia->getObjeto($estructura->infoReferencia->getReferencia);

#                 my $string_result = '@'.$obj_generico->getTableName.'@'.$campo.'@'.$subcampo.'@'.$dato;
#                 my $string_result = '@'.$obj_generico->getTableName.'@'.$dato;
                my $string_result = $obj_generico->getTableName.'@'.$dato;

#                 C4::AR::Debug::debug("Catalogacion => _procesar_referencia => getReferencia:    ".$estructura->infoReferencia->getReferencia);
#                 C4::AR::Debug::debug("Catalogacion => _procesar_referencia => dato entrada:     ".$dato);
#                 C4::AR::Debug::debug("Catalogacion => _procesar_referencia => Tabla:            ".$obj_generico->getTableName);
#                 C4::AR::Debug::debug("Catalogacion => _procesar_referencia => Modulo:           ".$obj_generico->toString);
#                 C4::AR::Debug::debug("Catalogacion => _procesar_referencia => string_result:    ".$string_result);

                return($string_result);
                #FIXME, este valor es el que devuelve cuando NO lo encuentra en la tabla de referencia, en este caso deberia arreglarlo

#             return('10'); #FIXME, este valor es el que devuelve cuando lo encuentra en la tabla de referencia
        }else{  
            return $dato;
        }
    }
}


=head2  
sub _setDatos_de_estructura
    

Esta funcion setea 

    @Parametros
    $cat: es un objeto de cat_estructura_catalogacion que contiene toda la estructura que se va a setear a la HASH
=cut
sub _setDatos_de_estructura {
    my ($cat, $datos_hash_ref) = @_;

    my %hash_ref_result;

    
    $hash_ref_result{'dato'} =                   $datos_hash_ref->{'dato'};
    $hash_ref_result{'datoReferencia'}=          $datos_hash_ref->{'datoReferencia'};
    $hash_ref_result{'tiene_estructura'}=        $datos_hash_ref->{'tiene_estructura'};
    $hash_ref_result{'ayuda_subcampo'} =         $datos_hash_ref->{'ayuda_subcampo'};
    $hash_ref_result{'descripcion_subcampo'} =   $datos_hash_ref->{'descripcion_subcampo'};

    $hash_ref_result{'subcampo'} =               $cat->getSubcampo;
    $hash_ref_result{'campo'} =                  $cat->getCampo;
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

#     C4::AR::Debug::debug("_setDatos_de_estructura => campo, subcampo: ".$cat->getCampo.", ".$cat->getSubcampo);
#     C4::AR::Debug::debug("_setDatos_de_estructura => dato: ".$datos_hash_ref->{'dato'});
#     C4::AR::Debug::debug("_setDatos_de_estructura => datoReferencia: ".$datos_hash_ref->{'datoReferencia'});
    if( ($cat->getReferencia) && ($cat->getTipo eq 'combo') ){
        #tiene una referencia, y es un COMBO
#         C4::AR::Debug::debug("_setDatos_de_estructura => ======== COMBO ======== ");
        _obtenerOpciones ($cat, \%hash_ref_result);

    }elsif( ($cat->getReferencia) && ($cat->getTipo eq 'auto') ){
        #es un autocomplete
        $hash_ref_result{'referenciaTabla'} = $cat->infoReferencia->getReferencia;
        #si es un autocomplete y no tengo el dato de la referencia, muestro un blanco
        if ( ($hash_ref_result{'datoReferencia'} eq 0) || ($hash_ref_result{'dato'} eq 0) || not defined($hash_ref_result{'datoReferencia'}) ) {
          $hash_ref_result{'dato'} = '';#'NO TIENE';
        }

        if ($hash_ref_result{'datoReferencia'} eq -1){
            C4::AR::Debug::debug("_setDatos_de_estructura => datoReferencia = -1 => el autor no existe se agrega ".$hash_ref_result{'dato'});
        }

#         C4::AR::Debug::debug("_setDatos_de_estructura => ======== AUTOCOMPLETE ======== ");
#         C4::AR::Debug::debug("_setDatos_de_estructura => datoReferencia: ".$hash_ref_result{'datoReferencia'});
#         C4::AR::Debug::debug("_setDatos_de_estructura => referenciaTabla: ".$hash_ref_result{'referenciaTabla'});
    }else{
        #cualquier otra componete
#         C4::AR::Debug::debug("_setDatos_de_estructura => ======== ".$cat->getTipo." ======== ");
    }

    return (\%hash_ref_result);
}

#para los datos q no tienen estructura
sub _setDatos_de_estructura_base {
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

    C4::AR::Debug::debug("_setDatos_de_estructura_base => campo, subcampo: ".$cat->getCampo.", ".$cat->getSubcampo);
    C4::AR::Debug::debug("_setDatos_de_estructura_base => dato: ".$datos_hash_ref->{'dato'});

    return (\%hash_ref_result);
}

=head2
Esta funcion retorna la estructura de catalogacion con los datos de un Nivel (NO REPETIBLES).
Ademas mapea las campos fijos de nivel 1, 2 y 3 a MARC
=cut
sub getEstructuraYDatosDeNivel{
    my ($params) = @_;

    my @result;
    my $nivel;
    my $tipo_ejemplar;

    if( $params->{'nivel'} eq '1'){
        $nivel = C4::AR::Nivel1::getNivel1FromId1($params->{'id'});
        $tipo_ejemplar = 'ALL';
        C4::AR::Debug::debug("getEstructuraYDatosDeNivel=>  getNivel1FromId1");
    }
    elsif( $params->{'nivel'} eq '2'){
        $nivel = C4::AR::Nivel2::getNivel2FromId2($params->{'id'});
        $tipo_ejemplar = $nivel->getTipoDocumento;
        C4::AR::Debug::debug("getEstructuraYDatosDeNivel=>  getNivel2FromId2");
    }
    elsif( $params->{'nivel'} eq '3'){
        $nivel = C4::AR::Nivel3::getNivel3FromId3($params->{'id3'});
        $tipo_ejemplar = $nivel->nivel2->getTipoDocumento;
        C4::AR::Debug::debug("getEstructuraYDatosDeNivel=>  getNivel3FromId3");
    }

    #paso todo a MARC
    my $nivel_info_marc_array = undef;
    eval{
      $nivel_info_marc_array = $nivel->toMARC; #mapea los campos de la tabla nivel 1, 2, o 3 a MARC
    };

    my $campo;
    my $liblibrarian;
    my $indicador_primario;
    my $indicador_secundario;
    my $descripcion_campo;  
    my @result_total;

# TODO falta mostrar los campos de la estructura que estan vacios
# SOLO TRAE LOS CAMPOS QUE TIENEN ESTRUCTURA Y TIENEN DATOS

    #se genera la estructura de catalogacion para enviar al cliente
    if ($nivel_info_marc_array ){
   
        for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++){
                my @result;
                my $campo                       = $nivel_info_marc_array->[$i]->{'campo'};
                my $indicador_primario_dato     = C4::AR::Utilidades::HEXtoASCII($nivel_info_marc_array->[$i]->{'indicador_primario_dato'});
                my $indicador_secundario_dato   = C4::AR::Utilidades::HEXtoASCII($nivel_info_marc_array->[$i]->{'indicador_secundario_dato'});
    
                foreach my $subcampo (@{$nivel_info_marc_array->[$i]->{'subcampos_array'}}){

                    my %hash_temp;
                    #RECUPERO LA INFO DE LA ESTRUCTURA DE CATALOGACION CONFIGURADA
                    my $cat_estruct_array = _getEstructuraFromCampoSubCampo(    
                                                                                $nivel_info_marc_array->[$i]->{'campo'}, 
                                                                                $subcampo->{'subcampo'},
                                                                                $tipo_ejemplar,
                                                        );
            
                    if($cat_estruct_array){

                        my ($campos_base_array_ref) = C4::AR::EstructuraCatalogacionBase::getEstructuraBaseFromCampo($campo);

                        #se verifica que exista el campo en la BIBLIA
                        if($campos_base_array_ref){

                            $liblibrarian           = $cat_estruct_array->camposBase->getLiblibrarian;
                            $indicador_primario     = $cat_estruct_array->camposBase->getIndicadorPrimario;
                            $indicador_secundario   = $cat_estruct_array->camposBase->getIndicadorSecundario;
                            $descripcion_campo      = $cat_estruct_array->camposBase->getDescripcion.' - '.$cat_estruct_array->getCampo;  
    
                        } else {

                            $liblibrarian           = "NO EXISTE EL CAMPO (".$campo.")";
                            $indicador_primario     = "NO EXISTE EL CAMPO (".$campo.")";
                            $indicador_secundario   = "NO EXISTE EL CAMPO (".$campo.")";
                            $descripcion_campo      = "NO EXISTE EL CAMPO (".$campo.")";  

                        }
            
                        $hash_temp{'tiene_estructura'}  = '1';
                        $hash_temp{'dato'}              = $subcampo->{'dato'};
                        $hash_temp{'datoReferencia'}    = $subcampo->{'datoReferencia'};
        
                        C4::AR::Debug::debug("Catalogacion => getEstructuraYDatosDeNivel => campo => ".$nivel_info_marc_array->[$i]->{'campo'});
                        C4::AR::Debug::debug("Catalogacion => getEstructuraYDatosDeNivel => subcampo => ".$subcampo->{'subcampo'});
                        C4::AR::Debug::debug("Catalogacion => getEstructuraYDatosDeNivel => liblibrarian => ".$subcampo->{'liblibrarian'});
                        C4::AR::Debug::debug("Catalogacion => getEstructuraYDatosDeNivel => dato => ".$subcampo->{'dato'});
                        C4::AR::Debug::debug("Catalogacion => getEstructuraYDatosDeNivel => datoReferencia => ".$subcampo->{'datoReferencia'});
            
                        my $hash_result = _setDatos_de_estructura($cat_estruct_array, \%hash_temp);
                            
                        push(@result, $hash_result);
                    }else{
                        #EL CAMPO, SUBCAMPO NO TIENE UNA ESTRUCTURA CONFIGURADA
                        my $hash_result;

                        #RECUPERO LA INFO DE LA ESTRUCTURA BASE
                        my $cat_estruct_base_array = C4::AR::EstructuraCatalogacionBase::getEstructuraBaseFromCampoSubCampo(    
                                                                                                    $nivel_info_marc_array->[$i]->{'campo'}, 
                                                                                                    $subcampo->{'subcampo'}
                                                                                );

                        $liblibrarian           = $cat_estruct_base_array->camposBase->getLiblibrarian;
                        $indicador_primario     = $cat_estruct_base_array->camposBase->getIndicadorPrimario;
                        $indicador_secundario   = $cat_estruct_base_array->camposBase->getIndicadorSecundario;
                        $descripcion_campo      = $cat_estruct_base_array->camposBase->getDescripcion.' - '.$cat_estruct_base_array->getCampo;  




                        $hash_result->{'tiene_estructura'}  = '0';
                        $hash_result->{'campo'}             = $campo;
                        $hash_result->{'subcampo'}          = $subcampo->{'subcampo'};
                        $hash_result->{'dato'}              = $subcampo->{'dato'};  
                        my $hash_result                     = _setDatos_de_estructura_base($cat_estruct_base_array, $hash_result);

  
                        push(@result, $hash_result);
                    }
                }# END foreach my $s (@{$m->{'subcampos_array'}})
        
                my %hash_campos;
        
                $hash_campos{'campo'}                       = $campo;
                $hash_campos{'nombre'}                      = $liblibrarian;
                $hash_campos{'indicador_primario'}          = $indicador_primario;
                $hash_campos{'indicador_primario_dato'}     = $indicador_primario_dato;
                $hash_campos{'indicadores_primarios'}       = C4::AR::EstructuraCatalogacionBase::getIndicadorPrimarioFromEstructuraBaseByCampo($campo);
                $hash_campos{'indicador_secundario'}        = $indicador_secundario;
                $hash_campos{'indicador_secundario_dato'}   = $indicador_secundario_dato;
                $hash_campos{'indicadores_secundarios'}     = C4::AR::EstructuraCatalogacionBase::getIndicadorSecundarioFromEstructuraBaseByCampo($campo);
                $hash_campos{'descripcion_campo'}           = $descripcion_campo.' - '.$campo;
                $hash_campos{'ayuda_campo'}                 = 'esta es la ayuda del campo '.$campo;
                $hash_campos{'subcampos_array'}             = \@result;
    
                push (@result_total, \%hash_campos);
        
        }# END for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++)

    }# END if ($nivel_info_marc_array )

    return @result_total;
}


=head2
    sub agregarCamposVacios

    modifica el marc_record, le agrega los campos vacios configurados en la estructura de catalogacion
=cut
sub agregarCamposVacios {
    my ($marc_record, $estructura_array_ref) = @_;
    
    #recorro la estructura de catalogacion en busca de campos vacios que debe tener el marc_record
    for(my $j=0;$j<scalar(@$estructura_array_ref);$j++){ 

        my %hash_campos;
        my @subcampos_array;
        my $campo = $estructura_array_ref->[$j]->{'campo'};
        
        #recorro los subcampos del campo que se esta procesando
        foreach my $subcampo (@{$estructura_array_ref->[$j]->{'subcampos_array'}}){
            #C4::AR::Debug::debug("Catalogacion => agregarCamposVacios => campo, subcampo => ".$campo.", ".$subcampo->{'subcampo'});
            #setedo el dato para cada (campo, subcampo) en estructura_array_ref                            

            if ($marc_record->field($campo)) {
                #C4::AR::Debug::debug("EXISTE el campo ".$campo);
                my $field = $marc_record->field( $campo );
                if ( !$field->subfield( $subcampo->{'subcampo'} ) ) {
                    #C4::AR::Debug::debug("NO EXISTE el subcampo ".$subcampo->{'subcampo'}." => dato => ".$marc_record->field($campo)->subfield( $subcampo->{'subcampo'}));
                    $field->add_subfields( $subcampo->{'subcampo'} => " " );

                }else{
                    #C4::AR::Debug::debug("EXISTE el subcampo => ".$subcampo->{'subcampo'}." => dato => ".$marc_record->field($campo)->subfield( $subcampo->{'subcampo'}));
                }
            } else {
                #C4::AR::Debug::debug("NO EXISTE el campo ".$campo);
                #no existe el campo, se genera un nuevo campo y subcampo vacio
                my $campo_subcampo = MARC::Field->new(
                                    $campo, " ", " ", $subcampo->{'subcampo'} => " "
                        );
                
                $marc_record->append_fields( $campo_subcampo );    
            }
        }# END foreach my $subcampo (@{$estructura_array_ref->[$j]->{'subcampos_array'}})
    }# END for(my $j=0;$j<scalar(@$catalogaciones_array_ref);$j++)

    C4::AR::Debug::debug("agregarCamposVacios => as_usmarc => ".$marc_record->as_usmarc);
}

sub getEstructuraSinDatos {
    my ($params) = @_;
#     C4::AR::Debug::debug("getEstructuraSinDatos ============================================================================INI");

    my $nivel =     $params->{'nivel'};
    my $itemType =  $params->{'id_tipo_doc'};
    my $orden =     $params->{'orden'};
    
    #obtengo todos los campos <> de la estructura de catalogacion del Nivel 1, 2 o 3
    my ($cant, $campos_array_ref) = getCamposFromEstructura($nivel, $itemType);


#     C4::AR::Debug::debug("getEstructuraSinDatos => cant campos distintos: ".$cant);    

    my @result_total;
    my $campo = '';
    my $campo_ant = '';
    foreach my $c  (@$campos_array_ref){

        my %hash_campos;
        my @result;
        #obtengo todos los subcampos de la estructura de catalogacion segun el campo
        my ($cant, $subcampos_array_ref) = getSubCamposFromEstructuraByCampo($c->getCampo, $nivel, $itemType);

        foreach my $sc  (@$subcampos_array_ref){
            my %hash;
        
            $hash{'tiene_estructura'}  = '1';
            $hash{'dato'}              = '';
            $hash{'datoReferencia'}    = 0;
            
            my ($hash_temp) = _setDatos_de_estructura($sc, \%hash);
            C4::AR::Debug::debug("getEstructuraSinDatos => campo, subcampo: ".$c->getCampo.", ".$sc->getSubcampo);
            
            push (@result, $hash_temp);
        }

        my %hash_campos;

        $hash_campos{'campo'}                   = $c->getCampo;
        $hash_campos{'nombre'}                  = $c->camposBase->getLiblibrarian;
        $hash_campos{'indicador_primario'}      = $c->camposBase->getIndicadorPrimario;
        $hash_campos{'indicadores_primarios'}   = C4::AR::EstructuraCatalogacionBase::getIndicadorPrimarioFromEstructuraBaseByCampo($c->getCampo);
        $hash_campos{'indicador_secundario'}    = $c->camposBase->getIndicadorSecundario;
        $hash_campos{'indicadores_secundarios'} = C4::AR::EstructuraCatalogacionBase::getIndicadorSecundarioFromEstructuraBaseByCampo(
                                                                                                                                      $c->getCampo
                                                                                                                                    );
        $hash_campos{'descripcion_campo'}       = $c->camposBase->getDescripcion.' - '.$c->getCampo;
        $hash_campos{'ayuda_campo'}             = 'esta es la ayuda del campo '.$c->getCampo;
        $hash_campos{'subcampos_array'}         = \@result;

        push (@result_total, \%hash_campos);

    }

#     C4::AR::Debug::debug("getEstructuraSinDatos ============================================================================FIN");

    # devuelve scalar(@result_total) que es la cantidad de campos distintos con sus respectivos subcampos
    return (scalar(@result_total), \@result_total);
}

=head2
    sub getIndicadorPrimarioByCampo
    Trae todos los inficadores primarios segun el campo pasado por parametro
=cut
sub getIndicadorPrimarioByCampo {
    my ($campo) = @_;

    use C4::Modelo::PrefIndicadorPrimario::Manager;

    my $indicadores_array_ref = C4::Modelo::PrefIndicadorPrimario::Manager->get_pref_indicador_primario(   
                                                                query => [ 
                                                                                campo_marc => { eq => $campo },

                                                                        ],

                                                                sort_by => ( 'dato' ),
                                                             );

    return ($indicadores_array_ref);
}

=head2
    sub getIndicadorSecundarioByCampo
    Trae todos los inficadores primarios segun el campo pasado por parametro
=cut
sub getIndicadorSecundarioByCampo{
    my ($campo) = @_;

    use C4::Modelo::PrefIndicadorSecundario::Manager;

    my $indicadores_array_ref = C4::Modelo::PrefIndicadorSecundario::Manager->get_pref_indicador_secundario(   
                                                                query => [ 
                                                                                campo_marc => { eq => $campo },

                                                                        ],

                                                                sort_by => ( 'dato' ),
                                                             );

    return ($indicadores_array_ref);
}

sub getOpcionesFromIdicadorPrimarioByCampo{
    my ($campo, $subcampo) = @_;

    my ($indicadores_array_ref) = getIndicadorPrimarioByCampo($campo);
    my @array_valores;

    for(my $i=0; $i<scalar(@$indicadores_array_ref); $i++ ){
        my $valor;
        $valor->{"clave"}= $indicadores_array_ref->[$i]->getId;
        $valor->{"valor"}= $indicadores_array_ref->[$i]->getDato;

        push (@array_valores, $valor);
    }

    return (\@array_valores);
}

sub getOpcionesFromIdicadorSecundarioByCampo{
    my ($campo, $subcampo) = @_;

    my ($indicadores_array_ref) = getIndicadorSecundarioByCampo($campo);
    my @array_valores;

    for(my $i=0; $i<scalar(@$indicadores_array_ref); $i++ ){
        my $valor;
        $valor->{"clave"}= $indicadores_array_ref->[$i]->getId;
        $valor->{"valor"}= $indicadores_array_ref->[$i]->getDato;

        push (@array_valores, $valor);
    }

    return (\@array_valores);
}


sub _obtenerOpciones{
    my ($cat_estruct_object, $hash_ref) = @_;

#     C4::AR::Debug::debug("_obtenerOpciones => es un combo, se setean las opciones para => ".$cat_estruct_object->infoReferencia->getReferencia);
#     C4::AR::Debug::debug("_obtenerOpciones => getCampos => ".$cat_estruct_object->infoReferencia->getCampos);
    my $orden = $cat_estruct_object->infoReferencia->getCampos;
    my ($cantidad, $valores) = &C4::AR::Referencias::obtenerValoresTablaRef(   
                                                                $cat_estruct_object->infoReferencia->getReferencia,  #tabla  
                                                                $cat_estruct_object->infoReferencia->getCampos,  #campo
                                                                $orden
                                                );
    $hash_ref->{'opciones'} = $valores;

#     C4::AR::Debug::debug("_obtenerOpciones => opciones => ".$valores);
}


=head2 t_guardarEnEstructuraCatalogacion
Esta transaccion guarda una estructura de catalogacion configurada por el bibliotecario 
=cut
sub t_guardarEnEstructuraCatalogacion {
    my ($params) = @_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object          = C4::AR::Mensajes::create();

    _verificar_campo_subcampo_to_estructura($msg_object, $params->{'campo'}, $params->{'subcampo'}, $params->{'nivel'}, $params->{'itemtype'}); 

    if(!$msg_object->{'error'}){
    #No hay error
        my  $estrCatalogacion = C4::Modelo::CatEstructuraCatalogacion->new();
        my $db = $estrCatalogacion->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
    
        eval {
            $estrCatalogacion->agregar($params);  
            $db->commit;
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U364', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B426',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'} = 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U365', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}


=head2 sub _verificar_campo_subcampo_to_estructura
=cut
sub _verificar_campo_subcampo_to_estructura{
    my ($msg_object, $campo, $subcampo, $nivel, $itemtype) = @_;

    my $campos_autorizados  = C4::AR::EstructuraCatalogacionBase::getSubCamposByNivel($nivel);
    my %autorizados;
    my $campo_subcampo_array; #campo y subcampo que se va agregar
    $msg_object->{'error'}  = 0;

    #armo el arreglo de campo => [subcampos] autorizados
    foreach my $autorizado (@$campos_autorizados){
       push(@{$autorizados{$autorizado->getCampo()}},$autorizado->getSubcampo());
    }

    #recupero el campo y subcampo de la BIBLIA para verificar la existencia
    my ($cat_estructura_base) = C4::AR::EstructuraCatalogacionBase::getEstructuraBaseFromCampoSubCampo($campo, $subcampo);

    if(!$cat_estructura_base){
        #NO EXISTE el campo, subcampo
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U412', 'params' => [" el campo ".$campo.", ".$subcampo." NO EXISTE"]} ) ;
        C4::AR::Debug::debug("_verificar_campo_subcampo_to_estructura => NO EXISTE el campo, subcampo".$campo.", ".$subcampo);
    }elsif (!C4::AR::Utilidades::existeInArray($subcampo, @{$autorizados{$campo}})) {
        #el campo, subcampo NO ESTA AUTORIZADO
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U412', 'params' => [" NO ESTA AUTORIZADO ".$campo.", ".$subcampo]} ) ;
        C4::AR::Debug::debug("_verificar_campo_subcampo_to_estructura => NO ESTA AUTORIZADO el campo, subcampo".$campo.", ".$subcampo);
    }elsif (_getEstructuraFromCampoSubCampo($campo, $subcampo, $itemtype)) {
        #el subcampo NO ES REPETIBLE y ya EXISTE en la ESTRUCTURA
        $msg_object->{'error'} = 0;#NO ES ERROR SE INFORMA AL USUARIO Y SE CAMBIA LA VISIBILIDAD CONFIGURADA (campo, subcampo, itemtype)
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U412', 'params' => [" el campo ".$campo.", ".$subcampo.",".$itemtype." no es repetible"]} ) ;
        C4::AR::Debug::debug("_verificar_campo_subcampo_to_estructura => NO SE PUEDE REPETIR el campo, subcampo".$campo.", ".$subcampo.",".$itemtype);
    }

}
###############################################################A PARTIR DE ESTE PUNTO ES LO VIEJO########################################



=item sub subirOrden
Esta funcion sube el orden como se va a mostrar del campo, subcampo catalogado
=cut
# FIXME esto no se va a usar mas, lo dejo para reusar en la visualizacion de la INTRA
# sub subirOrden{
#     my ($id,$itemtype) = @_;
# 
#     my $catAModificar = getEstructuraCatalogacionById($id);
# 
#     if($catAModificar){
#         $catAModificar->subirOrden($itemtype);
#     }else{
#         C4::AR::Debug::debug("Catalogacion => subirOrden => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
#     }
# }

=item sub bajarOrden
Esta funcion baja el orden como se va a mostrar del campo, subcampo catalogado
=cut
# FIXME esto no se va a usar mas, lo dejo para reusar en la visualizacion de la INTRA
# sub bajarOrden{
#     my ($id,$itemtype) = @_;
# 
#     my $catAModificar = getEstructuraCatalogacionById($id);
# 
#     if($catAModificar){
#         $catAModificar->bajarOrden($itemtype);
#      }else{
#         C4::AR::Debug::debug("Catalogacion => subirOrden => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
#     }
# }

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
    my ($params) = @_;
    
    my $id      = $params->{'id'};
    my $nivel   = $params->{'nivel'};

    #verifica que el campo q se esta intentando eliminar no se este utilizando en el nivel correspondiente
    my $catalogacion = getEstructuraCatalogacionById($id);
# TODO falta modularizar
    if($catalogacion){
        #obtengo el nivel al que pertence el campo que se intenta eliminar de la estructura de catalogacion
#         $nivel = C4::AR::EstructuraCatalogacionBase::getNivelFromEstructuraBaseByCampo($nivel);
        $params->{'campo'} = $catalogacion->getCampo;

        if(campoEnUsoFromNivel($params)){
            C4::AR::Debug::debug("EL CAMPO se esta  USANDOOOOOOOOOOOOOOOO ");
        } else {
            $catalogacion->delete();
        }

    }else{
        C4::AR::Debug::debug("Catalogacion => eliminarCampo => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
    }

#     if($catalogacion){
#         $catalogacion->delete();
#      }else{
#         C4::AR::Debug::debug("Catalogacion => eliminarCampo => NO EXISTE EL ID DE LA ESTRUCTURA QUE SE INTENTA MODIFICAR");
#     }
}

sub campoEnUsoFromNivel {
    my ($params)    = @_;

    my $existe      = 0;

    if( $params->{'nivel'} eq '1'){
        my $nivel_array_ref = C4::AR::Nivel1::getNivel1Completo();

        foreach my $nivel (@$nivel_array_ref){
           my  $nivel_info_marc_array = $nivel->toMARC;

            for(my $i=0;$i<scalar(@$nivel_info_marc_array);$i++){
                if($nivel_info_marc_array->[$i]->{'campo'}){
                    C4::AR::Debug::debug("EL CAMPO se esta  USANDOOOOOOOOOOOOOOOO ");
                    $existe = 1;
                }

                last if ($existe);
            }

            last if ($existe);
        }

        C4::AR::Debug::debug("Catalogacion => campoEnUsoFromNivel=> verifico existencia de campo en nivel 1");
    }
    elsif( $params->{'nivel'} eq '2'){
        C4::AR::Debug::debug("Catalogacion => campoEnUsoFromNivel=> verifico existencia de campo en nivel 2");
    }
    elsif( $params->{'nivel'} eq '3'){
        $existe = C4::AR::Nivel3::seUsaCampo($params->{'campo'});
        C4::AR::Debug::debug("Catalogacion => campoEnUsoFromNivel=> verifico existencia de campo en nivel 3");
    }

    return $existe;

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


=head2
sub getSubCamposFromEstructuraByCampo

=cut

sub getSubCamposFromEstructuraByCampo{
    my ($campo, $nivel, $itemType) = @_;

    use C4::Modelo::CatEstructuraCatalogacion::Manager;

    my $catalogaciones_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
                                                                query => [ 
                                                                                nivel => { eq => $nivel },
                                                                                campo => { eq => $campo },    

                                                                    or   => [   
                                                                                itemtype => { eq => $itemType },
                                                                                itemtype => { eq => 'ALL' },    
                                                                            ],

                                                                                intranet_habilitado => { gt => 0 }, 
                                                                        ],

                                                                with_objects    => [ 'infoReferencia' ],  #LEFT OUTER JOIN
                                                                require_objects => [ 'camposBase', 'subCamposBase' ], #INNER JOIN
                                                                sort_by => ( 'subcampo' ),
                                                             );

    return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
}


=item sub getCamposFromEstructura

Esta funcion trae todos los campos segun nivel e itemtype
ademas trae los indicadores Primero y Segundo (SI ES QUE EXISTE)

=cut
sub getCamposFromEstructura{
    my ($nivel, $itemType) = @_;

    use C4::Modelo::CatEstructuraCatalogacion::Manager;

    my $catalogaciones_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
                                                                distinct => 1,
                                                                select   => [ 'campo' ],

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



=item sub cantNivel2
     devuelve la cantidad de Niveles 2 que tiene  relacionados el Nivel 1 con id1 pasado por parameto
=cut
sub cantNivel2 {
    my ($id1) = @_;

    my $count = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2_count( query => [ id => { eq => $id1 } ]);

    return $count;
}

=head2
=cut
sub getDatosFromNivel{
    my ($params) = @_;

    C4::AR::Debug::debug("getDatosFromNivel => ======================================================================");
    my $nivel       = $params->{'nivel'};
    my $itemType    = $params->{'id_tipo_doc'};

    C4::AR::Debug::debug("getDatosFromNivel => tipo de documento: ".$itemType);

    #obtengo los datos de nivel 1, 2 y 3 mapeados a MARC, con su informacion de estructura de catalogacion
    my @resultEstYDatos = getEstructuraYDatosDeNivel($params);

    my @sorted = sort { $a->{campo} cmp $b->{campo} } @resultEstYDatos; # alphabetical sort 

    return (scalar(@resultEstYDatos), \@sorted);
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


=head2 sub _getEstructuraFromCampoSubCampo
    Este funcion devuelve la configuracion de la estructura de catalogacion de un campo, subcampo, realizada por el usuario
=cut
sub _getEstructuraFromCampoSubCampo{
    my ($campo, $subcampo, $itemtype, $db) = @_;

    $db = $db || C4::Modelo::PermCatalogo->new()->db;   
    my @filtros;

    push(@filtros, ( campo      => { eq => $campo } ) );
    push(@filtros, ( subcampo   => { eq => $subcampo } ) );
#     push(@filtros, ( itemtype   => { eq => $itemtype } ) );
    push (  @filtros, ( or   => [   itemtype   => { eq => $itemtype }, 
                                    itemtype   => { eq => 'ALL'     } ])
                     );
# TODO falta el or itemtype eq 'ALL' ?????????

	my $cat_estruct_info_array = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(  
                                                                                db              => $db,
																				query           =>  \@filtros, 
#                                                                 FIXME es necesario????????????
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


sub getLiblibrarian{
    my ($campo, $subcampo, $itemtype) = @_;

    use C4::Modelo::PrefEstructuraSubcampoMarc;
    use C4::Modelo::PrefEstructuraSubcampoMarc::Manager;
    #primero busca en estructura_catalogacion
    my $estructura_array = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo, $itemtype);


    if($estructura_array){
        return $estructura_array->getLiblibrarian;
    }else{
        my ($pref_estructura_sub_campo_marc_array) = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc( 
                                                                                    query => [  campo       => { eq => $campo },
                                                                                                subcampo    => { eq => $subcampo }
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


#====================================================DEPRECATEDDDDDDDDDDD==================================================

=item t_agruparCampos
Esta transaccion agrupa las configuraciones de campo, subcampo pasados por parametro 
=cut
# sub t_agruparCampos {
#     my($params)=@_;
# 
# ## FIXME ver si falta verificar algo!!!!!!!!!!
#     my $msg_object= C4::AR::Mensajes::create();
# 
#     if(!$msg_object->{'error'}){
#     #No hay error
#         my  $estrCatalogacion = C4::Modelo::CatEstructuraCatalogacion->new();
#         my $db = $estrCatalogacion->db;
#         # enable transactions, if possible
#         $db->{connect_options}->{AutoCommit} = 0;
#         my $grupo = $estrCatalogacion->getNextGroup;
#     
#         eval {
# #             $estrCatalogacion->agrupar($params, $db);  
#             my $array_grupos = $params->{'array_grupos'};
#         
#             foreach my $id (@$array_grupos){
#                 my ($cat_estructura_catalogacion) = C4::AR::Catalogacion::getEstructuraCatalogacionById($id, $db);
#                 if($cat_estructura_catalogacion){
#                     $cat_estructura_catalogacion->setGrupo($grupo);
#                     $cat_estructura_catalogacion->save();
#                 }
#             }
# 
#             $db->commit;
#             #se cambio el permiso con exito
#             $msg_object->{'error'}= 0;
#             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U410', 'params' => []} ) ;
#         };
#     
#         if ($@){
#             #Se loguea error de Base de Datos
#             &C4::AR::Mensajes::printErrorDB($@, 'B448',"INTRA");
#             $db->rollback;
#             #Se setea error para el usuario
#             $msg_object->{'error'}= 1;
#             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U411', 'params' => []} ) ;
#         }
# 
#         $db->{connect_options}->{AutoCommit} = 1;
# 
#     }
# 
#     return ($msg_object);
# }



#para los datos q no tienen estructura
# sub _setDatos_de_estructura2 {
#     my ($cat, $datos_hash_ref) = @_;
# 
#     my %hash_ref_result;
# 
#     $hash_ref_result{'campo'} =                  $cat->getCampo;
#     $hash_ref_result{'subcampo'} =               $cat->getSubcampo;
#     $hash_ref_result{'Id_rep'} =                 $datos_hash_ref->{'Id_rep'};
#     $hash_ref_result{'tiene_estructura'}=        $datos_hash_ref->{'tiene_estructura'};
#     $hash_ref_result{'dato'}=                    $datos_hash_ref->{'dato'};
#     $hash_ref_result{'nivel'} =                  '';#$cat->getNivel;
#     $hash_ref_result{'visible'} =                '';#$cat->getVisible;
#     $hash_ref_result{'liblibrarian'} =           $cat->getLiblibrarian;
#     $hash_ref_result{'itemtype'} =               '';#$cat->getItemType;
#     $hash_ref_result{'repetible'} =              '';#$cat->subCamposBase->getRepetible;
#     $hash_ref_result{'tipo'} =                   '';#$cat->getTipo;
#     $hash_ref_result{'referencia'} =             '';#$cat->getReferencia;
#     $hash_ref_result{'obligatorio'} =            $cat->getObligatorio;
#     $hash_ref_result{'idCompCliente'} =          '';#$cat->getIdCompCliente;
#     $hash_ref_result{'intranet_habilitado'} =    '';#$cat->getIntranet_habilitado;
#     $hash_ref_result{'rules'} =                  '';#$cat->getRules;    
# 
#     C4::AR::Debug::debug("_setDatos_de_estructura2 => campo, subcampo: ".$cat->getCampo.", ".$cat->getSubcampo);
#     C4::AR::Debug::debug("_setDatos_de_estructura2 => dato: ".$datos_hash_ref->{'dato'});
# 
#     return (\%hash_ref_result);
# }


=item sub getEstructuraCatalogacionFromDBRepetibles
    Retorna la estructura de catalogacion del Nivel 1, 2 o 3 que se encuentra configurada en la BD pero SOLO de los campos REPETIBLES
# =cut
# sub getEstructuraCatalogacionFromDBRepetibles{
#     my ($nivel,$itemType)=@_;
# 
#     use C4::Modelo::CatEstructuraCatalogacion::Manager;
# 
#     my $catalogaciones_array_ref = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion(   
#                                                                 query   => [ 
#                                                                                 nivel => { eq => $nivel },
# 
#                                                                     or  => [   
#                                                                                 itemtype => { eq => $itemType },
#                                                                                 itemtype => { eq => 'ALL' },    
#                                                                             ],
# 
#                                                                                 intranet_habilitado => { gt => 0 }, 
#                                                                                 repetible => { eq => 1 },
#                                                                         ],
# 
#                                                                 with_objects    => [ 'infoReferencia' ],  #LEFT OUTER JOIN
#                                                                 require_objects => [ 'subCamposBase' ], #INNER JOIN
#                                                                 sort_by         => ( 'intranet_habilitado' ),
#                                                              );
# 
#     return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
# }

=item sub t_eliminarNivelRepetible
Esta funcion elimina un "campo", de uno de los niveles repetibles segun el nivel indicado por parametro y segun el id del nivel repetible
=cut
# sub t_eliminarNivelRepetible{
#     my ($params) = @_;
#     
#     if($params->{'nivel'} eq '1'){
#         C4::AR::Nivel1::t_eliminarNivel1Repetible($params);
#     }elsif($params->{'nivel'} eq '2'){
#         C4::AR::Nivel2::t_eliminarNivel2Repetible($params);
#     }elsif($params->{'nivel'} eq '3'){
#         C4::AR::Nivel3::t_eliminarNivel3Repetible($params);
#     }else{
# #         ERROR
#     }
# }

=item
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

            $hash_campos{'campo'}               = $c->getCampo;
            $hash_campos{'nombre'}              = $c->camposBase->getNombre;
            $hash_campos{'descripcion_campo'}   = $c->camposBase->getDescripcion.' - '.$c->getCampo;
            $hash_campos{'ayuda_campo'}         = 'esta es la ayuda del campo '.$c->getCampo;
            $hash_campos{'subcampos_array'}     = \@result;

            push (@result_total, \%hash_campos);
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

#     return (scalar(@$catalogaciones_array_ref), \@result);
    return (scalar(@$catalogaciones_array_ref), \@result_total);
}
=cut

=item sub getCatalogacionesConDatos
 Esta funcion retorna la estructura_catalogacion y los datos para los campos REPETIBLES
 TENER EN CUENTA QUE SI NO HAY UNA ESTRUCTURA DE CATALOGACION QUE SOPORTE (QUE GUARDE) LOS DATOS, ESTOS NO SE VERAN
=cut
# TODO actualizar segun tablas nuevas
# sub getCatalogacionesConDatos{
#     my ($params)=@_;
# 
#   my $nivel= $params->{'nivel'};
# 
#   use C4::Modelo::CatNivel1;
#     use C4::Modelo::CatNivel1::Manager;
# 
#     use C4::Modelo::CatNivel1Repetible;
#     use C4::Modelo::CatNivel1Repetible::Manager;
#       
#     use C4::Modelo::CatNivel2Repetible;
#     use C4::Modelo::CatNivel2Repetible::Manager;
# 
#     use C4::Modelo::CatNivel3Repetible;
#     use C4::Modelo::CatNivel3Repetible::Manager;
#     my $catalogaciones_array_ref;
#   my $nivel1_array_ref;
# 
#    if ($nivel == 1){
#     C4::AR::Debug::debug("getCatalogacionesConDatos => NIVEL 1");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
#                                                 query => [ 
#                                                           'cat_nivel1.id1' => { eq => $params->{'id'} },
#                                                     ], 
# 
#                                              with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN
#                                              require_objects => [ 'CEC' ] #INNER JOIN
# 
#                           );
#   
#    }
#    elsif ($nivel == 2){
#     C4::AR::Debug::debug("getCatalogacionesConDatos => NIVEL 2");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
#                                                                               query => [ 
#                                                                                           id2 => { eq => $params->{'id'} },
#                                                                                     ],
#                                                                 require_objects => [ 'cat_nivel2', 'CEC' ]
# 
#                                                                      );
#    }
#    else{
#     C4::AR::Debug::debug("getCatalogacionesConDatos => NIVEL 3");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
#                                                                               query => [ 
#                                                                                            id3 => { eq => $params->{'id3'} },
#                                                                                     ],
#                                                                               require_objects => [ 'cat_nivel3', 'CEC' ]
#                                                                      );
#    }
# 
#     return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
# }


=item sub getDatosRepetibleFromNivel 
    esta funcion trae toda la info del nivel pasado por parametro segun el id
=cut

# TODO actualizar segun tablas nuevas
# sub getDatosRepetibleFromNivel{
#     my ($params) = @_;
# 
#     my $nivel = $params->{'nivel'};
# 
#     use C4::Modelo::CatNivel1;
#     use C4::Modelo::CatNivel1::Manager;
# 
#     use C4::Modelo::CatNivel1Repetible;
#     use C4::Modelo::CatNivel1Repetible::Manager;
#       
#     use C4::Modelo::CatNivel2Repetible;
#     use C4::Modelo::CatNivel2Repetible::Manager;
# 
#     use C4::Modelo::CatNivel3Repetible;
#     use C4::Modelo::CatNivel3Repetible::Manager;
#     my $catalogaciones_array_ref;
#     my $nivel1_array_ref;
# 
#    if ($nivel == 1){
#     C4::AR::Debug::debug("getDatosRepetibleFromNivel => NIVEL 1");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
#                                                     query => [ 
#                                                                 'cat_nivel1.id1' => { eq => $params->{'id'} },
#                                                         ], 
#                                                     with_objects => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN
# 
#                             );
#     
#    }
#    elsif ($nivel == 2){
#     C4::AR::Debug::debug("getDatosRepetibleFromNivel => NIVEL 2");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
#                                                     query => [ 
#                                                                 id2 => { eq => $params->{'id'} },
#                                                             ],
#                                                     with_objects => [ 'cat_nivel2' ], #LEFT JOIN
#                                 );
#    }
#    else{
#     C4::AR::Debug::debug("getDatosRepetibleFromNivel => NIVEL 3");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
#                                                     query => [ 
#                                                                 id3 => { eq => $params->{'id3'} },
#                                                         ],
#                                                      with_objects => [ 'cat_nivel3' ], #LEFT JOIN
#                                 );
#    }
# 
# 
#     return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref);
# }


=item sub getRepetible
    Esta funcion recupera (SI EXISTE) el objeto de un nivel repetible
    @Parametros:
    
    $params->{'nivel'} = nivel por el que se va a filtrar
    $params->{'id'} = ID correspondiente al nivel 1, 2 o 3
    $params->{'campo'} = campo MARC
    $params->{'subcampo'} = subcampo MARC
=cut

# TODO no se si es necesario
# sub getRepetible{
#     my ($params) = @_;
# 
#     my $nivel= $params->{'nivel'};
# 
#     use C4::Modelo::CatNivel1;
#     use C4::Modelo::CatNivel1::Manager;
# 
#     use C4::Modelo::CatNivel1Repetible;
#     use C4::Modelo::CatNivel1Repetible::Manager;
#       
#     use C4::Modelo::CatNivel2Repetible;
#     use C4::Modelo::CatNivel2Repetible::Manager;
# 
#     use C4::Modelo::CatNivel3Repetible;
#     use C4::Modelo::CatNivel3Repetible::Manager;
#     my $catalogaciones_array_ref;
#     my $nivel1_array_ref;
# 
#    if ($nivel == 1){
#     C4::AR::Debug::debug("getRepetible => NIVEL 1");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(   
#                                                 query => [ 
#                                                             'cat_nivel1.id1'    => { eq => $params->{'id'} },
#                                                             'campo'             => { eq => $params->{'campo'} },
#                                                             'subcampo'          => { eq => $params->{'subcampo'} },        
#                                                     ], 
#                                                 with_objects        => [ 'cat_nivel1','cat_nivel1.cat_autor'], #LEFT JOIN
#                                                 require_objects     => [ 'CEC' ] #INNER JOIN
# 
#                             );
#     
#    }
#    elsif ($nivel == 2){
#     C4::AR::Debug::debug("getRepetible => NIVEL 2");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel2Repetible::Manager->get_cat_nivel2_repetible(   
#                                                     query => [ 
#                                                                 id2         => { eq => $params->{'id'} },
#                                                                 'campo'     => { eq => $params->{'campo'} },
#                                                                 'subcampo'  => { eq => $params->{'subcampo'} },   
#                                                             ],
#                                                     require_objects     => [ 'CEC' ],#INNER JOIN
#                                                     with_objects        => [ 'cat_nivel2' ], #LEFT JOIN
#                                 );
#    }
#    else{
#     C4::AR::Debug::debug("getRepetible => NIVEL 3");
#          $catalogaciones_array_ref = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible(   
#                                                     query => [ 
#                                                                 id3         => { eq => $params->{'id3'} },
#                                                                 'campo'     => { eq => $params->{'campo'} },
#                                                                 'subcampo'  => { eq => $params->{'subcampo'} },   
#                                                         ],
#                                                         require_objects     => [ 'CEC' ], #INNER JOIN  
#                                                         with_objects        => [ 'cat_nivel3' ], #LEFT JOIN
#                                 );
#    }
# 
# 
#     return (scalar(@$catalogaciones_array_ref), $catalogaciones_array_ref->[0]);
# }
