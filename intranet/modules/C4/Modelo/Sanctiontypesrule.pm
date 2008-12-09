package Sanctiontypesrule;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sanctiontypesrules',

    columns => [
        sanctiontypecode => { type => 'integer', not_null => 1 },
        sanctionrulecode => { type => 'integer', not_null => 1 },
        orden            => { type => 'integer', default => 1, not_null => 1 },
        amount           => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'sanctiontypecode', 'sanctionrulecode' ],
);

1;

