package C4::Modelo::CatControlSinonimoAutor;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_control_sinonimo_autor',

    columns => [
        id    => { type => 'integer', not_null => 1 },
        autor => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id', 'autor' ],
);


sub agregar{

    my ($self)=shift;
    my ($sinonimo,$id_autor)=@_;

    $self->setAutor($sinonimo);
    $self->setId($id_autor);

    $self->save();
}

sub getId{
    my ($self)=shift;
    return ($self->id);
}

sub setId{
    my ($self)=shift;
    my ($id) = @_;
    return ($self->id($id));
}

sub getAutor{
    my ($self)=shift;
    return ($self->autor);
}

sub setAutor{
    my ($self)=shift;
    my ($autor) = @_;
    return ($self->autor($autor));
}

1;

