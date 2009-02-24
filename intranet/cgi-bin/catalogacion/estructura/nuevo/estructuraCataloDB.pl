#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

open A,"/tmp/debug.txt";
print A "dsDFKDSNFJDFNDKJSfj";
close A;
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

#     my ($tablaRef_array) = C4::AR::Catalogacion::getTablaRef();
## FIXME para que esta esto!!!!!!!!!!!!!!!!!!!!!!
#     my ($tablaRef_array) = C4::AR::Referencias::obtenerTablasDeReferencia();
#     
#     my ($json_string_tabla) = C4::AR::Utilidades::arrayObjectsToJSONString($tablaRef_array);

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
    my $intra = $obj->{'intra'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();

    $catalogacion->subirOrden;

    print $input->header;
}

#Baja el orden en la vista del campo seleccionado
elsif($tipoAccion eq "BAJAR_ORDEN"){
    my $id=$obj->{'idMod'};
    my $intra = $obj->{'intra'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->bajarOrden;

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

elsif($tipoAccion eq "ELIMINAR_NIVEL"){

    my $nivel= $obj->{'nivel'};
    my $id= $obj->{'id1'} || $obj->{'id2'} || $obj->{'id3'};
    my ($Message_arrayref);
   
    if ($nivel == 1){
      $Message_arrayref= &C4::AR::Catalogacion::t_eliminarNivel1($id);
    }
    elsif($nivel == 2){
      $Message_arrayref= &C4::AR::Catalogacion::t_eliminarNivel2($id);
    }
    elsif($nivel == 3){
      $Message_arrayref= &C4::AR::Catalogacion::t_eliminarNivel3($id);
    }

    my $infoOperacionJSON=to_json $Message_arrayref;
    
    print $input->header;
    print $infoOperacionJSON;
}
# ***********************************************ABM CATALOGACION*****************************************************************

elsif($tipoAccion eq "MOSTRAR_ESTRUCTURA_DEL_NIVEL"){
#Se muestran la estructura de catalogacion segun el nivel pasado por parametro
    my $id_tipo_doc= $obj->{'id_tipo_doc'};
    my $nivel= $obj->{'nivel'};

    my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getCatalogaciones($nivel,$id_tipo_doc,$orden);
    
    my $infoOperacionJSON= C4::AR::Utilidades::arrayObjectsToJSONString($catalogaciones_array_ref);
    
    print $input->header;
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_1"){
#Se guarda informacion del NIVEL 1
    $obj->{'titulo'}= 'Libro de Prueba';
    $obj->{'autor'}= '3954';
    my ($Message_arrayref, $id1) = &C4::AR::Catalogacion::t_guardarNivel1($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id1'}= $id1;

    print $input->header;
#     print $infoOperacionJSON;
    print to_json \%info;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_2"){
#Se guarda informacion del NIVEL 2 relacionada con un ID de NIVEL 1
#     $obj->{'titulo'}= 'TEST';
#     $obj->{'autor'};
    my ($Message_arrayref, $id2) = &C4::AR::Catalogacion::t_guardarNivel2($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;
    my %info;
    $info{'Message_arrayref'}= $Message_arrayref;
    $info{'id2'}= $id2;

    print $input->header;
#     print $infoOperacionJSON;
    print to_json \%info;
}

elsif($tipoAccion eq "GUARDAR_NIVEL_3"){
#Se muestran la estructura de catalogacion para que el usuario agregue un documento
#     $obj->{'titulo'}= 'TEST';
#     $obj->{'autor'}= '222';
    my ($Message_arrayref) = &C4::AR::Catalogacion::t_guardarNivel3($obj);
    
    my $infoOperacionJSON=to_json $Message_arrayref;

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

    my $id2=$obj->{'id2'};

    my $nivel2 = C4::Modelo::CatNivel2->new(id2 => $id2);
    $nivel2->load();

    $t_params->{'nivel2'}= $nivel2;

    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
# **********************************************FIN ABM CATALOGACION****************************************************************

