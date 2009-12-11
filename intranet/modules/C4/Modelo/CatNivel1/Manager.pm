package C4::Modelo::CatNivel1::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel1;

sub object_class { 'C4::Modelo::CatNivel1' }

__PACKAGE__->make_manager_methods('cat_nivel1');

1;

