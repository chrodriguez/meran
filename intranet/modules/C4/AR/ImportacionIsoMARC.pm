package C4::AR::ImportacionIsoMARC;

#
#para la importacion de codigos iso a marc y donde estan las descripciones de cada campo y sus
#subcampos
#

use strict;
require Exporter;

use C4::Context;
use Date::Manip;
use C4::AR::Utilidades;
use C4::Modelo::IoImportacionIso;
use C4::Modelo::IoImportacionIsoRegistro;


use MARC::Record;
use MARC::Field;
use MARC::Moose::Record;
use MARC::Moose::Reader::File::Isis;
use MARC::Moose::Reader::File::Iso2709;
use MARC::Moose::Reader::File::Marcxml;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
           guardarNuevaImportacion
           getImportaciones
           eliminarImportacion
           getImportacionById
           getImportacionLike
           getEsquema
           getRow
           editarValorEsquema
           addCampo
);

=item sub guardarNuevaImportacion
Guarda una nueva imporatción
=cut
sub guardarNuevaImportacion {
    my ($params,$msg_object) = @_;

    my $db =  C4::Modelo::IoImportacionIso->new()->db;
       $db->{connect_options}->{AutoCommit} = 0;
       $db->begin_work;

   eval {

    my $Io_importacion          = C4::Modelo::IoImportacionIso->new(db=> $db);
    my $nuevo_esquema =0;
    #Si el esquema es nuevo hay que crearlo vacio al menos!
    if($params->{'nuevo_esquema'}){
       #Crear Nuevo Esquema
           my %parametros;
           $parametros{'nombre'}      = $params->{'nombreEsquema'};
           $parametros{'descripcion'}   = 'Esquema generado';
           $nuevo_esquema = C4::Modelo::IoImportacionIsoEsquema->new(db=> $db);
           $nuevo_esquema->agregar(\%parametros);

       #Necesitamos el id del nuevo esquema ACA!
           $params->{'esquemaImportacion'}     = $nuevo_esquema->getId;
        }

    $Io_importacion->agregar($params);

    #Obtengo los campos/subcampos para ver si por si es necesario realizar un corrimiento de campos
     my $campos_archivo = C4::AR::ImportacionIsoMARC::obtenerCamposDeArchivo($params);
     $params->{'camposArchivo'}     = $campos_archivo;
     my %camposMovidos;
     $params->{'camposMovidos'}     = \%camposMovidos;

    #Ahora los registros del archivo $params->{'write_file'}
    C4::AR::ImportacionIsoMARC::guardarRegistrosNuevaImportacion($Io_importacion,$params,$msg_object,$db);

    #Si el esquema es nuevo hay que llenarlo con los datos de los registros cargados
    if($nuevo_esquema){
       #Armar nuevo esquema (hash de hashes)
        my $detalle_esquema = $Io_importacion->obtenerCamposSubcamposDeRegistros();

        my $total = 0;
        my $actual = 0;
        foreach my $campo ( keys %$detalle_esquema) {
            foreach my $subcampo ( keys %{$detalle_esquema->{$campo}}) {
                $actual++;
                my $nuevo_esquema_detalle          = C4::Modelo::IoImportacionIsoEsquemaDetalle->new(db=>$db);
                my %detalle=();
                $detalle{'campo'}=$campo;
                $detalle{'subcampo'}=$subcampo;
                $detalle{'id_importacion_esquema'}=$nuevo_esquema->getId;
                $nuevo_esquema_detalle->agregar(\%detalle);

                C4::AR::Utilidades::printAjaxPercent($total,$actual);
            }
        }
    }

    $db->commit;
    };
        if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B456',"INTRA");
        eval {$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO08', 'params' => []} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
}


=item sub guardarRegistrosNuevaImportacion
Guarda los registros de una nueva imporatción
=cut
sub guardarRegistrosNuevaImportacion {
    my ($importacion,$params,$msg_object,$db) = @_;

    use Switch;

    my $reader;
    switch ($params->{'formatoImportacion'}) {
        case "iso"   {$reader=MARC::Moose::Reader::File::Iso2709->new(file   => $params->{'write_file'})}
        case "isis"  {$reader=MARC::Moose::Reader::File::Isis->new(file   => $params->{'write_file'})}
        case "xml"   {$reader=MARC::Moose::Reader::File::Marcxml->new(file   => $params->{'write_file'})}
    }

#Leemos los registros armamos el Marc::Record
    while ( my $record = $reader->read() ) {
    eval {
         my $marc_record = MARC::Record->new();

         for my $field ( @{$record->fields} ) {
             my $new_field=0;

             if(($field->tag < '010')&&(!$field->{'subf'})){
                 #CONTROL FIELD
                 $new_field = MARC::Field->new( $field->tag, $field->{'value'} );
                 }
                 else {
                    for my $subfield ( @{$field->subf} ) {
                        if(!$new_field){
                            my $ind1=$field->ind1?$field->ind1:'#';
                            my $ind2=$field->ind2?$field->ind2:'#';

                            my $campo = $field->tag;
                            #Si es un campo de CONTROL pero tiene SUBCAMPOS hay que moverlo a un 900 para que no se pierdan los datos.
                             if(($field->tag < '010')&&($field->{'subf'})){
                                 #Empiezo viendo a partir de los campos 900 (son solo 10 los de control!!!)
                                my $movidos =$params->{'camposMovidos'};
                                my $campos =$params->{'camposArchivo'};

                                if($movidos->{$campo}){
                                    #ya fue movido?
                                    $campo=$movidos->{$campo};
                                 }
                                 else{
                                     #hay que moverlo
                                     $campo+=900;
                                     while (($campos->{$campo}) && ($campo <= 999)){
                                         #C4::AR::Debug::debug("Campo ".$campo." ==> ".$campos->{$campo});
                                         $campo++;
                                        }
                                        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO017', 'params' => [$field->tag,$campo]});
                                      #lo marco como movido y utilizado
                                     $movidos->{$field->tag}=$campo;
                                     $campos->{$campo}=1;
                                }
                             }

                            $new_field= MARC::Field->new($campo, $ind1, $ind2,$subfield->[0] => $subfield->[1]);
                            }
                        else{
                            $new_field->add_subfields( $subfield->[0] => $subfield->[1] );
                        }
                    }
                }
             if($new_field){
                $marc_record->append_fields($new_field);
             }
         }

            my %parametros;
            $parametros{'id_importacion_iso'}      = $importacion->getId;
            $parametros{'marc_record'}   = $marc_record->as_usmarc();

            my $Io_registro_importacion          = C4::Modelo::IoImportacionIsoRegistro->new(db => $db);
            $Io_registro_importacion->agregar(\%parametros);

      };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B455','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO04', 'params' => []} ) ;
     }

    } # WHILE  ( my $record = $reader->read()

}

