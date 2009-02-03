#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;
# use JSON;

my $input=new CGI;

# my $obj;

# if($input->param('obj') eq ""){

# 	my ($template, $loggedinuser, $cookie) = get_template_and_user({
## FIXME cambie esto hasta que se saque toda la logica para borrar nivel 1, 2 y 3 de aca

my ($template, $session, $t_params) = get_template_and_user({
		template_name   => ('busquedas/detalle.tmpl'),
		query           => $input,
		type            => "intranet",
		authnotrequired => 0,
		flagsrequired   => {catalogue => 1},
    	});

	#Cuando viene desde otra pagina que llama al detalle.
	my $id1=$input->param('id1');

	my $nivel1=&buscarNivel1($id1); #C4::AR::Catalogacion;
	my $cantItemN1=&cantidadItem(1,$id1);
	my @autor= getautor($nivel1->{'autor'});
	my @nivel1Loop= &C4::AR::Nivel1::detalleNivel1($id1, $nivel1,"intra");
	my @nivel2Loop= &C4::AR::Nivel2::detalleNivel2($id1,"intra");

	$t_params->{'loopnivel1'} = \@nivel1Loop;
	$t_params->{'loopnivel2'} = \@nivel2Loop;
	$t_params->{'titulo'}     = $nivel1->{'titulo'};
	$t_params->{'id1'}	  = $id1;
	$t_params->{'cantItemN1'} = $cantItemN1;
	$t_params->{'datosautor'} = \@autor;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
