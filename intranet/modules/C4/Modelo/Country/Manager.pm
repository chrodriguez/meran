package C4::Modelo::Country::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Country;

sub object_class { 'C4::Modelo::Country' }

__PACKAGE__->make_manager_methods('countries');

1;

