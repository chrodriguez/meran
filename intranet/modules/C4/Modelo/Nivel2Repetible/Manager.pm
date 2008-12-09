package Nivel2Repetible::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Nivel2Repetible;

sub object_class { 'Nivel2Repetible' }

__PACKAGE__->make_manager_methods('nivel2_repetibles');

1;

