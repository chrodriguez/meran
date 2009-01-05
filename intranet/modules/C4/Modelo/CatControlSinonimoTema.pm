package C4::Modelo::CatControlSinonimoTema;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_control_sinonimo_tema',

    columns => [
        id   => { type => 'serial', not_null => 1 },
        tema => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'tema' ],
);

1;

