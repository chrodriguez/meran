#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;

my $input=new CGI;

my ($template, $session, $t_params) = get_template_and_user({
																template_name => "opac-MARCdetail.tmpl",
																query => $input,
																type => "opac",
																authnotrequired => 1,
																flagsrequired => {borrow => 1},
			     						});

my $idNivel3=$input->param('id3');

my $MARCDetail_array= C4::AR::Busquedas::MARCDetail($idNivel3,'intra');

$t_params->{'MARCDetail_array'}= $MARCDetail_array;


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
