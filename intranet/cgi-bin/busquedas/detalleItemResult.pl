#!/usr/bin/perl

use strict;
require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
			template_name   => 'busquedas/detalleItemResult.tmpl',
			query           => $input,
			type            => "intranet",
			authnotrequired => 0,
			flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
        });

my $dateformat = C4::Date::get_date_format();
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $id3=$obj->{'id3'};
my $fechaIni= $obj->{'fechaIni'};
my $fechaFin= $obj->{'fechaFin'};
my $funcion = $obj->{'funcion'};
my $orden=$obj->{'orden'}||'date';
my $fechaIni=  format_date_in_iso($fechaIni,$dateformat);
my $fechaFin=  format_date_in_iso($fechaFin,$dateformat);

my $ini;
my $cantR;
my $orden;
my $tipoPres;
my $tipoOp;

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,@resultsdata)= &historicoCirculacion('ok',$fechaIni,$fechaFin,'-1',$id3,$ini,$cantR,$orden,$tipoPres, $tipoOp);

C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion,$t_params);

$template->param(
		HISTORICO => \@resultsdata,
		);

output_html_with_http_headers $cookie, $template->output;