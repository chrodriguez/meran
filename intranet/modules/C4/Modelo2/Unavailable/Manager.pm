package Unavailable::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Unavailable;

sub object_class { 'Unavailable' }

__PACKAGE__->make_manager_methods('unavailable');

1;