=item sub getImportaciones
obtiene las importaciones
=cut
sub getImportaciones {
    require C4::Modelo::IoImportacionIso;
    require C4::Modelo::IoImportacionIso::Manager;

    my $importaciones = C4::Modelo::IoImportacionIso::Manager->get_io_importacion_iso(sort_by => ['fecha_upload DESC']);
    my @importaciones;

    foreach my $importacion (@$importaciones){
        push (@importaciones, $importacion);
    }

    return (\@importaciones);
}

=item sub getRegistrosFromImportacion
Se obtienen los registros de la importacion
=cut
sub getRegistrosFromImportacion {

    my ($id_importacion,$filter,$ini,$cantR,$db) = @_;

    require C4::Modelo::IoImportacionIsoRegistro;
    require C4::Modelo::IoImportacionIsoRegistro::Manager;
    $db = $db || C4::Modelo::IoImportacionIsoRegistro->new()->db;

    my @filtros;
    push (@filtros, ( id_importacion_iso => { eq => $id_importacion}));

    if((!$filter)||($filter eq 'MAIN')){
        #Solo registros padre por defecto
        push (@filtros, ( relacion => { eq => '' }));
        }
    elsif($filter eq 'UNIDENTIFIED'){
        push (@filtros, ( identificacion => { eq => undef }));
        }
    elsif($filter eq 'MATCH'){
        push (@filtros, ( matching => { eq => 1 }));
        }
    elsif($filter eq 'IGNORED'){
        push (@filtros, ( estado => { eq => 'I' }));
        }
    elsif($filter eq 'ALL'){
        #si se muestran todos no se agregan mas filtros
        }


    my $registros_array_ref;

    if($cantR eq 'ALL'){

     $registros_array_ref= C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro(  db              => $db,
                                                                                                    query => \@filtros,);
     }else{
     $registros_array_ref= C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro(  db              => $db,
                                                                                                    query => \@filtros,
                                                                                                    limit   => $cantR,
                                                                                                    offset  => $ini,
                                                                                                        );

     }

    #Obtengo la cantidad total de registros de la importacion para el paginador
    my $registros_array_ref_count = C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro_count(  db  => $db,
                                                                                                                        query => \@filtros);

    if(scalar(@$registros_array_ref) > 0){
        return ($registros_array_ref_count, $registros_array_ref);
    }else{
        return (0,0);
    }

}

=item
     Esta funcion devuelve un registro de importacion segun su id
=cut
sub getRegistroFromImportacionById {
    my ($id) = @_;

    require C4::Modelo::IoImportacionIsoRegistro;
    require C4::Modelo::IoImportacionIsoRegistro::Manager;

    my $registroImportacionTemp;
    my @filtros;

    if ($id){
        push (@filtros, ( id => { eq => $id}));
        $registroImportacionTemp = C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro( query => \@filtros );
        return $registroImportacionTemp->[0];
    }

    return 0;
}


=item
     Esta funcion devuelve un los ejemplares de un  registro de importacion segun su id
=cut
sub getRegistrosHijoFromRegistroDeImportacionById {
    my ($id) = @_;

    my ($registro_importacion) = C4::AR::ImportacionIsoMARC::getRegistroFromImportacionById($id);

    if ($registro_importacion->getIdentificacion){
        my @filtros;
        push (@filtros, ( relacion => { eq => $registro_importacion->getIdentificacion }));
        push (@filtros, ( id_importacion_iso => { eq => $registro_importacion->id_importacion_iso }));

        require C4::Modelo::IoImportacionIsoRegistro;
        require C4::Modelo::IoImportacionIsoRegistro::Manager;

        #Obtengo la cantidad total de registros de la importacion para el paginador
        my $registros_array_ref = C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro( query => \@filtros );

        if(scalar(@$registros_array_ref) > 0){
            return (scalar(@$registros_array_ref), $registros_array_ref);
        }
    }
    return (0,0);
}

=item
     Esta funcion devuelve un los ejemplares de un  registro de importacion segun su id
=cut
sub getRegistroPadreFromRegistroDeImportacionById {
    my ($id) = @_;

    my ($registro_importacion) = C4::AR::ImportacionIsoMARC::getRegistroFromImportacionById($id);

    if ($registro_importacion->getRelacion){
        my @filtros;
        push (@filtros, ( identificacion => { eq => $registro_importacion->getRelacion }));
        push (@filtros, ( id_importacion_iso => { eq => $registro_importacion->id_importacion_iso }));

        require C4::Modelo::IoImportacionIsoRegistro;
        require C4::Modelo::IoImportacionIsoRegistro::Manager;

        #Obtengo la cantidad total de registros de la importacion para el paginador
        my $registros_array_ref = C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro( query => \@filtros );

        if($registros_array_ref->[0]){
            return $registros_array_ref->[0];
        }
    }
    return 0;
}


=item
    Esta funcion elimina una importacion (con todos sus registros)
    Parametros:
                {id_importacion}
=cut
sub eliminarImportacion {

     my ($id) = @_;
     my $msg_object= C4::AR::Mensajes::create();
     my $importacion = C4::AR::ImportacionIsoMARC::getImportacionById($id);

     eval {
        $msg_object = $importacion->eliminar();
        if(!$msg_object->{'error'}){
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO00', 'params' => []} ) ;
        }
     };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B453','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO01', 'params' => []} ) ;
     }

     return ($msg_object);
}

