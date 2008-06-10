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


my $query = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-reserve.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

my $id2 = $query->param('id2');
my $id1 = $query->param('id1');

my %params;

$params{'tipo'}= 'OPAC'; #INTRA u OPAC
$params{'id1'}= $id1;
$params{'id2'}= $id2;
$params{'borrowernumber'}= $borrowernumber;
$params{'loggedinuser'}= $borrowernumber;
$params{'issuesType'}= 'DO';

my ($error, $reservaGrupo, $message)= &C4::AR::Reservas::reservarOPAC(\%params);

$template->param (
	message	=> $message,
	error	=> $error,
	reservaGrupo => $reservaGrupo,
	CirculationEnabled => C4::Context->preference("circulation"),
);

output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
