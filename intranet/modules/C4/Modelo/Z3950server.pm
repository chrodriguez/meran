package C4::Modelo::Z3950server;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'z3950servers',

    columns => [
        host     => { type => 'varchar', length => 255 },
        port     => { type => 'integer' },
        db       => { type => 'varchar', alias => 'db_col', length => 255 },
        userid   => { type => 'varchar', length => 255 },
        password => { type => 'varchar', length => 255 },
        name     => { type => 'text', length => 65535 },
        id       => { type => 'serial', not_null => 1 },
        checked  => { type => 'integer' },
        rank     => { type => 'integer' },
        syntax   => { type => 'varchar', length => 80 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