=item
     Esta funcion devuelve la importacion segun su id
=cut
sub getImportacionById {
    my ($id) = @_;

    require C4::Modelo::IoImportacionIso;
    require C4::Modelo::IoImportacionIso::Manager;

    my $importacionTemp;
    my @filtros;

    if ($id){
        push (@filtros, ( id => { eq => $id}));
        $importacionTemp = C4::Modelo::IoImportacionIso::Manager->get_io_importacion_iso( query => \@filtros );
        return $importacionTemp->[0]
    }

    return 0;
}


=item
    Este funcion devuelve la informacion de importaciones segun su nombre, archivo o comentario
=cut
sub getImportacionLike {
    my ($busqueda,$orden,$ini,$cantR,$inicial) = @_;

    require C4::Modelo::IoImportacionIso;
    require C4::Modelo::IoImportacionIso::Manager;

    my @filtros;
    my $importacionTemp = C4::Modelo::IoImportacionIso->new();

    if($busqueda ne 'TODOS'){
        if (!($inicial)){
                push (  @filtros, ( or   => [   nombre => { like => '%'.$busqueda.'%'}, archivo => { like => '%'.$busqueda.'%'}, comentario => { like => '%'.$busqueda.'%'},]));
        }else{
                push (  @filtros, ( or   => [   nombre => { like => $busqueda.'%'}, archivo => { like => $busqueda.'%'}, comentario => { like => '%'.$busqueda.'%'},]) );
        }
    }

    my $ordenAux= $importacionTemp->sortByString($orden);
    my $importaciones_array_ref = C4::Modelo::IoImportacionIso::Manager->get_io_importacion_iso(   query => \@filtros,
                                                                                        sort_by => $ordenAux,
                                                                                        limit   => $cantR,
                                                                                        offset  => $ini,
     );

    #Obtengo la cantidad total de importaciones para el paginador
    my $importaciones_array_ref_count = C4::Modelo::IoImportacionIso::Manager->get_io_importacion_iso_count( query => \@filtros);

    if(scalar(@$importaciones_array_ref) > 0){
        return ($importaciones_array_ref_count, $importaciones_array_ref);
    }else{
        return (0,0);
    }
}

=item sub guardarNuevaImportacion
Obtiene un esquema de importacion
=cut

sub getEsquema{
    my ($id_esquema) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;

    push(@filtros,(id_importacion_esquema => {eq =>$id_esquema}));

    my $detalle_esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                                        query => \@filtros,
                                                                                                        group_by => ['campo_origen,subcampo_origen'],
    );

    my $esquema = getEsquemaObject($id_esquema);

    return ($detalle_esquema,$esquema);
}

sub addEsquema{
    my ($nombre,$descripcion) = @_;

    use C4::Modelo::IoImportacionIsoEsquema;

    my $esquema = C4::Modelo::IoImportacionIsoEsquema->new();
    $esquema->setNombre($nombre);
    $esquema->setDescripcion($descripcion);
    $esquema->save();

    return $esquema;
}

sub addCampo{
    my ($id_esquema) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;

    my $esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
    my $value = "ZZZ";
    my $error_code = 0;

    eval{
        $esquema->setIdImportacionEsquema($id_esquema);
        $esquema->setCampoOrigen($value);
        $esquema->setSubcampoOrigen($value);
        $esquema->setCampoDestino($value);
        $esquema->setSubcampoDestino($value);
        $esquema->setNivel(1);
        $esquema->setIgnorar(0);

        $esquema->save();
    };

    if ($@){
        return ($esquema,'IO02');
    }

    return ($esquema,$error_code);
}

sub getOrdenEsquema{

    my ($params) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;

    my $detalle = getRow($params->{'id_esquema'});

    push(@filtros,(id_importacion_esquema => { eq => $detalle->esquema->getId }));
    push(@filtros,(campo_origen           => { eq => $detalle->getCampoOrigen}));
    push(@filtros,(subcampo_origen => { eq => $detalle->getSubcampoOrigen }));

    my $detalle_esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                                    query => \@filtros,
                                                                                                    sort_by => ['orden ASC'],
    );

    return ($detalle_esquema,$detalle);

}

sub updateNewOrder{
    my ($params) = @_;
    my $msg_object      = C4::AR::Mensajes::create();

    # ordeno los ids que llegan desordenados primero, para obtener un clon de los ids, y ahora usarlo de indice para el orden
    # esto es porque no todos los campos de cat_visualizacion_intra se muestran en el template a ordenar ( ej 8 y 9 )
    # entonces no puedo usar un simple indice como id.
    my $newOrderArray = $params->{'newOrderArray'};

    my @array = sort { $a <=> $b } @$newOrderArray;

    my $i = 0;
    # hay que hacer update de todos los campos porque si viene un nuevo orden y es justo ordenado (igual que @array : 1,2,3...)
    # tambien hay que actualizarlo
    foreach my $campo (@$newOrderArray){

        my @filtros;
        push(@filtros,(id => { eq => $campo }));

        my $config_temp   = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                    query   => \@filtros,
                               );

        my $configuracion = $config_temp->[0];

        $configuracion->setOrden($i+1);
        $configuracion->save();

        $i++;
    }

    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'M000', 'params' => []} ) ;

    return ($msg_object);
}

sub addCampoAEsquema{
    my ($params) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;

    my $esquema = getRow($params->{'id_esquema'});
    my $msg_object = C4::AR::Mensajes::create();

    eval{
        my $new_esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
        $new_esquema->setIdImportacionEsquema($esquema->getIdImportacionEsquema);
        $new_esquema->setCampoOrigen($esquema->getCampoOrigen);
        $new_esquema->setSubcampoOrigen($esquema->getSubcampoOrigen);
        $new_esquema->setCampoDestino($params->{'campo'});
        $new_esquema->setSubcampoDestino($params->{'subcampo'});
        $new_esquema->setSeparador($params->{'separador'});
        $new_esquema->setNivel(1);
        $new_esquema->setIgnorar(0);
        $new_esquema->setNextOrden();

        $new_esquema->save();

        $msg_object->{'error'}= 0;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO016', 'params' => [$params->{'campo'},$params->{'subcampo'},$esquema->esquema->getNombre]} ) ;

    };

    if ($@){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO015', 'params' => []} ) ;
    }

    return ($msg_object);

}


