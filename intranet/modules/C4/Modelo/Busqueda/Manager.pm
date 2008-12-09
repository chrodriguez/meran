package Busqueda::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Busqueda;

sub object_class { 'Busqueda' }

__PACKAGE__->make_manager_methods('busquedas');

1;

