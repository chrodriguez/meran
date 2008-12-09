package Session::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Session;

sub object_class { 'Session' }

__PACKAGE__->make_manager_methods('sessions');

1;