sub getRow{
    my ($id) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;

    push(@filtros,(id => {eq =>$id}));

    my $esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(query => \@filtros,);

    if ($esquema->[0]){
        return $esquema->[0];
    }else{
        return 0;
    }

}

sub getEsquemaObject{
    my ($id) = @_;

    use C4::Modelo::IoImportacionIsoEsquema::Manager;
    my @filtros;

    push(@filtros,(id => {eq =>$id}));

    my $esquema = C4::Modelo::IoImportacionIsoEsquema::Manager->get_io_importacion_iso_esquema(query => \@filtros,);

    if ($esquema->[0]){
        return $esquema->[0];
    }else{
        return 0;
    }

}

sub delEsquema{
    my ($id_esquema) = @_;

    use C4::Modelo::IoImportacionIsoEsquema::Manager;
    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;

    my $msg_code = 'IO05';

    my @filtros_detalle;
    push(@filtros_detalle,(id_importacion_esquema => {eq =>$id_esquema}));

    my @filtros_esquema;
    push(@filtros_esquema,(id => {eq =>$id_esquema}));

    eval{
        C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->delete_io_importacion_iso_esquema_detalle(where => \@filtros_detalle);
        C4::Modelo::IoImportacionIsoEsquema::Manager->delete_io_importacion_iso_esquema(where => \@filtros_esquema);
    };

    if ($@){
        return 'IO06';
    }

    return($msg_code);
}

sub delCampo{
    my ($id) = @_;

    my $row = getRow($id);

    my @filtros;
    my $id_esquema = $row->esquema->getId;

    push( @filtros, ( id_importacion_esquema => { eq => $id_esquema }, ) );
    push( @filtros, ( campo_origen => { eq => $row->getCampoOrigen }, ) );
    push( @filtros, ( subcampo_origen => { eq => $row->getSubcampoOrigen }, ) );

    eval{
        C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->delete_io_importacion_iso_esquema_detalle(where => \@filtros);
    };

    if ($@){
       return (0,'IO07');
    }else{
        return ($id_esquema,'IO03');
    }
}

sub delCampoOne{
    my ($id) = @_;

    my $row = getRow($id);

    my @filtros;
    my $id_esquema = $row->esquema->getId;

    push( @filtros, ( id => { eq => $id }, ) );

    eval{
        C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->delete_io_importacion_iso_esquema_detalle(where => \@filtros);
    };

    if ($@){
       return (0,'IO07');
    }else{
        return ($id_esquema,'IO03');
    }
}

sub actualizarMappeo{
    my ($row,$new_value,$action) = @_;

    my @filtros;
    push( @filtros, ( id_importacion_esquema => { eq => $row->esquema->getId }, ) );
    push( @filtros, ( campo_origen => { eq => $row->getCampoOrigen }, ) );
    push( @filtros, ( subcampo_origen => { eq => $row->getSubcampoOrigen }, ) );

    if ($action eq "co"){
        C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->update_io_importacion_iso_esquema_detalle(
                                                                                             where => \@filtros,
                                                                                             set   => { campo_origen => $new_value },

        );
    }else{
        C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->update_io_importacion_iso_esquema_detalle(
                                                                                             where => \@filtros,
                                                                                             set   => { subcampo_origen => $new_value },

        );

    }
}

sub editarValorEsquema{
    my ($row_id,$value) = @_;

    use Switch;

    my @values = split('___',$row_id);


    my $object = getRow(@values[0]);

    switch (@values[1]) {
        case "co"  {actualizarMappeo($object,$value,@values[1]); $object->load(); $value = $object->getCampoOrigen()}
        case "sco"  {actualizarMappeo($object,$value,@values[1]); $object->load(); $value = $object->getSubcampoOrigen()}
        case "cd"   {$object->setCampoDestino($value); $value = $object->getCampoDestino()}
        case "scd"  {$object->setSubcampoDestino($value); $value = $object->getSubcampoDestino()}
        case "n"    {$object->setNivel($value); $value = $object->getNivel()}
        case "ign"  {$object->setIgnorarFront($value); $object->load(); $value = $object->getIgnorarFront();}
        case "sep"  {$object->setSeparador($value); $value = $object->getSeparador();}
    }
    $object->save();

    return ($value);

}

sub editarEsquema{
    my ($row_id,$value) = @_;

    use Switch;

    my @values = split('___',$row_id);


    my $object = getEsquemaObject(@values[0]);

    switch (@values[1]) {
        case "nombre"  {$object->setNombre($value)}
        case "desc"  {$object->setDescripcion($value)}
    }
    $object->save();

    return ($value);

}

sub getCamposXFromEsquemaOrigenLike {
      my ($id_esquema,$campoX) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;

    my @filtros;
    push(@filtros, (id_importacion_esquema => {eq =>$id_esquema}));
    push(@filtros, (campo_origen => { like => $campoX.'%'}) );

    my $db_campos_MARC = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                        query => \@filtros,
                                                                                        sort_by => ('campo_origen'),
                                                                                        select   => [ 'campo_origen'],
                                                                                        group_by => [ 'campo_origen'],
                                                                       );
    return($db_campos_MARC);
}


sub getSubCamposFromEsquemaOrigenLike {
      my ($id_esquema,$campo) = @_;
    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;

    my @filtros;
    push(@filtros, (id_importacion_esquema => {eq =>$id_esquema}));
    push(@filtros, (campo_origen => { eq => $campo}) );

    my $db_subcampos_MARC = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                        query => \@filtros,
                                                                                        sort_by => ('subcampo_origen'),
                                                                                        select   => [ 'subcampo_origen'],
                                                                                        group_by => [ 'subcampo_origen'],
                                                                       );
    return($db_subcampos_MARC);
}



