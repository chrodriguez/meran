#!/usr/bin/perl

require Exporter;

use strict;
use JSON;
use CGI;
use C4::AR::Auth;
use C4::AR::PdfGenerator;


my $input= new CGI;
my ($template, $session, $t_params);

#($template, $session, $t_params) = get_template_and_user({
#                        template_name => "usuarios/libre_deuda.tmpl",
#                        query => $input,
#                        type => "intranet",
#                        authnotrequired => 0,
#                        flagsrequired => {  ui => 'ANY', 
#                                            tipo_documento => 'ANY', 
#                                            accion => 'CONSULTA', 
#                                            entorno => 'undefined'},
#                        debug => 1,
# });

my $authnotrequired= 0;

my ($userid, $session, $flags) = C4::AR::Auth::checkauth(   $input, 
                                                        $authnotrequired,
                                                        {   ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'usuarios',
                                                            tipo_permiso => 'catalogo'
                                                        },
                                                        "intranet"
                            );

my $nro_socio = $input->param('nro_socio');
my $msg_object = C4::AR::Usuarios::_verificarLibreDeuda($nro_socio);

if (!($msg_object->{'error'})){
    my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
	C4::AR::PdfGenerator::libreDeuda($socio);
} else {
    my $infoOperacionJSON=to_json $msg_object;
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
}


#my $out= C4::AR::Auth::get_html_content($template, $t_params, $session);
#my $filename= C4::AR::PdfGenerator::pdfFromHTML($out);
#print C4::AR::PdfGenerator::pdfHeader();
#
#C4::AR::PdfGenerator::printPDF($filename);


