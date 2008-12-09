package Ref_dptos_partidos;

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
    table => 'ref_dptos_partidos',
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

sub getProvincia{
    my ($self) = shift;
    return ($self->PROVINCIA);
}

sub setProvincia{
    my ($self) = shift;
    my ($provincia) = @_;
    $self->PROVINCIA($provincia);
}

sub getEstado{
    my ($self) = shift;
    return ($self->ESTADO);
}

sub setEstado{
    my ($self) = shift;
    my ($estado) = @_;
    $self->ESTADO($estado);
}

sub getDpto_partido{
    my ($self) = shift;
    return ($self->DPTO_PARTIDO);
}

sub setDpto_partido{
    my ($self) = shift;
    my ($dpto_partido) = @_;
    $self->DPTO_PARTIDO($dpto_partido);
}
1;
