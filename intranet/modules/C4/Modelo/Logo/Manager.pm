package C4::Modelo::Logo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Logo;

sub object_class { 'C4::Modelo::Logo' }

__PACKAGE__->make_manager_methods('logo');

1;
