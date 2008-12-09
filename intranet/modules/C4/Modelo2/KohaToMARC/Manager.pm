package KohaToMARC::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use KohaToMARC;

sub object_class { 'KohaToMARC' }

__PACKAGE__->make_manager_methods('kohaToMARC');

1;

