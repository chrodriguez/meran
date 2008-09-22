#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Issues;
use Date::Manip;
use C4::Date;
use C4::AR::Sanctions;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user ({
	template_name	=> 'members/detallePrestamos.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
  });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrnumber'};
my $dateformat = C4::Date::get_date_format();
my $issues = prestamosPorUsuario($borrnumber);
my $count=0;
my $venc=0;
my @issuedat;

foreach my $key (keys %$issues) {

	my $issue = $issues->{$key};
    	$issue->{'date_due'} = format_date($issue->{'date_due'},$dateformat);
	my ($vencido,$df)= &C4::AR::Issues::estaVencido($issue->{'id3'},$issue->{'issuecode'});
    	$issue->{'date_fin'} = format_date($df,$dateformat);

	if ($vencido){ 
		$venc=1;
          	$issue->{'color'} ='red';
        }

    	push @issuedat, $issue;
    	$count++;
}


$template->param(
			circulateEnable => $count,
			bornum          => $borrnumber,
			prestamos       => \@issuedat,
);

output_html_with_http_headers $input, $cookie, $template->output;

