package C4::Modelo::PrefValorAutorizado;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_valor_autorizado',

    columns => [
        id               => { type => 'serial', not_null => 1 },
        category         => { type => 'character', default => '', length => 40, not_null => 1 },
        authorised_value => { type => 'character', default => '', length => 80, not_null => 1 },
        lib              => { type => 'character', length => 80 },
    ],

    primary_key_columns => [ 'id' ],
);

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getCategory{
    my ($self) = shift;
    return ($self->category);
}

sub setCategory{
    my ($self) = shift;
    my ($category) = @_;
    $self->category($category);
}

sub getAuthorisedValue{
    my ($self) = shift;
    return ($self->authorised_value);
}

sub setAuthorisedValue{
    my ($self) = shift;
    my ($authorised_value) = @_;
    $self->authorised_value($authorised_value);
}

sub getLib{
    my ($self) = shift;
    return ($self->lib);
}

sub setLib{
    my ($self) = shift;
    my ($lib) = @_;
    $self->lib($lib);
}

sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setCategory($data_hash->{'category'});
    $self->setAuthorisedValue($data_hash->{'authorised_value'});
    $self->setLib($data_hash->{'lib'});
    $self->save();
}

1;

