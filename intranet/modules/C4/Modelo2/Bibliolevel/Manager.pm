package Bibliolevel::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Bibliolevel;

sub object_class { 'Bibliolevel' }

__PACKAGE__->make_manager_methods('bibliolevel');

1;

