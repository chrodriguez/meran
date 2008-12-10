package Busqueda;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'busquedas',

    columns => [
        idBusqueda => { type => 'integer', not_null => 1 },
        borrower   => { type => 'integer' },
        fecha      => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'idBusqueda' ],

    relationships => [
        historialBusqueda => {
            class      => 'HistorialBusqueda',
            column_map => { idBusqueda => 'idBusqueda' },
            type       => 'one to many',
        },
    ],
);

1;

