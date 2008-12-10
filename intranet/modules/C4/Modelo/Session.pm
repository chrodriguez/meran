package Session;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'sessions',

    columns => [
        sessionID => { type => 'varchar', length => 255, not_null => 1 },
        userid    => { type => 'varchar', length => 255 },
        ip        => { type => 'varchar', length => 16 },
        lasttime  => { type => 'integer' },
    ],

    primary_key_columns => [ 'sessionID' ],
);

1;

