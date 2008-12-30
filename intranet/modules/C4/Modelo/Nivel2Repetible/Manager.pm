package C4::Modelo::Nivel2Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Nivel2Repetible;

sub object_class { 'C4::Modelo::Nivel2Repetible' }

__PACKAGE__->make_manager_methods('nivel2_repetibles');

1;

