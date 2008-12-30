package C4::Modelo::Sanctionissuetype::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Sanctionissuetype;

sub object_class { 'C4::Modelo::Sanctionissuetype' }

__PACKAGE__->make_manager_methods('sanctionissuetypes');

1;

