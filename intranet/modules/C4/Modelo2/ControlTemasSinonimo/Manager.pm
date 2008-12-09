package ControlTemasSinonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use ControlTemasSinonimo;

sub object_class { 'ControlTemasSinonimo' }

__PACKAGE__->make_manager_methods('control_temas_sinonimos');

1;

