package C4::Modelo::CatVisualizacionIntra;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_visualizacion_intra',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        campo           => { type => 'character', length => 3, not_null => 1 },
        subcampo        => { type => 'character', length => 1, not_null => 1 },
        vista_intra     => { type => 'varchar', length => 255 },
        tipo_ejemplar   => { type => 'char', length => 3 },
        orden           => { type => 'integer', length => 11, not_null => 1 }
    ],

    primary_key_columns => [ 'id' ],
);
use utf8;

sub agregar{

    my ($self)=shift;
    my ($params) = @_;

    $self->setCampo($params->{'campo'});
    $self->setSubCampo($params->{'subcampo'});
    $self->setVistaIntra($params->{'liblibrarian'});
    $self->setTipoEjemplar($params->{'ejemplar'});
# C4::AR::Debug::debug("CatVisualizacionIntra => agregar => nivel => ".C4::AR::EstructuraCatalogacionBase::getNivelFromEstructuraBaseByCampo($params->{'campo'}));

    if(C4::AR::EstructuraCatalogacionBase::getNivelFromEstructuraBaseByCampoSubcampo($params->{'campo'}, $params->{'subcampo'}) <= 1){
        $self->setTipoEjemplar('ALL');
    }

    $self->save();
}

sub modificar{

    my ($self)=shift;
    my ($string) = @_;
    $string = Encode::decode_utf8($string);
    $self->setVistaIntra($string);

    $self->save();
}

sub setOrder{

    my ($self)=shift;
    my ($orden) = @_;

    $self->orden($orden);

    $self->save();
}

sub getVistaIntra{
    my ($self)=shift;

    return $self->vista_intra;
}

sub setVistaIntra{
    my ($self) = shift;
    my ($vista_intra) = @_;
    utf8::encode($vista_intra);
    $self->vista_intra($vista_intra);
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

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getOrden{
    my ($self)=shift;

    return $self->orden;
}

sub setOrden{
    my ($self) = shift;
    my ($orden) = @_;
    $self->orden($orden);
}

sub getTipoEjemplar{
    my ($self) = shift;

    return $self->tipo_ejemplar;
}

sub setTipoEjemplar{
    my ($self) = shift;
    my ($tipo_ejemplar) = @_;

    $self->tipo_ejemplar($tipo_ejemplar);
}

1;

