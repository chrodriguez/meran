package Ref_provincias;

# this class IS a "Usr_persona::DB::Object" 
# and contains all the methodes that 
# Usr_persona::DB::Object does
use base 'C4::Modelo::MeranDB::DB::Object';

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
    table => 'ref_provincias',
    auto  => 1,
  );


sub getNombre{
    my ($self) = shift;
    return ($self->NOMBRE);
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->NOMBRE($nombre);
}


sub getPais{
    my ($self) = shift;
    return ($self->PAIS);
}

sub setPais{
    my ($self) = shift;
    my ($pais) = @_;
    $self->PAIS($pais);
}

sub getProvincia{
    my ($self) = shift;
    return ($self->PROVINCIA);
}

sub setProvincia{
    my ($self) = shift;
    my ($provincia) = @_;
    $self->PROVINCIA($provincia);
}

1;
