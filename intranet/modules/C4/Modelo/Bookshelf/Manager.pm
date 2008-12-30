package C4::Modelo::Bookshelf::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Bookshelf;

sub object_class { 'C4::Modelo::Bookshelf' }

__PACKAGE__->make_manager_methods('bookshelf');

1;

