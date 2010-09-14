#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
            template_name => "opac-main.tmpl",
            query => $input,
            type => "opac",
            authnotrequired => 0,
            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
            debug => 1,
      });

my $ini = $input->param('page') || 0;
my $orden = 'titulo';
my $url = "/cgi-bin/koha/opac-prestamos_vigentes.pl?token=".$input->param('token');
my $nro_socio = C4::Auth::getSessionNroSocio($session);
my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,$prestamos)=C4::AR::Prestamos::getHistorialPrestamosVigentesParaTemplate($nro_socio,$ini,$cantR,$orden);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginadorOPAC($cantidad, $cantR, $pageNumber,$url,$t_params);
$t_params->{'prestamos'}= $prestamos;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'content_title'}= C4::AR::Filtros::i18n("Pr&eacute;stamos Vigentes");
$t_params->{'partial_template'}= "opac-prestamos_vigentes.inc";

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
