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
);


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