package MarcSubfieldStructure::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use MarcSubfieldStructure;

sub object_class { 'MarcSubfieldStructure' }

__PACKAGE__->make_manager_methods('marc_subfield_structure');

1;

