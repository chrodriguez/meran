package C4::Modelo::ReferenciaColaboradore::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::ReferenciaColaboradore;

sub object_class { 'C4::Modelo::ReferenciaColaboradore' }

__PACKAGE__->make_manager_methods('referenciaColaboradores');

1;

