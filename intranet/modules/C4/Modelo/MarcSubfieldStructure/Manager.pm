package C4::Modelo::MarcSubfieldStructure::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::MarcSubfieldStructure;

sub object_class { 'C4::Modelo::MarcSubfieldStructure' }

__PACKAGE__->make_manager_methods('marc_subfield_structure');

1;

