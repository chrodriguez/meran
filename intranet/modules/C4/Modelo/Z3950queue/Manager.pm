package Z3950queue::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Z3950queue;

sub object_class { 'Z3950queue' }

__PACKAGE__->make_manager_methods('z3950queue');

1;

