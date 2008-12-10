package KohaToMARC;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'kohaToMARC',

    columns => [
        idmap      => { type => 'integer', not_null => 1 },
        tabla      => { type => 'varchar', default => '', length => 100, not_null => 1 },
        campoTabla => { type => 'varchar', default => '', length => 100, not_null => 1 },
        nombre     => { type => 'varchar', default => '', length => 100, not_null => 1 },
        campo      => { type => 'varchar', default => '', length => 3, not_null => 1 },
        subcampo   => { type => 'varchar', default => '', length => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'idmap' ],
);

1;

