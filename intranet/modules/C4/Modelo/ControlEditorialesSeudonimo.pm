package ControlEditorialesSeudonimo;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'control_editoriales_seudonimos',

    columns => [
        id  => { type => 'integer', not_null => 1 },
        id2 => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'id2' ],
);

1;

