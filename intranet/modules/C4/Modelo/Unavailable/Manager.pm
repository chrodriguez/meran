package C4::Modelo::Unavailable::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Unavailable;

sub object_class { 'C4::Modelo::Unavailable' }

__PACKAGE__->make_manager_methods('unavailable');

1;

