package C4::Modelo::HistoricSanction;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'historicSanctions',

    columns => [
        id               => { type => 'serial', not_null => 1 },
        type             => { type => 'varchar', default => '', length => 15, not_null => 1 },
        borrowernumber   => { type => 'integer', default => '0', not_null => 1 },
        responsable      => { type => 'varchar', length => 20, not_null => 1 },
        timestamp        => { type => 'timestamp', not_null => 1 },
        date             => { type => 'date', default => '0000-00-00', not_null => 1 },
        end_date         => { type => 'date' },
        sanctiontypecode => { type => 'integer', default => '0' },
    ],

    primary_key_columns => [ 'id' ],
);

1;

