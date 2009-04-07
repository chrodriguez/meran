#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

my $input=new CGI;

my ($template, $session, $t_params) = get_template_and_user({
																		template_name   => ('catalogacion/estructura/nuevo/detalle.tmpl'),
																		query           => $input,
																		type            => "intranet",
																		authnotrequired => 0,
																		flagsrequired   => {catalogue => 1},
    										});

	#Cuando viene desde otra pagina que llama al detalle.
	my $id1=$input->param('id1');
# FIXME hacer una funcion detalle completo  de todo esto
	my $nivel1= &C4::AR::Nivel1::getNivel1FromId1($id1);
	my $nivel2_array_ref= &C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

	my @nivel2;
	
	for(my $i=0;$i<scalar(@$nivel2_array_ref);$i++){
		my $hash_nivel2;
C4::AR::Debug::debug("Procesando Nivel2 ".$nivel2_array_ref->[$i]->getId2."\n");
		$nivel2_array_ref->[$i]->load();
		$hash_nivel2->{'id2'}= $nivel2_array_ref->[$i]->getId2;
		$hash_nivel2->{'tipo_documento'}= C4::AR::Referencias::getNombreTipoDocumento($nivel2_array_ref->[$i]->getTipo_documento);
		$hash_nivel2->{'nivel2_array'}= ($nivel2_array_ref->[$i])->toMARC; #arreglo de los campos fijos de Nivel 2 mapeado a MARC
# 		$hash_nivel2= C4::AR::Nivel3::detalleNivel3($nivel2_array_ref->[$i]->getId2);
		my ($totales_nivel3,@result)= C4::AR::Nivel3::detalleNivel3YDisponibilidad($nivel2_array_ref->[$i]->getId2);
		$hash_nivel2->{'nivel3'}= \@result;
		$hash_nivel2->{'cantPrestados'}= $totales_nivel3->{'cantPrestados'};
		$hash_nivel2->{'cantReservas'}= $totales_nivel3->{'cantReservas'};
		$hash_nivel2->{'cantReservasEnEspera'}= $totales_nivel3->{'cantReservasEnEspera'};
		$hash_nivel2->{'disponibles'}= $totales_nivel3->{'disponibles'};
	
		push(@nivel2, $hash_nivel2);
	}

	$t_params->{'nivel1'}= $nivel1->toMARC,
	$t_params->{'id1'}	  = $id1;
	$t_params->{'nivel2'}= \@nivel2,

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
