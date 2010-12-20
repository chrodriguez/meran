package C4::Modelo::AdqRecomendacionDetalle;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use C4::Modelo::AdqRecomendacion;
use C4::Modelo::CatRegistroMarcN2;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_recomendacion_detalle',

    columns => [  

          id                    => { type => 'integer', not_null => 1 },  
          adq_recomendacion_id  => { type => 'integer', not_null => 1 },  
          cat_nivel2_id         => { type => 'integer', not_null => 1 },
          autor                 => { type => 'varchar', length => 255, not_null => 1},
          titulo                => { type => 'varchar', length => 255, not_null => 1},
          lugar_publicacion     => { type => 'varchar', length => 255, not_null => 1},
          editorial             => { type => 'varchar', length => 255, not_null => 1},
          fecha_publicacion     => { type => 'varchar'},
          coleccion             => { type => 'varchar', length => 255, not_null => 1},
          isbn_issn             => { type => 'varchar', length => 45, not_null => 1},
          cantidad_ejemplares   => { type => 'integer', length => 5, not_null => 1 },  
          motivo_propuesta      => { type => 'varchar', length => 255, not_null => 1},
          comentario            => { type => 'varchar', length => 255, not_null => 1},
          reserva_material      => { type => 'integer', not_null => 1 },
        
    ],

    relationships =>
    [
      ref_adq_recomendacion => 
      {
         class       => 'C4::Modelo::AdqRecomendacion',
         key_columns => {adq_recomendacion_id => 'id' },
         type        => 'one to one',
       },
      
      ref_cat_nivel2 => 
      {
        class       => 'C4::Modelo::CatRegistroMarcN2',
        key_columns => { cat_nivel2_id => 'id' },
        type        => 'one to one',
      },

    ],
    
    primary_key_columns => [ 'id' ],
    unique_key => ['id'],

);


#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setAdqRecomendacionId{
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

sub setMotivoPropuesta {
    my ($self) = shift;
    my ($motivo) = @_;
    utf8::encode($motivo);
    $self->motivo_propuesta($motivo);
}

sub setComentario {
    my ($self) = shift;
    my ($comentario) = @_;
    utf8::encode($comentario);
    $self->comentario($comentario);
}

sub setReservaMaterial {
    my ($self) = shift;
    my ($reserva_material) = @_;
    $self->reserva_material($reserva_material);
}


sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getAdqRecomendacionId{
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

sub getMotivoPropuesta{
    my ($self) = shift;
    return ($self->motivo_propuesta);
}
        
sub getComentario{
    my ($self) = shift;
    return ($self->comentario);
}
 
sub getReservaMaterial{
    my ($self) = shift;
    return ($self->reserva_material);
}             
        