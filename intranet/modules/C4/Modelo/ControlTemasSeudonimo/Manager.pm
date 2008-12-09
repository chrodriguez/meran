package ControlTemasSeudonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use ControlTemasSeudonimo;

sub object_class { 'ControlTemasSeudonimo' }

__PACKAGE__->make_manager_methods('control_temas_seudonimos');

1;

