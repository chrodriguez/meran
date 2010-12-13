package C4::Modelo::AdqPresupuestoDetalle;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use C4::Modelo::AdqPresupuesto;
use C4::Modelo::AdqRecomendacionDetalle;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_presupuesto_detalle',

    columns => [
        id                                 => { type => 'integer', not_null => 1 },
        adq_presupuesto_id                 => { type => 'integer', not_null => 1 },
        adq_recomendacion_detalle_id       => { type => 'varchar', length => 255, not_null => 1},
        precio_unitario                    => { type => 'float', not_null => 1},
        cantidad                           => { type => 'integer', not_null => 1},
        seleccionado                       => { type => 'integer', length => 11, not_null => 1 },
    ],


    relationships =>
    [
      ref_presupuesto => 
      {
         class       => 'C4::Modelo::AdqPresupuesto',
         key_columns => {adq_presupuesto_id => 'id' },
         type        => 'one to one',
       },
      
      ref_recomendacion_detalle => 
      {
        class       => 'C4::Modelo::AdqRecomendacionDetalle',
        key_columns => {adq_recomendacion_detalle_id => 'id' },
        type        => 'one to one',
      },



    ],
    
    primary_key_columns => [ 'id' ],
    unique_key => ['id'],

);
