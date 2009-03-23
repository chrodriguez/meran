package C4::Modelo::RefLocalidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_localidad',

    columns => [
        LOCALIDAD        => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE           => { type => 'varchar', length => 100 },
        NOMBRE_ABREVIADO => { type => 'varchar', length => 40 },
        DPTO_PARTIDO     => { type => 'varchar', length => 11 },
        DDN              => { type => 'varchar', length => 11 },
    ],

    primary_key_columns => [ 'LOCALIDAD' ],
);

sub getIdLocalidad{
    my ($self) = shift;
    return ($self->LOCALIDAD);
}

sub getNombre{
    my ($self) = shift;
    return ($self->NOMBRE);
}

sub setId_persona{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->NOMBRE($nombre);
}

sub lastTable{
    
    return(1);
}

1;

