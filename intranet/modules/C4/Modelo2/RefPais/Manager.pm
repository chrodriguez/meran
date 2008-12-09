package RefPais::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use RefPais;

sub object_class { 'RefPais' }

__PACKAGE__->make_manager_methods('ref_paises');

1;

