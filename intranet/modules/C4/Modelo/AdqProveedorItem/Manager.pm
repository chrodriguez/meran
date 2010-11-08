package C4::Modelo::AdqProveedorItem::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::AdqProveedorItem;

sub object_class { 'C4::Modelo::AdqProveedorItem' }

__PACKAGE__->make_manager_methods('adq_proveedor_item');

1;