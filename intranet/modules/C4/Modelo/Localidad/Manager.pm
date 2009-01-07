package C4::Modelo::Localidad::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo.:Localidad;

sub object_class { 'C4::Modelo::Localidad' }

__PACKAGE__->make_manager_methods('localidades');

1;

