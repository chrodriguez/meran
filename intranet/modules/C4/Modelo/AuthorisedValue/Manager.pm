package C4::Modelo::AuthorisedValue::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::AuthorisedValue;

sub object_class { 'C4::Modelo::AuthorisedValue' }

__PACKAGE__->make_manager_methods('authorised_values');

1;

