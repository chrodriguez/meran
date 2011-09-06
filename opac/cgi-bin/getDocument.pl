#!/usr/bin/perl



# Copyright 2000-2002 Katipo Communications
#
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
#

use strict;
use C4::AR::Auth;
use C4::Output;
use CGI;
use C4::AR::Catalogacion;
use C4::Context;
my $input = new CGI;

#SE PONE CUALQUIER TEMPLATE PARA EL CHEQUEO DE PERMISOS, PERO EL TEMPLATE NO SE USA
my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "main.tmpl",
                        query => $input,
                        type => "opac",
                        authnotrequired => 1,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'CONSULTA', 
                                            tipo_permiso => 'undefined'},
                        debug => 1,
                    });

my $file_id=$input->param('id');
my $eDocsDir = C4::Context->config('edocsdir');
my $file = C4::AR::Catalogacion::getDocumentById($file_id);
my $tmpFileName = $eDocsDir.'/'.$file->getFilename;

open INF, $tmpFileName or die "\nCan't open $tmpFileName for reading: $!\n";

print $input->header(
                            -type           => $file->getFileType, 
                            -attachment     => $file->getTitle,
                            -expires        => '0',
                    );
my $buffer;

#SE ESCRIBE EL ARCHIVO EN EL CLIENTE
while (read (INF, $buffer, 65536) and print $buffer ) {};


