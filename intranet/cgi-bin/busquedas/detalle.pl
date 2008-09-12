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
my ($template, $loggedinuser, $cookie);

# if($input->param('obj') eq ""){

# 	my ($template, $loggedinuser, $cookie) = get_template_and_user({
## FIXME cambie esto hasta que se saque toda la logica para borrar nivel 1, 2 y 3 de aca

	my ($template, $loggedinuser, $cookie) = get_template_and_user({
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

	$template->param(
		loopnivel1 => \@nivel1Loop,
		loopnivel2 => \@nivel2Loop,
		titulo     => $nivel1->{'titulo'},
		id1	   => $id1,
		cantItemN1 => $cantItemN1,
		datosautor => \@autor,
	);

output_html_with_http_headers $input, $cookie, $template->output;
	
# }
# else{
# ## FIXME ESTO NO DEBERIA ESTAR ACA, SE DEBE HACER UN xxxDB.pl PARA MANEJAR ESTE TIPO DE OPERACIONES
# 
# 	my %infoRespuesta;
# 	#Cuando viene desde detalle, es un llamado ajax, que se hace con el AjaxHelper
# 	$obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
# 	
# 	my $id1=$obj->{'id1'};
# 	my $accion=$obj->{'accion'};
# 
# 	my %params;
# 
# 	$params{'id1'}= $id1;
# 	$params{'id2'}= $obj->{'id2'};
# 	$params{'id3'}= $obj->{'id3'};
# 	$params{'responsable'}= $loggedinuser;
# 	
# 	if($accion eq "borrarGrupo"){
# 		
# 		my ($error, $codMsg, $message)= &C4::AR::Nivel2::t_deleteGrupo(\%params);
# 		
# 		$infoRespuesta{'error'}= $error;
# 		$infoRespuesta{'codMsg'}= $codMsg;
# 		$infoRespuesta{'message'}= $message;
# 	}
# 	elsif($accion eq "borrarN1"){
# # 		&eliminarNivel1($id1);
# 		
# 		my ($error, $codMsg, $message)= &C4::AR::Nivel1::t_deleteNivel1(\%params);
# 		
# 		$infoRespuesta{'error'}= $error;
# 		$infoRespuesta{'codMsg'}= $codMsg;
# 		$infoRespuesta{'message'}= $message;
# 
# 	}
# 	elsif($accion eq "borrarEjemplar"){
# 
# 		my ($error, $codMsg, $message)= &C4::AR::Nivel3::t_deleteItem(\%params);
# 
# 		$infoRespuesta{'error'}= $error;
# 		$infoRespuesta{'codMsg'}= $codMsg;
# 		$infoRespuesta{'message'}= $message;
# 	}
# 	
# 
# 	#se convierte el arreglo de respuesta en JSON
# 	my $infoRespuestaJSON = to_json \%infoRespuesta;
# 	print $input->header;
# 	#se envia en JSON al cliente
# 	print $infoRespuestaJSON;
# }

