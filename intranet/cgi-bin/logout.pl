#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI::Session;

my ($template, $t_params)= C4::Output::gettemplate("auth.tmpl", 'intranet');

my ($session)= C4::Auth::cerrarSesion();

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
