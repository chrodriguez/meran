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
my ($user, $session, $flags)= checkauth($input, $authnotrequired, { editcatalogue => 1}, 'intra');
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
                                                        template_name => "catalogacion/estructura/nuevo/mostrarCatalogacion.tmpl",
			                                            query => $input,
			                                            type => "intranet",
			                                            authnotrequired => 0,
			                                            flagsrequired => {editcatalogue => 1},
			                                            debug => 1,
			        });

    my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getCatalogaciones($nivel,$itemType,$orden);
    
    #Se pasa al cliente el arreglo de objetos estructura_catalogacion   
    $t_params->{'catalogaciones'}= $catalogaciones_array_ref;
    $t_params->{'nivel'}= $nivel;
    
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}

elsif($tipoAccion eq "GENERAR_ARREGLO_CAMPOS_REFERENCIA"){
    my $tableAlias= $obj->{'tableAlias'};
    
    my ($campos_array) = C4::AR::Referencias::getCamposDeTablaRef($tableAlias);

    my $info = to_json($campos_array);
    my $infoOperacionJSON= $info;

    print $input->header;
    print $infoOperacionJSON;

}

elsif($tipoAccion eq "GENERAR_ARREGLO_CAMPOS"){
    my $nivel = $obj->{'nivel'};
    my $campoX = $obj->{'campoX'};

    my ($campos_array) = C4::AR::Catalogacion::getCamposXLike($nivel,$campoX);

    my $info= C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

     my $infoOperacionJSON= $info;

    print $input->header;
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "GENERAR_ARREGLO_SUBCAMPOS"){
    my $nivel = $obj->{'nivel'};
    my $campo = $obj->{'campo'};

    my ($campos_array) = C4::AR::Catalogacion::getSubCamposLike($nivel,$campo);

    my $info= C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

    my $infoOperacionJSON= $info;

    print $input->header;
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "GENERAR_ARREGLO_TABLA_REF"){

    my ($tablaRef_array) = C4::AR::Referencias::obtenerTablasDeReferenciaAsString();
    
    my ($infoOperacionJSON) = to_json($tablaRef_array);

    
    print $input->header;
    print $infoOperacionJSON;

}

elsif($tipoAccion eq "MOSTRAR_FORM_AGREGAR_CAMPOS"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                                                        template_name => "catalogacion/estructura/nuevo/agregarCampoMARC.tmpl",
                                                        query => $input,
                                                        type => "intranet",
                                                        authnotrequired => 0,
                                                        flagsrequired => {editcatalogue => 1},
                                                        debug => 1,
                    });


    $t_params->{'selectCampoX'} = C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');

    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}

elsif($tipoAccion eq "MOSTRAR_FORM_MODIFICAR_CAMPOS"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                                                        template_name => "catalogacion/estructura/nuevo/modificarCampoMARC.tmpl",
                                                        query => $input,
                                                        type => "intranet",
                                                        authnotrequired => 0,
                                                        flagsrequired => {editcatalogue => 1},
                                                        debug => 1,
                    });

    my $id=$obj->{'id'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();

    $t_params->{'selectCampoX'}= C4::AR::Utilidades::generarComboCampoX('eleccionCampoX()');
    $t_params->{'catalogacion'}= $catalogacion;

    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif($tipoAccion eq "GUARDAR_ESTRUCTURA_CATALOGACION"){
    # Se guardan los datos en estructura de catalogacion    
    #estan todos habilidatos
    $obj->{'intranet_habilitado'}= 1;
    my ($Message_arrayref)= C4::AR::Catalogacion::t_guardarEnEstructuraCatalogacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    print $input->header;
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "MODIFICAR_ESTRUCTURA_CATALOGACION"){
    # Se guardan los datos en estructura de catalogacion    
    #estan todos habilidatos
    $obj->{'intranet_habilitado'}= 1;
    my ($Message_arrayref)= C4::AR::Catalogacion::t_modificarEnEstructuraCatalogacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    print $input->header;
    print $infoOperacionJSON;
}
#Sube el orden en la vista del campo seleccionado
elsif($tipoAccion eq "SUBIR_ORDEN"){
    my $id=$obj->{'idMod'};
    my $itemtype=$obj->{'itemtype_cliente'};
    C4::AR::Catalogacion::subirOrden($id,$itemtype);

    print $input->header;
}

#Baja el orden en la vista del campo seleccionado
elsif($tipoAccion eq "BAJAR_ORDEN"){
    my $id=$obj->{'idMod'};

    C4::AR::Catalogacion::bajarOrden($id);

    print $input->header;
}

#Se cambia la visibilidad del campo.
elsif($tipoAccion eq "CAMBIAR_VISIBILIDAD"){
    my $idestcat=$obj->{'id'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $idestcat);
    $catalogacion->load();

    $catalogacion->cambiarVisibilidad;
    print $input->header;
}

#Se deshabilita el campo seleccionado para la vista en intranet
elsif($tipoAccion eq "ELIMINAR_CAMPO"){
    my $id=$obj->{'idMod'};
    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->delete();

    print $input->header;
}

elsif($tipoAccion eq "AGREGAR_CAMPO"){
    my $id=$obj->{'idMod'};

    my ($Message_arrayref)= C4::AR::Catalogacion::t_guardarEnEstructuraCatalogacion($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    
    print $input->header;
    print $infoOperacionJSON;
}
# ***********************************************ABM CATALOGACION*****************************************************************

elsif($tipoAccion eq "MOSTRAR_ESTRUCTURA_DEL_NIVEL"){
#Se muestran la estructura de catalogacion segun el nivel pasado por parametro

    my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getHashCatalogaciones($obj);
    
    my $infoOperacionJSON= to_json($catalogaciones_array_ref);
    
    print $input->header;
	print $infoOperacionJSON;
}

elsif($tipoAccion eq "MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS"){
#Se muestran la estructura de catalogacion segun el nivel pasado por parametro
	my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getHashCatalogacionesConDatos($obj);
    
	my $infoOperacionJSON= to_json($catalogaciones_array_ref);
    
    print $input->header;
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "MOSTRAR_INFO_NIVEL1_LATERARL"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                                                        template_name => "catalogacion/estructura/nuevo/ADInfoNivel1.tmpl",
                                                        query => $input,
                                                        type => "intranet",
                                                        authnotrequired => 0,
                                                        flagsrequired => {editcatalogue => 1},
                                                        debug => 1,
                    });

    my $id1=$obj->{'id1'};

    my $nivel1 = C4::Modelo::CatNivel1->new(id1 => $id1);
    $nivel1->load();

    $t_params->{'nivel1'}= $nivel1;

    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}

