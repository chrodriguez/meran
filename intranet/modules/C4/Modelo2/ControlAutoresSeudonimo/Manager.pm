package ControlAutoresSeudonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use ControlAutoresSeudonimo;

sub object_class { 'ControlAutoresSeudonimo' }

__PACKAGE__->make_manager_methods('control_autores_seudonimos');

1;

