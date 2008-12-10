package Sanctionissuetype;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'sanctionissuetypes',

    columns => [
        sanctiontypecode => { type => 'integer', not_null => 1 },
        issuecode        => { type => 'character', length => 2, not_null => 1 },
    ],

    primary_key_columns => [ 'sanctiontypecode', 'issuecode' ],
);

1;

