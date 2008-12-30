package C4::Modelo::Iso2709::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Iso2709;

sub object_class { 'C4::Modelo::Iso2709' }

__PACKAGE__->make_manager_methods('iso2709');

1;

