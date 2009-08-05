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
    $accion = $input->param('action') || undef;
}


# my ($userid, $session, $flags) = checkauth($input, 0,{});
if ($accion eq "catalogo"){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({	
                        template_name => "admin/permisos_catalogo.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                        debug => 1,
			        });

    my $combo_tipoDoc = C4::AR::Utilidades::generarComboTipoNivel3();
    $t_params->{'combo_tipoDoc'} = $combo_tipoDoc;
    my %params_options;
    $params_options{'optionALL'} = 1;
    my $combo_UI = C4::AR::Utilidades::generarComboUI(\%params_options);
    $t_params->{'combo_UI'}=$combo_UI;
    my $combo_permisos = C4::AR::Utilidades::generarComboPermisos();
    $t_params->{'combo_permisos'}= $combo_permisos;
    my $combo_perfiles = C4::AR::Utilidades::generarComboPerfiles();
    $t_params->{'combo_perfiles'}= $combo_perfiles;
    $t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("Permisos de Cat&aacute;logo");

	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "OBTENER_PERMISOS_CATALOGO"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/detalle_permisos_catalogo.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosCatalogo($nro_socio,$id_ui,$tipo_documento,$perfil);
    $t_params->{'permisos'}=$permisos;
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS_CATALOGO"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                            debug => 1,
                    });

    my $updateStatus = C4::AR::Permisos::actualizarPermisosCatalogo($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosCatalogo($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "NUEVO_PERMISO_CATALOGO"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                            debug => 1,
                    });

    C4::AR::Permisos::nuevoPermisoCatalogo($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosCatalogo($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "SHOW_NUEVO_PERMISO_CATALOGO"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}


# PERMISOS GENERALES

elsif ($accion eq "general"){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos_general.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                        debug => 1,
              });

    my $combo_tipoDoc = C4::AR::Utilidades::generarComboTipoNivel3();
    $t_params->{'combo_tipoDoc'} = $combo_tipoDoc;
    my %params_options;
    $params_options{'optionALL'} = 1;
    my $combo_UI = C4::AR::Utilidades::generarComboUI(\%params_options);
    $t_params->{'combo_UI'}=$combo_UI;
    my $combo_permisos = C4::AR::Utilidades::generarComboPermisos();
    $t_params->{'combo_permisos'}= $combo_permisos;
    my $combo_perfiles = C4::AR::Utilidades::generarComboPerfiles();
    $t_params->{'combo_perfiles'}= $combo_perfiles;
    $t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("Permisos generales");

  C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "OBTENER_PERMISOS_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/detalle_permisos_general.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento,$perfil);
    $t_params->{'permisos'}=$permisos;
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                            debug => 1,
                    });

    my $updateStatus = C4::AR::Permisos::actualizarPermisosGeneral($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "NUEVO_PERMISO_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                            debug => 1,
                    });

    C4::AR::Permisos::nuevoPermisoGeneral($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
elsif ($accion eq "SHOW_NUEVO_PERMISO_GENERAL"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
# PERMISOS PARA CIRCULAR

elsif ($accion eq "circulacion"){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos_circulacion.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'},
                        debug => 1,
              });

    my $combo_tipoDoc = C4::AR::Utilidades::generarComboTipoNivel3();
    $t_params->{'combo_tipoDoc'} = $combo_tipoDoc;
    my %params_options;
    $params_options{'optionALL'} = 1;
    my $combo_UI = C4::AR::Utilidades::generarComboUI(\%params_options);
    $t_params->{'combo_UI'}=$combo_UI;
    my $combo_permisos = C4::AR::Utilidades::generarComboPermisos();
    $t_params->{'combo_permisos'}= $combo_permisos;
    my $combo_perfiles = C4::AR::Utilidades::generarComboPerfiles();
    $t_params->{'combo_perfiles'}= $combo_perfiles;
    $t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("Permisos de Circulaci&oacute;n");

  C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}
