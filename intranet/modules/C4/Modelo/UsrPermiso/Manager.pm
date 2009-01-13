package C4::Modelo::UsrPermiso::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::UsrPermiso;

sub object_class { 'C4::Modelo::UsrPermiso' }

__PACKAGE__->make_manager_methods('usr_permiso');

1;

