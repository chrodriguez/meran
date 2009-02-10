package C4::Modelo::RefIdioma;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_idioma',

    columns => [
        idLanguage   => { type => 'character',length => 2 ,not_null => 1 },
        description  => { type => 'varchar', length => 30, not_null => 1 },
    ],

    primary_key_columns => [ 'idLanguage' ],
);

sub nextMember{
    use C4::Modelo::RefPais;
    return(C4::Modelo::RefPais->new());
}

1;

