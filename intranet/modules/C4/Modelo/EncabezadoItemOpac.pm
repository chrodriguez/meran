package C4::Modelo::EncabezadoItemOpac;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'encabezado_item_opac',

    columns => [
        idencabezado => { type => 'integer', not_null => 1 },
        itemtype     => { type => 'varchar', length => 4, not_null => 1 },
    ],

    primary_key_columns => [ 'idencabezado', 'itemtype' ],
);

1;

