#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Preferencias;
# use C4::AR::Utilidades;
use JSON;

my $input = new CGI;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $json = $obj->{'json'};
my $tabla = $obj->{'tabla'};
my $tipo = $obj->{'tipo'};
my $accion = $obj->{'accion'};


if($accion eq "BUSCAR_PREFERENCIAS"){
#Busca las preferencias segun lo ingresado como parametro y luego las muestra

my ($template, $session, $t_params)
  = get_template_and_user({template_name => "admin/preferenciasResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

	my $buscar=$obj->{'buscar'};
	my $orden=$obj->{'orden'};
	my ($cant,$preferencias)=&C4::AR::Preferencias::getPreferenciaLike($buscar,$orden);
	$t_params->{'preferencias'}= $preferencias;
	$t_params->{'cant'}= $cant;
	
	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}#end if($accion eq "BUSCAR_PREFERENCIAS")

if($accion eq "MODIFICAR_VARIABLE"){
#Muestra el tmpl para modificar una preferencias

my ($template, $session, $t_params) = 
	get_template_and_user({
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
	my $campo="";
	my $categoria="";

	my $variable=$obj->{'variable'};
	$infoVar=&C4::AR::Preferencias::getPreferencia($variable);
	$valor=$infoVar->{'value'};
	$op=$infoVar->{'options'};
	my $tipo=$infoVar->{'type'};
	if($op ne ""){	
		if($tipo eq "referencia"){my @array;
								  @array=split(/\|/,$op);
								  $tabla=$array[0];
							 	  $campo=$array[1];}
		elsif($tipo eq "valAuto"){$categoria=$op}
	}
	

	$t_params->{'variable'}= $variable;
	$t_params->{'explicacion'}= &C4::AR::Utilidades::trim($infoVar->{'explanation'});
	$t_params->{'tabla'}= $tabla;
	$t_params->{'categoria'}= $categoria;
	$t_params->{'campo'}= $campo;

	my $nuevoCampo;
	my %labels;
	my @values;
	
	if($tipo eq "bool"){
		push(@values,1);
		push(@values,0);
		$labels{1}="Si";
		$labels{0}="No";
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("radio","valor",\@values,\%labels,$valor);
	}
	elsif($tipo eq "texta"){
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("texta","valor",60,4,$valor);
	}
	elsif($tipo eq "valAuto"){
		my $categoria=$obj->{'categoria'}||$op;
		%labels=&C4::AR::Utilidades::obtenerDatosValorAutorizado($categoria);
		@values=keys(%labels);
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("combo","valor",\@values,\%labels,$valor);
		$t_params->{'categoria'}= $categoria;
	}
	elsif($tipo eq "referencia"){
		my $campo=$obj->{'campo'}||$op;
		my $id=&C4::AR::Utilidades::obtenerIdentTablaRef($tabla);
		my ($js,$valores)=&C4::AR::Utilidades::obtenerValoresTablaRef($tabla,$id,$campo,$campo);
		@values=keys %$valores;
		foreach my $val(@values){
			$labels{$val}=$valores->{$val};
		}
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("combo","valor",\@values,\%labels,$valor);
		$t_params->{'tabla'}= $tabla;
		$t_params->{'campo'}= $campo;
	}	elsif($tipo eq "text"){
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("text","valor",60,0,$valor);
	}

	$t_params->{'tipo'}= $tipo;
	$t_params->{'valor'}= $nuevoCampo;




	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

} #end if($accion eq "MODIFICAR_VARIABLE")

if($accion eq "GUARDAR_MODIFICACION_VARIABLE"){
#Guarda la modificacion realizada a la preferencia

 	my $variable=$obj->{'variable'};
 	my $valor=$obj->{'valor'};
 	my $expl=$obj->{'explicacion'};

	my $Message_arrayref = &C4::AR::Preferencias::t_modificarVariable($variable,$valor,$expl);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    print $input->header;
    print $infoOperacionJSON;

} #end GUARDAR_MODIFICACION_VARIABLE

if($accion eq "SELECCION_CAMPO"){
	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ parameters => 1});

	my $guardar=$obj->{'guardar'};
	my $tipo=$obj->{'tipo'};
	my $strjson="";
	if($tipo eq "referencia"){
		if($tabla){
		#Se buscan los campos de la tabla seleccionada
		my @campos=&C4::AR::Utilidades::obtenerCampos($tabla);
				foreach my $campo(@campos){
				$strjson.=",{'clave':'".$campo->{'campo'}."','valor':'".$campo->{'campo'}."'}";
			}
		}
		else{
		#Se buscan las tablas de referencia
			my %tablas=&C4::AR::Utilidades::buscarTablasdeReferencias();
			foreach my $tabla(keys(%tablas)){
				$strjson.=",{'clave':'".$tabla."','valor':'".$tabla."'}";
			}
		}
	}
	else{
		#Se buscan los valores autorizados
		my $valAuto=&C4::AR::Utilidades::obtenerValoresAutorizados();
		foreach my $val(@$valAuto){
			$strjson.=",{'clave':'".$val->{'category'}."','valor':'".$val->{'category'}."'}";
		}
	}
	$strjson=substr($strjson,1,length($strjson));
	$strjson="[".$strjson."]";
	print $input->header;
	print $strjson;
}#end SELECCION_CAMPO

if($accion eq "NUEVA_VARIABLE"){
#Muestra el tmpl para agregar una preferencias

my ($template, $session, $t_params) = 
	get_template_and_user({
				template_name => "admin/modificarPreferencia.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});



	my $valor="";
	my $op="";
	my $nuevoCampo;
	my %labels;
	my @values;
	
	if($tipo eq "bool"){
		push(@values,1);
		push(@values,0);
		$labels{1}="Si";
		$labels{0}="No";
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("radio","valor",\@values,\%labels,$valor);
	}
	elsif($tipo eq "texta"){
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("texta","valor",60,4,$valor);
	}
	elsif($tipo eq "valAuto"){
		my $categoria=$obj->{'categoria'}||$op;
		%labels=&C4::AR::Utilidades::obtenerDatosValorAutorizado($categoria);
		@values=keys(%labels);
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("combo","valor",\@values,\%labels,$valor);
		$t_params->{'categoria'}= $categoria;
	}
	elsif($tipo eq "referencia"){
		my $campo=$obj->{'campo'}||$op;
		my $id=&C4::AR::Utilidades::obtenerIdentTablaRef($tabla);
		my ($js,$valores)=&C4::AR::Utilidades::obtenerValoresTablaRef($tabla,$id,$campo,$campo);
		@values=keys %$valores;
		foreach my $val(@values){
			$labels{$val}=$valores->{$val};
		}
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("combo","valor",\@values,\%labels,$valor);
		$t_params->{'tabla'}= $tabla;
		$t_params->{'campo'}= $campo;
	}	elsif($tipo eq "text"){
		$nuevoCampo=&C4::AR::Utilidades::crearComponentes("text","valor",60);
	}

	$t_params->{'tipo'}= $tipo;
	$t_params->{'valor'}= $nuevoCampo;

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}#end NUEVA_VARIABLE


if($accion eq "GUARDAR_NUEVA_VARIABLE"){

#Se guarda la nueva preferencias

	my $variable=$obj->{'variable'};
	my $valor=$obj->{'valor'};
	my $expl=$obj->{'explicacion'};
	my $opciones="";

	if($tipo eq "referencia"){$opciones=$tabla."|".$obj->{'campo'};}

	if($tipo eq "valAuto"){ $opciones=$obj->{'categoria'};}

	my $Message_arrayref= &C4::AR::Preferencias::t_guardarVariable($variable,$valor,$expl,$tipo,$opciones);
 
	my $infoOperacionJSON=to_json $Message_arrayref;

	print $input->header;
	print $infoOperacionJSON;

}#end GUARDAR_NUEVA_VARIABLE

