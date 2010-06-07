#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

#Genera un inventario a partir de la busqueda por signatura topografica

my $input   = new CGI;
my @results;
my $obj     = C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $sigtop  = $obj->{'sigtop'};
my $orden   = $obj->{'orden'} || 'barcode';

my ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "reports/inventory-sig-topResult.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug           => 1,
             });

#Buscar
my $cat_nivel3;

if($sigtop ne ''){
   $cat_nivel3 = C4::AR::Estadisticas::listarItemsDeInventorioSigTop($sigtop,$orden);
}
#
# Generar Planilla
# my $loggedinuser = $session->param('loggedinuser');
# my $planilla=generar_planilla_inventario_sig_top(\@res,$loggedinuser);
#

my @results;
my $cant = scalar(@$cat_nivel3);


$t_params->{'results'}  = $cat_nivel3;

# print $cat_nivel3->[0]->nivel2->nivel1->autor;
# $t_params->{'name'}= $planilla;
$t_params->{'cantidad'} = $cant;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
