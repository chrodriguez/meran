package C4::Modelo::UsrRefCategoriasSocio::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::UsrRefCategoriasSocio;

sub object_class { 'C4::Modelo::UsrRefCategoriasSocio' }

__PACKAGE__->make_manager_methods('usr_ref_categorias_socio');

1;

