package MarcTagStructure::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use MarcTagStructure;

sub object_class { 'MarcTagStructure' }

__PACKAGE__->make_manager_methods('marc_tag_structure');

1;

