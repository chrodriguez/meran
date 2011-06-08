#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;

use C4::AR::Busquedas;
use C4::AR::Utilidades;
use HTML::Template;

my $query = new CGI;

my $tema=$query->param('tema');
my $detalle=$query->param('detalle');


my $obj=$query->param('obj');

if($obj ne ""){
	$obj=from_json_ISO($obj);
}

$tema= $obj->{'tema'};


my $search;
$search->{'tema'}=$tema;
$search->{'detalle'}=$detalle;


my ($template, $nro_socio, $cookie)
    = get_template_and_user({template_name => "busquedas/tema.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {     ui => 'ANY', 
                                        tipo_documento => 'ANY', 
                                        accion => 'CONSULTA', 
                                        entorno => 'undefined'},
			     debug => 1,
			     });

my ($count,@results)=&buscarTema($search);

  $template->param(SEARCH_RESULTS => \@results);
  $template->param(numrecords => $count);
  $template->param(value => $tema);

output_html_with_http_headers $cookie, $template->output;
