#!/usr/bin/perl
use strict;
require Exporter;
use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                template_name   => "opac-main.tmpl",
                                query           => $query,
                                type            => "opac",
                                authnotrequired => 1,
                                flagsrequired   => {  ui            => 'ANY', 
                                                    tipo_documento  => 'ANY', 
                                                    accion          => 'CONSULTA', 
                                                    entorno         => 'undefined'},
            });

$t_params->{'opac'};
$t_params->{'content_title'}    = C4::AR::Filtros::i18n("Formulario de contacto");

my $post = $query->param('post_message') || 0;

if ($post){

    use C4::Modelo::Contacto;
    my ($contacto)  = C4::Modelo::Contacto->new();
    my $params_hash = $query->Vars;
    $t_params->{'mensaje_error'} = 0;
        #verificamos que los campos requeridos tengan valor
    if( ($params_hash->{'nombre'} eq "") || ($params_hash->{'apellido'} eq "") || ($params_hash->{'email'} eq "") || ($params_hash->{'mensaje'} eq "") ){
        $t_params->{'mensaje_error'} = 1;
    }else{
  	    $contacto->agregar($params_hash);
    }
        
    $t_params->{'partial_template'} = "opac-contact_posted.inc";
    
}else{
    $t_params->{'partial_template'} = "opac-contact.inc";
}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
