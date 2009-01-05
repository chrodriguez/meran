package C4::Modelo::PrefInformacionReferencia;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_informacion_referencia',

    columns => [
        idinforef  => { type => 'serial', not_null => 1 },
        idestcat   => { type => 'integer', not_null => 1 },
        referencia => { type => 'varchar', length => 255, not_null => 1 },
        orden      => { type => 'varchar', length => 255, not_null => 1 },
        campos     => { type => 'varchar', length => 255, not_null => 1 },
        separador  => { type => 'varchar', length => 3 },
    ],

    primary_key_columns => [ 'idinforef' ],
);

1;

