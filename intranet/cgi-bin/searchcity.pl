#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Koha;
use C4::Date;
use C4::Search;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "searchcity.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {catalogue =>1,editcatalogue=>1,borrowers=>1},
                                debug => 1,
                                });


my $ciudad = $input->param("ciudad");
if ($ciudad){
	$template->param(ciudades => buscarCiudades($ciudad),);
}
else{
	$template->param(ciudades => buscarCiudadesMasUsadas(),);
}

output_html_with_http_headers $input, $cookie, $template->output;
