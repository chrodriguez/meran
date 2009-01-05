package C4::Modelo::Uploadedmarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'uploadedmarc',

    columns => [
        id     => { type => 'serial', not_null => 1 },
        marc   => { type => 'scalar', length => 4294967295 },
        hidden => { type => 'integer' },
        name   => { type => 'varchar', length => 255 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

