package C4::Modelo::SistSesion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'sist_sesion',

    columns => [
        sessionID => { type => 'varchar', length => 255, not_null => 1 },
        userid    => { type => 'varchar', length => 255 },
        ip        => { type => 'varchar', length => 16 },
        lasttime  => { type => 'integer' },
    ],

    primary_key_columns => [ 'sessionID' ],
);

1;

