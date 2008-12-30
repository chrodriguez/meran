package C4::Modelo::HistoricCirculation::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::HistoricCirculation;

sub object_class { 'C4::Modelo::HistoricCirculation' }

__PACKAGE__->make_manager_methods('historicCirculation');

1;

