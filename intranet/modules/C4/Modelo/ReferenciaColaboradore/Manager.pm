package ReferenciaColaboradore::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use ReferenciaColaboradore;

sub object_class { 'ReferenciaColaboradore' }

__PACKAGE__->make_manager_methods('referenciaColaboradores');

1;

