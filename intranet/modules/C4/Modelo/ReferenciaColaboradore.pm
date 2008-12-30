package C4::Modelo::ReferenciaColaboradore;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'referenciaColaboradores',

    columns => [
        descripcion => { type => 'varchar', length => 35, not_null => 1 },
        codigo      => { type => 'varchar', default => '', length => 8, not_null => 1 },
        index       => { type => 'serial', not_null => 1 },
    ],

    primary_key_columns => [ 'index' ],
);

1;

