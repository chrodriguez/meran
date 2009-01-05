package C4::Modelo::PrefTablaReferenciaInfo;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia_info',

    columns => [
        orden      => { type => 'varchar', length => 20, not_null => 1 },
        referencia => { type => 'varchar', length => 30, not_null => 1 },
        similares  => { type => 'varchar', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'referencia' ],
);

1;

