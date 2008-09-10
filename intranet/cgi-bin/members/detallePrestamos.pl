#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Issues;
use Date::Manip;
use C4::Date;
# use C4::AR::Reservas;
use C4::AR::Sanctions;
# use C4::AR::Busquedas;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
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

=item
my $data=C4::AR::Usuarios::getBorrowerInfo($borrnumber);
$data->{'updatepassword'}= $data->{'changepassword'};

my $dateformat = C4::Date::get_date_format();
# Curso de usuarios#
if (C4::Context->preference("usercourse")){
	$data->{'course'}=1;
	$data->{'usercourse'} = C4::Date::format_date($data->{'usercourse'},$dateformat);
}
#
$data->{'dateenrolled'} = C4::Date::format_date($data->{'dateenrolled'},$dateformat);
$data->{'expiry'} = C4::Date::format_date($data->{'expiry'},$dateformat);
$data->{'dateofbirth'} = C4::Date::format_date($data->{'dateofbirth'},$dateformat);
$data->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');

$data->{'city'}=C4::AR::Busquedas::getNombreLocalidad($data->{'city'});
$data->{'streetcity'}=C4::AR::Busquedas::getNombreLocalidad($data->{'streetcity'});

# Converts the branchcode to the branch name
$data->{'branchcode'} = C4::AR::Busquedas::getBranch($data->{'branchcode'})->{'branchname'};

# Converts the categorycode to the description
$data->{'categorycode'} = C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});
=cut

my $issues = prestamosPorUsuario($borrnumber);
my $count=0;
my $venc=0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $sanctions = hasSanctions($borrnumber);
####Es regular el Usuario?####
my $regular =&C4::AR::Usuarios::esRegular($borrnumber);

$template->param(regular       => $regular);
####
foreach my $san (@$sanctions) {
	if ($san->{'id3'}) {
		my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
		$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; 
	}

	$san->{'nddate'}=format_date($san->{'enddate'},$dateformat);
	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}
#

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

=item
my ($rcount, $reserves) = DatosReservas($borrnumber);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;

foreach my $res (@$reserves) {	
    	$res->{'rreminderdate'} = format_date($res->{'rreminderdate'},$dateformat);

	my $author=C4::AR::Busquedas::getautor($res->{'rautor'});
        $res->{'rauthor'} = $author->{'completo'};
	$res->{'id'} = $author->{'id'}; 
    	if ($res->{'rid3'}) {
		my $item=C4::AR::Catalogacion::buscarNivel3($res->{'rid3'});
		$res->{'barcode'} = $item->{'barcode'};
		$res->{'signatura_topografica'} = $item->{'signatura_topografica'};
        	$res->{'rbranch'} = C4::AR::Busquedas::getBranch($res->{'rbranch'})->{'branchname'};
        	push @realreserves, $res;
        	$rcount++;
  	}
        else{
        	push @waiting, $res;
        	$wcount++;
        }
}
=cut

# $template->param($data);
$template->param(
		bornum          => $borrnumber,
#los libros que tiene "en espera para retirar"
# 		waiting		=> \@waiting,
#los libros que tiene esperando un ejemplar
# 		realreserves    => \@realreserves,
		prestamos       => \@issuedat,
# 		sanctions       => $sanctions,
	);

output_html_with_http_headers $input, $cookie, $template->output;

