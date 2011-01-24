#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                        template_name => "reports/historicoSanciones.tmpl",
			                            query => $input,
			                            type => "intranet",
			                            authnotrequired => 0,
			                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			                            debug => 1,
			     });


my $orden= "date"; 

###Marca la Fecha de Hoy          
# my @datearr = localtime(time);
# my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
# my $dateformat = C4::Date::get_date_format();
# $t_params->{'todaydate'}= C4::Date::format_date($today,$dateformat);


$t_params->{'selectusuarios'}= C4::AR::Utilidades::generarComboDeSocios();
$t_params->{'selectTiposPrestamos'}= C4::AR::Utilidades::generarComboTipoPrestamo();
my %params_combo;
$params_combo{'clone_values'}= 1;
$t_params->{'selectTipoOperacion'}=C4::AR::Utilidades::generarComboTipoDeOperacion(\%params_combo);

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
