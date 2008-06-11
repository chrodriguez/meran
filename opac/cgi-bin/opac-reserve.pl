#!/usr/bin/perl
# NOTE: This file uses standard 8-character tabs

use strict;
require Exporter;
use CGI;

use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::AR::Reservas;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Context;
use C4::AR::Mensajes;
use C4::AR::Utilidades;


my $query = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-reserve.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });


my $obj=$query->param('obj');

$obj=from_json_ISO($obj);


my $id1= $obj->{'id1'};
my $id2 = $obj->{'id2'};

my %params;

$params{'tipo'}= 'OPAC'; 
$params{'id1'}= $id1;
$params{'id2'}= $id2;
$params{'borrowernumber'}= $borrowernumber;
$params{'loggedinuser'}= $borrowernumber;
$params{'issuesType'}= 'DO';

my ($error, $codMsg, $message)= &C4::AR::Reservas::reservarOPAC(\%params);

my $acciones= getAccion($codMsg);

if($acciones->{'tablaReservas'}){
#EL USUARIO LLEGO AL MAXIMO DE RESERVAS, Y SE MUESTRAN LAS RESERVAS HECHAS
	my ($cant, $reservas)= C4::AR::Reservas::DatosReservas($borrowernumber);

	$template->param (
		RESERVES => $reservas
	);
}

$template->param (
	
	message	=> $message,
	error	=> $error,
	reservaGrupo => $acciones->{'reservaGrupo'},
	tablaReservas => $acciones->{'tablaReservas'},
	CirculationEnabled => C4::Context->preference("circulation"),
);

output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
