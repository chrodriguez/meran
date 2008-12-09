package Sanction::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Sanction;

sub object_class { 'Sanction' }

__PACKAGE__->make_manager_methods('sanctions');

1;

