package Bibliolevel;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'bibliolevel',

    columns => [
        code        => { type => 'varchar', length => 4, not_null => 1 },
        description => { type => 'varchar', default => '', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'code' ],
);

1;

