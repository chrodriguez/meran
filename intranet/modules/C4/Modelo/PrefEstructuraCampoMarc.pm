package C4::Modelo::PrefEstructuraCampoMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_estructura_campo_marc',

    columns => [
        tagfield         => { type => 'character', length => 3, not_null => 1 },
        liblibrarian     => { type => 'character', length => 255, not_null => 1 },
        libopac          => { type => 'character', length => 255, not_null => 1 },
        repeatable       => { type => 'integer', default => '0', not_null => 1 },
        mandatory        => { type => 'integer', default => '0', not_null => 1 },
        authorised_value => { type => 'character', length => 10 },
    ],

    primary_key_columns => [ 'tagfield' ],
);

1;

