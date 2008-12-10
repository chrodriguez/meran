package ControlTemasSeudonimo;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'control_temas_seudonimos',

    columns => [
        id  => { type => 'integer', not_null => 1 },
        id2 => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'id2' ],
);

1;

