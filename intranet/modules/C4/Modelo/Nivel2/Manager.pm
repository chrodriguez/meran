package C4::Modelo::Nivel2::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Nivel2;

sub object_class { 'C4::Modelo::Nivel2' }

__PACKAGE__->make_manager_methods('nivel2');

1;

