#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my $authnotrequired= 0;
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

my $nivel=$obj->{'nivel'};
my $orden=$obj->{'orden'}||"intranet_habilitado";
my $itemType='ALL';
if($nivel > 1){
    $itemType=$obj->{'itemtype'};
}

if($tipoAccion eq "MOSTRAR_CAMPOS"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/estructura/mostrarCatalogacion.tmpl",
			                query => $input,
			                type => "intranet",
			                authnotrequired => 0,
			                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
			                debug => 1,
			        });

    my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getCatalogaciones($nivel,$itemType,$orden);
    
    #Se pasa al cliente el arreglo de objetos estructura_catalogacion   
    $t_params->{'catalogaciones'}= $catalogaciones_array_ref;
    $t_params->{'nivel'}= $nivel;
    $t_params->{'itemType'}= $itemType;
    
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

elsif($tipoAccion eq "GENERAR_ARREGLO_CAMPOS_REFERENCIA"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $tableAlias= $obj->{'tableAlias'};
    
    my ($campos_array) = C4::AR::Referencias::getCamposDeTablaRef($tableAlias);

    my $info = to_json($campos_array);
    my $infoOperacionJSON= $info;

    C4::Output::printHeader($session);
    print $infoOperacionJSON;

}

elsif($tipoAccion eq "GENERAR_ARREGLO_CAMPOS"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $nivel = $obj->{'nivel'};
    my $campoX = $obj->{'campoX'};

    my ($campos_array) = C4::AR::Catalogacion::getCamposXLike($nivel,$campoX);

    my $info= C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

	my $infoOperacionJSON= $info;

    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "GENERAR_ARREGLO_SUBCAMPOS"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $nivel = $obj->{'nivel'};
    my $campo = $obj->{'campo'};

    my ($campos_array) = C4::AR::Catalogacion::getSubCamposLike($nivel,$campo);

    my $info= C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

    my $infoOperacionJSON= $info;

    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "GENERAR_ARREGLO_TABLA_REF"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1',
                                                    tipo_permiso => 'catalogo'
                                                    
                                                }, 
                                                'intranet'
                                    );

    my ($tablaRef_array) = C4::AR::Referencias::obtenerTablasDeReferenciaAsString();
    
    my ($infoOperacionJSON) = to_json($tablaRef_array);

    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;

}

elsif($tipoAccion eq "MOSTRAR_FORM_AGREGAR_CAMPOS"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "catalogacion/estructura/agregarCampoMARC.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
                        debug => 1,
                    });


    $t_params->{'selectCampoX'} = C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

elsif($tipoAccion eq "MOSTRAR_FORM_MODIFICAR_CAMPOS"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "catalogacion/estructura/modificarCampoMARC.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
                        debug => 1,
                    });

    my $id=$obj->{'id'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();

    $t_params->{'selectCampoX'}= C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');
    $t_params->{'catalogacion'}= $catalogacion;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif($tipoAccion eq "GUARDAR_ESTRUCTURA_CATALOGACION"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    # Se guardan los datos en estructura de catalogacion    
    #estan todos habilidatos
    $obj->{'intranet_habilitado'}= 1;
    my ($Message_arrayref)= C4::AR::Catalogacion::t_guardarEnEstructuraCatalogacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "MODIFICAR_ESTRUCTURA_CATALOGACION"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    # Se guardan los datos en estructura de catalogacion    
    #estan todos habilidatos
    $obj->{'intranet_habilitado'}= 1;

    my ($Message_arrayref)= C4::AR::Catalogacion::t_modificarEnEstructuraCatalogacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}
#Sube el orden en la vista del campo seleccionado
elsif($tipoAccion eq "SUBIR_ORDEN"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $id=$obj->{'idMod'};
    my $itemtype=$obj->{'itemtype_cliente'};
    C4::AR::Catalogacion::subirOrden($id,$itemtype);

    C4::Output::printHeader($session);
}

#Baja el orden en la vista del campo seleccionado
elsif($tipoAccion eq "BAJAR_ORDEN"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $id=$obj->{'idMod'};

    C4::AR::Catalogacion::bajarOrden($id);

    C4::Output::printHeader($session);
}

#Se cambia la visibilidad del campo.
elsif($tipoAccion eq "CAMBIAR_VISIBILIDAD"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $idestcat=$obj->{'id'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $idestcat);
    $catalogacion->load();

    $catalogacion->cambiarVisibilidad;
    C4::Output::printHeader($session);
}

#Se deshabilita el campo seleccionado para la vista en intranet
elsif($tipoAccion eq "ELIMINAR_CAMPO"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $id=$obj->{'idMod'};
    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->delete();

    C4::Output::printHeader($session);
}

elsif($tipoAccion eq "AGREGAR_CAMPO"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
    my $id=$obj->{'idMod'};

    my ($Message_arrayref)= C4::AR::Catalogacion::t_guardarEnEstructuraCatalogacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}
# ***********************************************ABM CATALOGACION*****************************************************************

elsif($tipoAccion eq "MOSTRAR_ESTRUCTURA_DEL_NIVEL"){
    my $entorno= 'estructura_catalogacion_n1';
    if($obj->{'nivel'} eq '2'){$entorno= 'estructura_catalogacion_n2'};
    if($obj->{'nivel'} eq '3'){$entorno= 'estructura_catalogacion_n3'};

    my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => $entorno}, 
                                                'intranet'
                                    );
