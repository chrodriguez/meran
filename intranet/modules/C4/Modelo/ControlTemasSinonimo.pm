package C4::Modelo::ControlTemasSinonimo;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'control_temas_sinonimos',

    columns => [
        id   => { type => 'serial', not_null => 1 },
        tema => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'tema' ],
);

1;

