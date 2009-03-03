#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use C4::AR::Busquedas;

my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-detail.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => {borrow => 1},
			     });



my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $idNivel1= $obj->{'id1'};

my (@nivel2Loop)= &C4::AR::Nivel2::detalleNivel2OPAC($idNivel1);

my $nivel1=&C4::AR::Catalogacion::buscarNivel1($idNivel1);
my $autor=C4::AR::Busquedas::getautor($nivel1->{'autor'});
my @nivel1Loop= &C4::AR::Nivel1::detalleNivel1OPAC($idNivel1, $nivel1, 'opac');

for (my $i=0; $i < scalar(@nivel2Loop); $i++){
	@nivel2Loop[$i]->{'loopnivel1'}= \@nivel1Loop;
}
	

$t_params->{'CirculationEnabled'}= C4::AR::Preferencias->getValorPreferencia("circulation");
$t_params->{'loopnivel2'}= \@nivel2Loop;
$t_params->{'id1'}= $idNivel1;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