#Se muestran la estructura de catalogacion segun el nivel pasado por parametro

    my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getHashCatalogaciones($obj);
    
    my $infoOperacionJSON= to_json($catalogaciones_array_ref);
    
	C4::Output::printHeader($session);
	print $infoOperacionJSON;
}

elsif($tipoAccion eq "MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
#Se muestran la estructura de catalogacion segun el nivel pasado por parametro
	my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getHashCatalogacionesConDatos($obj);
    
	my $infoOperacionJSON= to_json($catalogaciones_array_ref);
    
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}
elsif($tipoAccion eq "MOSTRAR_SUBCAMPOS_DE_CAMPO"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );
#Se muestran la estructura de catalogacion segun el nivel pasado por parametro

    my ($sub_campos_string) = &C4::AR::Utilidades::obtenerDescripcionDeSubCampos($obj->{'campo'});
    
	C4::Output::printHeader($session);
	print $sub_campos_string;
}

elsif($tipoAccion eq "MOSTRAR_INFO_NIVEL1_LATERARL"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/estructura/ADInfoNivel1.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
                            debug => 1,
                    });

    my $id1=$obj->{'id1'};

    my $nivel1 = C4::Modelo::CatNivel1->new(id1 => $id1);
    $nivel1->load();

    $t_params->{'nivel1'}= $nivel1;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

elsif($tipoAccion eq "MOSTRAR_INFO_NIVEL2_LATERARL"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/estructura/ADInfoNivel2.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
                            debug => 1,
                    });

    my $id1=$obj->{'id1'};

    my $nivel2_array_ref = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(
                                                    query => [
                                                                id1=> { eq => $id1},
                                                            ]
                                                );

    #se envia al cliente todos los objetos nivel2 segun id1
    $t_params->{'nivel2_array'}= $nivel2_array_ref;


    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

elsif($tipoAccion eq "MOSTRAR_INFO_NIVEL3_TABLA"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "catalogacion/estructura/ADInfoNivel3.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
                            debug => 1,
                    });

    my $id1= $obj->{'id1'};
    my $id2= $obj->{'id2'};

#   FIXME trae todos los ejemplares (nivel3) segun un id1 e id2, hacer una funcion en Catalogacion
    my $nivel3 = C4::Modelo::CatNivel3::Manager->get_cat_nivel3(
                                                        query => [ id1 => { eq => $id1 },
                                                                   id2 => { eq => $id2 } ]      
                                                );

    $t_params->{'nivel3_array'}= $nivel3;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
# **********************************************FIN ABM CATALOGACION****************************************************************

