package C4::Modelo::CatVisualizacionOpac;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_visualizacion_opac',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        campo        => { type => 'character', length => 3, not_null => 1 },
        subcampo     => { type => 'character', length => 1, not_null => 1 },
        vista_opac   => { type => 'varchar', length => 255 },
        id_perfil    => { type => 'integer', default => 1, not_null => 1 },
        orden        => { type => 'integer', length => 11, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

use utf8;
sub agregar{

    my ($self)=shift;
    my ($params) = @_;

    $self->setCampo($params->{'campo'});
    $self->setSubCampo($params->{'subcampo'});
    $self->setVistaOpac($params->{'liblibrarian'});
    $self->setIdPerfil($params->{'perfil'});    
    my $orden = C4::Modelo::CatVisualizacionOpac::Manager->get_max_orden() + 1;
    $self->setOrden($orden);


    $self->save();
}

sub modificar{

    my ($self)=shift;
    my ($string) = @_;
    $string = Encode::decode_utf8($string);
    $self->setVistaOpac($string);

    $self->save();
}

sub getVistaOpac{
    my ($self)=shift;

    return $self->vista_opac;
}

sub setVistaOpac{
    my ($self) = shift;
    my ($vista_opac) = @_;
    utf8::encode($vista_opac);
    $self->vista_opac($vista_opac);
}

sub getSubCampo{
    my ($self)=shift;

    return $self->subcampo;
}

sub setSubCampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}

sub getCampo{
    my ($self)=shift;

    return $self->campo;
}

sub getId{
    my ($self)=shift;

    return $self->id;
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getIdPerfil{
    my ($self)=shift;

    return $self->id_perfil;
}

sub setIdPerfil{
    my ($self) = shift;
    my ($id_perfil) = @_;
    $self->id_perfil($id_perfil);
}

sub getOrden{
    my ($self) = shift;

    return $self->orden;
}

sub setOrden{
    my ($self) = shift;
    my ($orden) = @_;
    $self->orden($orden);
    $self->save();
}

1;
