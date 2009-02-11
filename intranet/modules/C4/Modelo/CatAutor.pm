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
#     alias_column => ['id', 'campo'],
    primary_key_columns => [ 'id' ],
);

sub nextMember{
    use C4::Modelo::CatRefTipoNivel3;
    return(C4::Modelo::CatRefTipoNivel3->new());
}

sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo)=@_;
    use C4::Modelo::CatAutor::Manager;
    
# method_name('get')
# $self->meta->alias_column($campo => 'campo');

    my $ref_valores = C4::Modelo::CatAutor::Manager->get_cat_autor( 
                                                select   => [$self->meta->primary_key , $campo],
                                                sort_by => ($campo),
#                                                 limit => 10,
                                     );
# open(A, ">>/tmp/debug.txt");
# print A "restult: ".$ref_valores->[0]->campo."\n";
# close(A);
    return (scalar(@$ref_valores), $ref_valores);
}

1;

