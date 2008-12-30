package C4::Modelo::Biblioanalysi::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Biblioanalysi;

sub object_class { 'C4::Modelo::Biblioanalysi' }

__PACKAGE__->make_manager_methods('biblioanalysis');

1;

