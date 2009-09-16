#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Estantes;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipo= $obj->{'tipo'};


if(($tipo eq "VER_ESTANTE")||($tipo eq "VER_SUBESTANTE")){

	my ($template, $session, $t_params) = get_template_and_user(
            {template_name => "estantes/subEstante.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
					});
	
	my $id_estante= $obj->{'estante'};
    my $estante= C4::AR::Estantes::getEstante($id_estante);
    my $subEstantes= C4::AR::Estantes::getSubEstantes($id_estante);

	$t_params->{'estante'}= $estante;
    $t_params->{'SUBESTANTES'}= $subEstantes;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

