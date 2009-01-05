package C4::Modelo::Provincia::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Provincia;

sub object_class { 'C4::Modelo::Provincia' }

__PACKAGE__->make_manager_methods('provincias');

1;

