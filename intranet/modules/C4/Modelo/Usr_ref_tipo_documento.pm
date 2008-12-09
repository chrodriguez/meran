package Usr_ref_tipo_documento;

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
    table => 'usr_ref_tipo_documento',
    auto  => 1,
  );


sub getId_tipo_documento{
    my ($self) = shift;
    return ($self->id_tipo_documento);
}

sub setId_tipo_documento{
    my ($self) = shift;
    my ($id_tipo_documento) = @_;
    $self->id_tipo_documento($id_tipo_documento);
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

sub getDescripcion{
    my ($self) = shift;
    return ($self->descripcion);
}

sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
}

1;
