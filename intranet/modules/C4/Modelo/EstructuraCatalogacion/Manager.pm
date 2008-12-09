package EstructuraCatalogacion::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use EstructuraCatalogacion;

sub object_class { 'EstructuraCatalogacion' }

__PACKAGE__->make_manager_methods('estructura_catalogacion');

1;

