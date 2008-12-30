package C4::Modelo::Issuetype::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Issuetype;

sub object_class { 'C4::Modelo::Issuetype' }

__PACKAGE__->make_manager_methods('issuetypes');

1;

