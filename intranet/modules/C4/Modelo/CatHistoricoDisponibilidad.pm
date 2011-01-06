package C4::Modelo::CatHistoricoDisponibilidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_historico_disponibilidad',

    columns => [
         id_detalle     => { type => 'serial', not_null => 1 },
         id3            => { type => 'integer', length => 11, not_null => 1 },
         detalle        => { type => 'varchar', length => 30, not_null => 1 },
         timestamp      => { type => 'timestamp',not_null => 1, default => 'CURRENT_TIMESTAMP' },
         fecha          => { type => 'varchar', length => 10, not_null => 1, default => '0000-00-00' },
         tipo_prestamo  => { type => 'varchar', length => 40, not_null => 1},
         id_ui          => {type => 'varchar', length => 5, not_null => 1},
    ],

    primary_key_columns => ['id_detalle'],

    relationships => [
        nivel3 => {
#             class       => 'C4::Modelo::CatNivel3',
            class       => 'C4::Modelo::CatRegistroMarcN3',
            key_columns => { id3 => 'id3' },
            type        => 'one to one',
        },
   ],
);

sub getId_detalle {
    my ($self) = shift;
    return ( $self->id_detalle );
}

sub setId_detalle {
    my ($self)        = shift;
    my ($id_detalle) = @_;
    $self->id_detalle($id_detalle);
}

sub getDetalle {
    my ($self) = shift;
    return ( $self->detalle );
}

sub setDetalle {
    my ($self)        = shift;
    my ($detalle) = @_;
    $self->detalle($detalle);
}

sub getId3 {
    my ($self) = shift;
    return ( $self->id3 );
}

sub setId3 {
    my ($self) = shift;
    my ($id3)  = @_;
    $self->id3($id3);
}

sub getFecha {
    my ($self) = shift;
    return ( $self->fecha );
}

sub setFecha {
    my ($self)      = shift;
    my ($fecha) = @_;
    $self->fecha($fecha);
}

sub getTipo_prestamo{
    my ($self) = shift;
    return ($self->tipo_prestamo);
}

sub setTipo_prestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
    $self->tipo_prestamo($tipo_prestamo);
}

sub getId_ui{
    my ($self) = shift;
    return ($self->id_ui);
}

sub setId_ui{
    my ($self) = shift;
    my ($id_ui) = @_;
    $self->id_ui($id_ui);
}

sub getTimestamp {
    my ($self) = shift;
    return ( $self->timestamp );
}


1;

