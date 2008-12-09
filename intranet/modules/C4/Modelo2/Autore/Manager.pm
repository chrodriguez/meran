package Autore::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Autore;

sub object_class { 'Autore' }

__PACKAGE__->make_manager_methods('autores');

1;

