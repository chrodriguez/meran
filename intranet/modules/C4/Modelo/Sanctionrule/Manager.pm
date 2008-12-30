package C4::Modelo::Sanctionrule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Sanctionrule;

sub object_class { 'C4::Modelo::Sanctionrule' }

__PACKAGE__->make_manager_methods('sanctionrules');

1;

