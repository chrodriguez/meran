#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/users.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                        debug => 1,
			    });

my  $ui= $input->param('ui_name') || C4::AR::Preferencias::getValorPreferencia("defaultUI");
my $ComboUI=C4::AR::Utilidades::generarComboUI();

my %params;
$params{'default'}= 'SIN SELECCIONAR';
my $comboCategoriasDeSocio= C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);
#Para los a�os
my @date=localtime;
my $year_Default= $date[5]+1900;
my @years;
for (my $i =2005 ; $i < 2036; $i++){
	push (@years,$i);
}
my $years=CGI::scrolling_list(  -name      => 'year',
				-id	   => 'year',
                                -values    => \@years,
                                -defaults  => $year_Default,
                                -size      => 1,
                                 );
#fin a�os

$t_params->{'unidades'}= $ComboUI;
$t_params->{'categorias'}= $comboCategoriasDeSocio;
$t_params->{'years'}= $years;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);