package C4::Modelo::IoImportacionIso;

use strict;
use utf8;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso',

    columns => [
        id                      => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1 },
        id_importacion_esquema  => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1},
        archivo                 => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        comentario              => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        estado                  => { type => 'character',   overflow => 'truncate', length => 1,    not_null => 1},
        fecha_upload            => { type => 'date',        overflow => 'truncate', not_null => 1},
        fecha_import            => { type => 'date',        overflow => 'truncate', not_null => 1},
        cant_registros_n1       => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1},
        cant_registros_n2       => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1},
        cant_registros_n3       => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1},
        accion_general          => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        accion_sinmatcheo       => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        accion_item             => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        accion_barcode          => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        reglas_matcheo          => { type => 'text',        overflow => 'truncate', not_null => 1},

    ],


    relationships =>
    [
      esquema =>
      {
         class       => 'C4::Modelo::IoImportacionIsoEsquema',
         key_columns => {id_importacion_esquema => 'id' },
         type        => 'one to one',
       },

      registros =>
      {
        class       => 'C4::Modelo::IoImportacionIsoRegistro',
        key_columns => {id => 'id_importacion_iso' },
        type        => 'one to many',
      },

    ],

    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------

sub addImportacionIso{
    my ($self)   = shift;
    my ($params) = @_;

    #$self->setProveedorId($params->{'id_proveedor'});
    #$self->setRefEstadoPresupuestoId(1);
    #$self->setRefPedidoCotizacionId($params->{'pedido_cotizacion_id'});

    $self->save();
}
#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setIdImportacionEsquema{
    my ($self) = shift;
    my ($esquema) = @_;
    $self->id_importacion_esquema($esquema);
}

sub setArchivo{
    my ($self)  = shift;
    my ($archivo) = @_;
    utf8::encode($archivo);
    $self->archivo($archivo);
}

sub setComentario{
    my ($self)   = shift;
    my ($comentario) = @_;
    utf8::encode($comentario);
    $self->comentario($comentario);
}

sub setEstado{
    my ($self)   = shift;
    my ($estado) = @_;
    utf8::encode($estado);
    $self->estado($estado);
}

sub setFechaUpload{
    my ($self)   = shift;
    my ($fecha) = @_;
    $self->fecha_upload($fecha);
}

sub setFechaImport{
    my ($self)   = shift;
    my ($fecha) = @_;
    $self->fecha_import($fecha);
}

sub setCantRegistrosN1{
    my ($self)   = shift;
    my ($cant) = @_;
    $self->cant_registros_n1($cant);
}

sub setCantRegistrosN2{
    my ($self)   = shift;
    my ($cant) = @_;
    $self->cant_registros_n2($cant);
}

sub setCantRegistrosN3{
    my ($self)   = shift;
    my ($cant) = @_;
    $self->cant_registros_n3($cant);
}

sub setAccionGeneral{
    my ($self)   = shift;
    my ($accion) = @_;
    $self->accion_general($accion);
}

sub setAccionSinmatcheol{
    my ($self)   = shift;
    my ($accion) = @_;
    $self->accion_sinmatcheo($accion);
}

sub setAccionItem{
    my ($self)   = shift;
    my ($accion) = @_;
    $self->accion_item($accion);
}

sub setAccionBarcode{
    my ($self)   = shift;
    my ($accion) = @_;
    $self->accion_barcode($accion);
}

sub setReglasMatcheo{
    my ($self)   = shift;
    my ($reglas) = @_;
    $self->reglas_matcheo($reglas);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getIdImportacionEsquema{
    my ($self) = shift;
    return $self->id_importacion_esquema;
}

sub getArchivo{
    my ($self)  = shift;
    return $self->archivo;
}

sub getComentario{
    my ($self)   = shift;
    return $self->comentario;
}

sub getEstado{
    my ($self)   = shift;
    return $self->estado;
}

sub getFechaUpload{
    my ($self)   = shift;
    return $self->fecha_upload;
}

sub getFechaImport{
    my ($self)   = shift;
    return $self->fecha_import;
}

sub getCantRegistrosN1{
    my ($self)   = shift;
    return $self->cant_registros_n1;
}

sub getCantRegistrosN2{
    my ($self)   = shift;
    return $self->cant_registros_n2;
}

sub getCantRegistrosN3{
    my ($self)   = shift;
    return $self->cant_registros_n3;
}

sub getAccionGeneral{
    my ($self)   = shift;
    return $self->accion_general;
}

sub getAccionSinmatcheol{
    my ($self)   = shift;
    return $self->accion_sinmatcheo;
}

sub getAccionItem{
    my ($self)   = shift;
    return $self->accion_item;
}

sub getAccionBarcode{
    my ($self)   = shift;
    return $self->accion_barcode;
}

sub getReglasMatcheo{
    my ($self)   = shift;
    return $self->reglas_matcheo;
}
