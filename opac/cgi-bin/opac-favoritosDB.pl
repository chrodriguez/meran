#!/usr/bin/perl
use strict;
require Exporter;

use CGI;
use C4::Auth;
use C4::Date;;
use Date::Manip;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									query => $input,
									type => "opac",
									authnotrequired => 0,
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
									debug => 1,
			     });
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $action = $obj->{'action'};
my $id1 = $obj->{'id1'};
my $nro_socio = C4::Auth::getSessionNroSocio();

print $session->header;

if ($action eq "add_favorite"){
    print C4::AR::Nivel1::addToFavoritos($id1,$nro_socio);
}
elsif ($action eq "delete_favorite"){
    print C4::AR::Nivel1::removeFromFavoritos($id1,$nro_socio);
}


1;