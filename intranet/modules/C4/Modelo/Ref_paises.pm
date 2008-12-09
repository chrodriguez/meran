package Ref_paises;

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
    table => 'ref_paises',
    auto  => 1,
  );


sub getIso{
    my ($self) = shift;
    return ($self->iso);
}   

sub setIso{
    my ($self) = shift;
    my ($iso) = @_;
    $self->iso($iso);
}

sub getIso3{
    my ($self) = shift;
    return ($self->iso3);
}

sub setIso3{
    my ($self) = shift;
    my ($iso3) = @_;
    $self->iso3($iso3);
}


sub getNombreLargo{
    my ($self) = shift;
    return ($self->nombre_largo);
}

sub setNombreLargo{
    my ($self) = shift;
    my ($nombreLargo) = @_;
    $self->nombre_largo($nombreLargo);
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

sub getCodigo{
    my ($self) = shift;
    return ($self->codigo);
}

sub setCodigo{
    my ($self) = shift;
    my ($codigo) = @_;
    $self->codigo($codigo);
}
1;
