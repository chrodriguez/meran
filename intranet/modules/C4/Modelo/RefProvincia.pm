package RefProvincia;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'ref_provincias',

    columns => [
        PROVINCIA => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE    => { type => 'varchar', length => 60 },
        PAIS      => { type => 'varchar', default => '0', length => 11 },
    ],

    primary_key_columns => [ 'PROVINCIA' ],
);

1;

