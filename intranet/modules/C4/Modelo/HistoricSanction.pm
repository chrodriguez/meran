package HistoricSanction;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'historicSanctions',

    columns => [
        id               => { type => 'integer', not_null => 1 },
        type             => { type => 'varchar', default => '', length => 15, not_null => 1 },
        borrowernumber   => { type => 'integer', default => '0', not_null => 1 },
        responsable      => { type => 'varchar', default => '', length => 20, not_null => 1 },
        timestamp        => { type => 'timestamp', not_null => 1 },
        date             => { type => 'date', default => '0000-00-00', not_null => 1 },
        end_date         => { type => 'date' },
        sanctiontypecode => { type => 'integer', default => '0' },
    ],

    primary_key_columns => [ 'id' ],
);

1;

