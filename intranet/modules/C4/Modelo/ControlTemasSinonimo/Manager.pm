package C4::Modelo::ControlTemasSinonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::ControlTemasSinonimo;

sub object_class { 'C4::Modelo::ControlTemasSinonimo' }

__PACKAGE__->make_manager_methods('control_temas_sinonimos');

1;

