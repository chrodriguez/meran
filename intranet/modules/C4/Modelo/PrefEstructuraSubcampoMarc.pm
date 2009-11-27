package C4::Modelo::PrefEstructuraSubcampoMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);


__PACKAGE__->meta->setup(
    table   => 'pref_estructura_subcampo_marc',

    columns => [
        nivel              => { type => 'integer', default => '0', not_null => 1 },
        obligatorio        => { type => 'integer', default => '0', not_null => 1 },
        campo              => { type => 'character', length => 3, not_null => 1 },
        subcampo           => { type => 'character', length => 1, not_null => 1 },
        liblibrarian       => { type => 'character', length => 255, not_null => 1 },
        libopac            => { type => 'character', length => 255, not_null => 1 },
        repetible          => { type => 'integer', default => '0', not_null => 1 },
        descripcion        => { type => 'character', length => 255, not_null => 1 },
        mandatory          => { type => 'integer', default => '0', not_null => 1 },
        kohafield          => { type => 'character', length => 40 },
    ],

    primary_key_columns => [ 'campo', 'subcampo' ],

    relationships =>
    [
      campoRef => 
      {
        class       => 'C4::Modelo::PrefEstructuraCampoMarc',
        key_columns => { campo => 'campo' },
        type        => 'one to one',
      },
    ]
);


sub getCampo{
    my ($self) = shift;

    return (C4::AR::Utilidades::trim($self->campo));
}

sub setCampo{
    my ($self) = shift;

    my ($campo) = @_;
    $self->campo($campo);
}

sub getSubcampo{
    my ($self) = shift;

    return (C4::AR::Utilidades::trim($self->subcampo));
}

sub setSubcampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}

sub getObligatorio{
    my ($self) = shift;
    return ($self->obligatorio);
}

sub setObligatorio{
    my ($self) = shift;
    my ($obligatorio) = @_;
    $self->obligatorio($obligatorio);
}

sub getLiblibrarian{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->liblibrarian));
}

sub setLiblibrarian{
    my ($self) = shift;
    my ($liblibrarian) = @_;
    $self->liblibrarian($liblibrarian);
}

sub getRepetible{
    my ($self) = shift;
    return ($self->repetible);
}

sub getDescripcion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->descripcion));
}

sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
}

1;

