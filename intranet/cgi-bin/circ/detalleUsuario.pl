#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user ({
	template_name	=> 'circ/detalleUsuario.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrowernumber'};

=item
my $sanctions = C4::AR::Sanctions::hasSanctions($borrnumber);
	
my $dateformat = C4::Date::get_date_format();
foreach my $san (@$sanctions) {
	if ($san->{'id3'}) {
		my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
		$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; 
	}

	if ($san->{'reservaNoRetiradaVencida'}){
		$template->param(reservaNoRetiradaVencida =>$san->{'reservaNoRetiradaVencida'});
	}
# 	$san->{'enddate'}=format_date($san->{'enddate'},$dateformat);
# 	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}

my $debts= C4::AR::Sanctions::tieneLibroVencido($borrnumber); # indica si el usuario tiene libros vencidos
$template->param(sanctions =>$sanctions,
		 debts =>$debts
		);
=cut

my @resultBorrower;
$resultBorrower[0]=C4::AR::Usuarios::getBorrowerInfo($borrnumber);

$template->param(
	borrower => \@resultBorrower,
);

output_html_with_http_headers $input, $cookie, $template->output;

