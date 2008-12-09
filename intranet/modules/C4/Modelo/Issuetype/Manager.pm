package Issuetype::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Issuetype;

sub object_class { 'Issuetype' }

__PACKAGE__->make_manager_methods('issuetypes');

1;

