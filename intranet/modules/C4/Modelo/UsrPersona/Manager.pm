package UsrPersona::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use UsrPersona;

sub object_class { 'UsrPersona' }

__PACKAGE__->make_manager_methods('usr_persona');

1;

