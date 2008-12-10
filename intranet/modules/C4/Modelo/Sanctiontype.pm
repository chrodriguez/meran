package Sanctiontype;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'sanctiontypes',

    columns => [
        sanctiontypecode => { type => 'integer', not_null => 1 },
        categorycode     => { type => 'character', default => '', length => 2, not_null => 1 },
        issuecode        => { type => 'character', default => '', length => 2, not_null => 1 },
    ],

    primary_key_columns => [ 'sanctiontypecode' ],

    unique_key => [ 'categorycode', 'issuecode' ],
);

1;