sub procesarRelacionRegistroEjemplares {
      my ($params) = @_;

     my $msg_object= C4::AR::Mensajes::create();

     eval {

          my $id_importacion             = $params->{'id'};
          my $importacion = C4::AR::ImportacionIsoMARC::getImportacionById($id_importacion);

          my $campo_relacion = $params->{'campo_relacion'};
          my $subcampo_relacion = $params->{'subcampo_relacion'};
          my $preambulo_relacion = $params->{'preambulo_relacion'};
          if (($campo_relacion )&&($campo_relacion ne '-1')) {
              $importacion->setCampoRelacion($campo_relacion,$subcampo_relacion,$preambulo_relacion);
              }

          my $campo_identificacion = $params->{'campo_identificacion'};
          my $subcampo_identificacion = $params->{'subcampo_identificacion'};
          if (($campo_identificacion)&&($campo_identificacion ne '-1')) {
              $importacion->setCampoIdentificacion($campo_identificacion,$subcampo_identificacion);
          }

          $importacion->save();

        #ACA HAY QUE PROCESAR LA RELACION
        # 1 - Buscar todas las identificaciones
        # 2 - Buscar todas las relaciones registro/ejemplar
        $importacion->setearIdentificacionRelacionRegistros();

        if(!$msg_object->{'error'}){
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO09', 'params' => []} ) ;
        }
     };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B457','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO10', 'params' => []} ) ;
     }

     return ($msg_object);

}


sub obtenerCamposDeArchivo {
    my ($params)    = @_;

    my %detalleCampos=();
    use Switch;
    my $reader;
    switch ($params->{'formatoImportacion'}) {
        case "iso"   {$reader=MARC::Moose::Reader::File::Iso2709->new(file   => $params->{'write_file'})}
        case "isis"  {$reader=MARC::Moose::Reader::File::Isis->new(file   => $params->{'write_file'})}
        case "xml"   {$reader=MARC::Moose::Reader::File::Marcxml->new(file   => $params->{'write_file'})}
    }

    while ( my $record = $reader->read() ) {
    eval {
         for my $field ( @{$record->fields} ) {
             my $campo = $field->tag;
             if(!$detalleCampos{$campo}){
                $detalleCampos{$campo}= 1;
            }
         }
        };
    }
    return(\%detalleCampos);
}



sub procesarReglasMatcheo {
      my ($params) = @_;

     my $msg_object= C4::AR::Mensajes::create();

     eval {
          my $id_importacion             = $params->{'id'};
          my $importacion = C4::AR::ImportacionIsoMARC::getImportacionById($id_importacion);

          my $reglas_matcheo = $params->{'reglas_matcheo'};
          $importacion->setReglasMatcheo($reglas_matcheo);
          $importacion->save();
          my $reglas= $importacion->getReglasMatcheoArray();

        #ACA HAY QUE PROCESAR LAS REGLAS
        my $tt1 = time();
        # Recorrer cada registro y ver si matchea contra alguno de la base
        my $registros_importacion = $importacion->getRegistrosPadre();
		my $cant_registros=0;
        foreach my $registro (@$registros_importacion){
            #Armo las reglas con dato y busco en el catalogo si existe
            my $reglas_registro = $registro->getDatosFromReglasMatcheo($reglas);
            my $id_matching =0;
                if(scalar(@$reglas_registro)){
                    $id_matching = C4::AR::ImportacionIsoMARC::getIdMatchingFromCatalog($reglas_registro);
                }

            if($id_matching){
                $registro->setMatching(1);
                $registro->setIdMatching($id_matching);
                $cant_registros++;
                }
              else{
                $registro->setMatching(0);
                  }
              $registro->save();
            }
		my $tt2 = time();
		my $tardo2=($tt2 - $tt1);
		my $min= $tardo2/60;
		my $hour= $min/60;
		C4::AR::Debug::debug( "AL FIN TERMINO TODO!!! Tardo $tardo2 segundos !!! que son $min minutos !!! o mejor $hour horas !!!");


        if(!$msg_object->{'error'}){
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO11', 'params' => [$cant_registros]} ) ;
        }
     };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B458','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO12', 'params' => []} ) ;
     }

     return ($msg_object);

}


sub getIdMatchingFromCatalog {
    my ($reglas)    = @_;

    #obtengo los datod de todos los niveles1

    my  $indice_array_ref = C4::AR::Sphinx::getAllIndiceBusqueda();

	if ($indice_array_ref) {
    foreach my $indice ( @$indice_array_ref) {
            my $marc_record=  $indice->getMarcRecordObject;
            my $match=0;
                foreach my $regla (@$reglas){
                    my @datos = $marc_record->subfield($regla->{'campo'},$regla->{'subcampo'});
                    foreach my $datos (@datos){
#						C4::AR::Debug::debug("CAMPARANDO ".C4::AR::Utilidades::trim($regla->{'dato'})." <==>".C4::AR::Utilidades::trim($datos));
						if ( C4::AR::Utilidades::trim($regla->{'dato'}) eq C4::AR::Utilidades::trim($datos)) {
							C4::AR::Debug::debug("MATCH REGLA=".$regla->{'campo'}."&".$regla->{'subcampo'}." => ".$regla->{'dato'});
							return $indice->getId;
							}
					}
                }

            if($match){
                return $indice->getId;
                }
        }
	}
    return(0);
}


sub cambiarEsdatoRegistro {
      my ($params) = @_;

     my $msg_object= C4::AR::Mensajes::create();

     eval {


          my $id_registro             = $params->{'id'};
          my ($registro_importacion) = C4::AR::ImportacionIsoMARC::getRegistroFromImportacionById($id_registro);
          $registro_importacion->setEstado($params->{'estado'});
          $registro_importacion->save();

        if(!$msg_object->{'error'}){
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO11', 'params' => []} ) ;
        }
     };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B458','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO12', 'params' => []} ) ;
     }

     return ($msg_object);

}

#Dividir el registro en niveles de meran

