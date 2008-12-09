package TablasDeReferenciasInfo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use TablasDeReferenciasInfo;

sub object_class { 'TablasDeReferenciasInfo' }

__PACKAGE__->make_manager_methods('tablasDeReferenciasInfo');

1;

