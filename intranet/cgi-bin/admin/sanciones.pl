#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use Template;
use C4::AR::Sanciones;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "admin/sanciones.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug => 1,
			    });

my $params;
$params->{'onChange'}='buscarTiposPrestamosSancionados()';

my $CGIusr_ref_categoria_socio=C4::AR::Utilidades::generarComboCategoriasDeSocio($params);
my $CGIcirc_ref_tipo_prestamo=C4::AR::Utilidades::generarComboTipoPrestamo($params);

$t_params->{'categorias_de_socio'}= $CGIusr_ref_categoria_socio;
$t_params->{'tipos_de_prestamos'}= $CGIcirc_ref_tipo_prestamo;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
