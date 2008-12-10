package MarcTagStructure;

use strict;

use base 'C4::Modelo::MeranDB::DB::Object';

__PACKAGE__->meta->setup(
    table   => 'marc_tag_structure',

    columns => [
        tagfield         => { type => 'character', length => 3, not_null => 1 },
        liblibrarian     => { type => 'character', default => '', length => 255, not_null => 1 },
        libopac          => { type => 'character', default => '', length => 255, not_null => 1 },
        repeatable       => { type => 'integer', default => '0', not_null => 1 },
        mandatory        => { type => 'integer', default => '0', not_null => 1 },
        authorised_value => { type => 'character', length => 10 },
    ],

    primary_key_columns => [ 'tagfield' ],
);

1;

