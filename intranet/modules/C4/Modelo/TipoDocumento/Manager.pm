package C4::Modelo::TipoDocumento::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::TipoDocumento;

sub object_class { 'C4::Modelo::TipoDocumento' }

__PACKAGE__->make_manager_methods('tipo_documento');

1;

