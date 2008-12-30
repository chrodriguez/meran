package C4::Modelo::ControlAutoresSinonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::ControlAutoresSinonimo;

sub object_class { 'C4::Modelo::ControlAutoresSinonimo' }

__PACKAGE__->make_manager_methods('control_autores_sinonimos');

1;

