package C4::Modelo::PrefIso2709::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::PrefIso2709;

sub object_class { 'C4::Modelo::PrefIso2709' }

__PACKAGE__->make_manager_methods('pref_iso2709');

1;

