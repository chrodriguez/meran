package UsrSocio::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use UsrSocio;

sub object_class { 'UsrSocio' }

__PACKAGE__->make_manager_methods('usr_socios');

1;

