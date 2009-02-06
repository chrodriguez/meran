package C4::Modelo::CatTema;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_tema',

    columns => [
        id     => { type => 'serial', not_null => 1 },
        nombre => { type => 'text', length => 65535, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);
sub getAlias(){
    return ("temas");
}

sub lastTable(){
    return (1);
}

sub nextMember(){

#     return(C4::Modelo::CatTema()->new());
}

sub default(){
    return (0);
}
1;

