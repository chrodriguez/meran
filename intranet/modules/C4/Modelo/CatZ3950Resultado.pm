package C4::Modelo::CatZ3950Resultado;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_z3950_resultado',

    columns => [
        id       => { type => 'serial', not_null => 1 },
        servidor_id  => { type => 'serial', not_null => 1 },
        resultado => { type => 'longblob'},
        registros   => { type => 'integer' },
        cola_id       => { type => 'serial', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    relationships => [
        cola => {
            class       => 'C4::Modelo::CatZ3950Cola',
            key_columns => { cola_id => 'id' },
        type        => 'one to one',
        },
        servidor => {
            class       => 'C4::Modelo::PrefServidorZ3950',
            key_columns => { servidor_id => 'id' },
        type        => 'one to one',
        },
    ],
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

sub getBusqueda{
    my ($self) = shift;
    return ($self->busqueda);
}

sub setBusqueda{
    my ($self) = shift;
    my ($busqueda) = @_;
    $self->busqueda($busqueda);
}

sub getTipo{
    my ($self) = shift;
    return ($self->tipo);
}

sub setTipo{
    my ($self) = shift;
    my ($tipo) = @_;
    $self->tipo($tipo);
}

sub getComienzo{
    my ($self) = shift;
    return ($self->comienzo);
}

sub setComienzo{
    my ($self) = shift;
    my ($comienzo) = @_;
    $self->comienzo($comienzo);
}

sub getFin{
    my ($self) = shift;
    return ($self->fin);
}

sub setFin{
    my ($self) = shift;
    my ($fin) = @_;
    $self->fin($fin);
}

sub getResultado{
    my ($self) = shift;
    return ($self->resultado);
}

sub setResultado{
    my ($self) = shift;
    my ($resultado) = @_;
    $self->resultado($resultado);
}

sub getRegistros{
    my ($self) = shift;
    return ($self->registros);
}

sub setRegistros{
    my ($self) = shift;
    my ($registros) = @_;
    $self->nombre($registros);
}

1;

