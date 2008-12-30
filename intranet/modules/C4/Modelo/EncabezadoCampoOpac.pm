package C4::Modelo::EncabezadoCampoOpac;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'encabezado_campo_opac',

    columns => [
        idencabezado => { type => 'serial', not_null => 1 },
        nombre       => { type => 'varchar', length => 255, not_null => 1 },
        orden        => { type => 'integer', not_null => 1 },
        linea        => { type => 'integer', default => '0', not_null => 1 },
        nivel        => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'idencabezado' ],
);

1;

