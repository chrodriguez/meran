package C4::Modelo::EstructuraCatalogacionOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::EstructuraCatalogacionOpac;

sub object_class { 'C4::Modelo::EstructuraCatalogacionOpac' }

__PACKAGE__->make_manager_methods('estructura_catalogacion_opac');

1;

