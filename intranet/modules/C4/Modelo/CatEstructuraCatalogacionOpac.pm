package C4::Modelo::CatEstructuraCatalogacionOpac;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_estructura_catalogacion_opac',

    columns => [
        idestcatopac => { type => 'serial', not_null => 1 },
        campo        => { type => 'character', length => 3, not_null => 1 },
        subcampo     => { type => 'character', length => 1, not_null => 1 },
        textpred     => { type => 'varchar', length => 255 },
        textsucc     => { type => 'varchar', length => 255 },
        separador    => { type => 'varchar', length => 3 },
        idencabezado => { type => 'integer', not_null => 1 },
        visible      => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'idestcatopac' ],
);

1;

