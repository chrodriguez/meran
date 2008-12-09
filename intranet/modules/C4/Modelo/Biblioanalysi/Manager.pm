package Biblioanalysi::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Biblioanalysi;

sub object_class { 'Biblioanalysi' }

__PACKAGE__->make_manager_methods('biblioanalysis');

1;

