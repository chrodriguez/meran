package RefProvincia::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use RefProvincia;

sub object_class { 'RefProvincia' }

__PACKAGE__->make_manager_methods('ref_provincias');

1;

