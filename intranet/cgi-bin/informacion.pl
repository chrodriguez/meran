#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;

my ($template, $t_params)= C4::Output::gettemplate("informacion.tmpl", 'intranet');


my $session = CGI::Session->new();
my $cookie= C4::Auth::_generarCookie($query,'sessionID', $session->param('sessionID'), '');

$t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),'INTRA',[]);

&C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);