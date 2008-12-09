package ReferenciaColaboradore;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'referenciaColaboradores',

    columns => [
        descripcion => { type => 'varchar', default => '', length => 35, not_null => 1 },
        codigo      => { type => 'varchar', default => '', length => 8, not_null => 1 },
        index       => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'index' ],
);

1;

