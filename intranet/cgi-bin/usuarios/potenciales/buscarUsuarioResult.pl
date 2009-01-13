#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::Date;
use Date::Manip;
use C4::AR::Usuarios;
use C4::AR::Utilidades;


my $input = new CGI;

my ($template, $session, $t_params, $cookie)= get_template_and_user({
                                template_name => "usuarios/potenciales/buscarUsuarioResult.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {borrowers => 1},
                                debug => 1,
                 });


my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $orden=$obj->{'orden'}||'apellido';
my $socioBuscado=$obj->{'persona'};
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $inicial=$obj->{'inicial'};
my $activo;

my ($cantidad,$socios);
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);


my $habilitados = $obj->{'habilitados_filter'};
($cantidad,$socios)= C4::AR::Usuarios::getSocioLike($socioBuscado,$orden,$ini,$cantR,$habilitados);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategoriasDeSocio();

my @resultsdata; 
my $i=0;

foreach my $socio (@$socios){
    my $clase="";
     if ($socio->getActivo == 0){
         $activo = "NO";
      }else{
         $activo = "SI";
     }
    
     my %row = (
            clase=> $clase,
            socio => $socio,
            comboCategorias => $comboDeCategorias,
            activo => $activo,
    );

    push(@resultsdata, \%row);
}

$t_params->{'resultsloop'}= \@resultsdata;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'socio'}= $socioBuscado;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
