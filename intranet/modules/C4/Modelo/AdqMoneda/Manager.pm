package C4::Modelo::AdqMoneda::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::AdqMoneda;

sub object_class { 'C4::Modelo::AdqMoneda' }

__PACKAGE__->make_manager_methods('adq_moneda');

1;