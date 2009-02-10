package C4::Modelo::RefNivelBibliografico;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ref_nivel_bibliografico',

    columns => [
        code        => { type => 'varchar', length => 4, not_null => 1 },
        description => { type => 'varchar', default => '', length => 20, not_null => 1 },
    ],

    primary_key_columns => [ 'code' ],
);

sub nextMember{
    use C4::Modelo::CatTema;
    return(C4::Modelo::CatTema->new());
}

1;

