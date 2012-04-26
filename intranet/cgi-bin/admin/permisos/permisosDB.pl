#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Preferencias;
use C4::AR::Permisos;
use JSON;

my $input = new CGI;
my $obj=$input->param('obj');

C4::AR::Debug::debug("obj => ".$obj);

$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $accion;
if ($obj != 0){
    $accion = $obj->{'accion'};
    $obj->{'tipo_documento'} = 'ALL'; #FIX PARA FERNANDA QUE DICE QUE ESTO NO HACE FALTA
}else{
    $accion = $input->param('action') || undef;
}

if ($accion eq "OBTENER_PERMISOS_CATALOGO"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'permisos', 
                                            tipo_permiso => 'general'
                        },
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosCatalogo($nro_socio,$id_ui,$tipo_documento,$perfil);
    $t_params->{'permisos'}=$permisos;
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS_CATALOGO"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

      my ($Message_arrayref)= C4::AR::Permisos::actualizarPermisosCatalogo($nro_socio,$id_ui,$tipo_documento,$permisos);

      my $infoOperacionJSON=to_json $Message_arrayref;

      C4::AR::Auth::print_header($session);
      print $infoOperacionJSON;

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
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'ALTA', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    
    my ($Message_arrayref)= C4::AR::Permisos::nuevoPermisoCatalogo($nro_socio,$id_ui,$tipo_documento,$permisos);

    my $infoOperacionJSON=to_json $Message_arrayref;
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
}
elsif ($accion eq "SHOW_NUEVO_PERMISO_CATALOGO"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

} elsif ($accion eq "OBTENER_PERMISOS_GENERAL"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/detalle_permisos_general.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'permisos', 
                                            tipo_permiso => 'general'
                        },
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosGenerales($nro_socio,$id_ui,$tipo_documento,$perfil);
    
    C4::AR::Utilidades::printHASH($permisos);
    
    $t_params->{'permisos'}=$permisos;
    
    
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

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
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    my ($Message_arrayref)= C4::AR::Permisos::actualizarPermisosGeneral($nro_socio,$id_ui,$tipo_documento,$permisos);

    my $infoOperacionJSON=to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
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
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'ALTA',   
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    my ($Message_arrayref)= C4::AR::Permisos::nuevoPermisoGeneral($nro_socio,$id_ui,$tipo_documento,$permisos);

    my $infoOperacionJSON=to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

} elsif ($accion eq "SHOW_NUEVO_PERMISO_GENERAL"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_catalogo.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

} elsif ($accion eq "OBTENER_PERMISOS_CIRCULACION"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'permisos', 
                                            tipo_permiso => 'general'
                        },
                        debug => 1,
                    });
    my $perfil = $obj->{'perfil'} || 0;
    my ($permisos,$newUpdate) = C4::AR::Permisos::obtenerPermisosCirculacion($nro_socio,$id_ui,$tipo_documento,$perfil);
    $t_params->{'permisos'}=$permisos;
    if ($newUpdate){
        $t_params->{'nuevoPermiso'}=1;
    }
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}
elsif ($accion eq "ACTUALIZAR_PERMISOS_CIRCULACION"){

    my $nro_socio = $obj->{'nro_socio'};
    my $id_ui = $obj->{'id_ui'};
    my $tipo_documento = $obj->{'tipo_documento'};
    my $permisos = $obj->{'permisos'};
    
    C4::AR::Debug::debug("entrooooooooooooooooooooooooooooooooooooooooooooooooo");

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'MODIFICACION', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    my ($Message_arrayref)= C4::AR::Permisos::actualizarPermisosCirculacion($nro_socio,$id_ui,$tipo_documento,$permisos);

    my $infoOperacionJSON=to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
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
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'ALTA', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    my ($Message_arrayref)= C4::AR::Permisos::nuevoPermisoCirculacion($nro_socio,$id_ui,$tipo_documento,$permisos);

    my $infoOperacionJSON=to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

}
elsif ($accion eq "SHOW_NUEVO_PERMISO_CIRCULACION"){

    my ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "admin/permisos/detalle_permisos_circulacion.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'
                            },
                            debug => 1,
                    });

    $t_params->{'nuevoPermiso'}=1;
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
