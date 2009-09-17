#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Preferencias;
use C4::AR::Referencias;
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


if ($accion eq "OBTENER_TABLAS"){

    my $alias_tabla= $obj->{'alias_tabla'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/referencias/detalle_tabla.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });

    my ($clave,$tabla,$datos,$campos) = C4::AR::Referencias::getTabla($alias_tabla);

    $t_params->{'campos'} = $campos;
    $t_params->{'datos'} = $datos;
    $t_params->{'tabla'} = $tabla;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);

}
elsif ($accion eq "MOSTRAR_REFERENCIAS"){

    my $alias_tabla= $obj->{'alias_tabla'};
    my $value_id = $obj->{'value_id'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/referencias/detalle_referencias.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    my ($referer_involved,$items_involved) = C4::AR::Referencias::mostrarReferencias($alias_tabla,$value_id);
    if ($items_involved){
        my ($tabla_related,$related_referers) = C4::AR::Referencias::mostrarSimilares($alias_tabla,$value_id);
    
        $t_params->{'involved'} = $items_involved;
        $t_params->{'referer_involved'} = $referer_involved;
        $t_params->{'related_referers'} = $related_referers;
        $t_params->{'tabla_related'} = $tabla_related;
    }
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "ASIGNAR_REFERENCIA"){

    my $alias_tabla= $obj->{'alias_tabla'};
    my $related_id = $obj->{'related_id'};
    my $referer_involved = $obj->{'referer_involved'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/referencias/detalle_referencias.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    C4::AR::Referencias::asignarReferencia($alias_tabla,$related_id,$referer_involved);
    my ($referer_involved,$items_involved)=C4::AR::Referencias::mostrarReferencias($alias_tabla,$related_id);
    my ($tabla_related,$related_referers) = C4::AR::Referencias::mostrarSimilares($alias_tabla,$related_id);


    $t_params->{'involved'} = $items_involved;
    $t_params->{'referer_involved'} = $referer_involved;
    $t_params->{'related_referers'} = $related_referers;
    $t_params->{'tabla_related'} = $tabla_related;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "ASIGNAR_Y_ELIMINAR_REFERENCIA"){

    my $alias_tabla= $obj->{'alias_tabla'};
    my $related_id = $obj->{'related_id'};
    my $referer_involved = $obj->{'referer_involved'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/referencias/detalle_referencias.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    C4::AR::Referencias::asignarYEliminarReferencia($alias_tabla,$related_id,$referer_involved);
    my ($referer_involved,$items_involved)=C4::AR::Referencias::mostrarReferencias($alias_tabla,$related_id);
    my ($tabla_related,$related_referers) = C4::AR::Referencias::mostrarSimilares($alias_tabla,$related_id);


    $t_params->{'involved'} = $items_involved;
    $t_params->{'referer_involved'} = $referer_involved;
    $t_params->{'related_referers'} = $related_referers;
    $t_params->{'tabla_related'} = $tabla_related;

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "NUEVO_PERMISO_CATALOGO"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    C4::AR::Permisos::nuevoPermisoCatalogo($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosCatalogo($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "SHOW_NUEVO_PERMISO_CATALOGO"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}


# PERMISOS GENERALES

elsif ($accion eq "general"){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/permisos_general.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
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

  C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "OBTENER_PERMISOS_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/detalle_permisos_general.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento,$perfil);
    $t_params->{'permisos'}=$permisos;
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'MODIFICACION', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    my $updateStatus = C4::AR::Permisos::actualizarPermisosGeneral($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "NUEVO_PERMISO_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    C4::AR::Permisos::nuevoPermisoGeneral($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "SHOW_NUEVO_PERMISO_GENERAL"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
# PERMISOS PARA CIRCULAR

elsif ($accion eq "circulacion"){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/permisos_circulacion.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
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

  C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "OBTENER_PERMISOS_CIRCULACION"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosCirculacion($nro_socio,$id_ui,$tipo_documento,$perfil);
    $t_params->{'permisos'}=$permisos;
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS_CIRCULACION"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'MODIFICACION', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    my $updateStatus = C4::AR::Permisos::actualizarPermisosCirculacion($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosCirculacion($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "NUEVO_PERMISO_CIRCULACION"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    C4::AR::Permisos::nuevoPermisoCirculacion($nro_socio,$id_ui,$tipo_documento,$permisos);
    my $permisos = C4::AR::Permisos::obtenerPermisosCirculacion($nro_socio,$id_ui,$tipo_documento);
    $t_params->{'permisos'}=$permisos;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif ($accion eq "SHOW_NUEVO_PERMISO_CIRCULACION"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
