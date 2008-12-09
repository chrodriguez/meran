package Sanctiontypesrule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Sanctiontypesrule;

sub object_class { 'Sanctiontypesrule' }

__PACKAGE__->make_manager_methods('sanctiontypesrules');

1;

