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

#Sube el orden en la vista del campo seleccionado
if($tipoAccion eq 'SUBIR_ORDEN'){
    my $id=$obj->{'idMod'};
    my $intra = $obj->{'intra'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();

    $catalogacion->subirOrden;

    print $input->header;
}

#Baja el orden en la vista del campo seleccionado
if($tipoAccion eq 'BAJAR_ORDEN'){
    my $id=$obj->{'idMod'};
    my $intra = $obj->{'intra'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->bajarOrden;

    print $input->header;
}

#Se cambia la visibilidad del campo.
if($tipoAccion eq 'CAMBIAR_VISIBILIDAD'){
    my $idestcat=$obj->{'id'};

    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $idestcat);
    $catalogacion->load();

    $catalogacion->cambiarVisibilidad;
    print $input->header;
}

#Se deshabilita el campo seleccionado para la vista en intranet
if($tipoAccion eq 'ELIMINAR_CAMPO'){
    my $id=$obj->{'idMod'};
    my $catalogacion = C4::Modelo::CatEstructuraCatalogacion->new(id => $id);
    $catalogacion->load();
    $catalogacion->delete();

    print $input->header;
}