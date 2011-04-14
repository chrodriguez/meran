package C4::Modelo::PrefAbout;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_about',

    columns => [
        id              => { type => 'int', length => 11, not_null => 1 },
        descripcion     => { type => 'text', length => 65535 },
    ],

    primary_key_columns => [ 'id' ],
);

1;
