package C4::Modelo::RefDptosPartido::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::RefDptosPartido;

sub object_class { 'C4::Modelo::RefDptosPartido' }

__PACKAGE__->make_manager_methods('ref_dptos_partidos');

1;

