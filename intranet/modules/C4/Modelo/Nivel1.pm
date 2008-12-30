package C4::Modelo::Nivel1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'nivel1',

    columns => [
        id1       => { type => 'serial', not_null => 1 },
        titulo    => { type => 'varchar', length => 100, not_null => 1 },
        autor     => { type => 'integer', not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id1' ],

    relationships => [
        nivel1_repetibles => {
            class      => 'C4::Modelo::Nivel1Repetible',
            column_map => { id1 => 'id1' },
            type       => 'one to many',
        },
    ],
);

1;

