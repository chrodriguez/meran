#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Novedades;
use Encode;
use C4::AR::Social;
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

my $action          = $input->param('action') || 0;
my $twitter_enabled = C4::AR::Social::twitterEnabled();
my $contenido       = $input->param('contenido');
my $cont;

#estamos agregando o editando
if ($action){

    #------------ data de los inputs-------------
    $t_params->{'titulo'}       = $input->param('titulo');
    $t_params->{'categoria'}    = $input->param('categoria');
    $t_params->{'contenido'}    = $input->param('contenido');
    $t_params->{'twiter'}       = $input->param('check_publicar');
    $t_params->{'nombreAdjunto'}= $input->param('nombreAdjunto');
    $t_params->{'links'}        = $input->param('links');
    #--------- FIN data de los inputs -----------
    

    #--------- imagenes nuevas -----------
    #me quedo con las hash que tengan 'file_*'
    my @arrayFiles;
    
    #copio la referencia de la hash
    my $hash        = $input->{'param'};
    
    #me quedo con las key, la trato a la referencia como una hash
    my @keys        = keys %$hash;
    
    #hago un grep para quedarme con las 'file_*'
    my @file_key    = grep { $_ =~ /^file_/; } @keys;
    
    foreach my $key ( @file_key ){

        #solo los que tengan algo adentro  
        if($hash->{$key}[0] ne ""){
            push(@arrayFiles, $input->param($key));
        } 
        
    }
    #-------- FIN imagenes nuevas ----------
    
    
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
    
#    $input->param('links', $linksFinal);
    #------- FIN links ---------
    
    my %novedad;
    
    $novedad{'titulo'}          = $input->param('titulo');
    $novedad{'contenido'}       = $input->param('contenido');
    $novedad{'links'}           = $linksFinal;
    $novedad{'categoria'}       = $input->param('categoria');
    $novedad{'nombreAdjunto'}   = $input->param('nombreAdjunto');
     
    my %paramHash;
    
    C4::AR::Debug::debug("titulo : " . $novedad{'titulo'});
    
    $paramHash{'datosNovedad'} = \%novedad;
    $paramHash{'arrayFiles'}   = \@arrayFiles;
    $paramHash{'adjunto'}      = $input->upload('adjunto');
     
    my ($Message_arrayref, $novedad) = C4::AR::Novedades::agregar(\%paramHash);
    
    if($Message_arrayref->{'error'} == 0){
   
        if ($input->param('check_publicar')){

              my $link      = C4::AR::Social::shortenUrl($novedad->getId());

              $cont         = $novedad->getResumen();
              $cont         = Encode::decode_utf8($cont);
              my $post      = C4::AR::Preferencias::getValorPreferencia('prefijo_twitter')." ".$cont."... Ver mas en: ".$link;

              #  Posteo en twitter. En C4::AR::Social::sendPost se verifica si la preferencia twitter_enabled esta activada
              my $mensaje   = C4::AR::Social::sendPost($post);
        }

        C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/admin/novedades_opac.pl?token='.$input->param('token'));
        
    }else{
    
        $t_params->{'mensaje'} = $Message_arrayref->{'messages'}[0]->{'message'};
        
    }
}

$t_params->{'twitter_enabled'}  = $twitter_enabled; 
$t_params->{'page_sub_title'}   = C4::AR::Filtros::i18n("Agregar Novedad");
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
