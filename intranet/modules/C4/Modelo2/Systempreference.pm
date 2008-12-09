package Systempreference;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'systempreferences',

    columns => [
        variable    => { type => 'varchar', length => 50, not_null => 1 },
        value       => { type => 'text', length => 65535 },
        explanation => { type => 'varchar', default => '', length => 200, not_null => 1 },
        options     => { type => 'text', length => 65535 },
        type        => { type => 'varchar', length => 20 },
    ],

    primary_key_columns => [ 'variable' ],
);

1;

