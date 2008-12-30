package C4::Modelo::MarcTagStructure;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'marc_tag_structure',

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

