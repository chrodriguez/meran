package C4::Modelo::PrefLdap::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::PrefLdap;

sub object_class { 'C4::Modelo::PrefLdap' }

__PACKAGE__->make_manager_methods('pref_ldap');

1;

