package RefDptosPartido::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use RefDptosPartido;

sub object_class { 'RefDptosPartido' }

__PACKAGE__->make_manager_methods('ref_dptos_partidos');

1;

