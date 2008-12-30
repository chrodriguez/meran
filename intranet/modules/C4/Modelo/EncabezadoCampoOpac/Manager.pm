package C4::Modelo::EncabezadoCampoOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::EncabezadoCampoOpac;

sub object_class { 'C4::Modelo::EncabezadoCampoOpac' }

__PACKAGE__->make_manager_methods('encabezado_campo_opac');

1;

