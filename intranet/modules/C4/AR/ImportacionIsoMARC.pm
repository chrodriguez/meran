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

    my $Io_importacion          = C4::Modelo::IoImportacionIso->new();
    $Io_importacion->agregar($params);

    #Ahora los registros del archivo $params->{'write_file'}
    C4::AR::ImportacionIsoMARC::guardarRegistrosNuevaImportacion($Io_importacion,$params,$msg_object);

}


=item sub guardarRegistrosNuevaImportacion
Guarda los registros de una nueva imporatción
=cut
sub guardarRegistrosNuevaImportacion {
    my ($importacion,$params,$msg_object) = @_;

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
             if($field->tag < '010'){
                 #CONTROL FIELD
                 $new_field = MARC::Field->new( $field->tag, $field->{'value'} );
                 }
                 else {
                    for my $subfield ( @{$field->subf} ) {
                        if(!$new_field){
                            my $ind1=$field->ind1?$field->ind1:'#';
                            my $ind2=$field->ind2?$field->ind2:'#';
                            $new_field= MARC::Field->new($field->tag, $ind1, $ind2,$subfield->[0] => $subfield->[1]);
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

            my $Io_registro_importacion          = C4::Modelo::IoImportacionIsoRegistro->new();
            $Io_registro_importacion->agregar(\%parametros);

      };

     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B455','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IO02', 'params' => []} ) ;
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

    my ($id_importacion,$ini,$cantR,$db) = @_;

    require C4::Modelo::IoImportacionIsoRegistro;
    require C4::Modelo::IoImportacionIsoRegistro::Manager;
    $db = $db || C4::Modelo::IoImportacionIsoRegistro->new()->db;


    my $registros_array_ref;

    if($cantR eq 'ALL'){

     $registros_array_ref= C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro(  db              => $db,
                                                                                                    query => [
                                                                                                        id_importacion_iso => { eq => $id_importacion },
                                                                                                        ],);
     }else{
     $registros_array_ref= C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro(  db              => $db,
                                                                                                    query => [
                                                                                                        id_importacion_iso => { eq => $id_importacion },
                                                                                                        ],
                                                                                                    limit   => $cantR,
                                                                                                    offset  => $ini,
                                                                                                        );
     }

    #Obtengo la cantidad total de registros de la importacion para el paginador
    my $registros_array_ref_count = C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro_count(  db  => $db,
                                                                                                                        query => [
                                                                                                                            id_importacion_iso => { eq => $id_importacion },
                                                                                                                        ]);

    if(scalar(@$registros_array_ref) > 0){
        return ($registros_array_ref_count, $registros_array_ref);
    }else{
        return (0,0);
    }

}


=item
     Esta funcion devuelve un registro de importacion segun su id
=cut
sub getRegistrosFromImportacionById {
    my ($id) = @_;

    require C4::Modelo::IoImportacionIsoRegistro;
    require C4::Modelo::IoImportacionIsoRegistro::Manager;

    my $registroImportacionTemp;
    my @filtros;

    if ($id){
        push (@filtros, ( id => { eq => $id}));
        $registroImportacionTemp = C4::Modelo::IoImportacionIsoRegistro::Manager->get_io_importacion_iso_registro( query => \@filtros );
        return $registroImportacionTemp->[0]
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

    my $esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(query => \@filtros,);

    return $esquema;
}

sub addCampo{
    my ($id_esquema) = @_;

    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;

    my $esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
    my $value = "ZZZ";

    $esquema->setIdImportacionEsquema($id_esquema);
    $esquema->setCampoOrigen($value);
    $esquema->setSubcampoOrigen($value);
    $esquema->setCampoDestino($value);
    $esquema->setSubcampoDestino($value);
    $esquema->setNivel(1);
    $esquema->setIgnorar(0);

    $esquema->save();

    return $esquema;
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
sub editarValorEsquema{
    my ($row_id,$value) = @_;

    use Switch;

    my @values = split('___',$row_id);


    my $object = getRow(@values[0]);

    switch (@values[1]) {
        case "co"  {$object->setCampoOrigen($value)}
        case "sco"  {$object->setSubcampoOrigen($value)}
        case "cd"   {$object->setCampoDestino($value)}
        case "scd"  {$object->setSubcampoDestino($value)}
        case "n"    {$object->setNivel($value)}
        case "ign"  {$object->setIgnorarFront($value); $value = $object->getIgnorarFront();}
    }
    $object->save();

    return ($value);

}
END { }       # module clean-up code here (global destructor)

1;
__END__
