package Localidade::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Localidade;

sub object_class { 'Localidade' }

__PACKAGE__->make_manager_methods('localidades');

1;

