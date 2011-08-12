package C4::Modelo::SysMetodoAuth::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::SysMetodoAuth;

sub object_class { 'C4::Modelo::SysMetodoAuth' }

__PACKAGE__->make_manager_methods('sys_metodo_auth');

1;

