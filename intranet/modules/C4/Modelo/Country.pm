package C4::Modelo::Country;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'countries',

    columns => [
        iso            => { type => 'character', length => 2, not_null => 1 },
        iso3           => { type => 'character', default => '', length => 3, not_null => 1 },
        name           => { type => 'varchar', default => '', length => 80, not_null => 1 },
        printable_name => { type => 'varchar', default => '', length => 80, not_null => 1 },
        code           => { type => 'varchar', default => '', length => 11, not_null => 1 },
    ],

    primary_key_columns => [ 'iso' ],
);

1;

