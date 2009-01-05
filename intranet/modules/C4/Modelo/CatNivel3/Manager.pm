package C4::Modelo::CatNivel3::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel3;

sub object_class { 'C4::Modelo::CatNivel3' }

__PACKAGE__->make_manager_methods('cat_nivel3');

1;

