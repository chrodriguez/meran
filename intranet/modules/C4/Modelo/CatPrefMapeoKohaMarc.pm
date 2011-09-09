package C4::Modelo::CatPrefMapeoKohaMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_pref_mapeo_koha_marc',

    columns => [
        idmap      => { type => 'serial', not_null => 1 },
        tabla      => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        campoTabla => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        nombre     => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        campo      => { type => 'varchar', overflow => 'truncate', length => 3, not_null => 1 },
        subcampo   => { type => 'varchar', overflow => 'truncate', length => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'idmap' ],
);

sub getId_map{
    my ($self) = shift;
    return ($self->idmap);
}

sub setId_map{
    my ($self) = shift;
    my ($idmap) = @_;
    $self->idmap($idmap);
}

sub getTabla{
    my ($self) = shift;
    return ($self->tabla);
}

sub setTabla{
    my ($self) = shift;
    my ($tabla) = @_;
    $self->tabla($tabla);
}

sub getCampoTabla{
    my ($self) = shift;
    return ($self->campoTabla);
}

sub setCampoTabla{
    my ($self) = shift;
    my ($campoTabla) = @_;
    $self->campoTabla($campoTabla);
}

sub getCampo{
    my ($self) = shift;
    return ($self->campo);
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getSubCampo{
    my ($self) = shift;
    return ($self->subcampo);
}

sub setSubCampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}

1;

