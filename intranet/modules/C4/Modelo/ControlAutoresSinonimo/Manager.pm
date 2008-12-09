package ControlAutoresSinonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use ControlAutoresSinonimo;

sub object_class { 'ControlAutoresSinonimo' }

__PACKAGE__->make_manager_methods('control_autores_sinonimos');

1;

