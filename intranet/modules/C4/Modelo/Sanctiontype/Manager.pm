package Sanctiontype::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Sanctiontype;

sub object_class { 'Sanctiontype' }

__PACKAGE__->make_manager_methods('sanctiontypes');

1;

