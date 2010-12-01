package C4::AR::Proveedores;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqProveedor;
use C4::Modelo::AdqProveedor::Manager;
use C4::Modelo::AdqProveedorMoneda;
use C4::Modelo::AdqProveedorMoneda::Manager;
use C4::Modelo::AdqProveedorFormaEnvio::Manager;
use C4::Modelo::RefAdqMoneda::Manager;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &agregarMoneda;
    &agregarProveedor;
    &eliminarProveedor;
    &modificarProveedor;
    &getProveedorLike;
    &editarAutorizado;
    &getMonedasProveedor;
    &getFormasEnvioProveedor;
    &getMonedas;
);

=item
    Esta funcion agrega una modena al proveedor ,,   ¿¿¿ NO IRIA EN AdqProveedorMoneda ???
    Parametros: 
                HASH: {id_proveedor},{id_moneda}
=cut
sub agregarMoneda{

     my ($params) = @_;

    C4::AR::Debug::debug("objeto : ".$params->{'id_proveedor'});

#      my $id_proveedor = $params->{'id_proveedor'};
#      my $id_moneda    = $params->{'id_moneda'};

#   hacer objeto esto y llamarlo como tal :

    C4::Modelo::AdqProveedorMoneda::agregarMonedaProveedor($params);
    return "ok";

    

#     my $proveedor = getProveedorInfoPorId($params->{'id_proveedor'});
# 
#     my $msg_object= C4::AR::Mensajes::create();
#     my $db = $proveedor->db;
# 
#     # _verificarDatosProveedor($param,$msg_object);
# 
#     if (!($msg_object->{'error'})){
#           $db->{connect_options}->{AutoCommit} = 0;
#           $db->begin_work;
# 
#           eval{
#               $proveedor->agregarMoneda($params->{'id_moneda'});
#               $msg_object->{'error'}= 0;
#               C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A023', 'params' => []});
# #             no agrega nada en 'codMsg'
#               $db->commit;
#           };
# 
#           if ($@){
# #           # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
#               &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
#               $msg_object->{'error'}= 1;
#               C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
#               $db->rollback;
#           }
# 
#           $db->{connect_options}->{AutoCommit} = 1;
#     }
# 
#     C4::AR::Debug::debug("msg_object = ".$msg_object->{'codMsg'});
#     return ($msg_object);
}




=item
    Esta funcion agrega un proveedor
    Parametros: 
                HASH: {nombre},{direccion},{proveedor_activo},{telefono},{mail},{tipoAccion}
=cut
sub agregarProveedor{

    my ($param) = @_;
    my $proveedor = C4::Modelo::AdqProveedor->new();
    my $msg_object= C4::AR::Mensajes::create();
    my $db = $proveedor->db;

     _verificarDatosProveedor($param,$msg_object);

    if (!($msg_object->{'error'})){
          # 	entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;

          eval{
              $proveedor->agregarProveedor($param);
              $msg_object->{'error'}= 0;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A001', 'params' => []});
              $db->commit;
          };
          if ($@){
#           # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
              &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
              $msg_object->{'error'}= 1;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
              $db->rollback;
          }

          $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}


=item
    Esta funcion elimina un proveedor
    Parametros: 
                {id_proveedor}
=cut

sub eliminarProveedor {

     my ($id_prov) = @_;
     my $msg_object= C4::AR::Mensajes::create();
     my $prov = C4::AR::Proveedores::getProveedorInfoPorId($id_prov);
 
     eval {
         $prov->desactivar;
         $msg_object->{'error'}= 0;
# FIXME no mostrar id_prov, mostrar Apellido y Nombre si es persona física y Razon social si es persona jurídica
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U320', 'params' => [$id_prov]} ) ;
     };
 
     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
# FIXME no mostrar id_prov, mostrar Apellido y Nombre si es persona física y Razon social si es persona jurídica
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => [$id_prov]} ) ;
     }
 
     return ($msg_object);
}


