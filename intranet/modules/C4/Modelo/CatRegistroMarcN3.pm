package C4::Modelo::CatRegistroMarcN3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n3',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        marc_record     => { type => 'text' },
        id1             => { type => 'integer', not_null => 1 },
        id2             => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    relationships => [
        cat_registro_marc_n1  => {
            class       => 'C4::Modelo::CatRegistroMarcN1',
            key_columns => { id1 => 'id' },
            type        => 'one to one',
        },

        cat_registro_marc_n2  => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { id2 => 'id' },
            type        => 'one to one',
        },
    ],
);



1;

