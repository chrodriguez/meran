package C4::Modelo::Bibliolevel;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'bibliolevel',

    columns => [
        code        => { type => 'varchar', length => 4, not_null => 1 },
        description => { type => 'varchar', default => '', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'code' ],
);

1;

