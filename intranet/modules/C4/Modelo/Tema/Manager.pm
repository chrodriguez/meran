package Tema::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Tema;

sub object_class { 'Tema' }

__PACKAGE__->make_manager_methods('temas');

1;

