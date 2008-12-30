package C4::Modelo::TablasDeReferenciasInfo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::TablasDeReferenciasInfo;

sub object_class { 'C4::Modelo::TablasDeReferenciasInfo' }

__PACKAGE__->make_manager_methods('tablasDeReferenciasInfo');

1;

