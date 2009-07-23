#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                      template_name => "reports/avail_year.tmpl",
                      query => $input,
                      type => "intranet",
                      authnotrequired => 0,
                      flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                      debug => 1,
              });

my  $ui= $input->param('id_ui') || C4::AR::Preferencias->getValorPreferencia("defaultUI");

my %params;
$params{'onChange'}= 'hacerSubmit()';
my $ComboUI=C4::AR::Utilidades::generarComboUI(\%params);

#Fechas
my $ini='';
my $fin='';
if($input->param('ini')){
   $ini=$input->param('ini');
}
if($input->param('fin')){
   $fin=$input->param('fin');
}
#

my ($cantidad,$resultsdata)= C4::AR::Estadisticas::disponibilidadAnio($ui,$ini,$fin); 

my $dateformat = C4::Date::get_date_format();

$t_params->{'resultsloop'}=$resultsdata;
$t_params->{'cantidad'}=$cantidad;
$t_params->{'unidades'}= $ComboUI;
$t_params->{'ui'}=$ui;
$t_params->{'ini'}=$ini;
$t_params->{'fin'}=$fin;
$t_params->{'namepng'}=&format_date_in_iso($ini,$dateformat).&format_date_in_iso($fin,$dateformat);


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
