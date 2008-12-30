package C4::Modelo::Nivel3Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Nivel3Repetible;

sub object_class { 'C4::Modelo::Nivel3Repetible' }

__PACKAGE__->make_manager_methods('nivel3_repetibles');

1;

