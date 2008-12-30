package C4::Modelo::MarcTagStructure::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::MarcTagStructure;

sub object_class { 'C4::Modelo::MarcTagStructure' }

__PACKAGE__->make_manager_methods('marc_tag_structure');

1;

