#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Date;
use C4::AR::Reservas; 
use Date::Manip;

my $input = new CGI;

my ($template, $borrowernumber, $params)= get_template_and_user({
									template_name => "opac-DetallePrestamos.tmpl",
									query => $input,
									type => "opac",
									authnotrequired => 0,
									flagsrequired => {borrow => 1},
									debug => 1,
			     });



my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $dateformat = C4::Date::get_date_format();

$params->{'borrowernumber'}= $borrowernumber;

my $issues = C4::AR::Issues::prestamosPorUsuario($borrowernumber);

my $count = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $venc=0;
my $cierre= C4::Context->preference("close");

foreach my $key (keys %$issues) {
	my $issue = $issues->{$key};
    	$issue->{'date_due'} = format_date($issue->{'date_due'},$dateformat);
    	my $err= "Error con la fecha"; 

     	my $hoy=C4::Date::format_date_in_iso(C4::Date::ParseDate("today"),$dateformat);
#      	my  $close = C4::Date::ParseDate(C4::Context->preference("close"));
	my  $close = C4::Date::ParseDate($cierre);
     	if (Date::Manip::Date_Cmp($close,C4::Date::ParseDate("today"))<0){#Se paso la hora de cierre
     		$hoy=C4::Date::format_date_in_iso(C4::Date::DateCalc($hoy,"+ 1 day",\$err),$dateformat);
     	}
   	my $df=C4::Date::format_date_in_iso(C4::AR::Issues::vencimiento($issue->{'id3'}),$dateformat);
    	$issue->{'date_fin'} = C4::Date::format_date($df,$dateformat);
    	if (Date::Manip::Date_Cmp($df,$hoy)<0){ 
		$venc=1;
	  	$issue->{'color'} ='red';
	}

    	$issue->{'renew'} = &C4::AR::Issues::sepuederenovar($borrowernumber, $issue->{'id3'});
    	if ($issue->{'overdue'}) {
		push @overdues, $issue;
		$overdues_count++;
		$issue->{'overdue'} = 1;
    	}else{
		$issue->{'issued'} = 1;
   	}	

	push @issuedat, $issue; 
    	$count++;
}


$params->{'vencimientos'}= $venc;
$params->{'ISSUES'}= \@issuedat;
$params->{'issues_count'}= $count;
$params->{'OVERDUES'}= \@overdues;
$params->{'overdues_count'}= $overdues_count;
$params->{'CirculationEnabled'}= C4::Context->preference("circulation");


C4::Auth::output_html_with_http_headers($input, $template, $params);
