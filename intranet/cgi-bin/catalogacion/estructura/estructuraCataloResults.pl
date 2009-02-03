#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $input = new CGI;

 my ($template, $session, $t_params) = get_template_and_user({
                                                    template_name => "catalogacion/estructura/estructuraCataloResults.tmpl",
			                                        query => $input,
			                                        type => "intranet",
			                                        authnotrequired => 0,
			                                        flagsrequired => {editcatalogue => 1},
			                                        debug => 1,
			     });

#FUNCIONES INTERNAS
#Genera el input select para la interface, tanto en la parte de agregar como de modificar. Los parametros que recibe es el id que va a llevar el input y el onchange que es el evento que se ejecuta cuando cambia el combo.
sub generarSelectTabla(){
	my($idInput,$default,$onchange,$disable)=@_;
	#Tablas de refencias
	my %tablas=buscarTablasdeReferencias();
	$tablas{-1}="Elegir tabla";
	my $selectTabla;
	if($default ne "" && $disable){
		$selectTabla=CGI::scrolling_list(      
					-id	   => $idInput,
					-name      => $idInput,
                                        -values    => \%tablas,
                                        -defaults  => $default,
					-size	   => 1,
					-onChange  => $onchange,
					-disabled   => "disabled",
				);
	}
	else{
		$selectTabla=CGI::scrolling_list(      
					-id	   => $idInput,
					-name      => $idInput,
                                        -values    => \%tablas,
                                        -defaults  => $default,
					-size	   => 1,
					-onChange  => $onchange,
                                 );
	}
	#Fin tabla de referencia
	return($selectTabla);
}

#Genera el input select con los campos de la tabla de referencia para obtener el orden en el que se quieren las tuplas de esa tabla.
sub generarSelectOrden(){
	my($idInput,$default,$tabla)=@_;
	my ($ejemplo,%camposTablas)=&obtenerCamposTablaRef($tabla);
	my $stringCampos = join",", values %camposTablas;
	my $default2=$default;
	my $selectOrden=CGI::scrolling_list(      
			-id	   => $idInput,
			-name      => $idInput,
			-defaults  => $default2,
			-values    => \%camposTablas,
			-size	   => 1,
			);
	return($ejemplo,$stringCampos,$selectOrden);
}
#FIN DE FUNCIONES INTERNAS

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $nivel=$obj->{'nivel'};
my $tagField=$obj->{'tagField'};
my $itemType='ALL';
if($nivel > 1){
	$itemType=$obj->{'itemtype'};
}

#Variable que sirve para identificar la accion que se realizo.
my $accion = $obj->{'accion'}; 
=item 
$accion=0 => es la eleccion del nivel en que se van a modificar los campos (Combo Nivel)
$accion=1 => es la eleccion de agregar un nuevo campo a la catalogacion(Boton agregar).

Las siguientes acciones estan en el archivo seleccionCamposMarc.pl
$accion=2 => es la eleccion del campoX que sirve para fitrar a los campos marc (Combo seleccion)
$accion=3 => es la eleccion del tagfield que da como resultado todos los subcampos marc de es campo menos lo que 	ya estan modificados y no son repetibles (Combo campo).
$accion=4 => es la eleccion de la tabla referecia, a la cual se le esta asociando el campo y subcampo, muestra 		los input necesarios para llenar la tabla informacion_referencia 
(Combo tabla de referecia).
Hasta aca!

$accion=5 => se guerdan el nuevo campo para la catalogacion, y si se eligio un tabla se guarda la referecia con 	todos los datos (Boton guardar del paso de agregado).
$accion=6 => se actualiza el campo eliminado con el intranet_habilitado=0 (Boton eliminar).
$accion=7 => sube el orden del campo seleccionado, baja el numero de intra_hab en 1 
	(Boton flecha para arriba).
$accion=8 => baja el orden del campo seleccionado, sube el numero de intra_hab en 1 
	(Boton flecha para abajo).
$accion=9 => Activa la parte de modificacion de un campo que ya esta en la catalogacion 
	(Boton modificar).
$accion=10 => se guardan las modificaciones hechas a los campos ya modificados por parte del usuario.
	(Boton guardar del paso de modificacion).
