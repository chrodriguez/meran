package ControlTemasSinonimo;

use strict;
use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'control_temas_sinonimos',

    columns => [
        id   => { type => 'integer', not_null => 1 },
        tema => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'tema' ],
);

1;

