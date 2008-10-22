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
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&uploadPicture);

sub uploadPicture {

my ($bornum,$foto_name,$filepath)=@_;

my $picturesDir= C4::Context->config("picturesdir");
my $msg='';
my $bytes_read;
my $size= 0;
 
if (!$foto_name) {
#Hace el upload de un archivo
$msg= "Se subi&oacute; la foto con &eacute;xito";
my @extensiones_permitidas=("bmp","jpg","gif","png");
my @nombreYextension=split('\.',$filepath);
  if (scalar(@nombreYextension)==2) { # verifica que el nombre del archivo tenga el punto (.)
        my $ext= @nombreYextension[1];
        my $buff='';
        my $write_file= $picturesDir."/".$bornum.".".$ext;

        if (!grep(/$ext/i,@extensiones_permitidas)) {
                $msg= "Solo se permiten imagenes (".join(", ",@extensiones_permitidas).")";
        } else 
	    {

                if (!(open(WFD,">$write_file"))) {
                        $msg="Hay un error y el archivo no puede escribirse en el servidor.";
                }
		else	
		  {
			while ($bytes_read=read($filepath,$buff,2096)) {
				$size += $bytes_read;
				binmode WFD;
				print WFD $buff;
			}
			close(WFD);
		 }
          }
  } else {
        $msg= "El nombre del archivo no tiene un formato correcto";
  }
} else {
#Borra el archivo previamente subido
unlink($picturesDir.'/'.$foto_name);
}
}
