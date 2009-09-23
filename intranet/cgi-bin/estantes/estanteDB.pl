#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Estantes;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
my $input=new CGI;
my $authnotrequired= 0;
my $Messages_arrayref;
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipo= $obj->{'tipo'};

if($tipo eq "VER_ESTANTES"){

    my ($template, $session, $t_params) = get_template_and_user(
            {template_name => "estantes/verEstante.tmpl",
                    query => $input,
                    type => "intranet",
                    authnotrequired => 0,
                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });

    my $estantes_publicos = C4::AR::Estantes::getListaEstantesPublicos();
    $t_params->{'ESTANTES'}= $estantes_publicos;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif($tipo eq "VER_SUBESTANTE"){

	my ($template, $session, $t_params) = get_template_and_user(
            {template_name => "estantes/subEstante.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
					});
	
	my $id_estante= $obj->{'estante'};
    if($id_estante ne 0){
    my $estante= C4::AR::Estantes::getEstante($id_estante);
    $t_params->{'estante'}= $estante;
    }

    my $subEstantes= C4::AR::Estantes::getSubEstantes($id_estante);

    $t_params->{'SUBESTANTES'}= $subEstantes;
    $t_params->{'cant_subestantes'}= @$subEstantes;
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
elsif($tipo eq "BORRAR_ESTANTES"){
    my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'BAJA', 
                                                    entorno => 'undefined' },
                                                'intranet'
                               );

    my $estantes_array_ref= $obj->{'estantes'};
    ($Messages_arrayref)= &C4::AR::Estantes::borrarEstantes($estantes_array_ref);

    my $infoOperacionJSON=to_json $Messages_arrayref;

    C4::Auth::print_header($session);
    print $infoOperacionJSON;
}
elsif($tipo eq "BORRAR_CONTENIDO"){
    my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'BAJA', 
                                                    entorno => 'undefined' },
                                                'intranet'
                               );
    my $id_estante= $obj->{'estante'};
    my $contenido_array_ref= $obj->{'contenido'};
    ($Messages_arrayref)= &C4::AR::Estantes::borrarContenido($id_estante,$contenido_array_ref);

    my $infoOperacionJSON=to_json $Messages_arrayref;

    C4::Auth::print_header($session);
    print $infoOperacionJSON;
}
elsif($tipo eq "MODIFICAR_ESTANTE"){
    my ($user, $session, $flags)= checkauth(    $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'MODIFICACION', 
                                                    entorno => 'undefined' },
                                                'intranet'
                               );

    my $id_estante= $obj->{'estante'};
    my $valor= $obj->{'valor'};
    ($Messages_arrayref)= &C4::AR::Estantes::modificarEstante($id_estante,$valor);

    my $infoOperacionJSON=to_json $Messages_arrayref;

    C4::Auth::print_header($session);
    print $infoOperacionJSON;
}

