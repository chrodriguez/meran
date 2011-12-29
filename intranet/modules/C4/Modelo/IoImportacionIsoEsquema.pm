package C4::Modelo::IoImportacionIsoEsquema;

use strict;
use utf8;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_esquema',

    columns => [
        id                        => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1 },
        nombre                    => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        descripcion               => { type => 'text', overflow => 'truncate'},
    ],


    relationships =>
    [
      detalle =>
      {
         class       => 'C4::Modelo::IoImportacionIsoEsquemaDetalle',
         key_columns => {id => 'id_importacion_esquema' },
         type        => 'one to many',
       },

    ],

    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------

sub addEsquema{
    my ($self)   = shift;
    my ($params) = @_;

    #$self->setProveedorId($params->{'id_proveedor'});
    #$self->setRefEstadoPresupuestoId(1);
    #$self->setRefPedidoCotizacionId($params->{'pedido_cotizacion_id'});

    $self->save();
}
#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    $self->nombre($nombre);
}

sub setDescripcion{
    my ($self)  = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getNombre{
    my ($self) = shift;
    return $self->nombre;
}

sub getDescripcion{
    my ($self)  = shift;
    return $self->descripcion;
}
