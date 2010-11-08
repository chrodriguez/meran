package C4::Modelo::AdqProveedorItem;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'ProveedorItem',

    columns => [
        id_proveedor   => { type => 'integer', not_null => 1 },
        id_item  => { type => 'integer', not_null => 1},
    ],
    
    relationships =>
    [
      item=> 
      {
        type        => 'one to one',
        key_columns => { id_item => 'id_item' },
        class       => 'C4::Modelo::Item', 
      },

      proveedor=> 
      {
        type        => 'one to one',
        key_columns => { id_proveedor => 'id_proveedor' },
        class       => 'C4::Modelo::Proveedor',    
      },
    ]
    primary_key_columns => [ 'id_proveedor', 'id_item' ],

);

1;



