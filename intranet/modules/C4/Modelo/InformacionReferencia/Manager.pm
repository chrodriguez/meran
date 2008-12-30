package C4::Modelo::InformacionReferencia::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::InformacionReferencia;

sub object_class { 'C4::Modelo::InformacionReferencia' }

__PACKAGE__->make_manager_methods('informacion_referencias');

1;

