package Sanctionrule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Sanctionrule;

sub object_class { 'Sanctionrule' }

__PACKAGE__->make_manager_methods('sanctionrules');

1;

