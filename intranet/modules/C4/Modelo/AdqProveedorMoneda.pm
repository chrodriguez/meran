package C4::Modelo::AdqProveedorMoneda;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor_moneda',

    columns => [
        proveedor_id   => { type => 'integer', length => 11, not_null => 1 },
        moneda_id  => { type => 'integer', length => 255, not_null => 1 },
    ],

    relationships =>
    [ proveedor_ref => 
      {
        class       => 'C4::Modelo::AdqProveedor',
        key_columns => { proveedor_id => 'proveedor_id' },
        type        => 'one to one',
      },
      moneda_ref => 
      {
        class       => 'C4::Modelo::AdqMoneda',
        key_columns => { moneda_id => 'moneda_id' },
        type        => 'one to one',
      },
    ],
    
    primary_key_columns => [ 'proveedor_id', 'moneda_id' ],

);

# *************************************************************************FUNCIONES DEL MODELO | PROVEEDOR-MONEDA************************************************************

# Agrega una nueva moneda, 
# 		PARAMETROS: proveedor_id, moneda_id
sub agregarProveedorMoneda{

    my ($self) = shift;
    my ($params) = @_;

    $self->setProveedor($params->{'proveedor_id'});
    $self->setMoneda($params->{'moneda_id'});
    
    $self->save();
}

# **********************************************************************FIN FUNCIONES DEL MODELO | PROVEEDOR-MONEDA************************************************************





# *********************************************************************************Getter y Setter*******************************************************************

sub setProveedor{
    my ($self) = shift;
    my ($proveedor_id) = @_;
    $self->proveedor_id($proveedor_id);
}

sub setMoneda{
    my ($self) = shift;
    my ($moneda_id) = @_;
    $self->moneda_id($moneda_id);
}

sub getProveedor{
    my ($self) = shift;
    return ($self->proveedor_id);
}

sub getMoneda{
    my ($self) = shift;
    return ($self->moneda_id);
}

# ******************************************************************************FIN Getter y Setter*******************************************************************



1;