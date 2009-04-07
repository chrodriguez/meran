package C4::Modelo::CatDetalleDisponibilidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_detalle_disponibilidad',

    columns => [
      id_detalle_disponibilidad       => { type => 'serial', not_null => 1 },
      id3                             => { type => 'integer', length => 11, not_null => 1 },
      estado                          => { type => 'varchar', length => 30, not_null => 1 },
      timestamp                       => { type => 'timestamp', default => 'CURRENT_TIMESTAMP', not_null => 1 },
      estado                          => { type => 'varchar', length => 30, not_null => 1 },
      fecha                           => { type => 'varchar', length => 10, not_null => 1 },
      disponibilidad                  => { type => 'varchar', length => 15, not_null => 1 },
      id_ui                           => { type => 'varchar', length => 5, not_null => 1 },
      agregacion_temp                 => { type => 'varchar', length => 255 },
      anio_agregacion                 => { type => 'varchar', length => 255 },
      mes_agregacion                  => { type => 'varchar', length => 255 },

    ],

    primary_key_columns => [ 'id_detalle_disponibilidad' ],

   relationships =>
    [
      nivel3 => 
      {
        class       => 'C4::Modelo::CatNivel3',
        key_columns => { id3 => 'id3' },
        type        => 'one to one',
      },
   ],
);

1;

