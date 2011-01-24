#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;

my ($template, $t_params)   = C4::Output::gettemplate("informacion/error.tmpl", 'intranet');

my $session                 = CGI::Session->load();
$t_params->{'loggedinuser'} = $session->param('userid');
my $message_error           = "404";

if ($ENV{'REDIRECT_STATUS'}  eq "404") {
    $message_error = C4::Context->preference("404_error_message") || $message_error;
} elsif ($ENV{'REDIRECT_STATUS'}  eq "500") {
    $message_error = C4::Context->preference("500_error_message") || $message_error;
}  

$t_params->{'message_error'}      = $message_error;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);