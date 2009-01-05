package C4::Modelo::Localidade::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Localidade;

sub object_class { 'C4::Modelo::Localidade' }

__PACKAGE__->make_manager_methods('localidades');

1;

