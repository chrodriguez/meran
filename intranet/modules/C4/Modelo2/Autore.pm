package Autore;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'autores',

    columns => [
        id           => { type => 'integer', not_null => 1 },
        nombre       => { type => 'text', default => '', length => 65535, not_null => 1 },
        apellido     => { type => 'text', default => '', length => 65535, not_null => 1 },
        nacionalidad => { type => 'character', length => 3 },
        completo     => { type => 'text', default => '', length => 65535, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

