#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $input = new CGI;

my $obj=$input->param('obj');

if($obj ne ""){
   $obj=from_json_ISO($obj);
}

my $signatura= $obj->{'signatura'};
my $isbn = $obj->{'isbn'};
my $codBarra= $obj->{'codBarra'};
my $autor= $obj->{'autor'};
my $titulo= $obj->{'titulo'};
my $tipo= $obj->{'tipo'};
my $idTema= $obj->{'idTema'};
my $tema= $obj->{'tema'};
my $comboItemTypes= $obj->{'comboItemTypes'};
my $idAutor= $obj->{'idAutor'};
my $orden= $obj->{'orden'}||'titulo';#PARA EL ORDEN
my $funcion= $obj->{'funcion'};


my $nivel1="";
my $nivel2="";
my $nivel3="";
my $nivel1rep="";
my $nivel2rep="";
my $nivel3rep="";
my $buscoPor="";


my ($template, $session, $t_params) = get_template_and_user ({
                                                            template_name  => 'busquedas/busquedaResult.tmpl',
                                                            query    => $input,
                                                            type     => "intranet",
                                                            authnotrequired   => 0,
                                                            flagsrequired  => { circulate => 1 },
                  });

my $ini= ($obj->{'ini'}||'');

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, $resultsdata)= C4::AR::Busquedas::busquedaAvanzada_newTemp($ini,$cantR,$obj);

my @id1_array;

foreach my $nivel3 (@$resultsdata){
      push(@id1_array,$nivel3->getId1);
}

my $array_nivel1 = C4::AR::Busquedas::armarInfoNivel1($cantidad,@id1_array);

$t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

$t_params->{'SEARCH_RESULTS'}=$array_nivel1;

$t_params->{'cantidad'}=$cantidad;

$t_params->{'buscoPor'}=$obj->{'titulo'};

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