=item
    Esta funcion edita un proveedor
    Parametros: 
                 HASH: {nombre},{direccion},{proveedor_activo},{telefono},{mail}
=cut
sub editarProveedor{
#   Recibe la informacion del proveedos, el objeto JSON.

    my ($params)=@_;
    my $msg_object= C4::AR::Mensajes::create();

    my $proveedor = getProveedorInfoPorId($params->{'id_proveedor'});

    my $db = $proveedor->db;

    _verificarDatosProveedor($params,$msg_object);

    if (!($msg_object->{'error'})){

#   entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
          eval{
              $proveedor->editarProveedor($params);
              $msg_object->{'error'}= 0;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A006', 'params' => []});
              $db->commit;
          };



          if ($@){

          # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
              &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
              $msg_object->{'error'}= 1;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
              $db->rollback;
          }

    }

     return ($msg_object);
}

# =item
#     Esta funcion devuelve la informacion del proveedor segun su id
# =cut
sub getProveedorInfoPorId {
    my ($params) = @_;

    my $proveedorTemp;
    my @filtros;

    if ($params){
        push (@filtros, ( id => { eq => $params}));
        $proveedorTemp = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor(   query => \@filtros );

        return $proveedorTemp->[0]
    }

    return 0;
}

# =item
#     Este funcion devuelve la informacion de proveedores segun su nombre
# =cut
sub getProveedorLike {

# FIXME definir los módulos arriba
#     use C4::Modelo::AdqProveedor;
#     use C4::Modelo::AdqProveedor::Manager;
    my ($proveedor,$orden,$ini,$cantR,$habilitados,$inicial) = @_;
    my @filtros;
    my $proveedorTemp = C4::Modelo::AdqProveedor->new();

    if($proveedor ne 'TODOS'){
        if (!($inicial)){
                push (  @filtros, ( or   => [   nombre => { like => '%'.$proveedor.'%'}, razon_social => { like => '%'.$proveedor.'%'}, ]));
        }else{
                push (  @filtros, ( or   => [   nombre => { like => $proveedor.'%'}, razon_social => { like => $proveedor.'%'}, ]) );
        }
    }

    if (!defined $habilitados){
        $habilitados = 1;
    }

    push(@filtros, ( activo => { eq => $habilitados}));
    my $ordenAux= $proveedorTemp->sortByString($orden);
    my $proveedores_array_ref = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor(   query => \@filtros,
                                                                                        sort_by => $ordenAux,
                                                                                        limit   => $cantR,
                                                                                        offset  => $ini,
     ); 

    #Obtengo la cant total de proveedores para el paginador
    my $proveedores_array_ref_count = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor_count( query => \@filtros, );

    if(scalar(@$proveedores_array_ref) > 0){
        return ($proveedores_array_ref_count, $proveedores_array_ref);
    }else{
        return (0,0);
    }
}

=item
   Modulo que devuelve todas las monedas que tenga el proveedor
=cut

sub getMonedasProveedor{
 
   my ($params) = @_;
   my $id_proveedor = $params;

   my $monedas = C4::Modelo::AdqProveedorMoneda::Manager->get_adq_proveedor_moneda(   query =>  [ 
                                                                                                proveedor_id  => { eq => $id_proveedor  },
                                                                                   ],
                                                                                    require_objects => ['moneda_ref'],
   
                                                    );
   my @nombres_monedas;
   foreach my $moneda (@$monedas){
      push (@nombres_monedas,$moneda);
   }
    
   return($monedas);
}

sub getFormasEnvioProveedor{
 
   my ($params) = @_;
   my $id_proveedor = $params;

   my $formas_envio = C4::Modelo::AdqProveedorFormaEnvio::Manager->get_adq_proveedor_forma_envio(   query =>  [ 
                                                                                              adq_proveedor_id  => { eq => $id_proveedor  },
                                                                                   ],
                                                                                    require_objects => ['forma_envio_ref'],
   
                                                    );

   return($formas_envio);
}





=item
   Modulo que devuelve todas las monedas para mostrarlas en Editar Proveedor - TEMPORAL aca, dsp va en C4::AR::Monedas ?
