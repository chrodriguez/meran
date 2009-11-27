package C4::Modelo::CatRegistroMarcN3::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatRegistroMarcN3;

sub object_class { 'C4::Modelo::CatRegistroMarcN3' }

__PACKAGE__->make_manager_methods('cat_registro_marc_n3');

1;

