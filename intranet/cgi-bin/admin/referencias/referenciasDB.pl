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
