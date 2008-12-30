package C4::Modelo::HistorialBusqueda;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'historialBusqueda',

    columns => [
        idHistorial => { type => 'serial', not_null => 1 },
        idBusqueda  => { type => 'integer', not_null => 1 },
        campo       => { type => 'varchar', length => 100, not_null => 1 },
        valor       => { type => 'varchar', length => 100, not_null => 1 },
        tipo        => { type => 'varchar', length => 10 },
    ],

    primary_key_columns => [ 'idHistorial' ],
);

1;

