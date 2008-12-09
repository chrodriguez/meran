package ControlEditorialesSeudonimo::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use ControlEditorialesSeudonimo;

sub object_class { 'ControlEditorialesSeudonimo' }

__PACKAGE__->make_manager_methods('control_editoriales_seudonimos');

1;

