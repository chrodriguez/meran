package C4::Modelo::Sanctionrule;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sanctionrules',

    columns => [
        sanctionrulecode => { type => 'serial', not_null => 1 },
        sanctiondays     => { type => 'integer', default => '0', not_null => 1 },
        delaydays        => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'sanctionrulecode' ],
);

1;

