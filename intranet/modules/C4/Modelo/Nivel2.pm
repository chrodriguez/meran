package Nivel2;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'nivel2',

    columns => [
        id2                 => { type => 'integer', not_null => 1 },
        tipo_documento      => { type => 'varchar', default => '', length => 4, not_null => 1 },
        timestamp           => { type => 'timestamp' },
        id1                 => { type => 'integer', default => '', not_null => 1 },
        nivel_bibliografico => { type => 'varchar', default => '', length => 2, not_null => 1 },
        soporte             => { type => 'varchar', default => '', length => 3, not_null => 1 },
        pais_publicacion    => { type => 'character', default => '', length => 2, not_null => 1 },
        lenguaje            => { type => 'character', default => '', length => 2, not_null => 1 },
        ciudad_publicacion  => { type => 'varchar', default => '', length => 20, not_null => 1 },
        anio_publicacion    => { type => 'varchar', length => 15 },
    ],

    primary_key_columns => [ 'id2' ],

    relationships => [
        historicCirculation => {
            class      => 'HistoricCirculation',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },

        nivel2_repetibles => {
            class      => 'Nivel2Repetible',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },

        reserves => {
            class      => 'Reserve',
            column_map => { id2 => 'id2' },
            type       => 'one to many',
        },
    ],
);

1;

