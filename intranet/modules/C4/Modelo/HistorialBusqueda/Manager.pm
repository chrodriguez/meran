package HistorialBusqueda::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use HistorialBusqueda;

sub object_class { 'HistorialBusqueda' }

__PACKAGE__->make_manager_methods('historialBusqueda');

1;

