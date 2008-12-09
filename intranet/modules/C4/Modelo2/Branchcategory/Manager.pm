package Branchcategory::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Branchcategory;

sub object_class { 'Branchcategory' }

__PACKAGE__->make_manager_methods('branchcategories');

1;

