package C4::Modelo::CatNivel2::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel2;

sub object_class { 'C4::Modelo::CatNivel2' }

__PACKAGE__->make_manager_methods('cat_nivel2');

1;

