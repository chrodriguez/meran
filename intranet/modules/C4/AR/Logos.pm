package C4::AR::Logos;

use strict;
use C4::Modelo::LogoEtiquetas;
use C4::Modelo::LogoEtiquetas::Manager;
use C4::Modelo::LogoUI;
use C4::Modelo::LogoUI::Manager;

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


=item
    Devuelve el path del archivo del logo de etiquetas
=cut
sub getPathLogoEtiquetas{

    my $logosArrayRef = C4::Modelo::LogoEtiquetas::Manager->get_logoEtiquetas( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => 1,
                                                                            );

    if(scalar(@$logosArrayRef) > 0){
        return C4::Context->config('logosIntraPath') . "/" . $logosArrayRef->[0]->getImagenPath;
    }else{
        return (0);
    }
}

=item
    Devuelve el tamaño del archivo del logo de etiquetas
=cut
sub getSizeLogoEtiquetas{

    my $logosArrayRef = C4::Modelo::LogoEtiquetas::Manager->get_logoEtiquetas( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => 1,
                                                                            );

    if(scalar(@$logosArrayRef) > 0){
        return ($logosArrayRef->[0]->getAncho, $logosArrayRef->[0]->getAlto);
    }else{
        return (0,0);
    }
}

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


sub deleteLogosUI{
    
    my $logos       = C4::Modelo::LogoUI::Manager->get_logoUI();

    my $uploaddir   = C4::Context->config('logosIntraPath');

    foreach my $logo (@$logos){

        my $image_name = $logo->getImagenPath();
        unlink($uploaddir."/".$image_name);
        $logo->delete();

    }

}

sub deleteLogos{
    
    my $logos       = C4::Modelo::LogoEtiquetas::Manager->get_logoEtiquetas();

    my $uploaddir   = C4::Context->config('logosIntraPath');

    foreach my $logo (@$logos){

        my $image_name = $logo->getImagenPath();
        unlink($uploaddir."/".$image_name);
        $logo->delete();

    }

}


sub modificarLogo{

    my ($params)    = @_;

    my $msg_object  = C4::AR::Mensajes::create();

    my $logo = getLogoById($params->{'idLogo'});

    if (C4::AR::Utilidades::validateString($params->{'alto'})){
        $logo->setAlto($params->{'alto'});
    }
    
    if (C4::AR::Utilidades::validateString($params->{'ancho'})){
        $logo->setAncho($params->{'ancho'});
    }

    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP08', 'params' => ['512 KB']} ) ;
    $logo->save();

    return ($msg_object);
    
}

sub agregarLogoUI{

    my ($params,$postdata) = @_;

    #borramos algun logo que este, para pisarlo con este nuevo
    deleteLogosUI();
    
    my $logo = C4::Modelo::LogoUI->new();

    $logo->setNombre('DEO-UI');
    
    # if (C4::AR::Utilidades::validateString($params->{'alto'})){
        # $logo->setAlto($params->{'alto'});
        # $logo->setAlto('1');
    # }
    
    # if (C4::AR::Utilidades::validateString($params->{'ancho'})){
        # $logo->setAncho($params->{'ancho'});
        # $logo->setAlto('1');
    # }
    
    my ($image,$msg) = uploadLogo($postdata,'DEO-UI', $params->{'context'});
    
    $logo->setImagenPath($image);
    
    if (!$msg->{'error'}){
       $logo->save();
    }
    
    return ($msg);
    
}

sub agregarLogo{

	my ($params,$postdata) = @_;

    #borramos algun logo que este, para pisarlo con este nuevo
    deleteLogos();
	
	my $logo = C4::Modelo::LogoEtiquetas->new();

    $logo->setNombre('DEO-booklabels');
	
	# if (C4::AR::Utilidades::validateString($params->{'alto'})){
		# $logo->setAlto($params->{'alto'});
        $logo->setAlto('1');
	# }
	
	# if (C4::AR::Utilidades::validateString($params->{'ancho'})){
		# $logo->setAncho($params->{'ancho'});
        $logo->setAlto('1');
	# }
	
	my ($image,$msg) = uploadLogo($postdata,'DEO-booklabels', $params->{'context'});
	
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
    my ($type,$notBinary)            = C4::AR::Utilidades::checkFileMagic($query, @filesAllowed);
    C4::AR::Debug::debug("type en logos.pm : " . $type);
    
    C4::AR::Debug::debug("vamos a escribir $name en el context $context y type $type en el dir $uploaddir y mono $uploaddir/$name.$type");
      
    if (!$type) {
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP00', 'params' => ['jpg','png','gif','jpeg']} ) ;
    }

    
    if (!$msg_object->{'error'}){

        if($notBinary){
        
            #no hay que escribirlo con binmode
            C4::AR::Debug::debug("UploadFile => uploadAdjuntoNovedadOpac => vamos a escribirla sin binmode");
            open(WRITEIT, ">$uploaddir/$name.$type") or die "Cant write to $uploaddir/$name.$type. Reason: $!";
            print WRITEIT $query;
            close(WRITEIT);
   
        }else{
        
            C4::AR::Debug::debug("UploadFile => uploadAdjuntoNovedadOpac => vamos a escribirla CON binmode");
            open ( WRITEIT, ">$uploaddir/$name.$type" ) or die "Cant write to $uploaddir/$name.$type. Reason: $!"; 
            binmode WRITEIT; 
            while ( <$query> ) { 
                print WRITEIT; 
            }
            close(WRITEIT);
        
        }
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
    
    use C4::Modelo::LogoEtiquetas::Manager;
    
    my @filtros;
    
    push (@filtros, (id => {eq => $id}) );
    
    my $logo = C4::Modelo::LogoEtiquetas::Manager->get_logoEtiquetas( query => \@filtros,);
    
    return $logo->[0];
}


sub listar{
    my $logos_array_ref = C4::Modelo::LogoEtiquetas::Manager->get_logoEtiquetas();

    my $logos_array_ref_count = C4::Modelo::LogoEtiquetas::Manager->get_logoEtiquetas_count();
    if(scalar(@$logos_array_ref) > 0){
        return ($logos_array_ref_count, $logos_array_ref);
    }else{
        return (0,0);
    }
}

sub listarUI{

    my $logos_array_ref = C4::Modelo::LogoUI::Manager->get_logoUI();

    my $logos_array_ref_count = C4::Modelo::LogoUI::Manager->get_logoUI_count();

    if(scalar(@$logos_array_ref) > 0){
        return ($logos_array_ref_count, $logos_array_ref);
    }else{
        return (0,0);
    }
}

1;
