package Nivel1Repetible;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'nivel1_repetibles',

    columns => [
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', default => '', length => 3, not_null => 1 },
        id1       => { type => 'integer', default => '', not_null => 1 },
        dato      => { type => 'varchar', default => '', length => 250, not_null => 1 },
        timestamp => { type => 'timestamp' },
        rep_n1_id => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'rep_n1_id' ],

    foreign_keys => [
        nivel1 => {
            class       => 'Nivel1',
            key_columns => { id1 => 'id1' },
        },
    ],
);

1;

