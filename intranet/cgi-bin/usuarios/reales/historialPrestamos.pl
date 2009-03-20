#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Date;
use C4::Interface::CGI::Output;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params) =  get_template_and_user ({
			template_name	=> 'usuarios/reales/historialPrestamos.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });


my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $bornum=$obj->{'borrowernumber'};
my $orden=$obj->{'orden'}||'date_due desc';
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cant,$issues)=C4::AR::Prestamos::historialPrestamos($bornum,$ini,$cantR,$orden);

$t_params->{'paginador'}=&C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);

my @loop_reading;
for (my $i=0;$i< $cantR;$i++){
   if ($issues->[$i]->{'id1'}){
 	my %line;
	$line{titulo}=$issues->[$i]->{'titulo'};
	$line{unititle}=C4::AR::Nivel1::getUnititle($issues->[$i]->{'id1'});;
	$line{autor}=$issues->[$i]->{'autor'};
	$line{idautor}=$issues->[$i]->{'id'};
	$line{id1}=$issues->[$i]->{'id1'};
	$line{id2}=$issues->[$i]->{'id2'};
	$line{id3}=$issues->[$i]->{'id3'};
	$line{signatura_topografica}=$issues->[$i]->{'signatura_topografica'};
	$line{barcode}=$issues->[$i]->{'barcode'};
 	$line{date_due}=$issues->[$i]->{'date_due'};
    	$line{date_fin} = $issues->[$i]->{'date_fin'};
	$line{date_renew}="-";
 	if ($issues->[$i]->{'renewals'}){
		$line{date_renew}=$issues->[$i]->{'lastreneweddate'};
	}
	$line{returndate}=$issues->[$i]->{'returndate'};
	$line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
	($line{grupos}) = C4::AR::Busquedas::obtenerGrupos($issues->[$i]->{'id1'},'','intra');

	push(@loop_reading,\%line);
   }
}

$t_params->{'cant'}= $cant;
$t_params->{'bornum'}= $bornum;
$t_params->{'showfulllink'}= ($cant > 50);
$t_params->{'loop_reading'}= \@loop_reading;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

