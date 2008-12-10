package EncabezadoCampoOpac;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'encabezado_campo_opac',

    columns => [
        idencabezado => { type => 'integer', not_null => 1 },
        nombre       => { type => 'varchar', default => '', length => 255, not_null => 1 },
        orden        => { type => 'integer', default => '', not_null => 1 },
        linea        => { type => 'integer', default => '0', not_null => 1 },
        nivel        => { type => 'integer', default => '', not_null => 1 },
    ],

    primary_key_columns => [ 'idencabezado' ],
);

1;

