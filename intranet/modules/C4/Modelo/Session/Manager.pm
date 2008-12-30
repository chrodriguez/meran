package C4::Modelo::Session::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Session;

sub object_class { 'C4::Modelo::Session' }

__PACKAGE__->make_manager_methods('sessions');

1;

