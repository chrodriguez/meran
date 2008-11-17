#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Date;
use Date::Manip;
use C4::Date;
use C4::AR::Reservas;
use C4::AR::Sanctions;

my $input=new CGI;

my ($template, $session, $params) = get_template_and_user ({
	template_name	=> 'usuarios/reales/detalleReservas.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrnumber'};
my $dateformat = C4::Date::get_date_format();

my ($rcount, $reserves) = C4::AR::Reservas::DatosReservas($borrnumber);
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

$params->{'bornum'}= $borrnumber;
#los libros que tiene "en espera para retirar"
$params->{'waiting'}= \@waiting;
#los libros que tiene esperando un ejemplar
if ( (@realreserves) > 0 ){
	$params->{'realreserves'}= \@realreserves;
}
C4::Auth::output_html_with_http_headers($input, $template, $params);

