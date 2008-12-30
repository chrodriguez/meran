package C4::Modelo::Busqueda;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'busquedas',

    columns => [
        idBusqueda => { type => 'serial', not_null => 1 },
        borrower   => { type => 'integer' },
        fecha      => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'idBusqueda' ],
);

1;

