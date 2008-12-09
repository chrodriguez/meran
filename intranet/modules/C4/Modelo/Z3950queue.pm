package Z3950queue;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'z3950queue',

    columns => [
        id         => { type => 'integer', not_null => 1 },
        term       => { type => 'text', length => 65535 },
        type       => { type => 'varchar', length => 10 },
        startdate  => { type => 'integer' },
        enddate    => { type => 'integer' },
        done       => { type => 'integer' },
        results    => { type => 'scalar', length => 4294967295 },
        numrecords => { type => 'integer' },
        servers    => { type => 'text', length => 65535 },
        identifier => { type => 'varchar', length => 30 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

