package C4::Modelo::CatNivel3Repetible;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3_repetible',

    columns => [
        rep_n3_id => { type => 'serial', not_null => 1 },
        id3       => { type => 'integer', not_null => 1 },
        campo     => { type => 'varchar', length => 3 },
        subcampo  => { type => 'varchar', length => 3, not_null => 1 },
        dato      => { type => 'varchar', length => 250, not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'rep_n3_id' ],

    foreign_keys => [
        cat_nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
        },
    ],
);

1;