sub getNivelesFromRegistro {
      my ($id_registro) = @_;
      
    my ($registro_importacion) = C4::AR::ImportacionIsoMARC::getRegistroFromImportacionById($id_registro);
	my $marc_record_to_meran = $registro_importacion->getRegistroMARCResultado();
	
	#Armamos un grupo de niveles vacio 
	my $marc_record_n1 = MARC::Record->new();
 	my $marc_record_n2 = MARC::Record->new();
	my $marc_record_n3 = MARC::Record->new();
	my @grupos=();
	my @ejemplares=();
	my $tipo_ejemplar='';
	my $total_ejemplares=0;
    foreach my $field ($marc_record_to_meran->fields) {
        if(! $field->is_control_field){
            my $campo                       = $field->tag;
            my $indicador_primario_dato     = $field->indicator(1);
            my $indicador_secundario_dato   = $field->indicator(2);
            #proceso todos los subcampos del campo
            foreach my $subfield ($field->subfields()) {
                my $subcampo          = $subfield->[0];
                my $dato              = $subfield->[1];
                my $estructura        = C4::AR::EstructuraCatalogacionBase::getEstructuraBaseFromCampoSubCampo($campo, $subcampo);
				
				use Switch;
				switch ($estructura->getNivel) {
				case 1 { 
						#El campo es de Nivel 1 
						if ($marc_record_n1->field($campo)){
							#Existe el campo, agrego el subcampo
							$marc_record_n1->field($campo)->add_subfields($subcampo => $dato);
						}
						else{
							#No existe el campo, se crea
							my $field = MARC::Field->new($campo,'','',$subcampo => $dato);
							$marc_record_n1->append_fields($field);
							}
					}
				case 2 {
						#Nivel 2

						#HAY QUE CREAR UNO NUEVO??
 						#C4::AR::Debug::debug("HAY QUE CREAR UNO NUEVO??  ".$campo."&".$subcampo."=".$dato." ".$marc_record_n2->subfield($campo,$subcampo)." repetible? ".$estructura->getRepetible);

						if(($marc_record_n2->subfield($campo,$subcampo))&&(!$estructura->getRepetible)&&(($campo ne '910')&&($subcampo ne 'a'))){
							#Existe el subcampo y no es repetible ==> es un nivel 2 nuevo
							#C4::AR::Debug::debug("Existe el subcampo y no es repetible ==> es un nivel 2 nuevo  ".$campo."&".$subcampo."=".$dato);
											
							#Agrego el último ejemplar y lo guardo
							if (scalar($marc_record_n3->fields())){
								C4::AR::Debug::debug("EJEMPLAR ".$marc_record_n3->as_formatted);	
								push(@ejemplares,$marc_record_n3);
								$marc_record_n3 = MARC::Record->new();
							}
								
							#Guardo el nivel 2 con sus ejemplares
							$tipo_ejemplar = C4::AR::ImportacionIsoMARC::getTipoDocumentoFromMarcRecord($marc_record_n2);
							my %hash_temp;
							$hash_temp{'grupo'}  = $marc_record_n2;
							$hash_temp{'tipo_ejemplar'}  = $tipo_ejemplar;
							$hash_temp{'cant_ejemplares'}   = scalar(@ejemplares);
							$total_ejemplares+=$hash_temp{'cant_ejemplares'};
							$hash_temp{'ejemplares'}   = \@ejemplares;
							push (@grupos, \%hash_temp);
							$marc_record_n2 = MARC::Record->new();
							@ejemplares = ();
						}				
						
						if ((($campo eq '910')&&($subcampo eq 'a'))&&($marc_record_n2->subfield($campo,$subcampo))){
								#ya existe el 910,a, no sirve que haya varios
								next;
							}
						
						#El campo es de Nivel 2
						if ($marc_record_n2->field($campo)){
							#Existe el campo, agrego el subcampo
							$marc_record_n2->field($campo)->add_subfields($subcampo => $dato);
						}
						else{
							#No existe el campo, se crea
							my $field = MARC::Field->new($campo,'','',$subcampo => $dato);
							$marc_record_n2->append_fields($field);
							}
						}
				case 3 {
						#Nivel 3 
						#Aca no hay ningun campo que sea repetible, si ya existe el subcampo es un nuevo ejemplar.
						
						 if($marc_record_n3->subfield($campo,$subcampo)){
							#Existe el subcampo y no es repetible ==> es un nivel 3 nuevo							
							#Agrego el último ejemplar y lo guardo
							C4::AR::Debug::debug("EJEMPLAR ".$marc_record_n3->as_formatted);	
								push(@ejemplares,$marc_record_n3);
								$marc_record_n3 = MARC::Record->new();
							}
						C4::AR::Debug::debug("EJ ".$campo."&".$subcampo."=".$dato);
						#El campo es de Nivel 3
						if ($marc_record_n3->field($campo)){
							#Existe el campo, agrego el subcampo
							$marc_record_n3->field($campo)->add_subfields($subcampo => $dato);
						}
						else{
							#No existe el campo, se crea
							my $field = MARC::Field->new($campo,'','',$subcampo => $dato);
							$marc_record_n3->append_fields($field);
							}
						}
				case 0 {
					C4::AR::Debug::debug("CAMPO MULTINIVEL ".$campo."&".$subcampo."=".$dato);
					#FIXME va en el 1 por ahora
						#El campo es de Nivel 1 
						if ($marc_record_n1->field($campo)){
							#Existe el campo, agrego el subcampo
							$marc_record_n1->field($campo)->add_subfields($subcampo => $dato);
						}
						else{
							#No existe el campo, se crea
							my $field = MARC::Field->new($campo,'','',$subcampo => $dato);
							$marc_record_n1->append_fields($field);
							}
				
					}
				} # END SWITCH
                
			}
			
		}
	}
	C4::AR::Debug::debug("ULTIMO EJEMPLAR ".$marc_record_n3->fields());
		C4::AR::Debug::debug("EJEMPLAR ".$marc_record_n3->as_formatted);
		#Agrego el último ejemplar y lo guardo
		if (scalar($marc_record_n3->fields())){
			C4::AR::Debug::debug("EJEMPLAR ".$marc_record_n3->as_formatted);
			push(@ejemplares,$marc_record_n3);
			$marc_record_n3 = MARC::Record->new();
		}
							
		#Guardo el nivel 2 con sus ejemplares
		$tipo_ejemplar = C4::AR::ImportacionIsoMARC::getTipoDocumentoFromMarcRecord($marc_record_n2);
		my %hash_temp;
		$hash_temp{'grupo'}  = $marc_record_n2;
		$hash_temp{'tipo_ejemplar'}  = $tipo_ejemplar;
		$hash_temp{'cant_ejemplares'}   = scalar(@ejemplares);
		$total_ejemplares+=$hash_temp{'cant_ejemplares'};
		$hash_temp{'ejemplares'}   = \@ejemplares;
		push (@grupos, \%hash_temp);
	
		C4::AR::Debug::debug("###########################################################################################");
		foreach my $grupo (@grupos){
			my $ej = $grupo->{'ejemplares'};
			C4::AR::Debug::debug(" GRUPO con ".scalar(@$ej)." ej");
			C4::AR::Debug::debug(" Grupo  ".$grupo->{'grupo'}->as_formatted);
				foreach my $ejemplar (@$ej){
						C4::AR::Debug::debug(" Ejemplar  ".$ejemplar->as_formatted);
				}
		}
		C4::AR::Debug::debug("###########################################################################################");
		
		my %hash_temp;
		$hash_temp{'registro'}  = $marc_record_n1;
		$hash_temp{'grupos'}   = \@grupos;
		$hash_temp{'tipo_ejemplar'}  = $tipo_ejemplar;
		$hash_temp{'total_ejemplares'}  = $total_ejemplares;
	return  \%hash_temp;
		
}

