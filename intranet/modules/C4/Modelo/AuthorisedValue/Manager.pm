package AuthorisedValue::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'AuthorisedValue' }

__PACKAGE__->make_manager_methods('authorised_values');

1;

