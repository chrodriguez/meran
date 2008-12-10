package Nivel1;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'nivel1',

    columns => [
        id1       => { type => 'integer', not_null => 1 },
        titulo    => { type => 'varchar', default => '', length => 100, not_null => 1 },
        timestamp => { type => 'timestamp' },
        autor     => { type => 'integer', default => '', not_null => 1 },
    ],

    primary_key_columns => [ 'id1' ],

    relationships => [
        historicCirculation => {
            class      => 'HistoricCirculation',
            column_map => { id1 => 'id1' },
            type       => 'one to many',
        },

        nivel1_repetibles => {
            class      => 'Nivel1Repetible',
            column_map => { id1 => 'id1' },
            type       => 'one to many',
        },
    ],
);

1;

