package Sanctionrule;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sanctionrules',

    columns => [
        sanctionrulecode => { type => 'integer', not_null => 1 },
        sanctiondays     => { type => 'integer', default => '0', not_null => 1 },
        delaydays        => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'sanctionrulecode' ],
);

1;

