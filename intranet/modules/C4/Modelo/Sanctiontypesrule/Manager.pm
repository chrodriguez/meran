package C4::Modelo::Sanctiontypesrule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Sanctiontypesrule;

sub object_class { 'C4::Modelo::Sanctiontypesrule' }

__PACKAGE__->make_manager_methods('sanctiontypesrules');

1;

