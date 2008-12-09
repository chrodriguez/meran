package Sanction;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';


__PACKAGE__->meta->setup(
    table   => 'sanctions',

    columns => [
        sanctionnumber   => { type => 'integer', not_null => 1 },
        sanctiontypecode => { type => 'integer', default => '0' },
        reservenumber    => { type => 'integer' },
        borrowernumber   => { type => 'integer', default => '0', not_null => 1 },
        startdate        => { type => 'date', default => '0000-00-00' },
        enddate          => { type => 'date', default => '0000-00-00' },
        delaydays        => { type => 'integer', default => '0' },
        id3              => { type => 'integer' },
    ],

    primary_key_columns => [ 'sanctionnumber' ],
);

1;

