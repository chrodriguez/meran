#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

my $input=new CGI;

my $obj;
if($input->param('obj') eq ""){

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
	
}
else{

#Cuando viene desde detalle, es un llamado ajax, que se hace con el AjaxHelper
	$obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $id1=$obj->{'id1'};
my $accion=$obj->{'accion'};

if($accion eq "borrarGrupo"){
	my $id2=$obj->{'id2'};
	&eliminarNivel2($id2);
}
elsif($accion eq "borrarN1"){
	&eliminarNivel1($id1);
}
elsif($accion eq "borrarEjemplar"){
	my $id3=$obj->{'id3'};
	&eliminarNivel3($id3);
}
print $input->header;
}

