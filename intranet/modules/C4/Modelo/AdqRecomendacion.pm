package C4::Modelo::AdqRecomendacion;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use C4::Modelo::UsrSocio;
use C4::Modelo::RefEstadoPresupuesto;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_recomendacion',

    columns => [
        id                                  => { type => 'integer', not_null => 1 },
        usr_socio_id                        => { type => 'integer', not_null => 1},
        fecha                               => { type => 'varchar', length => 255, not_null => 1},
        activa                              => { type => 'integer', length => 4, not_null => 1},
        adq_ref_tipo_recomendacion_id       => { type => 'integer', not_null => 1},
    ],


    relationships =>
    [
      ref_usr_socio => 
      {
         class       => 'C4::Modelo::UsrSocio',
         key_columns => {usr_socio_id => 'id_socio' },
         type        => 'one to many',
       },
      
      adq_ref_tipo_recomendacion_id => 
      {
        class       => 'C4::Modelo::AdqRefTipoRecomendacion',
        key_columns => {adq_ref_tipo_recomendacion_id => 'id' },
        type        => 'one to many',
      },


    ],
    
    primary_key_columns => [ 'id' ],
    unique_key => ['id'],

);


sub agregarRecomendacion{
    my ($self) = shift;
    my ($params) = @_;


C4::AR::Debug::debug("------------------------------------------------------------------------------------");
C4::AR::Debug::debug("AgregarRecomendacion");


    $self->setFecha($params->{'fecha'});
    #$self->setActiva($params->{'activa'});
    $self->setUsrSocioId($params->{'usr_socio_id'});
    $self->setAdqRefTipoRecomendacionId($params->{'adq_ref_tipo_recomendacion_id'});
    $self->setActiva(1);

    $self->save();

C4::AR::Debug::debug("------------------------------------------------------------------------------------");
C4::AR::Debug::debug("Post Save");


}


#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setUsrSocioId{
    my ($self) = shift;
    my ($socio) = @_;
    utf8::encode($socio);
    $self->usr_socio_id($socio);
}

sub setFecha{
    my ($self) = shift;
    my ($fecha) = @_;
    $self->fecha($fecha);
}

sub setActiva{
    my ($self) = shift;
    my ($valor) = @_;
    $self->activa($valor);
}


sub setAdqRefTipoRecomendacionId{
    my ($self) = shift;
    my ($valor) = @_;
    utf8::encode($valor);
    $self->adq_ref_tipo_recomendacion_id($valor);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getFecha{
    my ($self) = shift;
    return ($self->fecha);
}

sub getActiva{
    my ($self) = shift;
    return ($self->activa);
}


sub getUsrSocioId{
    my ($self) = shift;
    return ($self->usr_socio_id);
}

sub getAdqRefTipoRecomendacionId{
    my ($self) = shift;
    return ($self->adq_ref_tipo_recomendacion_id);
}
