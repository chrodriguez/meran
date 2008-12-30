package C4::Modelo::Nivel2Repetible;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'nivel2_repetibles',

    columns => [
        rep_n2_id => { type => 'serial', not_null => 1 },
        id2       => { type => 'integer', not_null => 1 },
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', length => 3, not_null => 1 },
        dato      => { type => 'varchar', length => 250 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'rep_n2_id' ],

    foreign_keys => [
        nivel2 => {
            class       => 'C4::Modelo::Nivel2',
            key_columns => { id2 => 'id2' },
        },
    ],
);

1;

