package C4::Modelo::Localidade;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'localidades',

    columns => [
        LOCALIDAD        => { type => 'varchar', length => 11, not_null => 1 },
        NOMBRE           => { type => 'varchar', length => 100 },
        NOMBRE_ABREVIADO => { type => 'varchar', length => 40 },
        DPTO_PARTIDO     => { type => 'varchar', length => 11 },
        DDN              => { type => 'varchar', length => 11 },
    ],

    primary_key_columns => [ 'LOCALIDAD' ],
);

1;

