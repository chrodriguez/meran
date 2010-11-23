#!/usr/bin/perl

use strict;
use C4::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params, $socio) = get_template_and_user({
                        template_name => "reports/registro.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug => 1,
                    });


#Marca la Fecha de Hoy

my @datearr                 = localtime(time);
my $today                   = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $dateformat              = C4::Date::get_date_format();
$t_params->{'todaydate'}    = format_date($today,$dateformat);
my $dateformat              = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio             = format_date_in_iso($input->param('dateselected'),$dateformat);
my $fechaFin                = format_date_in_iso($input->param('dateselectedEnd'),$dateformat);

$t_params->{'select_usuarios'}  = C4::AR::Utilidades::generarComboDeSocios();
$t_params->{'page_sub_title'}   = C4::AR::Filtros::i18n('Registro de actividades');

C4::Auth::output_html_with_http_headers($template, $t_params, $session, $socio);
