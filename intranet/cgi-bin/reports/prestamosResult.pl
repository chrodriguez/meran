#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::AR::SxcGenerator;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                template_name => "reports/prestamosResult.tmpl",
                                                query => $input,
                                                type => "intranet",
                                                authnotrequired => 0,
                                                flagsrequired => {borrowers => 1},
                                                debug => 1,
			    });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $branch = $obj->{'id_ui'};
my $orden = $obj->{'orden'} = $obj->{'orden'} || 'cardnumber';
my $estado = $obj->{'estado'} = $obj->{'estado'}|| 'TO';
#Fechas 
$obj->{'fechaIni'} = $obj->{'begindate'};
$obj->{'fechaFin'} = $obj->{'enddate'};

my $loggedinuser = $session->param('loggedinuser');
my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
$obj->{'ini'} = $ini;
$obj->{'cantR'} = $cantR;

if ($obj->{'renglones'}){
   $cantR=$obj->{'renglones'};
}

my ($cantidad,@resultsdata)= C4::AR::Estadisticas::prestamos($obj);#Prestamos sin devolver (vencidos y no vencidos)
my $funcion=$obj->{'funcion'};

if($cantR ne "todos"){
	C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion,$t_params);
}

# La planilla se debe generar si se la pide explicitamente!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# my $planilla=generar_planilla_prestamos(\@resultsdata,$loggedinuser);


$t_params->{'estado'}= $estado;
$t_params->{'resultsloop'}= \@resultsdata;
# $t_params->{'nene'} = @resultsdata[0]->socio->persona->getNombre;
$t_params->{'cantidad'}= $cantidad;
$t_params->{'renglones'}= $cantR;
# $t_params->{'planilla'}= $planilla;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