=cut

sub getMonedas{
 
   my $todasMonedas = C4::Modelo::RefAdqMoneda::Manager->get_ref_adq_moneda();
   my @nombres_monedas;
   foreach my $moneda (@$todasMonedas){
      push (@nombres_monedas,$moneda);
   }
    
   return($todasMonedas);
}


# TODO sub getFormasEnvioProveedor{
#  
#    my ($params) = @_;
#    my $id_proveedor = $params;
# 
#    my $monedas = C4::Modelo::AdqProveedorMoneda::Manager->get_adq_proveedor_moneda(   query =>  [ 
#                                                                                                 proveedor_id  => { eq => $id_proveedor  },
#                                                                                    ],
#                                                                                     require_objects => ['moneda_ref'],
#    
#                                                     );
#    my @nombres_monedas;
#    foreach my $moneda (@$monedas){
# #      push (@nombres_monedas,$moneda->moneda_ref->getNombre);
#       push (@nombres_monedas,$moneda);
#    }
# 
# #   C4::AR::Debug::debug(@nombres_monedas[0]);
#     
#    return($monedas);
# }


sub _verificarDatosProveedor {

     my ($data, $msg_object)    = @_;
     my $actionType             = $data->{'actionType'};
     my $checkStatus;

     my $tipo_proveedor         = $data->{'tipo_proveedor'};
   
     my $apellido               = $data->{'apellido'};
     my $nombre                 = $data->{'nombre'};
    
     my $nro_doc                = $data->{'nro_doc'};
     my $tipo_doc               = $data->{'tipo_doc'};
     my $razon_social           = $data->{'razon_social'};
     my $cuit_cuil              = $data->{'cuit_cuil'};

     my $pais                   = $data->{'pais'};
     my $provincia              = $data->{'provincia'};
     my $ciudad                 = $data->{'ciudad'};
     my $domicilio              = $data->{'domicilio'};
     my $telefono               = $data->{'telefono'};
     my $fax                    = $data->{'fax'};     

     my $emailAddress           = $data->{'email'};
     
     my $plazo_reclamo          = $data->{'plazo_reclamo'};
    
     my $proveedorActivo        = $data->{'proveedor_activo'};
 
# TODO AGREGAR TIPOS DE MATERIALES, FORMAS DE ENVIO y MONEDAS!!! -- TAMBIEN VER VALIDACIONES


     if (($actionType eq "AGREGAR_PROVEEDOR") || ($actionType eq "MODIFICACION")){


        if($tipo_proveedor eq "persona_fisica"){

    
            # es una persona fisica, se validan estos datos
            #   valida que el nombre sea valido - no puede estar en blanco ni tener caracteres invalidos - 
            if($nombre ne ""){
                if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($nombre)))){
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A007', 'params' => []} ) ;
                }
            } else {
                  $msg_object->{'error'}= 1;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
            }

            #   valida apellido
            if($apellido ne "") {
                if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($apellido)))){
                      $msg_object->{'error'}= 1;
                      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A009', 'params' => []} ) ;
                      }
            } else {
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A010', 'params' => []} ) ;   
            }

            #   valida nro documento
            if($nro_doc ne "") {
                if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($nro_doc) != 0)) || (&C4::AR::Validator::countSymbolChars($nro_doc) != 0) || (&C4::AR::Validator::countNumericChars($nro_doc) == 0))){
                      $msg_object->{'error'}= 1;
                      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A015', 'params' => []} ) ;
                      }
            } else {
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A016', 'params' => []} ) ;
                  
            }

        }else{
            #es una persona juridica
            #   valida razon social
            if($razon_social ne "") {
                if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($razon_social)))){
                      $msg_object->{'error'}= 1;
                      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A011', 'params' => []} ) ;
                      }
            } else {
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A012', 'params' => []} ) ;     
            }

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

       }

       return ($msg_object);

  
}

END { }       # module clean-up code here (global destructor)

1;
__END__