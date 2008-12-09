package HistoricCirculation::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use HistoricCirculation;

sub object_class { 'HistoricCirculation' }

__PACKAGE__->make_manager_methods('historicCirculation');

1;

