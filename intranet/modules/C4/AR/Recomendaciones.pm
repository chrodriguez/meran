package C4::AR::Recomendaciones;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqRecomendacion;
use C4::Modelo::AdqRecomendacion::Manager;
use C4::Modelo::AdqRecomendacionDetalle;
use C4::Modelo::AdqRecomendacionDetalle::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &agregrarRecomendacion;
    &getRecomendacionesActivas;
    &getRecomendacionDetallePorId;
    &getRecomendaciones;
    &getRecomendacionDetalle;
    &editarCantidadEjemplares;
    &getRecomendacionPorId;
    &updateRecomendacionDetalle;
);

=item
    Esta funcion edita la cantidad de ejemplares de una recomendacion
    Parametros: 
                 HASH: {id_recomendacion_detalle},{cantidad de ejemplares}
=cut
sub editarCantidadEjemplares{
#   Recibe la informacion del objeto JSON.

    my ($params)        =@_;
    my $msg_object      = C4::AR::Mensajes::create();

    my $recomendacion   = getRecomendacionDetallePorId($params->{'id_recomendacion_detalle'});

    $recomendacion->setearCantidad($params->{'cantidad_ejemplares'});
}

=item
    Esta funcion agrega una recomendacion y su detalle
    Parametros: 
                HASH: {cat_nivel2_id},{autor},{titulo},{lugar_publicacion},{editorial},{fecha_publicacion}, 
                      {coleccion}, {isbn_issn}, {cantidad_ejemplares}, 
                      {motivo_propuesta}, {comentario}, {reserva_material}
