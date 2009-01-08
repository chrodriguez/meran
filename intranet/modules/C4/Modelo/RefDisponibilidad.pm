package C4::Modelo::RefDisponibilidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_disponibilidad',

    columns => [
        codigo => { type => 'integer', not_null => 1 },
        nombre => { type => 'varchar', default => '', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'codigo' ],
    unique_key => [ 'nombre' ],
);

sub getCodigo{
    my ($self) = shift;

    return ($self->codigo);
}
    
sub setCodigo{
    my ($self) = shift;
    my ($codigo) = @_;

    $self->codigo($codigo);
}
    

sub getNombre{
    my ($self) = shift;

    return ($self->nombre);
}
    
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;

    $self->nombre($nombre);
}
    

1;

