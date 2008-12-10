package Unavailable;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'unavailable',

    columns => [
        code        => { type => 'integer', not_null => 1 },
        description => { type => 'varchar', default => '', length => 30, not_null => 1 },
    ],

    primary_key_columns => [ 'code' ],
);

1;

