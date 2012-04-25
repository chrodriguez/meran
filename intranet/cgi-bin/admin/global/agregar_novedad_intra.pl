#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::NovedadesIntra;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "admin/global/agregar_novedad_intra.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'usuarios'},
                                    debug => 1,
                });

my $action = $input->param('action') || 0;

if ($action){

    #--------- links -----------
    my $linksTodos  = $input->param('links');  
    my @links       = split('\ ', $linksTodos);   
    my $linksFinal  = "";
    
    foreach my $link (@links){
    
        if($link !~ /^http/){
            $linksFinal .= " http://" . $link;
        }else{
            $linksFinal .= " " . $link;
        }
    }
    
    $input->param('links', $linksFinal);
    #------- FIN links ---------

    my $status = C4::AR::NovedadesIntra::agregar($input);
    if ($status){
        C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/admin/global/novedades_intra.pl?token='.$input->param('token'));
    }
}


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
