package C4::Modelo::AdqProveedorFormaEnvio;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;


use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor_forma_envio',

    columns => [

        adq_proveedor_id   => { type => 'integer', length => 11, not_null => 1 },
        adq_forma_envio_id  => { type => 'integer', length => 11, not_null => 1},
    ],

    relationships =>
        [
          forma_envio_ref => 
          {
            class       => 'C4::Modelo::AdqFormaEnvio',
            key_columns => { adq_forma_envio_id => 'id' },
            type        => 'one to one',
          },
          proveedor_ref => 
          {
            class       => 'C4::Modelo::AdqProveedor',
            key_columns => { adq_proveedor_id => 'id' },
            type        => 'one to one',
          },
      ],


    primary_key_columns => [ 'adq_proveedor_id' ,'adq_forma_envio_id'],

);

1;