elsif($tipoAccion eq "MOSTRAR_INFO_NIVEL2_LATERARL"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                                                        template_name => "catalogacion/estructura/nuevo/ADInfoNivel2.tmpl",
                                                        query => $input,
                                                        type => "intranet",
                                                        authnotrequired => 0,
                                                        flagsrequired => {editcatalogue => 1},
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


    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}

elsif($tipoAccion eq "MOSTRAR_INFO_NIVEL3_TABLA"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                                                        template_name => "catalogacion/estructura/nuevo/ADInfoNivel3.tmpl",
                                                        query => $input,
                                                        type => "intranet",
                                                        authnotrequired => 0,
                                                        flagsrequired => {editcatalogue => 1},
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

    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
# **********************************************FIN ABM CATALOGACION****************************************************************

#============================================================= ABM Catalogo==============================================================
elsif($tipoAccion eq "GUARDAR_NIVEL_1"){
#Se guarda informacion del NIVEL 1
    my ($Message_arrayref, $id1) = &C4::AR::Nivel1::t_guardarNivel1($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $id1;

    print $input->header;
    print to_json \%info;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_2"){
    #Se guarda informacion del NIVEL 2 relacionada con un ID de NIVEL 1
    my ($Message_arrayref, $nivel2) = &C4::AR::Nivel2::t_guardarNivel2($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $nivel2->getId1;
    $info{'id2'}= $nivel2->getId2;

    print $input->header;
    print to_json \%info;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_3"){
#Se muestran la estructura de catalogacion para que el usuario agregue un documento
    my ($Message_arrayref, $nivel3) = &C4::AR::Nivel3::t_guardarNivel3($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;

    print $input->header;
    print to_json \%info;
}

elsif($tipoAccion eq "MODIFICAR_NIVEL_1"){

    my ($Message_arrayref, $id1) = &C4::AR::Nivel1::t_modificarNivel1($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $id1;

    print $input->header;
    print to_json \%info;
}

elsif($tipoAccion eq "MODIFICAR_NIVEL_2"){

    my ($Message_arrayref, $nivel2) = &C4::AR::Nivel2::t_modificarNivel2($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $nivel2->getId1;
    $info{'id2'}= $nivel2->getId2;

    print $input->header;
    print to_json \%info;
}

elsif($tipoAccion eq "MODIFICAR_NIVEL_3"){

    my ($Message_arrayref, $nivel3) = &C4::AR::Nivel3::t_modificarNivel3($obj);
    
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;

    print $input->header;
    print to_json \%info;
}
elsif($tipoAccion eq "ELIMINAR_NIVEL"){

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
    
    print $input->header;
	print to_json \%info;
}
#=============================================================FIN ABM Catalogo===============================================================

elsif($tipoAccion eq "MOSTRAR_DETALLE_NIVEL3"){

	 my ($template, $session, $t_params)  = get_template_and_user({
															template_name   => ('catalogacion/estructura/nuevo/ejemplaresDelGrupo.tmpl'),
															query           => $input,
															type            => "intranet",
															authnotrequired => 0,
															flagsrequired   => {catalogue => 1},
	});

	#Cuando viene desde otra pagina que llama al detalle.
	my $id2= $obj->{'id2'};
	my($nivel2_hashref)=&C4::AR::Nivel3::detalleNivel3($id2);
	
	$t_params->{'nivel3'}= $nivel2_hashref->{'nivel3'},
    
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}