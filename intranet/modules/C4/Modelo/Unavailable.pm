package C4::Modelo::Unavailable;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'unavailable',

    columns => [
        code        => { type => 'integer', not_null => 1 },
        description => { type => 'varchar', default => '', length => 30, not_null => 1 },
    ],

    primary_key_columns => [ 'code' ],
);

1;

