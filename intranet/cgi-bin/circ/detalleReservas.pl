#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;


my $input=new CGI;

my ($template, $session, $params) =  get_template_and_user ({
			template_name	=> 'circ/detalleReservas.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });


my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrowernumber= $obj->{'borrnumber'};

# now the reserved items....
my ($rescount, $reserves) = C4::AR::Reservas::DatosReservas ($borrowernumber);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;
my $clase1='par';
my $clase2='par';

foreach my $res (@$reserves) {

# 	$res->{'rreminderdate'} = C4::Date::format_date($res->{'rreminderdate'},$dateformat);
# 	$res->{'rnotificationdate'}  = C4::Date::format_date($res->{'rnotificationdate'},$dateformat);
# 	$res->{'rreminderdate'}  = C4::Date::format_date($res->{'rreminderdate'},$dateformat);

	if ($res->{'estado'} eq 'E') {
# 		$res->{'rbranch'} = $branches->{$res->{'rbranch'}}->{'branchcode'};
		push @realreserves, $res;
		$rcount++;
	} else { 
		push @waiting, $res;
		$wcount++;
	} 
}#end for

$params{'RESERVES'}= \@realreserves;
$params{'reserves_count'}= $rcount;
$params{'WAITRESERVES'}= \@waiting;
$params{'waiting_count'}= $wcount;

C4::Auth::output_html_with_http_headers($input, $template, $params);

