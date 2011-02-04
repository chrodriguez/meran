#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Context;
use C4::AR::Proveedores;
use C4::AR::Recomendaciones;
use CGI;
use C4::AR::PdfGenerator;

my $input = new CGI;
my $to_pdf = $input->param('export') || 0;

my $template_name = "adquisiciones/listCompraEjemplares.tmpl";

if($to_pdf){
	$template_name = "adquisiciones/listado_ejemplares_export.tmpl";
}  

my ($template, $session, $t_params) = get_template_and_user({
    template_name => $template_name,
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
    debug => 1,
});
 
if($to_pdf){

    C4::AR::Debug::debug("libro1 ".$input->param('libro1'));
    C4::AR::Debug::debug("libro2 ".$input->param('libro2'));
    C4::AR::Debug::debug("cantidad ".$input->param('cantidad'));
    
#   agarrar todos los parametros y pasarselos al otro template (listado_ejemplares_export) por
#   $t_params para ahi exportar a pdf

	my $out = C4::AR::Auth::get_html_content( $template, $t_params, $session );
#	C4::AR::Debug::debug($out);
	my $filename = C4::AR::PdfGenerator::pdfFromHTML($out);
	
	print C4::AR::PdfGenerator::pdfHeader();

	C4::AR::PdfGenerator::printPDF($filename);

}else{

    my $recomendaciones_activas                 = C4::AR::Recomendaciones::getRecomendacionesActivas();
# sacar la cantidad total desde $recomendaciones_activas para PDF (arriba)
    C4::AR::Debug::debug("recomendaciones ".scalar($recomendaciones_activas));
    if($recomendaciones_activas){
        my @resultsdata;
      
        for my $recomendacion (@$recomendaciones_activas){   
            my %row = ( recomendacion => $recomendacion, );
            push(@resultsdata, \%row);
        }

       $t_params->{'resultsloop'}= \@resultsdata; 
       
    }#END if($recomendaciones_activas)

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
