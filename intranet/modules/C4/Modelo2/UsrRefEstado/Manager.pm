package UsrRefEstado::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use UsrRefEstado;

sub object_class { 'UsrRefEstado' }

__PACKAGE__->make_manager_methods('usr_ref_estados');

1;

