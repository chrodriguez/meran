package C4::Modelo::EncabezadoItemOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::EncabezadoItemOpac;

sub object_class { 'C4::Modelo::EncabezadoItemOpac' }

__PACKAGE__->make_manager_methods('encabezado_item_opac');

1;

