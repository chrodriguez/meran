#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Issues;
use Date::Manip;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
	template_name	=> 'circ/detallePrestamos.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrnumber'};

my $issueslist = C4::AR::Issues::prestamosPorUsuario($borrnumber);
my @issues;
my $dateformat = C4::Date::get_date_format();

foreach my $it (keys %$issueslist) {
	my $book= $issueslist->{$it};
	$book->{'date_due'} = format_date($book->{'date_due'},$dateformat);

	my ($vencido,$df)= &C4::AR::Issues::estaVencido($book->{'id3'},$book->{'issuecode'});
	$book->{'date_fin'} = format_date($df,$dateformat);
	if ($vencido){$book->{'color'} ='red';}

	$book->{'issuetype'}=$book->{'issuetype'};
	if ($book->{'autor'} eq ''){$book->{'autor'}=' ';}

	push @issues,$book
}

my $cantIssues=scalar(@issues);

$template->param(
	issues     	=> \@issues,
	cantIssues 	=> $cantIssues,
	borrowernumber  => $borrnumber
);

output_html_with_http_headers $input, $cookie, $template->output;

