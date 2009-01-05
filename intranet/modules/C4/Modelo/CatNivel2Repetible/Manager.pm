package C4::Modelo::CatNivel2Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel2Repetible;

sub object_class { 'C4::Modelo::CatNivel2Repetible' }

__PACKAGE__->make_manager_methods('cat_nivel2_repetible');

1;

