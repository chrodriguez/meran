package HistoricCirculation;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'historicCirculation',

    columns => [
        id             => { type => 'integer', not_null => 1 },
        type           => { type => 'varchar', default => '', length => 15, not_null => 1 },
        borrowernumber => { type => 'integer', default => '0', not_null => 1 },
        responsable    => { type => 'varchar', default => '', length => 20, not_null => 1 },
        id1            => { type => 'integer', default => '0', not_null => 1 },
        id2            => { type => 'integer', default => '0', not_null => 1 },
        branchcode     => { type => 'varchar', length => 4 },
        timestamp      => { type => 'timestamp', not_null => 1 },
        id3            => { type => 'integer' },
        date           => { type => 'date', default => '0000-00-00', not_null => 1 },
        nota           => { type => 'varchar', length => 50 },
        end_date       => { type => 'date' },
        issuetype      => { type => 'varchar', length => 2 },
    ],

    primary_key_columns => [ 'id' ],

    foreign_keys => [
        nivel1 => {
            class       => 'Nivel1',
            key_columns => { id1 => 'id1' },
        },

        nivel2 => {
            class       => 'Nivel2',
            key_columns => { id2 => 'id2' },
        },
    ],
);

1;

