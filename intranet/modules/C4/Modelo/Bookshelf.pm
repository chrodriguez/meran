package C4::Modelo::Bookshelf;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'bookshelf',

    columns => [
        shelfnumber => { type => 'integer', not_null => 1 },
        shelfname   => { type => 'varchar', length => 255 },
        type        => { type => 'text', length => 65535, not_null => 1 },
        parent      => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'shelfnumber' ],
);

1;

