package C4::Modelo::CatEstante;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_estante',

    columns => [
        id        => { type => 'integer', not_null => 1 },
        estante   => { type => 'varchar', length => 255 },
        tipo      => { type => 'text', length => 65535, not_null => 1 },
        padre     => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);


sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub setId{
    my ($self) = shift;
    my ($id) = @_;
    $self->id($id);
}


1;

