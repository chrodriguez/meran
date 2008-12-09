package AuthorisedValue;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'authorised_values',

    columns => [
        id               => { type => 'integer', not_null => 1 },
        category         => { type => 'character', default => '', length => 10, not_null => 1 },
        authorised_value => { type => 'character', default => '', length => 80, not_null => 1 },
        lib              => { type => 'character', length => 80 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

