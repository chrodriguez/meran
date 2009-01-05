package C4::Modelo::CatNivel3Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel3Repetible;

sub object_class { 'C4::Modelo::CatNivel3Repetible' }

__PACKAGE__->make_manager_methods('cat_nivel3_repetible');

1;

