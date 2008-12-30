package C4::Modelo::RefPais;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_paises',

    columns => [
        iso          => { type => 'character', length => 2, not_null => 1 },
        iso3         => { type => 'character', default => '', length => 3, not_null => 1 },
        nombre       => { type => 'varchar', length => 80, not_null => 1 },
        nombre_largo => { type => 'varchar', length => 80, not_null => 1 },
        codigo       => { type => 'varchar', length => 11, not_null => 1 },
    ],

    primary_key_columns => [ 'iso' ],
);

1;

