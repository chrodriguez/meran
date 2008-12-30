package C4::Modelo::HistorialBusqueda::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::HistorialBusqueda;

sub object_class { 'C4::Modelo::HistorialBusqueda' }

__PACKAGE__->make_manager_methods('historialBusqueda');

1;

