package C4::AR::Novedades;

use strict;
use HTML::Entities;
require Exporter;
use C4::Modelo::SysNovedad;
use C4::Modelo::SysNovedad::Manager;
use C4::Modelo::SysNovedadNoMostrar;
use C4::Modelo::SysNovedadNoMostrar::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 
    getNovedadesNoMostrar
    getUltimasNovedades
    getNovedad
    listar
    agregar
    getNovedadesByFecha
    getPortadaOpac
    addPortadaOpac
    modPortadaOpac
);


sub agregar{

    my ($params, @arrayFiles)    = @_;
    my $novedad     = C4::Modelo::SysNovedad->new();
    my $msg_object  = C4::AR::Mensajes::create();
    my $db          = $novedad->db;
    my $image_name;
    
    use C4::AR::UploadFile;
    use C4::Modelo::ImagenesNovedadesOpac;
    
    if (!($msg_object->{'error'})){
    
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
        
        my $imagenes_novedades_opac;   
        
        eval{

            #agregamos primero la novedad
            #para sacarle el id despues
            C4::AR::Utilidades::printHASH($params->{'param'});
            $novedad->agregar($params->{'param'});
        
            #recorremos todas las imagenes y las guardamos      
            foreach my  $value (@arrayFiles) {
                     
                #pasarle la data necesaria
                $image_name = C4::AR::UploadFile::uploadFotoNovedadOpac($value);
                
                $imagenes_novedades_opac = C4::Modelo::ImagenesNovedadesOpac->new(db => $db);                 
                $imagenes_novedades_opac->saveImagenNovedad($image_name, $novedad->getId());                
                
                $msg_object->{'error'}= 0;
                
            }
            
            $db->commit;

        };

        if ($@){
        
           &C4::AR::Mensajes::printErrorDB($@, 'B449',"INTRA");
           $msg_object->{'error'}= 1;
           C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B449', 'params' => []} ) ;
           $db->rollback;
           
        }

        $db->{connect_options}->{AutoCommit} = 1;
     }
     
     return ($image_name);

}


sub editar{

    my ($input) = @_;
    my %params;
    my $novedad = getNovedad($input->param('novedad_id'));

    use HTML::Entities;
    my $contenido = $input->param('contenido');

    %params = $input->Vars;
    $params{'contenido'} = $contenido;
    $novedad->delete();
    $novedad = C4::Modelo::SysNovedad->new();
    
    return ($novedad->agregar(%params));
}


sub listar{
    my ($ini,$cantR) = @_;
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => $cantR,
                                                                                offset  => $ini,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref_count, $novedades_array_ref);
    }else{
        return (0,0);
    }
}

=item
    Esta funcion obtiene las novedades que no hay que mostrarle al socio recibido como parametro
=cut
sub getNovedadesNoMostrar{

    my ($nro_socio) = @_;
    
    my @filtros;
    
    push (@filtros, (usuario_novedad => {eq => $nro_socio}) );

    my $novedades_array_ref = C4::Modelo::SysNovedadNoMostrar::Manager->get_sys_novedad_no_mostrar( query => \@filtros,
                                                                              );
    if(scalar(@$novedades_array_ref) > 0){
        return (scalar(@$novedades_array_ref),$novedades_array_ref);
    }else{
        return (0,0);
    }
}

=item
    Esta funcion "elimina" la novedad recibida como parametro, la agrega a la tabla para no motrarla mas al user
=cut
sub noMostrarNovedad{

    my ($id_novedad) = @_;
    my %params;
    $params{'id_novedad'} = $id_novedad;
    
    my $novedad_no_borrar = C4::Modelo::SysNovedadNoMostrar->new();
    
    $novedad_no_borrar->agregar(%params);
    
    return "ok";
}

sub getUltimasNovedades{
    my ($limit) = @_;
    
    my $pref_limite = $limit || C4::AR::Preferencias::getValorPreferencia('limite_novedades');

    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['id DESC'],
                                                                                limit   => $pref_limite,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
    	if ($limit == 1){
            return ($novedades_array_ref_count, $novedades_array_ref->[0]);
    	}else{
            return ($novedades_array_ref_count, $novedades_array_ref);
    	}
    }else{
        return (0,0);
    }
}

sub getNovedad{

    my ($id_novedad) = @_;
    my @filtros;

    push (@filtros, (id => {eq => $id_novedad}) );
    
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( query => \@filtros,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref->[0]);
    }else{
        return (0);
    }
}


=item
    Trae las imagenes (si las hay) apartir de un id_novedad
=cut
sub getImagenesNovedad{

    my ($id_novedad) = @_;
    my @filtros;

    use C4::Modelo::ImagenesNovedadesOpac;
    use C4::Modelo::ImagenesNovedadesOpac::Manager;
    
    push (@filtros, (id_novedad => {eq => $id_novedad}) );
    
    my $novedades_array_ref = C4::Modelo::ImagenesNovedadesOpac::Manager->get_imagenes_novedades_opac( query => \@filtros,
                                                                              );

    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref, scalar(@$novedades_array_ref));
    }else{
        return (0,0);
    }
    
}

=item
    Trae las imagenes (si las hay) apartir de un id_novedad
