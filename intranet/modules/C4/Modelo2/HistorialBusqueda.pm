package HistorialBusqueda;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'historialBusqueda',

    columns => [
        idHistorial => { type => 'integer', not_null => 1 },
        idBusqueda  => { type => 'integer', default => '', not_null => 1 },
        campo       => { type => 'varchar', default => '', length => 100, not_null => 1 },
        valor       => { type => 'varchar', default => '', length => 100, not_null => 1 },
        tipo        => { type => 'varchar', length => 10 },
    ],

    primary_key_columns => [ 'idHistorial' ],

    foreign_keys => [
        busqueda => {
            class       => 'Busqueda',
            key_columns => { idBusqueda => 'idBusqueda' },
        },
    ],
);

1;

