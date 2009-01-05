package C4::Modelo::CircSancion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'circ_sancion',

    columns => [
        sanctionnumber   => { type => 'serial', not_null => 1 },
        sanctiontypecode => { type => 'integer', default => '0' },
        reservenumber    => { type => 'integer' },
        borrowernumber   => { type => 'integer', default => '0', not_null => 1 },
        startdate        => { type => 'date', default => '0000-00-00', not_null => 1 },
        enddate          => { type => 'date', default => '0000-00-00', not_null => 1 },
        delaydays        => { type => 'integer', default => '0' },
        itemnumber       => { type => 'integer' },
    ],

    primary_key_columns => [ 'sanctionnumber' ],
);

1;

