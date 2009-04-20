#!/usr/bin/perl

use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

my $input=new CGI;

my ($template, $session, $t_params) = get_template_and_user({
																template_name   => ('busquedas/MARCDetalle.tmpl'),
																query           => $input,
																type            => "intranet",
																authnotrequired => 0,
																flagsrequired   => {catalogue => 1},
    });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $idNivel3=$obj->{'id3'};

my $MARCDetail_array= C4::AR::Busquedas::MARCDetail($idNivel3,'intra');

$t_params->{'MARCDetail_array'}= $MARCDetail_array;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
