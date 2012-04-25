package C4::AR::Logos;

use strict;
use C4::Modelo::Logo;
use C4::Modelo::Logo::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 
    listar
    agregarLogo
    getLogoById
    eliminarLogo
);

#/intranet/htdocs/private-uploads/logos  (INTRA) --> /usr/share/meran/intranet/htdocs/private-uploads/logos
#/opac/htdocs/logos (OPAC) --> /usr/share/meran/opac/htdocs/htdocs/logos


sub eliminarLogo{
    my ($params)    = @_;
    
    my $msg_object  = C4::AR::Mensajes::create();

    my $logo        = getLogoById($params->{'idLogo'});
    
    my $uploaddir;
    if($params->{'context'} eq "opac"){
        $uploaddir       = C4::Context->config('logosOpacPath');
    }else{
        $uploaddir       = C4::Context->config('logosIntraPath');
    }
    
    if ($logo){
    
	    my $image_name = $logo->getImagenPath();
	    unlink($uploaddir."/".$image_name);
	    $logo->delete();
	    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP15',} ) ;
    }
            
    return ($msg_object);
    
}


sub agregarLogo{

	my ($params,$postdata) = @_;
	
	my $logo = C4::Modelo::Logo->new();
	
	if (C4::AR::Utilidades::validateString($params->{'nombre'})){
		$logo->setNombre($params->{'nombre'});
	}
	
	if (C4::AR::Utilidades::validateString($params->{'alto'})){
		$logo->setAlto($params->{'alto'});
	}
	
	if (C4::AR::Utilidades::validateString($params->{'ancho'})){
		$logo->setAncho($params->{'ancho'});
	}
	
	my ($image,$msg) = uploadLogo($postdata, $params->{'nombre'}, $params->{'context'});
	
	$logo->setImagenPath($image);
	
	if (!$msg->{'error'}){
	   $logo->save();
	}
	
	return ($msg);
	
}

sub uploadLogo{
    my ($query,$name,$context) = @_;
    
    my @filesAllowed    = qw(
                                jpeg
                                gif
                                png
                                jpg
                            );

    my $uploaddir;
    if($context eq "opac"){
        $uploaddir       = C4::Context->config('logosOpacPath');
    }else{
        $uploaddir       = C4::Context->config('logosIntraPath');
    }
    
    my $maxFileSize     = 2048 * 2048; # 1/2mb max file size...
    my $msg_object      = C4::AR::Mensajes::create();
    
    #checkeamos con libmagic el tipo del archivo
    my $type            = C4::AR::Utilidades::checkFileMagic($query, @filesAllowed);
    
    C4::AR::Debug::debug("vamos a escribir $name en el context $context y type $type en el dir $uploaddir y mono $uploaddir/$name.$type");
      
    if (!$type) {
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP00', 'params' => ['jpg','png','gif']} ) ;
    }

    
    if (!$msg_object->{'error'}){
#    	eval{
		    open ( WRITEIT, ">$uploaddir/$name.$type" ) or die "$!"; 
		    binmode WRITEIT; 
		    while ( <$query> ) { 
		    	print WRITEIT; 
		    }
		    close(WRITEIT);
#    	};
#    	if ($@){
#	         $msg_object->{'error'}= 1;
#	         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP01',} ) ;
#    	}
    }
    
    if (!$msg_object->{'error'}){
	    my $check_size = -s "$uploaddir/$name.$type";
	
	    if ($check_size > $maxFileSize) {
	         $msg_object->{'error'}= 1;
             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP07', 'params' => ['512 KB']} ) ;
	    } 
    }    
    
    if (!$msg_object->{'error'}){
    	C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP08', 'params' => ['512 KB']} ) ;
    }
    
    return ($name.".".$type,$msg_object);

}

sub getLogoById{
    
    my ($id) = @_;
    
    use C4::Modelo::Logo::Manager;
    
    my @filtros;
    
    push (@filtros, (id => {eq => $id}) );
    
    my $logo = C4::Modelo::Logo::Manager->get_logo( query => \@filtros,);
    
    return $logo->[0];
}


sub listar{
    my ($ini,$cantR) = @_;
    my $logos_array_ref = C4::Modelo::Logo::Manager->get_logo( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => $cantR,
                                                                                offset  => $ini,
                                                                              );

    my $logos_array_ref_count = C4::Modelo::Logo::Manager->get_logo_count();
    if(scalar(@$logos_array_ref) > 0){
        return ($logos_array_ref_count, $logos_array_ref);
    }else{
        return (0,0);
    }
}

1;
