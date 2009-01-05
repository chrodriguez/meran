package C4::Modelo::RefPai::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::RefPai;

sub object_class { 'C4::Modelo::RefPai' }

__PACKAGE__->make_manager_methods('ref_pais');

1;

