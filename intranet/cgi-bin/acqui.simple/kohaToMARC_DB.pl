#!/usr/bin/perl

# $Id: addbiblio.pl,v 1.32.2.7 2004/03/19 08:21:01 tipaul Exp $

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

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::CatalogacionOpac;
use C4::AR::Utilidades;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});
my $tabla= $input->param('tabla')||"";
my $action= $input->param('action')||"";


#******* Se arma una tabla con la catalogacion de OPAC y se muestra con un tmpl********************
if(($tabla ne "")&&($action eq "TABLARESULT")){

my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => "acqui.simple/kohaToMARCResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
});

my ($cant, @results)= &traerKohaToMARC($tabla);

$template->param( 	
 			RESULTSLOOP      => \@results,
		);

# output_html_with_http_headers $input, $cookie, $template->output;
print  $template->output;
}

#**************************************************************************************************

#**************************************Agrego Mapeo********************************************
if(($tabla ne "")&&($action eq "INSERT")){

my $campoKoha= $input->param('campoKOHA')||"";
my $campo= $input->param('campoMARC')||"";
my $subcampo= $input->param('subcampoMARC')||"";

&insertarMapeoKohaToMARC($tabla, $campoKoha, $campo, $subcampo);

print $input->header;
}
#**************************************************************************************************

#**************************************Elimino Mapeo********************************************
if(($action eq "DELETE")){

my $id= $input->param('idmap')||"";

&deleteMapeoKohaToMARC($id);

print $input->header;
}
#**************************************************************************************************

#**********************************Combo campos KOHA**********************************************
if(($tabla ne "")&&($action eq "SELECT")){
#campo KOHA
my ($cant,@resultsCamposKoha)= &obtenerCampos($tabla);#&showCamposKoha($tabla);
 
my $i=0;
my $result="";

foreach my $data (@resultsCamposKoha){

$result .= $data->{'campo'}."#";

}

print $input->header;
print $result;
	
}
#******************************Fin****Combo campos KOHA*******************************************
