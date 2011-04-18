#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Sanciones;
use JSON;

my $input       = new CGI;
my $obj         = $input->param('obj');
$obj            = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion  = $obj->{'accion'};
my $orden; # usado para el order_by de las consultas

my ($template, $session, $t_params) =  get_template_and_user ({
            template_name   => 'circ/sancionesResult.tmpl',
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
    });


if($tipoAccion eq "MOSTRAR_SANCIONES"){

    $orden                          = $obj->{'orden'}||'persona.apellido';
    my $sanciones                   = C4::AR::Sanciones::sanciones($orden);
    $t_params->{'CANT_SANCIONES'}   = scalar(@$sanciones);
    $t_params->{'SANCIONES'}        = $sanciones;
    
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    

}#end if($tipoAccion eq "MOSTRAR_SANCIONES")

elsif($tipoAccion eq "ELIMINAR_SANCIONES"){

    my $authnotrequired= 0;
    my ($userid, $session, $flags)= checkauth(      $input, 
                                                    $authnotrequired, 
                                                    {   ui              => 'ANY', 
                                                        tipo_documento  => 'ANY', 
                                                        accion          => 'BAJA', 
                                                        entorno         => 'undefined'}, 
                                                        'intranet'
                                    );

    my $sanciones_ids     = $obj->{'datosArray'};
    my $Message_arrayref  = C4::AR::Sanciones::eliminarSanciones($userid,$sanciones_ids);

    my $infoOperacionJSON = to_json $Message_arrayref;
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

}#end if($tipoAccion eq "ELIMINAR_SANCIONES")

elsif($tipoAccion eq "BUSCAR_SANCIONES"){
    
    my ($cant,$sanciones)           = C4::AR::Sanciones::getSancionesLike($obj->{'string'});
    $t_params->{'SANCIONES'}        = $sanciones;
    $t_params->{'CANT_SANCIONES'}   = scalar(@$sanciones);
    
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    
} #end if($accion eq "BUSCAR_SANCIONES")
