package C4::Modelo::Reserve;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'reserves',

    columns => [
        id2              => { type => 'integer', not_null => 1 },
        id3              => { type => 'integer' },
        reservenumber    => { type => 'serial', not_null => 1 },
        borrowernumber   => { type => 'integer', default => '0', not_null => 1 },
        reservedate      => { type => 'date', default => '0000-00-00', not_null => 1 },
        biblioitemnumber => { type => 'integer', default => '0', not_null => 1 },
        estado           => { type => 'character', length => 1 },
        branchcode       => { type => 'varchar', length => 4 },
        notificationdate => { type => 'date' },
        reminderdate     => { type => 'date' },
        cancellationdate => { type => 'date' },
        reservenotes     => { type => 'text', length => 65535 },
        timestamp        => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'reservenumber' ],

    unique_key => [ 'borrowernumber', 'biblioitemnumber' ],

    foreign_keys => [
        nivel3 => {
            class       => 'C4::Modelo::Nivel3',
            key_columns => { id3 => 'id3' },
        },
    ],
);

1;

