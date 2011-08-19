package C4::AR::UploadFile;

# module to upload/delete pictures of the borrowers
# written 03/2005
# by Luciano Iglesias - li@info.unlp.edu.ar - LINTI, Facultad de Informática, UNLP Argentina

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use C4::Context;
use C4::AR::Mensajes;
use C4::AR::Utilidades;
use C4::AR::Preferencias;
use Image::Resize;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		uploadPhoto
	 	deletePhoto
		uploadFile
		deleteDocument
	);

my $picturesDir = C4::Context->config("picturesdir");

sub uploadPhoto{
	my ($query) = @_;

    use C4::Modelo::UsrSocio;
    
    my $uploaddir       = C4::Context->config("picturesdir");
    my $maxFileSize     = 2048 * 2048; # 1/2mb max file size...
    my $file            = $query->param('POSTDATA');
    my $nro_socio       = $query->url_param('nro_socio'); 
    my $name            = $nro_socio;
    my $socio           = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
    my $type            = '';
     
    if ($file =~ /^GIF/i) {
        $type = "jpg";
    } elsif ($file =~ /PNG/i) {
        $type = "jpg";
    } elsif ($file =~ /JFIF/i) {
        $type = "jpg";
    } else {
        $type = "jpg";
    }

    if ($socio->tieneFoto){
    	unlink($socio->tieneFoto);
    }
    if (!$type) {
        print qq|{ "success": false, "error": "Invalid file type..." }|;
        print STDERR "file has been NOT been uploaded... \n";
    }
    
    $type = "jpg";
    
    open(WRITEIT, ">$uploaddir/$name.$type") or die "Cant write to $uploaddir/$name.$type. Reason: $!";
        print WRITEIT $file;
    close(WRITEIT);

    my $check_size = -s "$uploaddir/$name.$type";

    print STDERR qq|Main filesize: $check_size  Max Filesize: $maxFileSize \n\n|;

    print $query->header();
    
    if ($check_size < 1) {
        print STDERR "ooops, its empty - gonna get rid of it!\n";
        print qq|{ "success": false, "error": "File is empty..." }|;
        print STDERR "file has been NOT been uploaded... \n";
    } elsif ($check_size > $maxFileSize) {
        print STDERR "ooops, its too large - gonna get rid of it!\n";
        print qq|{ "success": false, "error": "File is too large..." }|;
        print STDERR "file has been NOT been uploaded... \n";
    } else  {
        print qq|{ "success": true }|;
        print STDERR "file has been successfully uploaded... thank you.\n";
 
    }
    

}

sub deletePhoto{
	my ($foto_name) = @_;
# TODO falta verificar permisos
	my $msg_object  = C4::AR::Mensajes::create();
	
# 	if (open(PHOTO,">>".$picturesDir.'/'.$foto_name)){
C4::AR::Debug::debug("UploadFile => deletePhoto => ".C4::AR::Utilidades::trim($picturesDir."/".$foto_name));
	if (unlink(C4::AR::Utilidades::trim($picturesDir."/".$foto_name))) { 
		$msg_object->{'error'}= 0;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U344', 'params' => []} ) ;	
	}else{
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U345', 'params' => []} ) ;	
	}
		
	return ($msg_object);
}

sub uploadFile{

    my ($prov,$write_file,$filepath, $presupuestos_dir) = @_;
    my $bytes_read; 
    my $msg                     = '';
    my $size                    = 0;
    my $msg_object              = C4::AR::Mensajes::create();
    my @extensiones_permitidas  = ("odt","xls");
  
    my @nombreYextension        = split('\.',$filepath);
   
    if (scalar(@nombreYextension)==2) { 
    
    # verifica que el nombre del archivo tenga el punto (.)
            my $ext         = @nombreYextension[1];
            my $buff        = '';
           
    #         if (!grep(/$ext/i,@extensiones_permitidas)) {
    #             $msg_object->{'error'}= 1;
    #             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U341', 'params' => []} ) ;
    #             C4::AR::Debug::debug("UploadFile => uploadPhoto => error U341");    
    #         } else 
    #         {
    #     
            if ((open(WFD,">$write_file"))) {
    #                 $msg_object->{'error'}= 1;
    #                 C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U342', 'params' => []} ) ;  
    #                 C4::AR::Debug::debug("UploadFile => uploadPhoto => error U342");    
    #             }
    #             else    
    #             {
                    while ($bytes_read=read($filepath,$buff,2096)) {
#                         C4::AR::Debug::debug("ESCRIBIENDO: ".$bytes_read);
                        $size += $bytes_read;
                        binmode WFD;
                        print WFD $buff;
                    }
                    close(WFD);
              }
    }
}

