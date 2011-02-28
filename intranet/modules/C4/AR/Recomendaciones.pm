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
     
     
    my $param = $params->Vars;
    #my $param = $params->param;
     #todo
     #_verificarDatosProveedor($param,$msg_object);

    if (!($msg_object->{'error'})){
          # entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;

			C4::AR::Debug::debug("------------------------------------------------------------------------------------");
			C4::AR::Debug::debug("commit");
          
           #eval{
           	
           	#C4::AR::Utilidades::printHASH($params_temp);
              $recomendacion->agregarRecomendacion($param, $usr_socio_id);
              my $id_adq_recomendacion = $recomendacion->getId();

            C4::AR::Debug::debug("------------------------------------------------------------------------------------");
            C4::AR::Debug::debug("ya agrego el id:" . $id_adq_recomendacion);
            
            
C4::AR::Debug::debug("$param");
#             recomendaciones detail
#                my %parametros;
#                $parametros{'id_adq_recomendacion'}   = $id_adq_recomendacion;
                my $recomendacion_detalle = C4::Modelo::AdqRecomendacionDetalle->new(db => $db);    
                $recomendacion_detalle->agregarRecomendacionDetalle($param, $id_adq_recomendacion);
              
              $msg_object->{'error'} = 0;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A001', 'params' => []});
              $db->commit;
           #};
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

     # valida que el autor sea valido - no puede estar en blanco ni tener caracteres invalidos - 
     if($autor ne ""){
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($autor)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A007', 'params' => []} ) ;
        }
    }else{
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
    }
    
    # valida que el titulo sea valido - no puede estar en blanco ni tener caracteres invalidos - 
    if($titulo ne ""){
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($titulo)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A007', 'params' => []} ) ;
        }
    }else{
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
    }
    
    # valida que el lugar_publicacion sea valido - no puede estar en blanco ni tener caracteres invalidos - 
    if($lugar_publicacion ne ""){
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($lugar_publicacion)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A007', 'params' => []} ) ;
        }
    }else{
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
    }
    
    # valida que el editorial sea valido - no puede estar en blanco ni tener caracteres invalidos - 
    if($editorial ne ""){
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($editorial)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A007', 'params' => []} ) ;
        }
    }else{
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
    }
    
    # valida que el editorial sea valido - no puede estar en blanco ni tener caracteres invalidos - 
    if($editorial ne ""){
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($editorial)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A007', 'params' => []} ) ;
        }
    }else{
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
    }
    
    
    



            #   valida nro documento, tambien que no exista ya en la base cuando estamos agregando un proveedor
            if($nro_doc ne "") {
                if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($nro_doc) != 0)) || (&C4::AR::Validator::countSymbolChars($nro_doc) != 0) || (&C4::AR::Validator::countNumericChars($nro_doc) == 0))){
                      $msg_object->{'error'}= 1;
                      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A015', 'params' => []} ) ;
                      }else{
                        # el dni es valido, validamos que sea unico si estamos agregando
                        if($actionType eq "AGREGAR_PROVEEDOR"){
                            my $proveedor_dni = getProveedorPorDni($nro_doc);
                            if($proveedor_dni != 0){
                                $msg_object->{'error'}= 1;
                                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A026', 'params' => []} ) ;
                            }
                        }else{
                            # si estamos editando tiene que tener el mismo dni el proveedor con mismo id
                            my $proveedor_dni = getProveedorPorDni($nro_doc);
                            if($proveedor_dni != 0){
                                if($proveedor_dni->getId != $data->{'id_proveedor'}){
                                    $msg_object->{'error'}= 1;
                                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A026', 'params' => []} ) ;
                                }
                            }
                        }
                      }
            } else {
            C4::AR::Debug::debug("nro_doc: ".$nro_doc);
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A016', 'params' => []} ) ;
                  
            }

        #   valida cuit_cuil
        if($cuit_cuil ne "") {
            if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($cuit_cuil) != 0)) || (&C4::AR::Validator::countSymbolChars($cuit_cuil) != 0) || (&C4::AR::Validator::countNumericChars($cuit_cuil) == 0))){
                  $msg_object->{'error'}= 1;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A013', 'params' => []} ) ;
                  }
        } else {
                 $msg_object->{'error'}= 1;
                 C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A014', 'params' => []} ) ;       
        }
          
        if($ciudad ne ""){
            if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($ciudad)))){
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A021', 'params' => []} ) ;
            }
        } else {
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A022', 'params' => []} ) ;        
        }


        #   valida si el email contiene algo
        if($emailAddress ne ""){
            if (!($msg_object->{'error'}) && (!(&C4::AR::Validator::isValidMail($emailAddress)))){
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A003', 'params' => []} ) ;
            }
        }

        #   valida el domicilio
        if($domicilio ne ""){
            if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($domicilio)))){
                  $msg_object->{'error'}= 1;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A008', 'params' => []} ) ;
            } 
        }else {
                  $msg_object->{'error'}= 1;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A004', 'params' => []} ) ;      
            }
        
      
          #   valida que el telefono no tenga caractes ni simbolos
          if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($telefono) != 0)) || (&C4::AR::Validator::countSymbolChars($telefono) != 0) || (&C4::AR::Validator::countNumericChars($telefono) == 0))){
                 $msg_object->{'error'}= 1;
                 C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A005', 'params' => []} ) ;     
           }

       return ($msg_object);

  
}
