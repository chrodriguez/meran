package Iso2709::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Iso2709;

sub object_class { 'Iso2709' }

__PACKAGE__->make_manager_methods('iso2709');

1;

