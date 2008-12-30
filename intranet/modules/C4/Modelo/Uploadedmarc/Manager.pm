package C4::Modelo::Uploadedmarc::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Uploadedmarc;

sub object_class { 'C4::Modelo::Uploadedmarc' }

__PACKAGE__->make_manager_methods('uploadedmarc');

1;

