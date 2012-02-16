#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use JSON;

my $input           = new CGI;
my $obj             = $input->param('obj');
my $editing         = $input->param('value') || $input->param('id');
my $editing_esquema = $input->param('edit_esquema') || 0;
my ($template, $session, $t_params);

my $show_template = 1;

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion  = $obj->{'accion'}||""; 

f($tipoAccion eq "UPDATE_ESQUEMA"){

        ($template, $session, $t_params)  = get_template_and_user({  
                            template_name => "includes/partials/modificar_value.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'permisos', 
                                                tipo_permiso => 'general'},
                            debug => 1,
                        });
    
        my $string_ref = $input->param('id');
        my $value = $input->param('value');
        
        $valor = C4::AR::Usuarios::editarRegularidadEsquema($string_ref,$value);



C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

