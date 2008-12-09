package Uploadedmarc::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use Uploadedmarc;

sub object_class { 'Uploadedmarc' }

__PACKAGE__->make_manager_methods('uploadedmarc');

1;

