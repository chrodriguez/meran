package InformacionReferencia::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use InformacionReferencia;

sub object_class { 'InformacionReferencia' }

__PACKAGE__->make_manager_methods('informacion_referencias');

1;

