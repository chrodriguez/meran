package Bookshelf;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'bookshelf',

    columns => [
        shelfnumber => { type => 'integer', not_null => 1 },
        shelfname   => { type => 'varchar', length => 255 },
        type        => { type => 'text', default => '', length => 65535, not_null => 1 },
        parent      => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'shelfnumber' ],
);

1;

