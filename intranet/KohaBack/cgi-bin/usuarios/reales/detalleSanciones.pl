#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use Date::Manip;
use C4::Date;
use C4::AR::Sanctions;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "usuarios/reales/detalleSanciones.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $bornum= $obj->{'borrowernumber'};
my $dateformat = C4::Date::get_date_format();
my $sanctions = hasSanctions($bornum);

foreach my $san (@$sanctions) {
	if ($san->{'id3'}) {
		my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
		$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; 
	}

	$san->{'nddate'}=format_date($san->{'enddate'},$dateformat);
	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}

$template->param(
		sanctions       => $sanctions,
	);

output_html_with_http_headers $input, $cookie, $template->output;
