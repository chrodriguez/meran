package Tema;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'temas',

    columns => [
        id     => { type => 'integer', not_null => 1 },
        nombre => { type => 'text', default => '', length => 65535, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

