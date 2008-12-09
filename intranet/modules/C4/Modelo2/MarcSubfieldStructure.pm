package MarcSubfieldStructure;

use strict;

use base qw(Rose::DB::Object::LoaderGenerated::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'marc_subfield_structure',

    columns => [
        nivel              => { type => 'integer', default => '0', not_null => 1 },
        obligatorio        => { type => 'integer', default => '0', not_null => 1 },
        tagfield           => { type => 'character', length => 3, not_null => 1 },
        tagsubfield        => { type => 'character', length => 1, not_null => 1 },
        liblibrarian       => { type => 'character', default => '', length => 255, not_null => 1 },
        libopac            => { type => 'character', default => '', length => 255, not_null => 1 },
        repeatable         => { type => 'integer', default => '0', not_null => 1 },
        mandatory          => { type => 'integer', default => '0', not_null => 1 },
        kohafield          => { type => 'character', length => 40 },
        tab                => { type => 'integer' },
        authorised_value   => { type => 'character', length => 13 },
        thesaurus_category => { type => 'character', length => 10 },
        value_builder      => { type => 'character', length => 80 },
    ],

    primary_key_columns => [ 'tagfield', 'tagsubfield' ],
);

1;

