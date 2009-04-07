package C4::Modelo::CatDetalleDisponibilidad::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatDetalleDisponibilidad;

sub object_class { 'C4::Modelo::CatDetalleDisponibilidad' }

__PACKAGE__->make_manager_methods('cat_detalle_disponibilidad');

1;

