package C4::AR::AyudaMarc;

use strict;
use C4::Modelo::CatAyudaMarc;
use C4::Modelo::CatAyudaMarc::Manager;

use vars qw($VERSION @ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	getAyudaMarc
	agregarAyudaMarc
);

sub getAyudaMarc{

	#TODO: filtrar solo por la UI actual

	my @filtros;

	my $ayudasArrayRef = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc( ); 

    #Obtengo la cantidad total de proveedores para el paginador
    my $ayudasArrayRefCount = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc_count( );

    if(scalar(@$ayudasArrayRef) > 0){
        return ($ayudasArrayRef, $ayudasArrayRefCount);
    }else{
        return (0,0);
    }
}

sub agregarAyudaMarc{

	my ($params) 	= @_;

	my $ayudaMarc 	= C4::Modelo::CatAyudaMarc->new();
	my $db 			= $ayudaMarc->db;
	my $msg_object	= C4::AR::Mensajes::create();

	$db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

	eval{

		$ayudaMarc->agregarAyudaMarc($params);

		$msg_object->{'error'} = 0;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM00', 'params' => []});
		$db->commit;

	};

	if($@){
       C4::AR::Mensajes::printErrorDB($@, 'AM01',"INTRA");
       $msg_object->{'error'}= 1;
       C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM01', 'params' => []} ) ;
       $db->rollback;
   }

   return ($msg_object);

}


END { }       # module clean-up code here (global destructor)

1;
__END__