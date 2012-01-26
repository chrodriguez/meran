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
                             }marc record

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
		C4::Debug::debug( "AL FIN TERMINO TODO!!! Tardo $tardo2 segundos !!! que son $min minutos !!! o mejor $hour horas !!!");


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


END { }       # module clean-up code here (global destructor)

1;
__END__
