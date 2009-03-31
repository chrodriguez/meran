package C4::Modelo::RepBusqueda;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_busqueda',

    columns => [
        idBusqueda => { type => 'serial', not_null => 1 },
        id_socio   => { type => 'integer' },
        fecha      => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'idBusqueda' ],
   
    relationships => [
         socio =>  {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { id_socio => 'id_socio' },
            type        => 'one to one',
      },
         
    ],
);

1;

