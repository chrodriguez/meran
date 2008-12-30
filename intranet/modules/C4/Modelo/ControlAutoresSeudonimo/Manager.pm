package C4::Modelo::ControlAutoresSeudonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::ControlAutoresSeudonimo;

sub object_class { 'C4::Modelo::ControlAutoresSeudonimo' }

__PACKAGE__->make_manager_methods('control_autores_seudonimos');

1;

