package Nivel3::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Nivel3;

sub object_class { 'Nivel3' }

__PACKAGE__->make_manager_methods('nivel3');

1;

