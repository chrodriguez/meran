package C4::Modelo::Reserve::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Reserve;

sub object_class { 'C4::Modelo::Reserve' }

__PACKAGE__->make_manager_methods('reserves');

1;

