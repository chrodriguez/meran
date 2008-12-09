package Nivel1::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Nivel1;

sub object_class { 'Nivel1' }

__PACKAGE__->make_manager_methods('nivel1');

1;

