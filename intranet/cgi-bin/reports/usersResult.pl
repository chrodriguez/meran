#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/usersResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $obj=$input->param('obj');
$obj= C4::AR::Utilidades::from_json_ISO($obj);

my $orden=$obj->{'orden'}||'cardnumber';
my $year = $obj->{'year'};
my $categ= $obj->{'categoria'};
my @chck=split('#',$obj->{'chck'});
my $usos=$obj->{'usos'};
my $branch=$obj->{'branch'};
my $funcion=$obj->{'funcion'};

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

#Obtengo los usuarios y la cantidad
my ($cantidad,@resultsdata)= usuarios($branch,$orden,$ini,$cantR,$year,$usos,$categ,@chck);
C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion);


$template->param( 	orden		 => $orden,
			resultsloop      => \@resultsdata,
			cantidad  	 => $cantidad
		);

output_html_with_http_headers $input, $cookie, $template->output;
