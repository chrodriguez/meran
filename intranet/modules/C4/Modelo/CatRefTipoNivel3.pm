package C4::Modelo::CatRefTipoNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_ref_tipo_nivel3',

    columns => [
        id_tipo_doc           => { type => 'varchar', length => 4, not_null => 1 },
        nombre                => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id_tipo_doc' ],
);


sub getId_tipo_doc{
    my ($self) = shift;
    return ($self->id_tipo_doc);
}

sub setId_tipo_doc{
    my ($self) = shift;
    my ($id_tipo_doc) = @_;
    $self->id_tipo_doc($id_tipo_doc);
}

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

1;

