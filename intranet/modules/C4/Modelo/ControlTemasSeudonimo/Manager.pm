package C4::Modelo::ControlTemasSeudonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::ControlTemasSeudonimo;

sub object_class { 'C4::Modelo::ControlTemasSeudonimo' }

__PACKAGE__->make_manager_methods('control_temas_seudonimos');

1;

