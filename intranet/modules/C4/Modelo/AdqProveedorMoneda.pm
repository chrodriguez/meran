package C4::Modelo::AdqProveedorMoneda;

use strict;
use utf8;
# use DBI;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor_moneda',

    columns => [
        proveedor_id   => { type => 'integer', length => 11, not_null => 1 },
        moneda_id  => { type => 'integer', length => 11, not_null => 1},
    ],

    relationships =>
        [
          moneda_ref => 
          {
            class       => 'C4::Modelo::RefAdqMoneda',
            key_columns => { moneda_id => 'id' },
            type        => 'one to one',
          },
          proveedor_ref => 
          {
            class       => 'C4::Modelo::AdqProveedor',
            key_columns => { proveedor_id => 'id' },
            type        => 'one to one',
          },
      ],


    primary_key_columns => [ 'proveedor_id' ,'moneda_id'],

);


# ************************************************************** FUNCIONES *******************************************************************

# Agrega una moneda a un proveedor
# parametros: id_proveedor, id_moneda
sub agregarMonedaProveedor{
    
    my ($self) = shift;
    my ($data) = @_;

    C4::AR::Debug::debug("id prov : ".$data->{'id_proveedor'});

    $self->setProveedorId($data->{'id_proveedor'});
    $self->setMonedaId($data->{'id_moneda'});

    $self->save();

}

# *********************************************************** FIN - FUNCIONES *****************************************************************



# *********************************************************************************Getter y Setter*******************************************************************

sub setProveedorId{
    my ($self) = shift;
    my ($id_proveedor) = @_;
    $self->proveedor_id($id_proveedor);
}

sub setMonedaId{
    my ($self) = shift;
    my ($id_moneda) = @_;
    $self->moneda_id($id_moneda);
}

# ******************************************************************************FIN Getter y Setter*******************************************************************


1;