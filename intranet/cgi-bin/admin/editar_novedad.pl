#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Novedades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "admin/agregar_novedad.tmpl",
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

my $id = $input->param('id') || 0;

if ($action eq 'editar'){

    #---------------- imagenes nuevas -----------------
    
    #me quedo con las hash que tengan 'file_*' por si agregaron nuevas imagenes
    my @arrayNewFiles;
    
    #copio la referencia de la hash
    my $hash        = $input->{'param'};
    
    #me quedo con las key, la trato a la referencia como una hash
    my @keys        = keys %$hash;
    
    #hago un grep para quedarme con las 'file_*'
    my @file_key    = grep { $_ =~ /^file_/; } @keys;
    
    foreach my $key ( @file_key ){

        #solo los que tengan algo adentro  
        if($hash->{$key}[0] ne ""){
            push(@arrayNewFiles, $input->param($key));
        } 
        
    }
    #---------------- fin imagenes nuevas -----------------
    
    my @arrayDeleteImages;
    
    #si marcaron alguna imagen para eliminarla
    if($input->param('cantidad')){
        
        for( my $i=0; $i<$input->param('cantidad'); $i++){
        
            push(@arrayDeleteImages, $input->param('imagen_' . $i));
            
        }
    
    }
    
    my %params;
    $params{'arrayNewFiles'}        = \@arrayNewFiles;
    $params{'arrayDeleteImages'}    = \@arrayDeleteImages;
    
    my ($Message_arrayref) = C4::AR::Novedades::editar($input, \%params);
    
    if($Message_arrayref->{'error'} == 0){

        C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/admin/novedades_opac.pl?token='.$input->param('token'));
    }else{
        $t_params->{'mensaje'} = $Message_arrayref->{'messages'}[0]->{'message'};
    }
    
}else{

    my ($imagenes_novedad,$cant)    = C4::AR::Novedades::getImagenesNovedad($id);
    
    $t_params->{'imagenes_hash'}    = $imagenes_novedad;
    
    $t_params->{'novedad'}          = C4::AR::Novedades::getNovedad($id);
    
    $t_params->{'cant_novedades'}   = $cant;
    
    $t_params->{'editing'}          = 1;
}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
