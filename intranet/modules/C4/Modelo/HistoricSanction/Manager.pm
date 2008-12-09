package HistoricSanction::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use HistoricSanction;

sub object_class { 'HistoricSanction' }

__PACKAGE__->make_manager_methods('historicSanctions');

1;

