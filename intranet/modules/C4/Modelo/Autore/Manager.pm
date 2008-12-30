package C4::Modelo::Autore::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Autore;

sub object_class { 'C4::Modelo::Autore' }

__PACKAGE__->make_manager_methods('autores');

1;

