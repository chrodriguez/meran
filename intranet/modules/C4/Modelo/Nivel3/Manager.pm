package C4::Modelo::Nivel3::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Nivel3;

sub object_class { 'C4::Modelo::Nivel3' }

__PACKAGE__->make_manager_methods('nivel3');

1;

