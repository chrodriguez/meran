package ControlAutoresSinonimo;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'control_autores_sinonimos',

    columns => [
        id    => { type => 'integer', not_null => 1 },
        autor => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'autor' ],
);

1;

