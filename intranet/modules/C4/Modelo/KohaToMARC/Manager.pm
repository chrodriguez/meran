package C4::Modelo::KohaToMARC::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::KohaToMARC;

sub object_class { 'C4::Modelo::KohaToMARC' }

__PACKAGE__->make_manager_methods('kohaToMARC');

1;

