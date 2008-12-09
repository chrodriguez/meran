package Sanctionissuetype::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Sanctionissuetype;

sub object_class { 'Sanctionissuetype' }

__PACKAGE__->make_manager_methods('sanctionissuetypes');

1;

