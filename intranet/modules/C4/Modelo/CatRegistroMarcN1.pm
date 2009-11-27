package C4::Modelo::CatRegistroMarcN1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n1',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        marc_record    => { type => 'text' },
    ],

    primary_key_columns => [ 'id' ],
);



1;

