package C4::Modelo::PrefEstructuraSubcampoMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_estructura_subcampo_marc',

    columns => [
        nivel              => { type => 'integer', default => '0', not_null => 1 },
        obligatorio        => { type => 'integer', default => '0', not_null => 1 },
        tagfield           => { type => 'character', length => 3, not_null => 1 },
        tagsubfield        => { type => 'character', length => 1, not_null => 1 },
        liblibrarian       => { type => 'character', length => 255, not_null => 1 },
        libopac            => { type => 'character', length => 255, not_null => 1 },
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

