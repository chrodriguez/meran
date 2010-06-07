#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::AR::Reportes;

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
my $array_hash_ref;

if($sigtop ne ''){
   ($cat_nivel3, $array_hash_ref)   = C4::AR::Estadisticas::listarItemsDeInventorioSigTop($sigtop,$orden);
   my ($path, $filename)            = C4::AR::Reportes::toXLS($array_hash_ref,1,'Pagina 1','inventario');
      
   $t_params->{'filename'}          = '/reports/'.$filename;

}

my $cant                = scalar(@$cat_nivel3);
$t_params->{'results'}  = $cat_nivel3;
$t_params->{'cantidad'} = $cant;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
