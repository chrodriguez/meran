package C4::Modelo::Provincia;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'provincias',

    columns => [
        PROVINCIA => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE    => { type => 'varchar', length => 60 },
        PAIS      => { type => 'varchar', default => '0', length => 11 },
    ],

    primary_key_columns => [ 'PROVINCIA' ],
);

1;

