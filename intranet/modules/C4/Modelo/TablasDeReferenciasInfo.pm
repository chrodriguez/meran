package TablasDeReferenciasInfo;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'tablasDeReferenciasInfo',

    columns => [
        orden      => { type => 'varchar', default => '', length => 20, not_null => 1 },
        referencia => { type => 'varchar', length => 30, not_null => 1 },
        similares  => { type => 'varchar', default => '', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'referencia' ],
);

1;

