#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Preferencias;
# use C4::AR::Utilidades;
use JSON;

my $input = new CGI;
my $obj=&C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $json=$obj->{'json'};
my $tabla=$obj->{'tabla'};

my $tipo=$obj->{'tipo'};
my $accion=$obj->{'accion'};
my $tabla=$obj->{'tabla'};



if($accion eq "BUSCAR_PREFERENCIAS"){
#Busca las preferencias segun lo ingresado como parametro y luego las muestra

my ($template, $borrowernumber, $cookie)
  = get_template_and_user({template_name => "admin/preferenciasResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

	my $buscar=$obj->{'buscar'};

	my $loop=&buscarPreferencias($buscar);
	$template->param(loop => $loop);

	output_html_with_http_headers $input, $cookie, $template->output;
}

if($accion eq "MODIFICAR_VARIABLE"){
#Muestra el tmpl para modificar una preferencias

	my ($template, $loggedinuser, $cookie) = 
	get_templateexpr_and_user({
				template_name => "admin/modificarPreferencia.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
	});

	my $infoVar;
	my $valor="";
	my $op="";

	my $variable=$obj->{'variable'};
	$infoVar=&C4::AR::Preferencias::buscarPreferencia($variable);
	$valor=$infoVar->{'value'};
	$op=$infoVar->{'options'};
	my $tipo=$infoVar->{'type'};
	my @array;

	if($op ne ""){
		@array=split(/\|/,$op);
		$op=$array[1];
	}

	if($tipo eq "combo"){$tabla=$array[0];}

	$template->param(
		variable    => $variable,
		explicacion => &C4::AR::Utilidades::trim($infoVar->{'explanation'}),
		tabla	    => $tabla,
		categoria   => $op,
		campo	    => $op,
	);

	my $compo;
	my %labels;
	my @values;

	$compo=&C4::AR::Utilidades::crearComponentes("text","valor",60,\%labels,$valor);
	$template->param(valor=>$compo);

	print $input->header;
	print $template->output;

} #end if($accion eq "MODIFICAR_VARIABLE")

if($accion eq "GUARDAR_MODIFICACION_VARIABLE"){
#Guarda la modificacion realizada a la preferencia

 	my $variable=$obj->{'variable'};
 	my $valor=$obj->{'valor'};
 	my $expl=$obj->{'explicacion'};

	my $opciones="";

	if($tipo eq "combo"){$opciones=$tabla."|".$obj->{'campo'};}

	if($tipo eq "valAuto"){
		my $categ=$obj->{'categoria'};
		$opciones="authorised_values|".$categ;
	}

	my $Message_arrayref = &C4::AR::Preferencias::t_modificarVariable($variable,$valor,$expl);

	print $input->header;
 	my $infoOperacionJSON=to_json $Message_arrayref;
	print $infoOperacionJSON;
} #end GUARDAR_MODIFICACION_VARIABLE


















## FIXME FALTA TERMINAR CON ESTAS OPCIONES !!!!!!!!!!!!!!!!!!!!!


# if($accion eq "SELECCION_CAMPO"){
# if($json ne ""){
if($accion eq "SELECCION_CAMPO"){
	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ parameters => 1});

	my $guardar=$obj->{'guardar'};
	my $tipo=$obj->{'tipo'};
	my $strjson="";
	if($tipo eq "combo"){
		if($tabla){
		my @campos=&C4::AR::Utilidades::obtenerCampos($tabla);
				foreach my $campo(@campos){
				$strjson.=",{'clave':'".$campo->{'campo'}."','valor':'".$campo->{'campo'}."'}";
			}
		}
		else{
			my %tablas=&C4::AR::Utilidades::buscarTablasdeReferencias();
			foreach my $tabla(keys(%tablas)){
				$strjson.=",{'clave':'".$tabla."','valor':'".$tabla."'}";
			}
		}
	}
	else{
		my $valAuto=&C4::AR::Utilidades::obtenerValoresAutorizados();
		foreach my $val(@$valAuto){
			$strjson.=",{'clave':'".$val->{'category'}."','valor':'".$val->{'category'}."'}";
		}
	}
	$strjson=substr($strjson,1,length($strjson));
	$strjson="[".$strjson."]";
	print $input->header;
	print $strjson;
}

if($accion eq "AGREGAR_VARIABLE"){

	my $variable=$obj->{'variable'};
	my $valor=$obj->{'valor'};
	my $expl=$obj->{'explicacion'};
	my $opciones="";

	if($tipo eq "combo"){$opciones=$tabla."|".$obj->{'campo'};}

	if($tipo eq "valAuto"){
		my $categ=$obj->{'categoria'};
		$opciones="authorised_values|".$categ;
	}

	my $Message_arrayref= &C4::AR::Preferencias::t_guardarVariable($variable,$valor,$expl,$tipo,$opciones);

	print $input->header;
 	my $infoOperacionJSON=to_json $Message_arrayref;
	print $infoOperacionJSON;
}




if($accion eq "SELECCION_CAMPO2"){

 	my $opcion=$obj->{'opcion'};
	my $valor="";
	my $op="";
	my $compo;
	my %labels;
	my @values;
	
	if($opcion eq "bool"){
		push(@values,1);
		push(@values,0);
		$labels{1}="Si";
		$labels{0}="No";
		$compo=&C4::AR::Utilidades::crearComponentes("radio","valor",\@values,\%labels,$valor);
	}
	elsif($opcion eq "texta"){
		$compo=&C4::AR::Utilidades::crearComponentes("texta","valor",60,4,$valor);
	}
	elsif($opcion eq "valAuto"){
		my $categoria=$obj->{'categoria'}||$op;
		%labels=&C4::AR::Utilidades::obtenerDatosValorAutorizado($categoria);
		@values=keys(%labels);
		$compo=&C4::AR::Utilidades::crearComponentes("combo","valor",\@values,\%labels,"");
	}
	elsif($opcion eq "combo"){
		my $campo=$obj->{'campo'}||$op;
		my $id=&C4::AR::Utilidades::obtenerIdentTablaRef($tabla);
		my ($js,$valores)=&C4::AR::Utilidades::obtenerValoresTablaRef($tabla,$id,$campo,$campo);
		@values=keys %$valores;
		foreach my $val(@values){
			$labels{$val}=$valores->{$val};
		}
		$compo=&C4::AR::Utilidades::crearComponentes("combo","valor",\@values,\%labels,$valor);
	}
	print $input->header;
 	print $compo;

}

