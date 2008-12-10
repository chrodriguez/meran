package Nivel2Repetible;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'nivel2_repetibles',

    columns => [
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', default => '', length => 3, not_null => 1 },
        id2       => { type => 'integer', default => '', not_null => 1 },
        dato      => { type => 'varchar', length => 250 },
        timestamp => { type => 'timestamp' },
        rep_n2_id => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'rep_n2_id' ],

    foreign_keys => [
        nivel2 => {
            class       => 'Nivel2',
            key_columns => { id2 => 'id2' },
        },
    ],
);

1;

