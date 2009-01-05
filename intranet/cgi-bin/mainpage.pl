#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $params, $cookie)= get_template_and_user({
									template_name => "main.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {catalogue => 1, circulate => 1,
									parameters => 1, borrowers => 1,
									permissions =>1, reserveforothers=>1,
									borrow => 1, reserveforself => 1,
									editcatalogue => 1, updatesanctions => 1, },
									debug => 1,
			});

## FIXME para q es???????????????
my $marc_p = C4::Context->boolean_preference("marc");

$params->{'NOTMARC'} = !$marc_p;

C4::Auth::output_html_with_http_headers($query, $template, $params,$session, $cookie);
