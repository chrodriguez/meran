package C4::Modelo::CatNivel1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel1',

    columns => [
        id1       => { type => 'serial', not_null => 1 },
        titulo    => { type => 'varchar', length => 100, not_null => 1 },
        autor     => { type => 'integer', not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id1' ],

);



sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;
    $self->setTitulo(data_hash->{'titulo'});
    $self->setAutor(data_hash->{'autor'});
    $self->save();
    if (data_hash->{'hayRepetibles'}){
        my $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new();
           $nivel1Repetible->agregar($data_hash);
    }

}
sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;
    my ($titulo) = @_;
    $self->titulo($titulo);
}

sub getAutor{
    my ($self) = shift;
    return ($self->autor);
}

sub setAutor{
    my ($self) = shift;
    my ($autor) = @_;
    $self->autor($autor);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}

1;

