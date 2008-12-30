package C4::Modelo::Bibliolevel::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Bibliolevel;

sub object_class { 'C4::Modelo::Bibliolevel' }

__PACKAGE__->make_manager_methods('bibliolevel');

1;

