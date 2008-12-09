package EncabezadoCampoOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use EncabezadoCampoOpac;

sub object_class { 'EncabezadoCampoOpac' }

__PACKAGE__->make_manager_methods('encabezado_campo_opac');

1;

