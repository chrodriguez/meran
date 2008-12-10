package Nivel3;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'nivel3',

    columns => [
        id3                   => { type => 'integer', not_null => 1 },
        id1                   => { type => 'integer', default => '', not_null => 1 },
        timestamp             => { type => 'timestamp', not_null => 1 },
        id2                   => { type => 'integer', default => '', not_null => 1 },
        barcode               => { type => 'varchar', length => 20 },
        signatura_topografica => { type => 'varchar', length => 30 },
        holdingbranch         => { type => 'varchar', length => 15 },
        homebranch            => { type => 'varchar', length => 15 },
        wthdrawn              => { type => 'integer', default => '0', not_null => 1 },
        notforloan            => { type => 'character', default => '0', length => 2 },
    ],

    primary_key_columns => [ 'id3' ],

    relationships => [
        nivel3_repetibles => {
            class      => 'Nivel3Repetible',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },

        reserves => {
            class      => 'Reserve',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },
    ],
);

1;

