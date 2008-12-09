package InformacionReferencia;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'informacion_referencias',

    columns => [
        idinforef  => { type => 'integer', not_null => 1 },
        idestcat   => { type => 'integer', default => '', not_null => 1 },
        referencia => { type => 'varchar', default => '', length => 255, not_null => 1 },
        orden      => { type => 'varchar', default => '', length => 255, not_null => 1 },
        campos     => { type => 'varchar', default => '', length => 255, not_null => 1 },
        separador  => { type => 'varchar', length => 3 },
    ],

    primary_key_columns => [ 'idinforef' ],
);

1;

