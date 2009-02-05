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

elsif($tipoAccion eq "GENERAR_ARREGLO_CAMPOS"){
#     use Rose::DB::Object::Helpers;
    my $nivel = $obj->{'nivel'};
    my $campoX = $obj->{'campoX'};

    my ($campos_array) = C4::AR::Catalogacion::getCamposXLike($nivel,$campoX);

    my $info= C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

     my $infoOperacionJSON= $info;

    print $input->header;
    print $infoOperacionJSON;
}

elsif($tipoAccion eq "GENERAR_ARREGLO_SUBCAMPOS"){
#     use Rose::DB::Object::Helpers;
    my $nivel = $obj->{'nivel'};
    my $campo = $obj->{'campo'};

    my ($campos_array) = C4::AR::Catalogacion::getSubCamposLike($nivel,$campo);

    my $info= C4::AR::Utilidades::arrayObjectsToJSONString($campos_array);

     my $infoOperacionJSON= $info;

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
#Sube el orden en la vista del campo seleccionado
elsif($tipoAccion eq 'SUBIR_ORDEN'){
    my $id=$obj->{'idMod'};
    my $intra = $obj->{'intra'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();

    $catalogacion->subirOrden;

    print $input->header;
}

#Baja el orden en la vista del campo seleccionado
elsif($tipoAccion eq 'BAJAR_ORDEN'){
    my $id=$obj->{'idMod'};
    my $intra = $obj->{'intra'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->bajarOrden;

    print $input->header;
}

#Se cambia la visibilidad del campo.
elsif($tipoAccion eq 'CAMBIAR_VISIBILIDAD'){
    my $idestcat=$obj->{'id'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $idestcat);
    $catalogacion->load();

    $catalogacion->cambiarVisibilidad;
    print $input->header;
}

#Se deshabilita el campo seleccionado para la vista en intranet
elsif($tipoAccion eq 'ELIMINAR_CAMPO'){
    my $id=$obj->{'idMod'};
    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->delete();

    print $input->header;
}

elsif($tipoAccion eq 'AGREGAR_CAMPO'){
    my $id=$obj->{'idMod'};
    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new();
    $catalogacion->agregar();
    print $input->header;
}