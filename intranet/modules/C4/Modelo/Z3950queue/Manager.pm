package C4::Modelo::Z3950queue::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Z3950queue;

sub object_class { 'C4::Modelo::Z3950queue' }

__PACKAGE__->make_manager_methods('z3950queue');

1;

