package C4::Modelo::IoImportacionIsoEsquemaDetalle;

use strict;
use utf8;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_esquema',

    columns => [
        id                          => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1 },
        id_importacion_esquema      => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1},
        campo_origen                => { type => 'character',   overflow => 'truncate', length => 3,    not_null => 1},
        subcampo_origen             => { type => 'character',   overflow => 'truncate', length => 1,    not_null => 1},
        campo_destino               => { type => 'character',   overflow => 'truncate', length => 3,    not_null => 1},
        subcampo_destino            => { type => 'character',   overflow => 'truncate', length => 1,    not_null => 1},

    ],


    relationships =>
    [
      esquema =>
      {
        class       => 'C4::Modelo::IoImportacionIsoEsquema',
         key_columns => {id_importacion_esquema => 'id' },
         type        => 'one to one',
       },

    ],

    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------

sub addEsquemaDetalle{
    my ($self)   = shift;
    my ($params) = @_;

    #$self->setProveedorId($params->{'id_proveedor'});
    #$self->setRefEstadoPresupuestoId(1);
    #$self->setRefPedidoCotizacionId($params->{'pedido_cotizacion_id'});

    $self->save();
}
#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setIdImportacionEsquema {
    my ($self) = shift;
    my ($esquema) = @_;
    $self->id_importacion_esquema($esquema);
}

sub setCampoOrigen{
    my ($self)  = shift;
    my ($campo) = @_;
    $self->campo_origen($campo);
}

sub setSubcampoOrigen{
    my ($self)  = shift;
    my ($subcampo) = @_;
    $self->subcampo_origen($subcampo);
}

sub setCampoDestino{
    my ($self)  = shift;
    my ($campo) = @_;
    $self->campo_destino($campo);
}

sub setSubcampoDestino{
    my ($self)  = shift;
    my ($subcampo) = @_;
    $self->subcampo_destino($subcampo);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getIdImportacionEsquema {
    my ($self) = shift;
    return $self->id_importacion_esquema;
}

sub getCampoOrigen{
    my ($self)  = shift;
    return $self->campo_origen;
}

sub getSubcampoOrigen{
    my ($self)  = shift;
    return $self->subcampo_origen;
}

sub getCampoDestino{
    my ($self)  = shift;
    return $self->campo_destino;
}

sub getSubcampoDestino{
    my ($self)  = shift;
    return $self->subcampo_destino;
}
