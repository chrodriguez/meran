package C4::Modelo::HistoricSanction::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::HistoricSanction;

sub object_class { 'C4::Modelo::HistoricSanction' }

__PACKAGE__->make_manager_methods('historicSanctions');

1;

