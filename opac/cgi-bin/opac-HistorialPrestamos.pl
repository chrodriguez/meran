#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-HistorialPrestamos.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
			});


my $obj=$input->param('obj');
$obj= &C4::AR::Utilidades::from_json_ISO($obj);

my $funcion= $obj->{'funcion'};
my $orden=$obj->{'orden'}||'date_due';
my $ini= $obj->{'ini'}||'';

my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);
my ($cantidad,$issues,$loop_reading)=C4::AR::Prestamos::getHistorialPrestamosParaTemplate(C4::Auth::getSessionNroSocio($session),$ini,$cantR,$orden);

$t_params->{'paginador'}= &C4::AR::Utilidades::crearPaginador($cantidad, $cantR, $pageNumber,$funcion,$t_params);
$t_params->{'loop_reading'}= $loop_reading;
$t_params->{'cantidad'}= $cantidad;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
