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
								template_name => "usuarios/reales/buscarUsuarioResult.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => {borrowers => 1},
								debug => 1,
			     });


my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $orden=$obj->{'orden'}||'apellido';
my $socio=$obj->{'socio'};
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $inicial=$obj->{'inicial'};
my $env;


my ($cantidad,$socios);
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

($cantidad,$socios)= C4::AR::Usuarios::getSocioLike($socio,$orden,$ini,$cantR);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);


my @resultsdata;
for (my $i=0; $i < $cantidad; $i++){
    my $clase="";
    my ($od,$issue)=C4::AR::Issues::cantidadDePrestamosPorUsuario($socios->[$i]->getNro_socio);
    my $regular= &C4::AR::Usuarios::esRegular($socios->[$i]->getNro_socio);

    if ($regular eq 1){$regular="Regular"; $clase="prestamo";}  
    else{
        if($regular eq 0){$regular="Irregular";$clase="fechaVencida";}
        else{
            $regular="---";
        }
    }

    my %row = (
            clase=>$clase,
            nro_socio => $socios->[$i]->getNro_socio,
            id_socio => $socios->[$i]->getId_socio,
#             cardnumber => $socios->[$i]->persona->getNro_socio,
            apellido => $socios->[$i]->persona->getApellido,
            nombre => $socios->[$i]->persona->getNombre,
#             completo => $socios->[$i]->persona->getApellido.", ".$socios->[$i]->persona->getNombre,
            categorycode => $socios->[$i]->getCod_categoria,
            calle => $socios->[$i]->persona->getCalle,
            version_documento => $socios->[$i]->persona->getVersion_documento,
            nro_documento => $socios->[$i]->persona->getNro_documento,
#             studentnumber => $socios->[$i]{'studentnumber'},
            ciudad => $socios->[$i]->persona->getCiudad,
#             odissue => "$od/$issue",
            issue => "$issue",
            od => "$od",
            regular => $regular,
    );
    push(@resultsdata, \%row);
}

$t_params->{'resultsloop'}= \@resultsdata;
$t_params->{'socio'}= $socio;
$t_params->{'cantidad'}= $cantidad;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
