package C4::Modelo::CatVisualizacionOpac::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatVisualizacionOpac;

sub object_class { 'C4::Modelo::CatVisualizacionOpac' }

__PACKAGE__->make_manager_methods('cat_visualizacion_opac');

1;

