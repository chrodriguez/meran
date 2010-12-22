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
use Image::Resize;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		&uploadPhoto,
	   	&deletePhoto
        $uploadFile,
	);

my $picturesDir = C4::Context->config("picturesdir");

sub uploadPhoto{
	my ($bornum, $filepath) = @_;

    C4::AR::Debug::debug("UploadFile => uploadPhoto");    
    my $bytes_read; 
	my $msg                     = '';
    my $size                    = 0;
    my $msg_object              = C4::AR::Mensajes::create();
	my @extensiones_permitidas  = ("bmp","jpg","gif","png");
	my @nombreYextension        = split('\.',$filepath);

	if (scalar(@nombreYextension)==2) { 
	# verifica que el nombre del archivo tenga el punto (.)
		my $ext         = @nombreYextension[1];
		my $buff        = '';
		my $write_file  = $picturesDir."/".$bornum.".".$ext;
	
		if (!grep(/$ext/i,@extensiones_permitidas)) {
			$msg_object->{'error'}= 1;
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U341', 'params' => []} ) ;
            C4::AR::Debug::debug("UploadFile => uploadPhoto => extension no permitida error U341");	
		} else 
		{
	
			if (!(open(WFD,">$write_file"))) {
				$msg_object->{'error'}= 1;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U342', 'params' => []} ) ;	
                C4::AR::Debug::debug("UploadFile => uploadPhoto => no se puede escribir error U342");    
			}
			else	
			{
				while ($bytes_read=read($filepath,$buff,2096)) {
					$size += $bytes_read;
					binmode WFD;
					print WFD $buff;
				}
				close(WFD);
                my  $image = Image::Resize->new($write_file);
                    $image = $image->resize(250, 250);
                    open(FH, ">".$write_file);
                    print FH $image->jpeg();
                    close(FH);
				$msg_object->{'error'}= 0;
				C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U340', 'params' => []} ) ;	
                C4::AR::Debug::debug("UploadFile => uploadPhoto => error U340");    
			}
		}
	} else {
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U343', 'params' => []} ) ;	
        C4::AR::Debug::debug("UploadFile => uploadPhoto => error U343");    
	}

	return ($msg_object);
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