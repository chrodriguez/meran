package C4::Modelo::Nivel1::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Nivel1;

sub object_class { 'C4::Modelo::Nivel1' }

__PACKAGE__->make_manager_methods('nivel1');

1;

