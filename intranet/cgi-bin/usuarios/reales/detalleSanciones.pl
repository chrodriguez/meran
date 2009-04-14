#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Date;
use C4::AR::Prestamos;
use Date::Manip;
use C4::Date;
use C4::AR::Sanciones;

my $input=new CGI;

my ($template, $session, $t_params) =  get_template_and_user ({
			template_name	=> 'usuarios/reales/detalleSanciones.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

my $obj=C4::AR::Utilidades::from_json_ISO($obj);
my $nro_socio= $obj->{'nro_socio'};

my $sanciones = C4::AR::Sanciones::tieneSanciones($nro_socio);

# foreach my $san (@$sanctions) {
# 	if ($san->{'id3'}) {
# 		my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
# 		$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; 
# 	}
# 
# 	$san->{'nddate'}=format_date($san->{'enddate'},$dateformat);
# 	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
# }

if (@$sanciones > 0){
	$t_params->{'SANCIONES'}= $sanciones;
}

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
