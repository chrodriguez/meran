package C4::Modelo::AdqItem::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::AdqItem;

sub object_class { 'C4::Modelo::AdqItem' }

__PACKAGE__->make_manager_methods('adq_item');

1;