sub uploadDocument {

    my ($file_name,$name,$id2,$file_data)=@_;

    my $eDocsDir= C4::Context->config("edocsdir");
    my $msg='';
    my $bytes_read;
    my $size= 0;
    
    my $showName = $name;
    
    if (!C4::AR::Utilidades::validateString($showName)){
    	$showName = $file_name;
    }
    
    my @nombreYextension=split('\.',$file_name);

    use Digest::MD5;
#Para chequeos de tamaño
# my $maxFileSize = 2048 * 2048; # 1/2mb max file size...
# my $check_size = -s "$uploaddir/$name.$type";
#if ($check_size > $maxFileSize) { blabla }


    if (C4::AR::Preferencias::getPreferencia("e_documents")){

        my @extensiones_permitidas=("bmp","jpg","gif","png","jpeg","doc","docx","odt","pdf","xls","zip");
        my $size = scalar(@nombreYextension) - 1;
        my $ext= @nombreYextension[$size];

        if (!grep(/$ext/i,@extensiones_permitidas)) {
                $msg= "Solo se permiten archivos del tipo (".join(", ",@extensiones_permitidas).") [Fallo de extension]";
        }elsif (scalar(@nombreYextension)>=2) { # verifica que el nombre del archivo tenga el punto (.)
            my $ext= @nombreYextension[$size];
            my $buff='';
            
            $name = @nombreYextension[0];
            my $file_type = $ext;
            my $hash_unique = Digest::MD5::md5_hex(localtime());
            my $file_name = $name.".".$ext."_".$hash_unique;
            my $write_file= $eDocsDir."/".$file_name;
                                                                                                                                
            if (!open(WFD,">$write_file")) {
                    $msg="Hay un error y el archivo no puede escribirse en el servidor.";
            }else{
            	my $size = 0;
                while ($bytes_read=read($file_data,$buff,2096,0)) {
                        $size += $bytes_read;
                        binmode WFD;
                        print WFD $buff;
                }
                close(WFD);

                my $isValidFileType = C4::AR::Utilidades::isValidFile($write_file);

                if ( !$isValidFileType )
                {
                    $msg= "Solo se permiten archivos (".join(", ",@extensiones_permitidas).") [Fallo de contenido]";
                    unlink($write_file);
                }else
                {
                    $msg= "El archivo ".$name.".$ext ($showName) se ha cargado correctamente";
                    C4::AR::Catalogacion::saveEDocument($id2,$file_name,$isValidFileType,$showName);
                }
            }
        }else{
            $msg= C4::AR::Filtros::i18n("El nombre del archivo no tiene un formato correcto.");
        }
    }else{
         $msg= C4::AR::Filtros::i18n("El manejo de archivos no esta habilitado.");
    }

    return($msg);
}

sub deleteDocument {

    my ($query,$params)=@_;

    my $eDocsDir= C4::Context->config("edocsdir");
    my $msg='';
    my $file_id = $params->{'id'};

    if (C4::AR::Preferencias::getPreferencia("e_documents")){
        my $file = C4::AR::Catalogacion::getDocumentById($file_id);

        my $write_file= $eDocsDir."/".$file->getFilename;
                                                                                                                                
        if (!open(WFD,"$write_file")) {
                $msg=C4::AR::Filtros::i18n("Hay un error y el archivo no puede eliminarse del servidor.");
        }else{
            unlink($write_file);
            $msg= C4::AR::Filtros::i18n("El archivo ").$file->getTitle.C4::AR::Filtros::i18n(" se ha eliminado correctamente");
            $file->delete();
        }
    }else{
        $msg= C4::AR::Filtros::i18n("El manejo de archivos no esta habilitado.");
    }

    return($msg);
}
