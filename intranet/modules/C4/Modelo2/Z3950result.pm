package Z3950result;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'z3950results',

    columns => [
        id            => { type => 'integer', not_null => 1 },
        queryid       => { type => 'integer' },
        server        => { type => 'varchar', length => 255 },
        startdate     => { type => 'integer' },
        enddate       => { type => 'integer' },
        results       => { type => 'scalar', length => 4294967295 },
        numrecords    => { type => 'integer' },
        numdownloaded => { type => 'integer' },
        highestseen   => { type => 'integer' },
        active        => { type => 'integer' },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'queryid', 'server' ],
);

1;

