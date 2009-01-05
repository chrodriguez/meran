package C4::Modelo::CatPrefMapeoKohaMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_pref_mapeo_koha_marc',

    columns => [
        idmap      => { type => 'serial', not_null => 1 },
        tabla      => { type => 'varchar', length => 100, not_null => 1 },
        campoTabla => { type => 'varchar', length => 100, not_null => 1 },
        nombre     => { type => 'varchar', length => 100, not_null => 1 },
        campo      => { type => 'varchar', length => 3, not_null => 1 },
        subcampo   => { type => 'varchar', length => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'idmap' ],
);

1;