=head2 sub detalleCompletoVistaPrevia
    Genera el detalle 
=cut

sub detalleCompletoVistaPrevia {
    my ($id_registro) = @_;
   
    my $detalle = C4::AR::ImportacionIsoMARC::getNivelesFromRegistro($id_registro);
    
    #recupero el nivel1 segun el id1 pasado por parametro
    my $nivel1              = $detalle->{'registro'};
    my $grupos = $detalle->{'grupos'};
    
    my @niveles2;    
    foreach my $nivel2 (@$grupos){
		my $nivel2_marc = $nivel2->{'grupo'};
		my %hash_nivel2=();
        $hash_nivel2{'tipo_documento'}          = C4::AR::ImportacionIsoMARC::getTipoDocumentoFromMarcRecord_Object($nivel2_marc);
        
        #Seteo bien el código de tipo de documento
        my $tipo_documento = C4::AR::ImportacionIsoMARC::getTipoDocumentoFromMarcRecord($nivel2_marc);
        $nivel2_marc->field('910')->update( a => $tipo_documento);
        
        $hash_nivel2{'nivel2_array'}            =  C4::AR::ImportacionIsoMARC::toMARC_Array($nivel2_marc,$hash_nivel2{'tipo_documento'},'',2);
        $hash_nivel2{'nivel2_template'}         = $nivel2->{'tipo_ejemplar'};
        $hash_nivel2{'tiene_indice'}            = 0;

        
        if($nivel2->{'grupo'}->subfield('865','a')){
			$hash_nivel2{'indice'}              = $nivel2_marc->subfield('865','a');
			$hash_nivel2{'tiene_indice'}		= 1;
		}
        $hash_nivel2{'esta_en_estante_virtual'} = 0;
        
        my $ejemplares = $nivel2->{'ejemplares'};
        my @niveles3=();
        
            foreach my $nivel3 (@$ejemplares){
				my $n3 =  C4::AR::ImportacionIsoMARC::getEjemplarFromMarcRecord($nivel3,$hash_nivel2{'tipo_documento'});
				push(@niveles3, $n3);
			}

        $hash_nivel2{'nivel3'}                  = \@niveles3;        
        $hash_nivel2{'cant_nivel3'}             = @niveles3;

        push(@niveles2, \%hash_nivel2);
    }
    
    my %t_params;
    $t_params{'nivel1'}           = C4::AR::ImportacionIsoMARC::toMARC_Array($nivel1,'LIB','',1);
    $t_params{'nivel1_template'}  = $detalle->{'tipo_ejemplar'};
    $t_params{'cantItemN1'}       = $detalle->{'total_ejemplares'};
    $t_params{'nivel2'}           = \@niveles2;

    return \%t_params;
}

sub toMARC_Array {
    my ($marc_record, $itemtype, $type, $nivel) = @_;
    my @MARC_result_array;
    $type           = $type || "__NO_TYPE";

    foreach my $field ($marc_record->fields) {
        if(! $field->is_control_field){
            my %hash;
            my $campo                       = $field->tag;
            my $indicador_primario_dato     = $field->indicator(1);
            my $indicador_secundario_dato   = $field->indicator(2);
            #proceso todos los subcampos del campo
            foreach my $subfield ($field->subfields()) {
                my %hash_temp;

                my $subcampo                        = $subfield->[0];
                my $dato                            = $subfield->[1];
                $hash_temp{'campo'}                 = $campo;
                $hash_temp{'subcampo'}              = $subcampo;
                $hash_temp{'liblibrarian'}          = C4::AR::Catalogacion::getLiblibrarian($campo, $subcampo, $itemtype, $type, $nivel);
                $hash_temp{'orden'}                 = C4::AR::Catalogacion::getOrdenFromCampoSubcampo($campo, $subcampo, $itemtype, $type, $nivel);
                $hash_temp{'datoReferencia'}        = C4::AR::Catalogacion::getRefFromStringConArrobasByCampoSubcampo($campo, $subcampo, $dato, $itemtype, $nivel);
                $hash_temp{'dato'}                  = $dato;
                push(@MARC_result_array, \%hash_temp);
            }
        }
    }

    @MARC_result_array = sort{$a->{'orden'} <=> $b->{'orden'}} @MARC_result_array;

    return (\@MARC_result_array);
}

