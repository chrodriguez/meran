package UsrRefTipoDocumento::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use UsrRefTipoDocumento;

sub object_class { 'UsrRefTipoDocumento' }

__PACKAGE__->make_manager_methods('usr_ref_tipo_documento');

1;