=cut
sub eliminarImagenesNovedad{

    my ($id_novedad) = @_;
    my @filtros;

    use C4::Modelo::ImagenesNovedadesOpac;
    use C4::Modelo::ImagenesNovedadesOpac::Manager;
    
    push (@filtros, (id_novedad => {eq => $id_novedad}) );
    
    my $novedades_array_ref = C4::Modelo::ImagenesNovedadesOpac::Manager->get_imagenes_novedades_opac( query => \@filtros,
                                                                              );

    if(scalar(@$novedades_array_ref) > 0){
    
        foreach my $imagen (@$novedades_array_ref){
            $imagen->delete();
        }
        
    }else{
        return (0);
    }
    
}

sub eliminar{

    my ($id_novedad) = @_;
    my @filtros;

    push (@filtros, (id => {eq => $id_novedad}) );
    
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( query => \@filtros,
                                                                              );

    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref->[0]->delete());
    }else{
        return (0);
    }
}

=item
    Trae las novedades ordenadas por fecha
=cut
sub getNovedadesByFecha{
#    my ($ini,$cantR) = @_;
    my $novedades_array_ref = C4::Modelo::SysNovedad::Manager->get_sys_novedad( 
                                                                                sort_by => ['fecha DESC'],
#                                                                                limit   => $cantR,
#                                                                                offset  => $ini,
                                                                              );

    #Obtengo la cant total de sys_novedads para el paginador
    my $novedades_array_ref_count = C4::Modelo::SysNovedad::Manager->get_sys_novedad_count();
    if(scalar(@$novedades_array_ref) > 0){
        return ($novedades_array_ref_count, $novedades_array_ref);
    }else{
        return (0,0);
    }
}


sub getPortadaOpac{
	
	use C4::Modelo::PortadaOpac::Manager;
	
	my @filtros;
	
	my $portada = C4::Modelo::PortadaOpac::Manager->get_portada_opac( sort_by => ['orden ASC']);
	
	return $portada;
}

sub addPortadaOpac{
	my ($params,$postdata) = @_;
	
	my $portada = C4::Modelo::PortadaOpac->new();
	
	if (C4::AR::Utilidades::validateString($params->{'footer'})){
		$portada->setFooter($params->{'footer'});
		$portada->setFooterTitle($params->{'footer_title'});
	}
	
	my ($image,$msg) = uploadCoverImage($postdata);
	
	$portada->setImagePath($image);
	
	if (!$msg->{'error'}){
	   $portada->save();
	}
	
	return ($msg);
	
}

sub modPortadaOpac{
    my ($params) = @_;
    
    my $msg_object  = C4::AR::Mensajes::create();
    
    
    
    eval{
	    my $portada = getPortadaOpacById($params->{'id_portada'});
	
	    if (C4::AR::Utilidades::validateString($params->{'footer'})){
	        $portada->setFooter($params->{'footer'});
	        $portada->setFooterTitle($params->{'footer_title'});
	    }
	    
	    $portada->save();
    };
    
    
    if ($@){
    	$msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP11', 'params' => []} ) ;
    }else{
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP10', 'params' => []} ) ;
    }
      
    return ($msg_object);
    
}



sub getPortadaOpacById{
    
    my ($id) = @_;
    
    use C4::Modelo::PortadaOpac::Manager;
    
    my @filtros;
    
    push (@filtros, (id => {eq => $id}) );
    
    my $portada = C4::Modelo::PortadaOpac::Manager->get_portada_opac( query => \@filtros,);
    
    return $portada->[0];
}


sub delPortadaOpac{
    my ($id) = @_;
    
    my $msg_object  = C4::AR::Mensajes::create();

    my $portada = getPortadaOpacById($id);
    
    my $uploaddir       = C4::Context->config("opachtdocs")."/uploads/portada";
    
    if ($portada){
	    my $image_name = $portada->getImagePath();
	    unlink($uploaddir."/".$image_name);
	    $portada->delete();
	    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP09', 'params' => ['jpg','png','gif']} ) ;
    }
            
    return ($msg_object);
    
}


sub uploadCoverImage{
    my ($postdata) = @_;

    use Digest::MD5;
    
    my $uploaddir       = C4::Context->config("opachtdocs")."/uploads/portada";
    my $maxFileSize     = 1024 * 1024; # 1/2mb max file size...
    my $file            = $postdata;
    my $type            = "";
    my $msg_object  = C4::AR::Mensajes::create();

    my $new_name        = Digest::MD5::md5_hex(localtime());
    
    if ($file =~ /^GIF/i) {
        $type = "gif";
    } elsif ($file =~ /PNG/i) {
        $type = "png";
    } elsif ($file =~ /JFIF/i) {
        $type = "jpg";
    } else {
        $type = "jpg";
    }


    if (!$type) {
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP00', 'params' => ['jpg','png','gif']} ) ;
    }

    
    if (!$msg_object->{'error'}){
    	eval{
		    open ( WRITEIT, ">$uploaddir/$new_name.$type" ) or die "$!"; 
		    binmode WRITEIT; 
		    while ( <$postdata> ) { 
		    	print WRITEIT; 
		    }
		    close(WRITEIT);
    	};
    	if ($@){
	         $msg_object->{'error'}= 1;
	         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP02',} ) ;
    	}
    }
    
    if (!$msg_object->{'error'}){
	    my $check_size = -s "$uploaddir/$new_name.$type";
	
	    if ($check_size > $maxFileSize) {
	         $msg_object->{'error'}= 1;
             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP07', 'params' => ['512 KB']} ) ;
	    } 
    }    
    
    if (!$msg_object->{'error'}){
    	C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'UP08', 'params' => ['512 KB']} ) ;
    }
    
    return ($new_name.".".$type,$msg_object);

}


1;