=cut
sub agregarRecomendacion{
    my ($params, $usr_socio_id) = @_;

    my $recomendacion = C4::Modelo::AdqRecomendacion->new();
    my $msg_object= C4::AR::Mensajes::create();
    my $db = $recomendacion->db;

# TODO

    #_verificarDatosProveedor($param,$msg_object);

    if (!($msg_object->{'error'})){
#           C4::AR::Utilidades::printHASH(\%datos_recomendacion);
           
          # entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
          eval{
                
              $recomendacion->agregarRecomendacion($usr_socio_id);
              for (my $i=0; $i< scalar(@{$params->{'table'}}); $i++) {
                   
                      my %datos_recomendacion;
                      $datos_recomendacion{'id_recomendacion'}=$recomendacion->getId();
                      $datos_recomendacion{'nivel_2'}= ($params->{'table'}[$i])->{'Nivel2'};
                      $datos_recomendacion{'autor'}=($params->{'table'}[$i])->{'Autor'};
                      $datos_recomendacion{'titulo'}=($params->{'table'}[$i])->{'Titulo'};
                      $datos_recomendacion{'lugar_publicacion'}=  ($params->{'table'}[$i])->{'LugarPublicacion'};
                      $datos_recomendacion{'editorial'}= ($params->{'table'}[$i])->{'Editorial'};
                      $datos_recomendacion{'fecha'}= ($params->{'table'}[$i])->{'Fecha'};
                      $datos_recomendacion{'coleccion'}= ($params->{'table'}[$i])->{'Coleccion'};
                      $datos_recomendacion{'isbn_issn'}= ($params->{'table'}[$i])->{'ISBN/ISSN'};
                      $datos_recomendacion{'cantidad_ejemplares'}= ($params->{'table'}[$i])->{'Cantidad'};
                      $datos_recomendacion{'motivo_propuesta'}= ($params->{'table'}[$i])->{'Motivo'};
                      $datos_recomendacion{'comentarios'}= ($params->{'table'}[$i])->{'Comentario'};
                      $datos_recomendacion{'reservar'}= ($params->{'table'}[$i])->{'reservar'}||0;
  
              

                      my $recomendacion_detalle = C4::Modelo::AdqRecomendacionDetalle->new(db => $db); 
                      $recomendacion_detalle->agregarRecomendacionDetalle(\%datos_recomendacion);
                     
               }        
             
               $msg_object->{'error'} = 0;
               C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A001', 'params' => []});
               $db->commit;

            };
            if ($@){
              # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
                  &C4::AR::Mensajes::printErrorDB($@, 'B410',"OPAC");
                  $msg_object->{'error'}= 1;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B410', 'params' => []} ) ;
                  $db->rollback;
              }

              $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}

=item
    Esta funcion devuelve las recomendaciones activas, con su detalle
=cut
sub getRecomendacionesActivas{

    my ($params) = @_;

    my $db                                      = C4::Modelo::AdqRecomendacionDetalle->new()->db;
    my $recomendaciones_activas_array_ref       = C4::Modelo::AdqRecomendacionDetalle::Manager->get_adq_recomendacion_detalle(   
                                                                    db => $db,
                                                                    query   => [ activa => 1 ],
                                                                    require_objects     => ['ref_adq_recomendacion'],
                                                                );

    return ($recomendaciones_activas_array_ref);
}

sub getRecomendaciones{

    my ($params) = @_;

    my $db                                      = C4::Modelo::AdqRecomendacion->new()->db;
    my $recomendaciones_activas_array_ref       = C4::Modelo::AdqRecomendacion::Manager->get_adq_recomendacion(   
                                                                    db => $db,
                                                                    query   => [ activa => 1 ],
                                                                );

    return ($recomendaciones_activas_array_ref);
}

=item
    Recupera un registro de recomendacion_detalle
    Retorna un objeto o 0 si no existe
=cut
sub getRecomendacionDetallePorId{

    my ($params) = @_;

    my $db                = C4::Modelo::AdqRecomendacionDetalle->new()->db;
    my $recomendacion     = C4::Modelo::AdqRecomendacionDetalle::Manager->get_adq_recomendacion_detalle(   
                                                                    db => $db,
                                                                    query   => [ id  => { eq => $params} ],
                                                                );                                                       
    if( scalar($recomendacion) > 0){
        return ($recomendacion->[0]);
    }else{
        return 0;
    }
}



sub getRecomendacionDetalle{

    my ($params) = @_;

    my $db                = C4::Modelo::AdqRecomendacionDetalle->new()->db;
    my $recomendacion     = C4::Modelo::AdqRecomendacionDetalle::Manager->get_adq_recomendacion_detalle(   
                                                                    db => $db,
                                                                    query   => [ adq_recomendacion_id => { eq => $params} ],
                                                                );                                                       

    if( scalar($recomendacion) > 0){
        return ($recomendacion);
    
    }
}



=item
    Recupera un registro de recomendacion
    Retorna un objeto o 0 si no existe
=cut








sub getRecomendacionPorId{

    my ($params, $db) = @_;
    my $recomendacion     = C4::Modelo::AdqRecomendacion::Manager->get_adq_recomendacion(   
                                                                    db => $db,
                                                                    query   => [ id  => { eq => $params} ],
                                                                );
                                                                
    if( scalar($recomendacion) > 0){
        return ($recomendacion->[0]);

    }else{
        return 0;
    }
}


=item
    Actualiza la info de una recomendacion
=cut
sub updateRecomendacionDetalle{

    my ($params) = @_;
    
    my $recomendacion = getRecomendacionDetallePorId($params->{'id_recomendacion'});
    
    my $db = $recomendacion->db;
    my $msg_object;
    
    #TODO _verificarDatosRecomendacion($params,$msg_object);
    
    if (!($msg_object->{'error'})){
    
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
          eval{
              $recomendacion->updateRecomendacionDetalle($params);
              

              $msg_object->{'error'}= 0;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A034', 'params' => []});
              $db->commit;
          };

          if ($@){
          # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo editar el proveedor
              &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
              $msg_object->{'error'}= 1;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
              $db->rollback;
          }

    }
    return ($msg_object);
    
}

sub _verificarDatosRecomendacion {

     my ($data, $msg_object)    = @_;
     my $checkStatus;

     my $cat_nivel_2            = $data->{'cat_nivel'};
     my $autor                  = $data->{'autor'};
     my $titulo                 = $data->{'titulo'};
     my $lugar_publicacion      = $data->{'lugar_publicacion'};
     my $editorial              = $data->{'editorial'};
     my $fecha_publicacion      = $data->{'fecha_publicacion'};
     my $coleccion              = $data->{'coleccion'};
     my $isbn                   = $data->{'isbn'};
     my $cantidad_ejemplares    = $data->{'cantidad_ejemplares'};
     my $motivo_propuesta       = $data->{'motivo_propuesta'};
     my $comentario             = $data->{'comentario'};
     my $reserva_material       = $data->{'reserva_material'};    
     
     #TODO: 
 
}

END { }       # module clean-up code here (global destructor)

1;
__END__
