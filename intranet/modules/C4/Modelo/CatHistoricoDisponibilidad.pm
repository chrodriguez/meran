package C4::Modelo::CatHistoricoDisponibilidad;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_historico_disponibilidad',

    columns => [
         id_detalle     => { type => 'serial', not_null => 1 },
         id3            => { type => 'integer', length => 11, not_null => 1 },
         detalle        => { type => 'varchar', length => 30, not_null => 1 },
         timestamp      => { type => 'timestamp',not_null => 1, default => 'CURRENT_TIMESTAMP' },
         fecha          => { type => 'varchar', length => 10, not_null => 1, default => '0000-00-00' },
         tipo_prestamo  => { type => 'varchar', length => 40, not_null => 1},
         id_ui          => {type => 'varchar', length => 5, not_null => 1},
         anio_agregacion=> {type => 'varchar', length => 255, not_null => 1},
         mes_agregacion => {type => 'varchar', length => 255, not_null => 1},
         agregacion_temp=> {type => 'varchar', length => 255, not_null => 1},
    ],

    primary_key_columns => ['id_detalle'],

    relationships => [
        nivel3 => {
            class       => 'C4::Modelo::CatNivel3',
            key_columns => { id3 => 'id3' },
            type        => 'one to one',
        },
   ],
);

1;

