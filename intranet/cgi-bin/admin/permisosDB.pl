#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Preferencias;
use C4::AR::Permisos;
# use C4::AR::Utilidades;
use JSON;

my $input = new CGI;
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $accion;
if ($obj != 0){
    $accion = $obj->{'accion'};
}else{
    $accion = undef;
}


# my ($userid, $session, $flags) = checkauth($input, 0,{});
if(!$accion){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({	template_name => "admin/permisos.tmpl",
																    query => $input,
																    type => "intranet",
																    authnotrequired => 0,
																    flagsrequired => {parameters => 1},
																    debug => 1,
			        });

    my $combo_tipoDoc = C4::AR::Utilidades::generarComboTipoNivel3();
    $t_params->{'combo_tipoDoc'} = $combo_tipoDoc;
    my $combo_UI = C4::AR::Utilidades::generarComboUI();
    $t_params->{'combo_UI'}=$combo_UI;
    my $combo_permisos = C4::AR::Utilidades::generarComboPermisos();
    $t_params->{'combo_permisos'}= $combo_permisos;

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "OBTENER_PERMISOS"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  template_name => "admin/detalle_permisos.tmpl",
                                                                    query => $input,
                                                                    type => "intranet",
                                                                    authnotrequired => 0,
                                                                    flagsrequired => {parameters => 1},
                                                                    debug => 1,
                    });
    my $permisos = C4::AR::Permisos::obtenerPermisos($nro_socio,$id_ui,$tipo_documento);

    $t_params->{'permisos'}=$permisos;


    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  template_name => "admin/detalle_permisos.tmpl",
                                                                    query => $input,
                                                                    type => "intranet",
                                                                    authnotrequired => 0,
                                                                    flagsrequired => {parameters => 1},
                                                                    debug => 1,
                    });

    C4::AR::Permisos::actualizarPermisos($nro_socio,$id_ui,$tipo_documento);


    my $permisos = C4::AR::Permisos::obtenerPermisos($nro_socio,$id_ui,$tipo_documento);

    $t_params->{'permisos'}=$permisos;


    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
