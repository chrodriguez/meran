package C4::Modelo::CatZ3950Cola;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_z3950_cola',

    columns => [
        id       => { type => 'serial', not_null => 1 },
        busqueda => { type => 'varchar', length => 255 },
        cola => { type => 'datetime' },
        comienzo => { type => 'datetime' },
        fin  => { type => 'datetime' },
    ],

    primary_key_columns => [ 'id' ],
    relationships => [
        resultados => {
            class       => 'C4::Modelo::CatZ3950Resultado',
            key_columns => {  id => 'cola_id' },
            type        => 'one to many',
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

sub getCola{
    my ($self) = shift;
    return ($self->cola);
}

sub setCola{
    my ($self) = shift;
    my ($cola) = @_;
    $self->cola($cola);
}

sub getCantResultados {
    my ($self) = shift;
    my $res=$self->resultados;
    return (scalar(@$res));
}

1;
