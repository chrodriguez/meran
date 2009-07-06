#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por nro. de inventario


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::SxcGenerator;

my $input = new CGI;

my @results;
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $desde=$obj->{'desde'};
my $hasta=$obj->{'hasta'};
my $orden=$obj->{'orden'}||'barcode';
my $accion=$obj->{'accion'};

my ($template, $session, $t_params)
    = get_template_and_user({template_name => "reports/inventoryResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			     debug => 1,
			     });

#Buscar
# my ($cant,@res) = C4::Circulation::Circ2::listitemsforinventory($desde,$hasta,"",1,"todos",$orden); #Hay que paginar

$t_params->{'minBarcode'} = $desde;
$t_params->{'maxBarcode'} = $hasta;
$t_params->{'id_ui_origen'} = "";
my ($res) = C4::AR::Estadisticas::listadoDeInventorio($t_params);

# Generar Planilla
# my $planilla=generar_planilla_inventario($res,$loggedinuser);


# my $cant=scalar(@results);

$t_params->{'results'} = $res,
# $t_params->{'name'} => $planilla;
$t_params->{'cantidad'}=> scalar(@$res);
$t_params->{'desde'} = $desde;
$t_params->{'hasta'} = $hasta;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

