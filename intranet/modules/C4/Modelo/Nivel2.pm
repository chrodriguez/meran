package C4::Modelo::Nivel2;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'nivel2',

    columns => [
        id2                 => { type => 'serial', not_null => 1 },
        id1                 => { type => 'integer', not_null => 1 },
        tipo_documento      => { type => 'varchar', length => 4, not_null => 1 },
        nivel_bibliografico => { type => 'varchar', length => 2, not_null => 1 },
        soporte             => { type => 'varchar', length => 3, not_null => 1 },
        pais_publicacion    => { type => 'character', length => 2, not_null => 1 },
        lenguaje            => { type => 'character', length => 2, not_null => 1 },
        ciudad_publicacion  => { type => 'varchar', length => 20, not_null => 1 },
        anio_publicacion    => { type => 'varchar', length => 15 },
        timestamp           => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id2' ],

    relationships => [
        nivel2_repetibles => {
            class      => 'C4::Modelo::Nivel2Repetible',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },
    ],
);

1;

