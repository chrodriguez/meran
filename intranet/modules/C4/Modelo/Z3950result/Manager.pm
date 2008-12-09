package Z3950result::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Z3950result;

sub object_class { 'Z3950result' }

__PACKAGE__->make_manager_methods('z3950results');

1;

