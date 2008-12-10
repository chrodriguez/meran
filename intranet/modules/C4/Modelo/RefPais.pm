package RefPais;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'ref_paises',

    columns => [
        iso          => { type => 'character', length => 2, not_null => 1 },
        iso3         => { type => 'character', default => '', length => 3, not_null => 1 },
        nombre       => { type => 'varchar', default => '', length => 80, not_null => 1 },
        nombre_largo => { type => 'varchar', default => '', length => 80, not_null => 1 },
        codigo       => { type => 'varchar', default => '', length => 11, not_null => 1 },
    ],

    primary_key_columns => [ 'iso' ],
);

1;

