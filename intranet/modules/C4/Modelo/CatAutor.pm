package C4::Modelo::CatAutor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_autor',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        nombre       => { type => 'text', length => 65535, not_null => 1 },
        apellido     => { type => 'text', length => 65535, not_null => 1 },
        nacionalidad => { type => 'character', length => 3 },
        completo     => { type => 'text', length => 65535, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

sub getAlias{
    return ("autor");
}

sub lastTable{
    return (0);
}

sub nextMember{
    use C4::Modelo::CatTema;
    return(C4::Modelo::CatTema->new());
}

sub default{
    return (0);
}
1;

