#!/usr/bin/perl
  
use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Busquedas;
 
my $input = new CGI;
 
my $op=$input->param('op');

if ($op eq 'pdf') {

    my $obj;
    $obj->{'orden'}=$input->param('orden')||'apellido';
    $obj->{'apellido1'}=$input->param('surname1');
    $obj->{'apellido2'}=$input->param('surname2');
    $obj->{'legajo1'}=$input->param('legajo1');
    $obj->{'legajo2'}=$input->param('legajo2');
    $obj->{'categoria_socio'}=$input->param('categoria_socio');
    $obj->{'export'}=1;

my ($cantidad,$results)=C4::AR::Usuarios::BornameSearchForCard($obj);

C4::AR::Utilidades::printARRAY($results);
 #HAY QUE GENERAR EL PDF CON LOS CARNETS
C4::AR::PdfGenerator::batchCardsGenerator($cantidad,$results);

}else{

 my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "/usuarios/reales/users-cards.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                 accion => 'CONSULTA', 
                                                 entorno => 'undefined'},
                             debug => 1,
     });

     my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
     my  $ui= $input->param('ui_name') || C4::AR::Preferencias::getValorPreferencia("defaultUI");
     my $ComboUI=C4::AR::Utilidades::generarComboUI();
     my %params;
 
     $params{'default'}= 'SIN SELECCIONAR';
     my $comboCategoriasDeSocio= C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);
     my $CGIregular = C4::AR::Utilidades::generarComboRegular();
  
     $t_params->{'unidades'}= $ComboUI;
     $t_params->{'categories'}= $comboCategoriasDeSocio;
     $t_params->{'regulares'}=$CGIregular;
 
      C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
  
   }




