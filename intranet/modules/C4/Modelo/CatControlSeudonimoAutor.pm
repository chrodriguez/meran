package C4::Modelo::CatControlSeudonimoAutor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_control_seudonimo_autor',

    columns => [
        id  => { type => 'integer', not_null => 1 },
        id2 => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'id2' ],
);

1;

