package C4::Modelo::Sanctiontype::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Sanctiontype;

sub object_class { 'C4::Modelo::Sanctiontype' }

__PACKAGE__->make_manager_methods('sanctiontypes');

1;

