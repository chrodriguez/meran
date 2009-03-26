package C4::Modelo::CircTipoSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_tipo_sancion',

    columns => [
        tipo_sancion => { type => 'serial', not_null => 1 },
        categoria_socio     => { type => 'character', default => '', length => 2, not_null => 1 },
        tipo_prestamo        => { type => 'character', default => '', length => 2, not_null => 1 },
    ],

    primary_key_columns => [ 'tipo_sancion' ],

    unique_key => [ 'categoria_socio', 'tipo_prestamo' ],

	relationships => [
	    ref_tipo_prestamo => {
            class      => 'C4::Modelo::CircRefTipoPrestamo',
            column_map => { tipo_prestamo => 'id_tipo_prestamo' },
            type       => 'one to one',
        },
	    ref_categoria_socio => {
            class      => 'C4::Modelo::UsrRefCategoriasSocio',
            column_map => { categoria_socio => 'categorycode' },
            type       => 'one to one',
        },
    ],

);




sub getTipo_prestamo{
    my ($self) = shift;
    return ($self->tipo_prestamo);
}

sub setTipo_prestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
    $self->tipo_prestamo($tipo_prestamo);
}

sub getTipo_sancion{
    my ($self) = shift;
    return ($self->tipo_sancion);
}

sub setTipo_sancion{
    my ($self) = shift;
    my ($tipo_sancion) = @_;
    $self->tipo_sancion($tipo_sancion);
}

sub getCategoria_socio{
    my ($self) = shift;
    return ($self->categoria_socio);
}

sub setCategoria_socio{
    my ($self) = shift;
    my ($categoria_socio) = @_;
    $self->categoria_socio($categoria_socio);
}
1;

