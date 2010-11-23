#!/usr/bin/perl

# Miguel 21-05-07
# Se obtiene un Historial de los prestamos realizados por los usuarios

use strict;
use C4::Auth;

use CGI;
use C4::AR::Prestamos;
use C4::Biblio;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/historico_Prestamos.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                            debug => 1,
			    });


my $orden;
if ($input->param('orden') eq ""){
	 $orden='firstname'}
else {$orden=$input->param('orden')};

my %params;
$params{'default'}= 'SIN SELECCIONAR';

my $camboTiposPrestamos= C4::AR::Utilidades::generarComboTipoPrestamo();
my $comboCategoriasDeSocio= C4::AR::Utilidades::generarComboCategoriasDeSocio();
my $camboTiposDeDocumentos= C4::AR::Utilidades::generarComboTipoNivel3();

$t_params->{'orden'}= $orden;
$t_params->{'selectTiposDocumentos'}= $camboTiposDeDocumentos;
$t_params->{'selectCatUsuarios'}= $comboCategoriasDeSocio;
$t_params->{'selectTiposPrestamos'}= $camboTiposPrestamos;
$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Historial de prestamos");

C4::Auth::output_html_with_http_headers($template, $t_params, $session);