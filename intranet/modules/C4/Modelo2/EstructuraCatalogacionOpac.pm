package EstructuraCatalogacionOpac;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'estructura_catalogacion_opac',

    columns => [
        idestcatopac => { type => 'integer', not_null => 1 },
        campo        => { type => 'character', default => '', length => 3, not_null => 1 },
        subcampo     => { type => 'character', default => '', length => 1, not_null => 1 },
        textpred     => { type => 'varchar', length => 255 },
        textsucc     => { type => 'varchar', length => 255 },
        separador    => { type => 'varchar', length => 3 },
        idencabezado => { type => 'integer', default => '', not_null => 1 },
        visible      => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'idestcatopac' ],
);

1;

