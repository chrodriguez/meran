package Systempreference::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Systempreference;

sub object_class { 'Systempreference' }

__PACKAGE__->make_manager_methods('systempreferences');

1;

