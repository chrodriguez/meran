package C4::Modelo::Busqueda::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Busqueda;

sub object_class { 'C4::Modelo::Busqueda' }

__PACKAGE__->make_manager_methods('busquedas');

1;

