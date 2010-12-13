package C4::Modelo::AdqRecomendacionDetalle;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use C4::Modelo::AdqRecomendacion;
use C4::Modelo::CatRegistroMarcN2;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_recomendacion_detalle',

    columns => [  

          id    
          adq_recomendacion_id  => { type => 'integer', not_null => 1 },  
          cat_nivel2_id         => { type => 'integer', not_null => 1 },
          autor                 => { type => 'varchar', length => 255, not_null => 1},
          titulo                => { type => 'varchar', length => 255, not_null => 1},
          lugar_publicacion     => { type => 'varchar', length => 255, not_null => 1},
          editorial             => { type => 'varchar', length => 255, not_null => 1},
          fecha_publicacion     => { type => 'date' },,
          coleccion             => { type => 'varchar', length => 255, not_null => 1},
          isbn_issn             => { type => 'varchar', length => 45, not_null => 1}
          cantidad_ejemplares   => { type => 'integer', length => 5, not_null => 1 },  
          motivo_propuesta      => { type => 'varchar', length => 255, not_null => 1},
          comentario            => { type => 'varchar', length => 255, not_null => 1},
          reserva_material      => { type => 'integer', not_null => 1 },
        

cat_registro_marc_n2

    relationships =>
    [
      ref_adq_recomendacion => 
      {
         class       => 'C4::Modelo::AdqRecomendacion',
         key_columns => {adq_recomendacion_id => 'id' },
         type        => 'one to one',
       },
      
      ref_cat_nivel2 => 
      {
        class       => 'C4::Modelo::cat_registro_marc_n2,
        key_columns => { cat_nivel2_id => 'id' },
        type        => 'one to one',
      },



    ],
    
    primary_key_columns => [ 'id' ],
    unique_key => ['id'],

);
