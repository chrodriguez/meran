package C4::Modelo::ControlEditorialesSeudonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::ControlEditorialesSeudonimo;

sub object_class { 'C4::Modelo::ControlEditorialesSeudonimo' }

__PACKAGE__->make_manager_methods('control_editoriales_seudonimos');

1;

