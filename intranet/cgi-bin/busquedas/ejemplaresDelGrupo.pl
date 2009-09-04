#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;
my $obj;
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ('busquedas/ejemplaresDelGrupo.tmpl'),
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
});

#Cuando viene desde otra pagina que llama al detalle.
my $id2= $obj->{'id2'};
#ob tengo el tipo de documento del grupo
my $itemtype= C4::AR::Nivel2::getTipoDocumento($id2);
my($nivel3,$nivel3Comp)=&C4::AR::Nivel3::detalleNivel3($id2,$itemtype,'intra');

$template->param(
	loopnivel3 => $nivel3,
	loopnivel3Comp => $nivel3Comp,
);

output_html_with_http_headers $cookie, $template->output;