#============================================================= ABM Catalogo==============================================================
elsif($tipoAccion eq "GUARDAR_NIVEL_1"){
     my ($user, $session, $flags)= checkauth(   $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'ALTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );

	#Se guarda informacion del NIVEL 1
    my ($Message_arrayref, $id1) = &C4::AR::Nivel1::t_guardarNivel1($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $id1;

    C4::Output::printHeader($session);
    print to_json \%info;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_2"){
     my ($user, $session, $flags)= checkauth(   $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'ALTA', 
                                                    entorno => 'datos_nivel2'}, 
                                                'intranet'
                                    );
    #Se guarda informacion del NIVEL 2 relacionada con un ID de NIVEL 1
    my ($Message_arrayref, $nivel2) = &C4::AR::Nivel2::t_guardarNivel2($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $nivel2->getId1;
    $info{'id2'}= $nivel2->getId2;

    C4::Output::printHeader($session);
    print to_json \%info;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_3"){

	my ($user, $session, $flags)= checkauth(
												$input, 	
												$authnotrequired,	
                                                { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'datos_nivel3'}, 
												'intranet'
											);
                
	#Se muestran la estructura de catalogacion para que el usuario agregue un documento
    my ($Message_arrayref, $nivel3) = &C4::AR::Nivel3::t_guardarNivel3($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;

    C4::Output::printHeader($session);
    print to_json \%info;
}

elsif($tipoAccion eq "MODIFICAR_NIVEL_1"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'MODIFICACION', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );

    my ($Message_arrayref, $id1) = &C4::AR::Nivel1::t_modificarNivel1($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $id1;

    C4::Output::printHeader($session);
    print to_json \%info;
}

elsif($tipoAccion eq "MODIFICAR_NIVEL_2"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'MODIFICACION', 
                                                    entorno => 'datos_nivel2'}, 
                                                'intranet'
                                    );

    my ($Message_arrayref, $nivel2) = &C4::AR::Nivel2::t_modificarNivel2($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $nivel2->getId1;
    $info{'id2'}= $nivel2->getId2;

    C4::Output::printHeader($session);
    print to_json \%info;
}

elsif($tipoAccion eq "MODIFICAR_NIVEL_3"){
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'MODIFICACION', 
                                                    entorno => 'datos_nivel3'}, 
                                                'intranet'
                                    );

    my ($Message_arrayref, $nivel3) = &C4::AR::Nivel3::t_modificarNivel3($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;

    C4::Output::printHeader($session);
    print to_json \%info;
}
elsif($tipoAccion eq "ELIMINAR_NIVEL"){
    my $entorno= 'datos_nivel1';
    if($obj->{'nivel'} eq '2'){$entorno= 'datos_nivel2'};
    if($obj->{'nivel'} eq '3'){$entorno= 'datos_nivel3'};
    
     my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'BAJA', 
                                                    entorno => $entorno}, 
                                                'intranet'
                                    );

    my $nivel= $obj->{'nivel'};
	my $id= $obj->{'id1'} || $obj->{'id2'};
    my ($Message_arrayref);
   
    if ($nivel == 1){
      ($Message_arrayref)= &C4::AR::Nivel1::t_eliminarNivel1($id);
    }
    elsif($nivel == 2){
      ($Message_arrayref)= &C4::AR::Nivel2::t_eliminarNivel2($id);
    }
    elsif($nivel == 3){
		($Message_arrayref)= &C4::AR::Nivel3::t_eliminarNivel3($obj);
    }

	my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    
    C4::Output::printHeader($session);
	print to_json \%info;
}
#=============================================================FIN ABM Catalogo===============================================================
elsif($tipoAccion eq "MOSTRAR_DETALLE_NIVEL3"){

	 my ($template, $session, $t_params)  = get_template_and_user({
							template_name   => ('catalogacion/estructura/ejemplaresDelGrupo.tmpl'),
							query           => $input,
							type            => "intranet",
							authnotrequired => 0,
							flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1' },
});

	#Cuando viene desde otra pagina que llama al detalle.
	my $id2= $obj->{'id2'};
	my($nivel2_hashref)=&C4::AR::Nivel3::detalleNivel3($id2);
	
	$t_params->{'disponibles'}= $nivel2_hashref->{'disponibles'};
	$t_params->{'cantReservas'}= $nivel2_hashref->{'cantReservas'};
	$t_params->{'cantReservasEnEspera'}= $nivel2_hashref->{'cantReservasEnEspera'};
	$t_params->{'cantPrestados'}= $nivel2_hashref->{'cantPrestados'};
	$t_params->{'nivel3'}= $nivel2_hashref->{'nivel3'};
	$t_params->{'id2'}= $id2;
	#se ferifica si la preferencia "circularDesdeDetalleDelRegistro" esta seteada
	$t_params->{'circularDesdeDetalleDelRegistro'}= C4::AR::Preferencias->getValorPreferencia('circularDesdeDetalleDelRegistro');
    
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
