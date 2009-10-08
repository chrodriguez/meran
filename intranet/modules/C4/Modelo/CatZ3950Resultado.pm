package C4::Modelo::CatZ3950Resultado;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_z3950_resultado',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        servidor_id     => { type => 'serial', not_null => 1 },
        registros       => { type => 'text', default => 0},
        cant_registros  => { type => 'integer' },
        cola_id         => { type => 'serial', not_null => 1 },
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

sub getServidorId {
    my ($self) = shift;
    return ($self->servidor_id);
}

sub setServidorId {
    my ($self) = shift;
    my ($servidor_id) = @_;
    $self->servidor_id($servidor_id);
}

sub getColaId{
    my ($self) = shift;
    return ($self->cola_id);
}

sub setColaId{
    my ($self) = shift;
    my ($cola_id) = @_;
    $self->cola_id($cola_id);
}

sub getCantRegistros{
    my ($self) = shift;
    return ($self->cant_registros);
}

sub setCantRegistros{
    my ($self) = shift;
    my ($cant_registros) = @_;
    $self->cant_registros($cant_registros);
}

sub getRegistros{
    my ($self) = shift;
    return ($self->registros);
}

sub setRegistros{
    my ($self) = shift;
    my ($registros) = @_;
    $self->registros($registros);
}

sub getRegistrosMARC {
    my ($self) = shift;
    my @regs = split(/\n/,$self->registros);
    my @marcs;

    my $i=0;
    foreach my $raw (@regs){
       my $marc  = new_from_usmarc MARC::Record($raw);
       $marc->encoding( 'UTF-8' );
        
       push (@marcs,$marc);
       $i++;
    }
    return \@marcs;
}
1;

