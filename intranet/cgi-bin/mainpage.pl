#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
# use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
use C4::Auth;

# use Template;
use CGI;

my $query = new CGI;

# my $input = new Template;

my ($template, $loggedinuser, $cookie, $params)
	= get_template_and_user({
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

my $marc_p = C4::Context->boolean_preference("marc");

$params->{'NOTMARC'} = !$marc_p;
# $params->{'top'}= "intranet-top.inc",
# 		'menuInc' => "menu.inc",
# 		'themelang' => '/intranet-tmpl/blue/es2/',
# 	    };

print "Content-type: text/html\n\n";

$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";
