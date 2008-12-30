package C4::Modelo::Tema::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Tema;

sub object_class { 'C4::Modelo::Tema' }

__PACKAGE__->make_manager_methods('temas');

1;

