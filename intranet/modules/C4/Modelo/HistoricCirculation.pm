package C4::Modelo::HistoricCirculation;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'historicCirculation',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        id1            => { type => 'integer', not_null => 1 },
        id2            => { type => 'integer', not_null => 1 },
        id3            => { type => 'integer', not_null => 1 },
        type           => { type => 'varchar', default => '', length => 15, not_null => 1 },
        borrowernumber => { type => 'integer', default => '0', not_null => 1 },
        responsable    => { type => 'varchar', length => 20, not_null => 1 },
        branchcode     => { type => 'varchar', length => 4 },
        timestamp      => { type => 'timestamp', not_null => 1 },
        date           => { type => 'date', default => '0000-00-00', not_null => 1 },
        nota           => { type => 'varchar', length => 50 },
        end_date       => { type => 'date' },
        issuetype      => { type => 'character', length => 2 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

