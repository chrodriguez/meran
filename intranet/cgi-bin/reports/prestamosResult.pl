#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::AR::SxcGenerator;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/prestamosResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $branch = $obj->{'branch'};
my $orden = $obj->{'orden'} || 'cardnumber';
my $estado=$obj->{'estado'}|| 'TO';
#Fechas 
my $begindate = $obj->{'begindate'};
my $enddate = $obj->{'enddate'};


my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

if ($obj->{'renglones'}){$cantR=$obj->{'renglones'};}

my ($cantidad,@resultsdata)= prestamos($branch,$orden,$ini,$cantR,$estado,$begindate,$enddate);#Prestamos sin devolver (vencidos y no vencidos)
my $funcion=$obj->{'funcion'};

if($cantR ne "todos"){
	C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion,$t_params);
}

my $planilla=generar_planilla_prestamos(\@resultsdata,$loggedinuser);


$template->param( 	
			estado		 => $estado,
			resultsloop      => \@resultsdata,
			cantidad         => $cantidad,
			renglones        => $cantR,
			planilla	 => $planilla,
		);

output_html_with_http_headers $input, $cookie, $template->output;
