package C4::Modelo::AdqPedidoCotizacionDetalle;

use strict;
use utf8;
use C4::Modelo::AdqPedidoCotizacionDetalle;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_pedido_cotizacion_detalle',

    columns => [
          id                        => { type => 'integer', not_null => 1 },  
          adq_pedido_cotizacion_id  => { type => 'integer', not_null => 1 },  
          cat_nivel2_id             => { type => 'integer', not_null => 1 },
          autor                     => { type => 'varchar', length => 255, not_null => 1},
          titulo                    => { type => 'varchar', length => 255, not_null => 1},
          lugar_publicacion         => { type => 'varchar', length => 255, not_null => 1},
          editorial                 => { type => 'varchar', length => 255, not_null => 1},
          fecha_publicacion         => { type => 'varchar'},
          coleccion                 => { type => 'varchar', length => 255, not_null => 1},
          isbn_issn                 => { type => 'varchar', length => 45, not_null => 1},
          cantidad_ejemplares       => { type => 'integer', length => 5, not_null => 1 },  
          precio_unitario           => { type => 'float', length => 5, not_null => 1},
          adq_recomendacion_detalle_id => { type => 'varchar', length => 255, not_null => 1},

    ],
    
        relationships =>
    [
      ref_adq_pedido_cotizacion => 
      {
         class       => 'C4::Modelo::AdqPedidoCotizacion',
         key_columns => {adq_pedido_cotizacion_id => 'id' },
         type        => 'one to one',
       },
      
      ref_adq_recomendacion_detalle => 
      {
        class       => 'C4::Modelo::AdqRecomendacionDetalle',
        key_columns => {adq_recomendacion_detalle_id => 'id' },
        type        => 'one to one',
      },

    ],



    primary_key_columns => [ 'id' ],
    unique_key => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------


#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setAdqPedidoCotizacionId{
    my ($self) = shift;
    my ($recomendacion) = @_;
    utf8::encode($recomendacion);
    $self->adq_recomendacion_id($recomendacion);
}

sub setCatNivel2Id{
    my ($self) = shift;
    my ($cat) = @_;
    $self->cat_nivel2_id($cat);
}

sub setAutor{
    my ($self) = shift;
    my ($autor) = @_;
    utf8::encode($autor);
    $self->autor($autor);
}

sub setTitulo{
    my ($self) = shift;
    my ($titulo) = @_;
    utf8::encode($titulo);
    $self->titulo($titulo);
}

sub setLugarPublicacion{
    my ($self) = shift;
    my ($lugar_public) = @_;
    utf8::encode($lugar_public);
    $self->lugar_publicacion($lugar_public);
}

sub setEditorial{
    my ($self) = shift;
    my ($editorial) = @_;
    utf8::encode($editorial);
    $self->editorial($editorial);
}


sub setRefAdqRecomendacionDetalle{
    my ($self) = shift;
    my ($detalle) = @_;
    utf8::encode($detalle);
    $self->ref_adq_recomendacion_detalle_id($detalle);
}

sub getRefAdqRecomendacionDetalle{
    my ($self) = shift;
    return ($self->ref_adq_recomendacion_detalle_id);
}

sub setFechaPublicacion{
    my ($self) = shift;
    my ($fecha_public) = @_;
    utf8::encode($fecha_public);
    $self->fecha_publicacion($fecha_public);
}

sub setColeccion{
    my ($self) = shift;
    my ($coleccion) = @_;
    utf8::encode($coleccion);
    $self->coleccion($coleccion);
}

sub setIsbnIssn {
    my ($self) = shift;
    my ($isbn_issn) = @_;
    utf8::encode($isbn_issn);
    $self->isbn_issn($isbn_issn);
}

sub setCantidadEjemplares {
    my ($self) = shift;
    my ($cant_ejemplares) = @_;
    utf8::encode($cant_ejemplares);
    $self->cantidad_ejemplares($cant_ejemplares);
}

sub setPrecioUnitario {
    my ($self) = shift;
    my ($precio_unitario) = @_;
    $self->cantidad_ejemplares($precio_unitario);
}


sub setAdqRecomendacionDetalle {
    my ($self) = shift;
    my ($adq_recomendacion_detalle) = @_;
    $self->reserva_material($adq_recomendacion_detalle);
}


sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getAdqPedidoCotizacionId{
    my ($self) = shift;
    return ($self->adq_recomendacion_id);
}

sub getCatNivel2Id{
    my ($self) = shift;
    return ($self->cat_nivel2_id);
}

sub getAutor{
    my ($self) = shift;
    return ($self->autor);
}

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub getLugarPublicacion{
    my ($self) = shift;
    return ($self->lugar_publicacion);
}

sub getEditorial{
    my ($self) = shift;
    return ($self->editorial);
}

sub getFechaPublicacion{
    my ($self) = shift;
    return ($self->fecha_publicacion);
}

sub getColeccion{
    my ($self) = shift;
    return ($self->coleccion);
}

sub getIsbnIssn{
    my ($self) = shift;
    return ($self->isbn_issn);
}

sub getCantidadEjemplares{
    my ($self) = shift;
    return ($self->cantidad_ejemplares);
}

sub getPrecioUnitario{
    my ($self) = shift;
    return ($self->precio_unitario);
}

sub getAdqRecomendacionDetalle{
    my ($self) = shift;
    return ($self->adq_recomendacion_detalle);
}             
#----------------------------------- FIN - GETTERS y SETTERS------------------------------------------------
