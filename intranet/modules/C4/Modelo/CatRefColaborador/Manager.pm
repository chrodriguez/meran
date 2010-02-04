package C4::Modelo::CatRefColaborador::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatRefColaborador;

sub object_class { 'C4::Modelo::CatRefColaborador' }

__PACKAGE__->make_manager_methods('cat_ref_colaborador');

1;

