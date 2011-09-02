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
        orden           => { type => 'integer', length => 11, not_null => 1 },
        pre             => { type => 'varchar', length => 12 },
        post            => { type => 'varchar', length => 12 },
        nivel           => { type => 'integer', length => 1 },
        vista_campo     => { type => 'varchar', length => 255 },
        orden_subcampo  => { type => 'integer', length => 11, not_null => 1 }
    ],

    primary_key_columns => [ 'id' ],
);
use utf8;

sub agregar{

    my ($self)   = shift;
    my ($params) = @_;

    $self->setCampo($params->{'campo'});
    $self->setNivel($params->{'nivel'});
    $self->setPre($params->{'pre'});
    $self->setPost($params->{'post'});
    $self->setSubCampo($params->{'subcampo'});
    $self->setVistaIntra($params->{'liblibrarian'});

    if(C4::AR::EstructuraCatalogacionBase::getNivelFromEstructuraBaseByCampoSubcampo($params->{'campo'}, $params->{'subcampo'}) <= 1){
        $self->setTipoEjemplar('ALL');
    }else{
        $self->setTipoEjemplar($params->{'ejemplar'});
    }
    
    my $orden = C4::Modelo::CatVisualizacionIntra::Manager->get_max_orden() + 1;
    $self->setOrden($orden);

    $self->save();
}

sub modificar{

    my ($self)      = shift;
    my ($string)    = @_;
    $string         = Encode::decode_utf8($string);
    $self->setVistaIntra($string);

    $self->save();
}

sub modificarPre{

    my ($self)      = shift;
    my ($string)    = @_;
    $string         = Encode::decode_utf8($string);
    $self->setPre($string);

    $self->save();
}

sub modificarPost{

    my ($self)      = shift;
    my ($string)    = @_;
    $string         = Encode::decode_utf8($string);
    $self->setPost($string);

    $self->save();
}

sub modificarNivel{

    my ($self)      = shift;
    my ($string)    = @_;
    $self->setNivel($string);

    $self->save();
}


sub getVistaIntra{
    my ($self) = shift;

    return $self->vista_intra;
}

sub setVistaIntra{
    my ($self)          = shift;
    my ($vista_intra)   = @_;
    utf8::encode($vista_intra);
    $self->vista_intra($vista_intra);
}

sub getSubCampo{
    my ($self) = shift;

    return $self->subcampo;
}

sub setSubCampo{
    my ($self)      = shift;
    my ($subcampo)  = @_;
    $self->subcampo($subcampo);
}

sub getCampo{
    my ($self) = shift;

    return $self->campo;
}

sub setCampo{
    my ($self)  = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getVistaCampo{
    my ($self) = shift;

    return $self->vista_campo;
}

sub setVistaCampo{
    my ($self)          = shift;
    my ($vista_campo)   = @_;
    utf8::encode($vista_campo);
    $self->vista_campo($vista_campo);
    $self->save();
}

sub getPre{
    my ($self) = shift;

    return $self->pre;
}

sub setPre{
    my ($self)  = shift;
    my ($pre)   = @_;
    $self->pre($pre);
}

sub getPost{
    my ($self) = shift;

    return $self->post;
}

sub setPost{
    my ($self) = shift;
    my ($post) = @_;
    $self->post($post);
}

sub getNivel{
    my ($self) = shift;

    return $self->nivel;
}

sub setNivel{
    my ($self)  = shift;
    my ($nivel) = @_;
    $self->nivel($nivel);
}

sub getOrdenSubCampo{
    my ($self) = shift;

    return $self->orden_subcampo;
}

sub setOrdenSubCampo{
    my ($self)  = shift;
    my ($orden) = @_;
    $self->orden_subcampo($orden);
    $self->save();
}

sub getOrden{
    my ($self) = shift;

    return $self->orden;
}

sub getId{
    my ($self) = shift;

    return $self->id;
}

sub setOrden{
    my ($self)  = shift;
    my ($orden) = @_;
    $self->orden($orden);
    $self->save();
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

