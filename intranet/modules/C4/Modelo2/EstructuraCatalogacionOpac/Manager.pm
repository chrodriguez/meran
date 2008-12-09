package EstructuraCatalogacionOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use EstructuraCatalogacionOpac;

sub object_class { 'EstructuraCatalogacionOpac' }

__PACKAGE__->make_manager_methods('estructura_catalogacion_opac');

1;

