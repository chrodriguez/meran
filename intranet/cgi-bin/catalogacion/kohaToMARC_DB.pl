#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::VisualizacionOpac;
use C4::AR::Utilidades;

my $input = new CGI;
my ($userid, $session, $flags) = checkauth($input, 0,{ editcatalogue => 1});

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $tabla= $obj->{'tabla'}||"";
my $action= $obj->{'action'}||"";


#******* Se arma una tabla con la catalogacion de OPAC y se muestra con un tmpl********************
if(($tabla ne "")&&($action eq "TABLARESULT")){

my ($template, $loggedinuser, $cookie)= get_templateexpr_and_user({template_name => "catalogacion/kohaToMARCResult.tmpl",
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

print  $template->output;
}

#**************************************************************************************************

#**************************************Agrego Mapeo********************************************
if(($tabla ne "")&&($action eq "INSERT")){

my $campoKoha= $obj->{'campoKOHA'}||"";
my $campo= $obj->{'campoMARC'}||"";
my $subcampo= $obj->{'subcampoMARC'}||"";

&insertarMapeoKohaToMARC($tabla, $campoKoha, $campo, $subcampo);

print $input->header;
}
#**************************************************************************************************

#**************************************Elimino Mapeo********************************************
if(($action eq "DELETE")){

my $id= $obj->{'idmap'}||"";

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
