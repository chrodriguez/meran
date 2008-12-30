package C4::Modelo::Nivel1Repetible;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'nivel1_repetibles',

    columns => [
        rep_n1_id => { type => 'serial', not_null => 1 },
        id1       => { type => 'integer', not_null => 1 },
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', length => 3, not_null => 1 },
        dato      => { type => 'varchar', length => 250, not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'rep_n1_id' ],

    foreign_keys => [
        nivel1 => {
            class       => 'C4::Modelo::Nivel1',
            key_columns => { id1 => 'id1' },
        },
    ],
);

1;

