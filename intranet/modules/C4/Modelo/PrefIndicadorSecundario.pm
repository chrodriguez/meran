package C4::Modelo::PrefIndicadorSecundario;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_indicador_secundario',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        indicador       => { type => 'character', default => '', length => 255, not_null => 1 },
        dato            => { type => 'character', default => '', length => 255, not_null => 1 },
        campo_marc      => { type => 'character', default => '', length => 3, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    relationships => [
        ref_pref_estructura_campo_marc => {
            class      => 'C4::Modelo::PrefEstructuraCampoMarc',
            column_map => { campo_marc => 'campo' },
            type       => 'one to one',
        },
    ],

);




sub getCampo{
    my ($self) = shift;
    return ($self->campo_marc);
}

sub setCampo{
    my ($self) = shift;
    my ($campo_marc) = @_;
    $self->campo_marc($campo_marc);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getIndicador{
    my ($self) = shift;
    return ($self->indicador);
}

sub setIndicador{
    my ($self) = shift;
    my ($indicador) = @_;
    $self->indicador($indicador);
}

sub getDato{
    my ($self) = shift;
    return ($self->dato);
}

sub setDato{
    my ($self) = shift;
    my ($dato) = @_;
    $self->dato($dato);
}




1;

