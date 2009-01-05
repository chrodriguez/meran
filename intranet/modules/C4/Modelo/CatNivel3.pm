package C4::Modelo::CatNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3',

    columns => [
        id3                   => { type => 'serial', not_null => 1 },
        id1                   => { type => 'integer', not_null => 1 },
        id2                   => { type => 'integer', not_null => 1 },
        barcode               => { type => 'varchar', length => 20 },
        signatura_topografica => { type => 'varchar', length => 30 },
        holdingbranch         => { type => 'varchar', length => 15 },
        homebranch            => { type => 'varchar', length => 15 },
        wthdrawn              => { type => 'integer', default => '0', not_null => 1 },
        notforloan            => { type => 'character', default => '0', length => 2 },
        timestamp             => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id3' ],

    relationships => [
        cat_nivel3_repetible => {
            class      => 'C4::Modelo::CatNivel3Repetible',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },

        circ_reserva => {
            class      => 'C4::Modelo::CircReserva',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },
    ],
);

1;

