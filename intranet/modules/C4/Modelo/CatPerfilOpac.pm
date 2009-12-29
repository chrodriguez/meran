package C4::Modelo::CatPerfilOpac;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_perfil_opac',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        nombre        => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

sub getNombre{
    my ($self)=shift;

    return $self->nombre;
}

sub setNombre{
    my ($self) = shift;
    my ($string) = @_;
    use utf8;
	utf8::encode($string);
    $self->nombre($string);
}

1;

