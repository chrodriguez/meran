package Nivel3Repetible;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'nivel3_repetibles',

    columns => [
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', default => '', length => 3, not_null => 1 },
        id3       => { type => 'integer', default => '', not_null => 1 },
        dato      => { type => 'varchar', default => '', length => 250, not_null => 1 },
        timestamp => { type => 'timestamp' },
        rep_n3_id => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'rep_n3_id' ],

    foreign_keys => [
        nivel3 => {
            class       => 'Nivel3',
            key_columns => { id3 => 'id3' },
        },
    ],
);

1;

