package C4::Modelo::Nivel1Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Nivel1Repetible;

sub object_class { 'C4::Modelo::Nivel1Repetible' }

__PACKAGE__->make_manager_methods('nivel1_repetibles');

1;

