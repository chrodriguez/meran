#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use C4::AR::Mensajes;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => "catalogacion/estructura/agregarItemResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $nivel=$obj->{'nivel'};
my $itemtype=$obj->{'itemtype'}||'ALL';
my $id1=$obj->{'id1'} || -1;
my $id2=$obj->{'id2'} || -1;
my $accion=$obj->{'accion2'} ||$obj->{'accion'} ||-1;
my %infoRespuesta;

my $descripcion= C4::AR::Busquedas::getItemType($itemtype);


if($accion eq "borrar"){
	&C4::AR::Nivel1::t_deleteNivel1($id1);
	$nivel=1;
}
elsif($accion eq "borrarN2"){
	my %params;
	$params{'id2'}= $obj->{'id2'};

	my ($error, $codMsg, $message)= &C4::AR::Nivel2::t_deleteGrupo(\%params);

	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;

	$nivel=2;
}
elsif($accion eq "modificarN1" && $nivel == 1){
	my $nivel1 =&buscarNivel1($id1);
	my $idAutor=$nivel1->{'autor'};
	my $autor=C4::AR::Busquedas::getautor($idAutor);
	$autor=$autor->{'completo'};
	$nivel=1;
	$template->param(accion  => $accion,
			 autor 	 => $autor,
			 idAutor => $idAutor);
}

#GUARDADO de los items
my $paso;
if($nivel == 3){
	$paso=$obj->{'paso'}||$nivel-1;
}
else{
	$paso=$obj->{'paso'}||$nivel;
}

my @nivel1o2;
my @nivel3;

my $objetosResp= $obj->{'respuesta'};
if($objetosResp){
	foreach my $obj(@$objetosResp){
		if($obj->{'nivel'} < 3){
			push(@nivel1o2,$obj);
		}
		else{
			push(@nivel3,$obj);
		}
	}
}

my $idAutor=$obj->{'idAutor'};
my $cantItems=$obj->{'cantitems'}; #recupero la cantidad de items del nivel 3 a insertar
my $barcode=$obj->{'codbarra'}; #recupero el codigo de barra para el o los items del nivel 3

my $error=0;
my $codMsg;
my $mensaje="";
my $paraMens;
if($paso > 1 && ($accion ne "modificarN1" && $accion ne "agregarN2" && $accion ne "borrarN2" && $accion ne "modificarN2")){
	if(($paso-1)==1){
		($id1,$error,$codMsg)= C4::AR::Nivel1::saveNivel1($idAutor,\@nivel1o2);
		if($error){
			$mensaje= C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
			$paso=1;
		}
	}
	elsif(($paso-1)==2 && (!$error)){
		my ($id2,$tipoDocN2,$error,$codMsg)=C4::AR::Nivel2::saveNivel2($id1,\@nivel1o2);
		if($error){
			$mensaje= C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
			$paso=2;
		}
		else{
			($error,$codMsg)=C4::AR::Nivel3::saveNivel3($id1,$id2,$barcode,$cantItems,$tipoDocN2,\@nivel3);
			$mensaje=C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
			$paso=2;
		}
	}
}
#FIN del guardado
elsif($accion eq "modificarN1" && $paso==2){
	&modificarNivel1Completo($id1,$idAutor,\@nivel1o2);
	$accion="";
	$template->param(
			accion	  => $accion,
			)
}

#BUSQUEDA de los datos ingresados en el nivel 1 y nivel 2 para mostrar en la pagina del paso 2
if($paso > 1 && $id1 != -1){
	my $itemNivel1=&buscarNivel1($id1);
	my $autor;
	if($itemNivel1->{'autor'} ne ""){
		$autor=C4::AR::Busquedas::getautor($itemNivel1->{'autor'});
		$autor=$autor->{'completo'};
	}
	my $titulo=$itemNivel1->{'titulo'};
	my @itemNivel2=&buscarNivel2PorId1($id1);
	$template->param(
			id1	=> $id1,
			titulo	=> $titulo,
			autor	=> $autor,
			resultsGrupos => \@itemNivel2
			);
}
#FIN busqueda


$template->param(
 			nivel		  => $nivel,
 			paso		  => $paso,
 			itemtype	  => $itemtype,
 			descripcion	  => $descripcion,
 			id1		  => $id1,
 			error		  => $error,
			mensaje		  => $mensaje,
		);

output_html_with_http_headers $input, $cookie, $template->output;
