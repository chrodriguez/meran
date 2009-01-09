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
my $personaBuscada=$obj->{'persona'};
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $inicial=$obj->{'inicial'};
my $activo;

my ($cantidad,$personas);
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);


my $habilitados = $obj->{'habilitados_filter'};
($cantidad,$personas)= C4::AR::Usuarios::getPersonaLike($personaBuscada,$orden,$ini,$cantR,$habilitados);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategoriasDeSocio();

my @resultsdata;
# for (my $i=0; $i < $cantidad; $i++){

# 
foreach my $persona ($personas){
    my $clase="";
#     if ($personas->[$i]->getActivo == 0){
#     if ($persona->getActivo == 0){
#         $activo = "NO";
#     }else{
#         $activo = "SI";
#     }
#     my %row = (
#             clase=>$clase,
#             id_persona => $personas->[$i]->getId_persona,
# #             cardnumber => $personas->[$i]->getNro_socio,
#             apellido => $personas->[$i]->getApellido,
#             nombre => $personas->[$i]->getNombre,
# #             completo => $personas->[$i]->getApellido.", ".$personas->[$i]->getNombre,
#             calle => $personas->[$i]->getCalle,
#             version_documento => $personas->[$i]->getVersion_documento,
#             nro_documento => $personas->[$i]->getNro_documento,
# #             studentnumber => $personas->[$i]{'studentnumber'},
#             ciudad => $personas->[$i]->getCiudad,
# #             odissue => "$od/$issue",
# #             issue => "$issue",
# #             od => "$od",
#             regular => $regular,
#             
#       
    
#     );
    
     my %row = (
            clase=> $clase,
            persona => $persona,
            comboCategorias => $comboDeCategorias,
            activo => $activo,
    );

    push(@resultsdata, \%row);
}

$t_params->{'resultsloop'}= \@resultsdata;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'persona'}= $personaBuscada;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
