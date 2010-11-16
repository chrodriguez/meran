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


=item
    Esta funcion elimina un proveedor
    Parametros: 
                {id_proveedor}
=cut
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
    Esta funcion edita un proveedor
    Parametros: 
                 HASH: {nombre},{direccion},{proveedor_activo},{telefono},{mail}
=cut
sub editarProveedor{
#   Recibe la informacion del proveedos, el objeto JSON.


    my ($info_proveedor)=@_;
    my $msg_object= C4::AR::Mensajes::create();


    my $proveedor = getProveedorInfoPorId($info_proveedor->{'id_proveedor'});
#     C4::AR::Debug::debug(" proveedor ".$proveedor);

    my $db = $proveedor->db;


#       Checkear esto:
    _verificarDatosProveedor($info_proveedor,$msg_object);

    if (!($msg_object->{'error'})){

#   entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
          C4::AR::Debug::debug("proveedor ".$info_proveedor->{'nombre'});
          eval{
              $proveedor->editarProveedor($info_proveedor);
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

    #       my $prov = C4::AR::Proveedores::getProveedorInfoPorId($id_prov);

    }

     return ($msg_object);
}

# =item
#     Esta funcion devuelve la informacion del proveedor segun su id
# =cut
sub getProveedorInfoPorId {
    my ($id_prov) = @_;

    my $proveedorTemp;
    my @filtros;

    if ($id_prov){
        push (@filtros, ( id_proveedor => { eq => $id_prov}));
        $proveedorTemp = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor(   query => \@filtros );

 
        return $proveedorTemp->[0]
    }

  return 0;
}

# =item
#     Este funcion devuelve la informacion del proveedor segun su id
# =cut
sub getProveedorLike {

    use C4::Modelo::AdqProveedor;
    use C4::Modelo::AdqProveedor::Manager;
    my ($proveedor,$orden,$ini,$cantR,$habilitados,$inicial) = @_;
    my @filtros;
    my $proveedorTemp = C4::Modelo::AdqProveedor->new();

    if($proveedor ne 'TODOS'){
        if (!($inicial)){
        C4::AR::Debug::debug("entro al if inicial");
                push (  @filtros, ( or   => [   nombre => { like => '%'.$proveedor.'%'}, ]));
        }else{
                push (  @filtros, ( or   => [   nombre => { like => $proveedor.'%'}, ]) );
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
    Modulo que chekea que todos los datos necesarios sean validos. Queda todo en $msg_object, ademas lo retorna;
    Usado en agregar proveedor y modificar proveedor
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
 

     if (($actionType eq "AGREGAR_PROVEEDOR") || ($actionType eq "MODIFICACION")){
 
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

END { }       # module clean-up code here (global destructor)

1;
__END__