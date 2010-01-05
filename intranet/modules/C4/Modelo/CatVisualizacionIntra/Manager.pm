package C4::Modelo::CatVisualizacionIntra::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatVisualizacionIntra;

sub object_class { 'C4::Modelo::CatVisualizacionIntra' }

__PACKAGE__->make_manager_methods('cat_visualizacion_intra');

1;

