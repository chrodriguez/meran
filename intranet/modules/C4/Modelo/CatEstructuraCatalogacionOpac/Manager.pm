package C4::Modelo::CatEstructuraCatalogacionOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatEstructuraCatalogacionOpac;

sub object_class { 'C4::Modelo::CatEstructuraCatalogacionOpac' }

__PACKAGE__->make_manager_methods('cat_estructura_catalogacion_opac');

1;

