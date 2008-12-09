package EncabezadoItemOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use EncabezadoItemOpac;

sub object_class { 'EncabezadoItemOpac' }

__PACKAGE__->make_manager_methods('encabezado_item_opac');

1;

