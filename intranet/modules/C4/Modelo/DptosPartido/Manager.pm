package C4::Modelo::DptosPartido::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::DptosPartido;

sub object_class { 'C4::Modelo::DptosPartido' }

__PACKAGE__->make_manager_methods('dptos_partidos');

1;