sub getDisponibilidadEjemplar{
	my ($ejemplar) = @_;
	    my $dato = $ejemplar->subfield('995','o');
	    my $resultado=C4::AR::Preferencias::getValorPreferencia("defaultDisponibilidad");
	    #FIXME	Debería ir a una tabla de referencia de alias o sinónimos
	    if ($dato){
			use Switch;
			switch ($dato) {
				case 'PRES' { 
					$resultado = "CIRC0000";
					}
				case 'SALA' { 
					$resultado = "CIRC0001";
					}
			}
		}
	return $resultado;
}

sub getEstadoEjemplar{
	my ($ejemplar) = @_;
	    my $dato = $ejemplar->subfield('995','e');
	    my $resultado=C4::AR::Preferencias::getValorPreferencia("defaultEstado");
	    #FIXME	Debería ir a una tabla de referencia de alias o sinónimos
	    if ($dato){
			use Switch;
			switch ($dato) {
				case 'DISPONIBLE' { 
					$resultado = "STATE002";
					}
				case 'NO DISPONIBLE' { 
					$resultado = "STATE000";
					}
			}
		}
	return $resultado;
}

sub getEstadoEjemplar_Object{
	my ($ejemplar) = @_;
	my $estado = C4::AR::ImportacionIsoMARC::getEstadoEjemplar($ejemplar);
	my $object_estado = C4::Modelo::RefEstado->getByPk($estado);
	return  $object_estado;
}


sub getDisponibilidadEjemplar_Object{
	my ($ejemplar) = @_;
	my $disponibilidad = C4::AR::ImportacionIsoMARC::getDisponibilidadEjemplar($ejemplar);
	my $object_disponibilidad = C4::Modelo::RefDisponibilidad->getByPk($disponibilidad);
	return $object_disponibilidad;
}


sub getEjemplarFromMarcRecord{
	my ($nivel3,$tipo_documento) = @_;
	    
	my %hash_nivel3=();
	$hash_nivel3{'tipo_documento'}          = $tipo_documento;
	$hash_nivel3{'barcode'}            		=  C4::AR::ImportacionIsoMARC::generaCodigoBarraFromMarcRecord($nivel3,$tipo_documento->getId_tipo_doc());
	$hash_nivel3{'signatura_topografica'}   =  $nivel3->subfield('995','t');
	$hash_nivel3{'disponibilidad'}   		=  C4::AR::ImportacionIsoMARC::getDisponibilidadEjemplar_Object($nivel3);
	$hash_nivel3{'estado'}   				=  C4::AR::ImportacionIsoMARC::getEstadoEjemplar_Object($nivel3);
	
	return \%hash_nivel3;
}

sub getTipoDocumentoFromMarcRecord{
		my ($marc_record) = @_;
#FIXME	Debería ir a una tabla de referencia de alias o sinónimos
		my $tipo_documento = $marc_record->subfield('910','a');
		
		my $resultado =C4::AR::Preferencias::getValorPreferencia("defaultTipoNivel3");
		if ($tipo_documento){
			use Switch;
			switch ($tipo_documento) {
				case 'TEXTO' { 
					$resultado = 'LIB';
					}
			}
		}
	return $resultado;
}

sub getTipoDocumentoFromMarcRecord_Object{
		my ($marc_record) = @_;
		my $tipo_documento = C4::AR::ImportacionIsoMARC::getTipoDocumentoFromMarcRecord($marc_record);
	    my $object_tipo_documento = C4::AR::Referencias::getTipoNivel3ByCodigo($tipo_documento);
	  	return $object_tipo_documento;
}


sub getUIFromMarcRecord {
		my ($marc_record) = @_;
#FIXME	Debería ir a una tabla de referencia de alias o sinónimos
		my $ui = $marc_record->subfield('995','c');
		
		my $resultado = '';
		#FIXME hay que ver si existe la UI
		
		if ($ui){
			if(C4::AR::Referencias::obtenerUIByIdUi($ui)){
			#es el id
				$resultado=$ui;
				}
			else{
				my $uiLike=C4::AR::Referencias::obtenerUILike($ui);
				if (scalar(@$uiLike)){
					#Existe algo parecido?
					$resultado=$uiLike->[0]->getId_ui;
					}
				else{
					#Valor por defecto
					$resultado =C4::AR::Preferencias::getValorPreferencia("defaultUI");
					}
				}
			}
			
	return $resultado;
}

sub generaCodigoBarraFromMarcRecord{
    my($marc_record_n3,$tipo_ejemplar) = @_;

   my $barcode; 
   my @estructurabarcode = split(',', C4::AR::Preferencias::getValorPreferencia("barcodeFormat"));
    
    my $like = '';

    for (my $i=0; $i<@estructurabarcode; $i++) {
        if (($i % 2) == 0) {
            my $pattern_string ='';
           	use Switch;
			switch ($estructurabarcode[$i]) {
				case 'UI' { 
					$pattern_string= C4::AR::ImportacionIsoMARC::getUIFromMarcRecord($marc_record_n3);
					}
				case 'tipo_ejemplar' {
					$pattern_string= C4::AR::ImportacionIsoMARC::getTipoDocumentoFromMarcRecord($marc_record_n3);
					}
            }
            if ($pattern_string){
                $like.= $pattern_string;
            }else{
                $like.= $estructurabarcode[$i];
            }
        } else {
            $like.= $estructurabarcode[$i];
        }
    }

	my $nro_inventario = $marc_record_n3->subfield('995','f');
	if ($nro_inventario){
	 #viene con nro de inventario
		$barcode  = $like.C4::AR::Nivel3::completarConCeros($nro_inventario);
	 }
	
	if ((C4::AR::Nivel3::existeBarcode($barcode))||(!$barcode)){
		# Si no viene el códifo en el campo 995, f  o ya existe se busca el máximo de su tipo
  	    $barcode  = $like.'AUTOGENERADO';
     }
     
    return ($barcode);
}

END { }       # module clean-up code here (global destructor)

1;
__END__
