package C4::Modelo::CatRefColaborador;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_ref_colaborador',

    columns => [
        descripcion => { type => 'varchar', overflow => 'truncate', length => 35, not_null => 1 },
        codigo      => { type => 'varchar', overflow => 'truncate', default => '', length => 8, not_null => 1 },
        index       => { type => 'serial', overflow => 'truncate', not_null => 1 },
    ],

    primary_key_columns => [ 'index' ],
);

1;

