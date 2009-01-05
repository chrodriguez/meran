package C4::Modelo::CatNivel1Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel1Repetible;

sub object_class { 'C4::Modelo::CatNivel1Repetible' }

__PACKAGE__->make_manager_methods('cat_nivel1_repetible');

1;

