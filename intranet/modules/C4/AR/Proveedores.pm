package C4::AR::Proveedores;

use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqProveedor;
use C4::Modelo::AdqProveedor::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(   
    &agregarProveedor;
    &eliminarProveedor;
    &modificarProveedor;
    &getProveedorLike;
    &editarAutorizado;
);

=item
    Este modulo agrega un proveedor
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
	  # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
	      &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
	      $msg_object->{'error'}= 1;
	      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
	      $db->rollback;
	  }


	  $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}


sub eliminarProveedor {

     my ($id_prov)=@_;
     my $msg_object= C4::AR::Mensajes::create();
     my $prov = C4::AR::Proveedores::getProveedorInfoPorId($id_prov);
 
     eval {
         $prov->desactivar;
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U320', 'params' => [$id_prov]} ) ;
     };
 
     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => [$id_prov]} ) ;
     }
 
     return ($msg_object);
}

=item
    Modulo que chekea que todos los datos necesarios sean validos. Queda todo en $msg_object, ademas lo retorna;
=cut
sub _verificarDatosProveedor {

     my ($data, $msg_object)=@_;
     my $actionType = $data->{'actionType'};
     my $checkStatus;
     my $nombre = $data->{'nombre'};
     my $direccion = $data->{'direccion'};
     my $telefono = $data->{'telefono'};
     my $emailAddress = $data->{'email'};
     my $proveedorActivo = $data->{'proveedor_activo'};
 

     if ($actionType eq "AGREGAR_PROVEEDOR"){
 
         if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($nombre)))){
             $msg_object->{'error'}= 1;
             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A002', 'params' => []} ) ;
         }
     

    #   valida si el email contiene algo
	if($emailAddress ne ""){
	  if (!($msg_object->{'error'}) && (!(&C4::AR::Validator::isValidMail($emailAddress)))){
	    $msg_object->{'error'}= 1;
	    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A003', 'params' => []} ) ;
	  }
	}

    #   valida que la direccion no este en blanco
	if($direccion ne ""){
	  if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($direccion)))){
		  $msg_object->{'error'}= 1;
		  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A004', 'params' => []} ) ;
	      }
	}

    #   valida que el telefono no tenga caractes ni simbolos
	if (!($msg_object->{'error'}) && ( ((&C4::AR::Validator::countAlphaChars($telefono) != 0)) || (&C4::AR::Validator::countSymbolChars($telefono) != 0) || (&C4::AR::Validator::countNumericChars($telefono) == 0))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A005', 'params' => []} ) ;
	    }
	}

    return ($msg_object);
}

sub editarProveedor{
    my ($params)=@_;
    use Switch;
    my $nombre = $params->{'nombre'};
    my $direccion = $params->{'direccion'};
    my $tel = $params->{'tel'};
    my $email = $params->{'email'};
   # my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
# 
#     if ($socio){
#         switch ($campo) {
#             case "nombre_autorizado" { $socio->setNombre_apellido_autorizado($value); $socio->save();  }
#             case "dni_autorizado" { $socio->setDni_autorizado($value); $socio->save();  }
#             case "telefono_autorizado" { $socio->setTelefono_autorizado($value); $socio->save();  }
#             else { }
#         }
#     }
#     return ($value);
}

sub getProveedorLike {

    use C4::Modelo::AdqProveedor;
    use C4::Modelo::AdqProveedor::Manager;
    my ($proveedor,$orden,$ini,$cantR,$habilitados,$inicial) = @_;
    my @filtros;
    my $proveedorTemp = C4::Modelo::AdqProveedor->new();
#     my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($proveedor);

    if($proveedor ne 'TODOS'){

        #SI VIENE INICIAL, SE BUSCA SOLAMENTE POR APELLIDOS QUE COMIENCEN CON ESA LETRA, SINO EN TODOS LADOS CON LIKE EN AMBOS LADOS
        if (!($inicial)){
        C4::AR::Debug::debug("entro al if inicial");
#             foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   nombre => { like => '%'.$proveedor.'%'},          
                                            ])
                     );
#             }
        }else{
#             foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   nombre => { like => $proveedor.'%'}, 
                                            ])
                                    );
#             }
        }
    }

    if (!defined $habilitados){
        $habilitados = 1;
    }

    push(@filtros, ( activo => { eq => $habilitados}));
 #   push(@filtros, ( es_socio => { eq => $habilitados}));
    my $ordenAux= $proveedorTemp->sortByString($orden);





    my $proveedores_array_ref = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor(   query => \@filtros,
                                                                            sort_by => $ordenAux,
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
#                                                               require_objects => ['nombre','direccion','telefono',
#                                                                                  'email'],
     ); 

C4::AR::Debug::debug("|" . @filtros . "|");

    #Obtengo la cant total de socios para el paginador
    my $proveedores_array_ref_count = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor_count( query => \@filtros,
#                                                              require_objects => ['nombre','direccion','telefono',
#                                                                                  'email'],
                                                                     );

    if(scalar(@$proveedores_array_ref) > 0){
        return ($proveedores_array_ref_count, $proveedores_array_ref);
    }else{
        return (0,0);
    }
}

END { }       # module clean-up code here (global destructor)

1;
__END__