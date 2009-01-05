package C4::Modelo::RefDptoPartido;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_dpto_partido',

    columns => [
        DPTO_PARTIDO => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE       => { type => 'varchar', length => 60 },
        PROVINCIA    => { type => 'varchar', length => 11 },
        ESTADO       => { type => 'character', length => 1 },
    ],

    primary_key_columns => [ 'DPTO_PARTIDO' ],
);

1;

