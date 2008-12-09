package Reserve;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'reserves',

    columns => [
        id2              => { type => 'integer', default => '', not_null => 1 },
        id3              => { type => 'integer' },
        reservenumber    => { type => 'integer', not_null => 1 },
        borrowernumber   => { type => 'integer', default => '0', not_null => 1 },
        reservedate      => { type => 'date', default => '0000-00-00', not_null => 1 },
        estado           => { type => 'character', length => 1 },
        branchcode       => { type => 'varchar', length => 4 },
        notificationdate => { type => 'date' },
        reminderdate     => { type => 'date' },
        cancellationdate => { type => 'date' },
        reservenotes     => { type => 'text', length => 65535 },
        timestamp        => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'reservenumber' ],

    foreign_keys => [
        nivel2 => {
            class       => 'Nivel2',
            key_columns => { id2 => 'id2' },
        },

        nivel3 => {
            class       => 'Nivel3',
            key_columns => { id3 => 'id3' },
        },
    ],
);

1;

