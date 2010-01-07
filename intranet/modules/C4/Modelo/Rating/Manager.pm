package C4::Modelo::Rating::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::Rating;

sub object_class { 'C4::Modelo::Rating' }

__PACKAGE__->make_manager_methods('rating');

1;

