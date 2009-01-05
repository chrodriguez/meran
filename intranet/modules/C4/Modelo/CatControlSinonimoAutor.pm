package C4::Modelo::CatControlSinonimoAutor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_control_sinonimo_autor',

    columns => [
        id    => { type => 'integer', not_null => 1 },
        autor => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'autor' ],
);

1;

