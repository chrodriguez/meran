package RefDptosPartido;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'ref_dptos_partidos',

    columns => [
        DPTO_PARTIDO => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE       => { type => 'varchar', length => 60 },
        PROVINCIA    => { type => 'varchar', length => 11 },
        ESTADO       => { type => 'character', length => 1 },
    ],

    primary_key_columns => [ 'DPTO_PARTIDO' ],
);

1;

