package C4::Modelo::UsrEstado;

# this class IS a "Usr_persona::DB::Object" 
# and contains all the methodes that 
# Usr_persona::DB::Object does
use base qw(C4::Modelo::DB::Object::AutoBase2);

# call the methode My::DB::Object->meta->setup() to 
# announce the layout of our database table;

__PACKAGE__->meta->setup
  (
    table   => 'usr_estado',
    columns => [
        id_estado        => { type => 'serial', overflow => 'truncate', not_null => 1, length => 11 },
        nombre           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        fuente           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id_estado' ],
);

sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setFuente($data_hash->{'fuente'});
    $self->setCategoria($data_hash->{'categoria'});
    $self->save();
}

sub getId_estado{
    my ($self) = shift;
    return ($self->id_estado);
}

sub getNombre{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nombre));
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

sub getFuente{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->fuente));
}

sub setFuente{
    my ($self) = shift;
    my ($fuente) = @_;
    $self->fuente($fuente);
}

1;
