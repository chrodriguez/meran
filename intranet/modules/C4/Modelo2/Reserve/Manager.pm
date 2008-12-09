package Reserve::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Reserve;

sub object_class { 'Reserve' }

__PACKAGE__->make_manager_methods('reserves');

1;

