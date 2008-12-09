package Bookshelf::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Bookshelf;

sub object_class { 'Bookshelf' }

__PACKAGE__->make_manager_methods('bookshelf');

1;

