package C4::Modelo::CatRegistroMarcN2Analitica;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n2_analitica',

    columns => [
        cat_registro_marc_n2_id             => { type => 'integer', not_null => 1 },
       	cat_registro_marc_n2_hijo_id        => { type => 'integer', not_null => 1 },
    ],

#     primary_key_columns => [ 'cat_registro_marc_n2_id', 'cat_registro_marc_n2_hijo_id' ],
    primary_key_columns => [ 'cat_registro_marc_n2_id' ],  

    relationships => [
        nivel2_hijo  => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { cat_registro_marc_n2_hijo_id => 'id' },
            type        => 'one to one',
        },
        nivel2_padre  => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { cat_registro_marc_n2_id => 'id' },
            type        => 'one to one',
        },

    ],
);


sub getId2Padre{
    my ($self)  = shift;

    return $self->cat_registro_marc_n2_id;
}

sub getId2Hijo{
    my ($self)  = shift;

    return $self->cat_registro_marc_n2_hijo_id;
}

sub setId2Padre{
    my ($self)  = shift;
    my ($id2)   = @_;

    $self->cat_registro_marc_n2_id($id2);
}

sub setId2Hijo{
    my ($self)  = shift;
    my ($id2)   = @_;

    $self->cat_registro_marc_n2_hijo_id($id2);
}



sub agregar{
    my ($self)      = shift;
    my ($id1,$marc_record)    = @_;

# TODO terminar

    $self->save();
}

sub modificar{
    my ($self)           = shift;
    my ($marc_record)    = @_;

# TODO terminar

    $self->save();
}

sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

# TODO terminar

# 
#     my ($nivel3) = C4::AR::Nivel3::getNivel3FromId2($self->getId2(), $self->db);
# 
#     foreach my $n3 (@$nivel3){
#       $n3->eliminar();
#     }

    $self->delete();    
}


1;
