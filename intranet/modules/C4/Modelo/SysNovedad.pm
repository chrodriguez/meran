package C4::Modelo::SysNovedad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sys_novedad',

    columns => [
        id            => { type => 'serial', length => 16 },
        usuario       => { type => 'varchar', not_null => 1, length => 16 },
        fecha         => { type => 'integer', not_null => 1, length => 16 },
        titulo        => { type => 'varchar', not_null => 1, length => 255 },
        categoria     => { type => 'varchar', not_null => 1, length => 255 },
        contenido     => { type => 'text', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

     relationships =>
    [
      socio => 
      {
        class       => 'C4::Modelo::UsrSocio',
        key_columns => { usuario => 'nro_socio' },
        type        => 'one to one',
      },
    ]
);


sub agregar{

    my ($self) = shift;


}

sub getId{
    my ($self) = shift;

    return ($self->id);
}

sub getUsuario{
    my ($self) = shift;

    return (C4::AR::Utilidades::trim($self->usuario));
}

sub setUsuario{
    my ($self) = shift;
    my ($usuario) = @_;

    $self->usuario($usuario);
}

sub getFechaLegible{
    my ($self) = shift;

    return ($self->fecha);
}

sub setFecha{
    my ($self) = shift;
    my ($fecha) = @_;

    $self->fecha($fecha);
}

sub getTitulo{
    my ($self) = shift;

    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;
    my ($titulo) = @_;

    $self->titulo($titulo);
}


sub getCategoria{
    my ($self) = shift;

    return ($self->categoria);
}

sub setCategoria{
    my ($self) = shift;
    my ($string) = @_;

    $self->categoria($string);
}

sub getContenido{
    my ($self) = shift;

    return ($self->contenido);
}

sub setContenido{
    my ($self) = shift;
    my ($string) = @_;

    $self->contenido($string);
}

# FIN GETTERS Y SETTERS

sub getResumen{
    my ($self) = shift;

    my $string_sub = substr ($self->contenido,0,100);
    return ($string_sub."...");
}

sub getFechaLegible{
    my ($self) = shift;

    return ($self->fecha);
}

1;
