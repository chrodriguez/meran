package Nivel2::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Nivel2;

sub object_class { 'Nivel2' }

__PACKAGE__->make_manager_methods('nivel2');

1;

