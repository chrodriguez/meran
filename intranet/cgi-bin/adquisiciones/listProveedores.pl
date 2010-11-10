#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "adquisiciones/listProveedores.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                    debug => 1,
                });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $orden=$obj->{'orden'}||'nombre';
my $proveedor=$obj->{'proveedor'};
$obj->{'ini'} = $obj->{'ini'} || 1;
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $inicial=$obj->{'inicial'};
my $env;
C4::AR::Validator::validateParams('U389',$obj,['proveedor','ini','funcion'] );


my ($cantidad,$proveedores);
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

if ($inicial){
    ($cantidad,$proveedores)= C4::AR::Usuarios::getSocioLike($socio,$orden,$ini,$cantR,1,$inicial);
}else{
    ($cantidad,$socios)= C4::AR::Usuarios::getSocioLike($socio,$orden,$ini,$cantR,1,0);
}

if($socios){
    $t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
    my @resultsdata;

    for my $socio (@$socios){
        my $clase="";
        my ($od,$issue)=C4::AR::Prestamos::cantidadDePrestamosPorUsuario($socio->getNro_socio);
        my $regular= &C4::AR::Usuarios::esRegular($socio->getNro_socio);
    
        if ($regular eq 1){$regular="Regular"; $clase="prestamo";}  
        else{
            if($regular eq 0){$regular="Irregular";$clase="fechaVencida";}
            else{
                $regular="---";
            }
        }
    
        my %row = (
                clase=>$clase,
                socio => $socio,
                issue => "$issue",
                od => "$od",
                regular => $regular,
        );
        push(@resultsdata, \%row);
    }
    
    $t_params->{'resultsloop'}= \@resultsdata;
    $t_params->{'cantidad'}= $cantidad;
    $t_params->{'socio_busqueda'}=$socio;

}#END if($socios)

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

1;