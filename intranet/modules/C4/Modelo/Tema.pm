package C4::Modelo::Tema;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'temas',

    columns => [
        id     => { type => 'serial', not_null => 1 },
        nombre => { type => 'text', length => 65535, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

