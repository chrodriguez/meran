package C4::Modelo::EstructuraCatalogacion::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::EstructuraCatalogacion;

sub object_class { 'C4::Modelo::EstructuraCatalogacion' }

__PACKAGE__->make_manager_methods('estructura_catalogacion');

1;

