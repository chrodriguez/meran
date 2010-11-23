package C4::Modelo::AdqProveedorMoneda;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor_moneda',

    columns => [
        proveedor_id   => { type => 'integer', length => 11, not_null => 1 },
        moneda_id  => { type => 'integer', length => 11, not_null => 1},
    ],

    relationships =>
        [
          moneda_ref => 
          {
            class       => 'C4::Modelo::RefAdqMoneda',
            key_columns => { moneda_id => 'id' },
            type        => 'one to one',
          },
          proveedor_ref => 
          {
            class       => 'C4::Modelo::AdqProveedor',
            key_columns => { proveedor_id => 'id' },
            type        => 'one to one',
          },
      ],


    primary_key_columns => [ 'proveedor_id' ],
    primary_key_columns => [ 'moneda_id' ],

);

1;