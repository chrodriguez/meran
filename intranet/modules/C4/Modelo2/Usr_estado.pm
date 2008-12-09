package Usr_estado;

# this class IS a "Usr_persona::DB::Object" 
# and contains all the methodes that 
# Usr_persona::DB::Object does
use base 'MeranDB::DB::Object';

# call the methode My::DB::Object->meta->setup() to 
# announce the layout of our database table;
=item
__PACKAGE__->meta->setup
  (
    table   => 'products',
    columns =>
        [
            id    => { type => 'integer', not_null => 1 },
            name  => { type => 'varchar', length => 255, not_null => 1 },
            price => { type => 'decimal' },
        ],
    primary_key_columns => 'id',
    unique_key => 'name',
    relationships => [],
);
=cut


  __PACKAGE__->meta->setup
  (
    table => 'usr_estado',
    auto  => 1,
  );

sub getId_persona{
    my ($self) = shift;
    return ($self->id_persona);
}

sub setId_persona{
    my ($self) = shift;
    my ($id_persona) = @_;
    $self->id_persona($id_persona);
}

sub getRegular{
    my ($self) = shift;
    return ($self->regular);
}

sub setRegular{
    my ($self) = shift;
    my ($regular) = @_;
    $self->regular($regular);
}

sub getCategoria{
    my ($self) = shift;
    return ($self->categoria);
}

sub setCategoria{
    my ($self) = shift;
    my ($categoria) = @_;
    $self->categoria($categoria);
}

sub getFuente{
    my ($self) = shift;
    return ($self->fuente);
}

sub setFuente{
    my ($self) = shift;
    my ($fuente) = @_;
    $self->fuente($fuente);
}

1;
