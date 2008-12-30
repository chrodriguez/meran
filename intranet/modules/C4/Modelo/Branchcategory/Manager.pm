package C4::Modelo::Branchcategory::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Branchcategory;

sub object_class { 'C4::Modelo::Branchcategory' }

__PACKAGE__->make_manager_methods('branchcategories');

1;

