package C4::Modelo::AdqProveedorTipoMaterial;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor_tipo_material',

    columns => [
        proveedor_id        => { type => 'integer', length => 11, not_null => 1},
        tipo_material_id    => { type => 'integer', length => 11, not_null => 1},
    ],

    primary_key_columns => [ 'proveedor_id', 'tipo_material_id' ],

);

# *************************************************FIN FUNCIONES DEL MODELO | MONEDA************************************************************

# Agrega un tipo de material a un proveedor
# parametros: id_proveedor, id_tipo_material
sub agregarMaterialProveedor{
    my ($self) = shift;
    my ($data) = @_;

    $self->setProveedorId($data->{'id_proveedor'});
    $self->setMaterialId($data->{'id_material'});

    $self->save();
    
         C4::AR::Debug::debug("entro");
}



# ************************************************************Getter y Setter*******************************************************************

sub setProveedorId{
    my ($self) = shift;
    my ($id_proveedor) = @_;
    $self->proveedor_id($id_proveedor);
}

sub setMaterialId{
    my ($self) = shift;
    my ($id_material) = @_;
    $self->tipo_material_id($id_material);
}




#sub getNombre{
#    my ($self) = shift;
#    return ($self->nombre);
#    
#}




1;
