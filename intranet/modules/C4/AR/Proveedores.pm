package C4::AR::Proveedores;

use strict;
require Exporter;
use C4::Modelo::AdqProveedor;
use C4::Modelo::AdqProveedor::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(   
    &agregarProveedor;
    &eliminarProveedor;
    &modificarProveedor;
);

sub agregarProveedor{

    my ($input) = @_;
    my %params;
    my $proveedor = C4::Modelo::AdqProveedor->new();
    my $db = $proveedor->db;

    _verificarDatosBorrower($params,$msg_object);
    if (!($msg_object->{'error'})){

        $params->{'iniciales'} = "DGR";
        #genero un estado de ALTA para la persona para una fuente de informacion
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
        eval{
            $proveedor->agregarProveedor($params);
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U329', 'params' => []});
            $db->commit;
        };

        if ($@){
            &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
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