package C4::AR::Proveedores;

use strict;
require Exporter;
#  va DBI ? 
use DBI;
use C4::Modelo::AdqProveedor;
use C4::Modelo::AdqProveedor::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(   
    &agregarProveedor;
    &eliminarProveedor;
    &modificarProveedor;
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

#     _verificarDatosBorrower($input,$msg_object);
#     if (!($msg_object->{'error'})){

#         $params->{'iniciales'} = "DGR";
        #genero un estado de ALTA para la persona para una fuente de informacion


    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
        C4::AR::Debug::debug("entro a agregar");
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

    return ($msg_object);
}


sub eliminarProveedor {

#     my ($id_prov)=@_;
#     my $msg_object= C4::AR::Mensajes::create();
#     my $prov = C4::AR::Proveedores::getProveedorInfoPorId($id_prov);
# 
#     eval {
#         $prov->desactivar;
#         $msg_object->{'error'}= 0;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U320', 'params' => [$id_prov]} ) ;
#     };
# 
#     if ($@){
#         #Se loguea error de Base de Datos
#         &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
#         #Se setea error para el usuario
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => [$id_prov]} ) ;
#     }
# 
#     return ($msg_object);
}

=item
    Modulo que chekea que todos los datos necesarios sean validos. Queda todo en $msg_object, ademas lo retorna;
=cut
sub _verificarDatosBorrower {

#     my ($data, $msg_object)=@_;
#     my $actionType = $data->{'actionType'};
# #   my $checkStatus;
#     my $nombre = $data->{'nombre'};
#     my $direccion = $data->{'direccion'};
#     my $telefono = $data->{'telefono'};
#     my $emailAddress = $data->{'email'};
#     my $proveedorActivo = $data->{'proveedor_activo'};
# 
#     if ( (!($msg_object->{'error'})) && (!$data->{'modifica'})){
#           $msg_object->{'error'} = (existeSocio($nro_socio) > 0);
#           if ($msg_object->{'error'}){
#               C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U500', 'params' => []} ) ;
#           }
#     }
# 
#     if (!($msg_object->{'error'}) && ($credential_type eq "superlibrarian") ){
#         my $socio = getSocioInfoPorNroSocio(C4::Auth::getSessionNroSocio());
#         if ( (!$socio) || (!($socio->isSuperUser())) ){
#           $msg_object->{'error'}= 1;
#           C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U399', 'params' => []} ) ;
#         }
#     }
# 
#     if (!($msg_object->{'error'}) && (!(&C4::AR::Validator::isValidMail($emailAddress)))){
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U332', 'params' => []} ) ;
#     }
# $msg_object
#     #### EN ESTE IF VAN TODOS LOS CHECKS PARA UN NUEVO BORROWER, NO PARA UN UPDATE
#     if ($actionType eq "new"){
# 
#         my $cardNumber = $data->{'nro_socio'};
#         if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($cardNumber)))){
#             $msg_object->{'error'}= 1;
#             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U333', 'params' => []} ) ;
#         }
#     }
#     #### FIN NUEVO BORROWER's CHECKS
# 
#     my $surname = $data->{'apellido'};
#     if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($surname)))){
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U334', 'params' => []} ) ;
#     }
# 
#     my $firstname = $data->{'nombre'};
#     if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($firstname)))){
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U335', 'params' => []} ) ;
#     }
# 
#     my $tipo_doc = $data->{'tipo_documento'};
#     if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($tipo_doc)))){
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U800', 'params' => []} ) ;
#     }
# 
#     my $documentnumber = $data->{'nro_documento'};
#     $checkStatus = &C4::AR::Validator::isValidDocument($data->{'tipo_documento'},$documentnumber);
#     if (!($msg_object->{'error'}) && ( $checkStatus == 0)){
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U336', 'params' => []} ) ;
#     }else{
#           if ( (!C4::AR::Usuarios::isUniqueDocument($documentnumber,$data)) ) {
#                 $msg_object->{'error'}= 1;
#                 C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U388', 'params' => []} ) ;
#           }
#     }
#     return ($msg_object);
}

END { }       # module clean-up code here (global destructor)

1;
__END__