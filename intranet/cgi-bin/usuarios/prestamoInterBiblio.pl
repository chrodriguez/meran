#!/usr/bin/perl

require Exporter;

use strict;
use CGI;
use C4::AR::PdfGenerator;

use C4::AR::Auth;
use C4::AR::Busquedas;


my $input= new CGI;
my $authnotrequired= 0;



# OBTENGO EL BORROWER LOGGEADO Y VERIFICO PERMISOS

# my $to_pdf = $input->param('export') || 0;
my ($template, $session, $t_params);
# my ($userid, $session, $flags); 

# if ($to_pdf){
    
    ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/prestamoInterBiblio-export.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
                });
# } else {
#       ($userid, $session, $flags) = checkauth( $input, 
#                                         $authnotrequired,
#                                         {   ui => 'ANY', 
#                                             tipo_documento => 'ANY', 
#                                             accion => 'CONSULTA', 
#                                             entorno => 'usuarios'
#                                         },
#                                         "intranet"
#                             );


      my $nro_socio = $input->param('nro_socio');
      my %t_params;
      $t_params{'nro_socio'} = $nro_socio;
      C4::AR::Validator::validateParams('U389',\%t_params,['nro_socio'] );

      my $accion = $input->param('tipoAccion');
      my $biblioDestino = C4::AR::Busquedas::getBranch($input->param('name_ui'));

      my $director = $input->param('director')||"___________________";


      my @autores=split("#",$input->param('autores'));
      my @titulos=split("#",$input->param('titulos'));
      my @otros=split("#",$input->param('otros'));
      my @datos;
      for(my $i=0;$i<scalar(@titulos);$i++){
          if($i<scalar(@autores)){
              $datos[$i]->{'autor'}=$autores[$i];
          }
          else{$datos[$i]->{'autor'}="";}
          if($i<scalar(@otros)){
              $datos[$i]->{'otros'}=$otros[$i];
          }
          else{$datos[$i]->{'otros'}="";}
          $datos[$i]->{'titulo'}=$titulos[$i];
      }

      my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);


      $t_params{'socio'}= $socio;
      $t_params{'biblio_destino'}= $biblioDestino;
      $t_params{'director'}= $director;
      $t_params{'datos'}= \@datos;

      C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);


# $socio->persona->getApellido;
# C4::AR::PdfGenerator::prestInterBiblio($nro_socio,$socio,$biblioDestino,$director,\@datos);
}

# if ($to_pdf){
#     $t_params->{'exported'} = 1;
#     my $out= C4::AR::Auth::get_html_content($template, $t_params, $session);
#     my $filename= C4::AR::PdfGenerator::pdfFromHTML($out);
# 
#     print C4::AR::PdfGenerator::pdfHeader();
# 
#     C4::AR::PdfGenerator::printPDF($filename);
#     
#     
# }