=cut
my $objResp=$obj->{'objeto'};
my $tagsubfield;
my $textoLib;
my $tabla;
my $ok=0;
my $error;
if( $accion==5 && $objResp ne ""){
	$tagField=$objResp->{'campo'};
	$tagsubfield = $objResp->{'subcampo'};
	$textoLib = $objResp->{'lib'};
	$tabla = $objResp->{'tabla'};
	$ok=1;

	if ($tagsubfield != -1 && $textoLib ne ''){
		my $hayDatos=&buscarDatosCampoMARC($nivel,$tagField,$tagsubfield,"");
		my $tablaRef=-1;
		my $hab;
		my $tablasIguales=0;
		if($hayDatos){
			($tablaRef,$hab)=&buscarInfoRefCampoSubcampo($tagField,$tagsubfield,"");
			$tablasIguales=($tabla == $tablaRef);
		}
		if(($tablasIguales || !$hayDatos) && $ok){
			my $id = -1;
			$id=&guardarCamposModificados($nivel,$itemType,$objResp);
			if($id == -1){ $error = "Error en el guardado del campo, intentelo otra vez."}
		}
		else{$error="Error en la informaci�n de referencia.";}
		$accion=1;
	}
	elsif($tagsubfield == -1){
		$error= "Error - Seleccione un subcampo Marc";
	}
	else{
		$error= "Error - Ingrese un nombre para el campo Marc";
	}
}	
elsif($accion ==5){$error="Error en el pasaje de parametros";}
#Se deshabilita el campo seleccionado para la vista en intranet
if($accion==6){
	my $id=$obj->{'idMod'};
	my $intra=$obj->{'intra'};
	&eliminarNivelIntranet($id,$intra,$nivel,$itemType);
	$accion=0;
}

#Sube el orden en la vista del campo seleccionado
if($accion==7){
	my $id=$obj->{'idMod'};
	my $intra = $obj->{'intra'};
	&subirOrden($id,$intra,$nivel,$itemType);
	$accion=0;
}

#Baja el orden en la vista del campo seleccionado
if($accion==8){
	my $id=$obj->{'idMod'};
	my $intra = $obj->{'intra'};
	&bajarOrden($id,$intra,$nivel,$itemType);
	$accion=0;
}

#Modificacion de un campo ya ingresado para la catalogacion
if($accion == 9){
	my $nivel=$obj->{'nivel'};
	my $id= $obj->{'idMod'};
	my $result= &buscarCampo($id);
	$result->[0]->{'tipoInput'}=$result->[0]->{'tipo'};
	my $tabla= $obj->{'tablaMod'}||$result->[0]->{'tabla'}||-1;
	my $campo=$result->[0]->{'campo'};
	my $subcampo=$result->[0]->{'subcampo'};
	my $hayDatos=&buscarDatosCampoMARC($nivel,$campo,$subcampo,"");
	if(!$hayDatos){
		my ($tablaRef,$hab)=&buscarInfoRefCampoSubcampo($campo,$subcampo,$itemType);
		if($tablaRef != -1){$hayDatos=1;}
	}
	my $tablaMod=&generarSelectTabla('tablaMod',$tabla,'eleccionTabla(9,"Modificar")',$hayDatos);
	if($tabla != -1){
		my $ordDef=$result->[0]->{'orden'};
		my($ejemplo,$stringCampos,$ordenMod)=&generarSelectOrden('ordenMod',$ordDef,$tabla);
		
        $t_params->{'selectordenMod'}= $ordenMod;
		$t_params->{'stringCamposMod'}= $stringCampos;
		$t_params->{'ejemploMod'}= $ejemplo;
			
	}

        $t_params->{'modificacion'}= $result;
		$t_params->{'idMod'}= $id;
		$t_params->{'selecttablaMod'}= $tablaMod;
		$t_params->{'tablaMod'}= $tabla;
		$t_params->{'campo'}= $campo;
		$t_params->{'subcampo'}= $subcampo;

}

#Se actualizan los campos marc ya modificados por el usuario.
if($accion==10){
	my $id=$obj->{'idMod'};
	my $idinforef=$obj->{'idinforef'};
	my $objResp=$obj->{'objeto'};
	if( $objResp ne ""){
		my $campo=$objResp->{'campo'};
		my $subcampo=$objResp->{'subcampo'};
		my $tabla=$objResp->{'tabla'};
		my $hayDatos=&buscarDatosCampoMARC($nivel,$campo,$subcampo,"");
		my $tablaRef=-1;
		my $hab;
		my $tablasIguales=0;
		if($hayDatos){
			($tablaRef,$hab)=&buscarInfoRefCampoSubcampo($campo,$subcampo,"");
			$tablasIguales=($tabla == $tablaRef);
		}
		if($tablasIguales || !$hayDatos){
			&modificarCampo($id,$objResp);
		}
		else{$error="Error en la informaci�n de referencia.";}
	}
	else{$error="Error en el pasaje de parametros"}
	$accion=0;
}

#Se cambia la visibilidad del campo.
if($accion==11){
	my $visible=$obj->{'visible'};
	my $idestcat=$obj->{'id'};
	&actualizarVisibilidad($idestcat,$visible);
	$accion=0;
}

#Busqueda de campos modificados para mostrar en el tmpl, se muestra siempre no depende de la
#variable tipo
my @results = &buscarCamposModificados($nivel,$itemType);
#fin busqueda
my $cant= scalar(@results); #Para ver si se muestar la tabla o no en el template

$t_params->{'RESULTDATA'}= \@results;
$t_params->{'accion'}= $accion;
$t_params->{'nivel'}= $nivel;
$t_params->{'cant'}= $cant;
$t_params->{'error'}= $error;
		

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
