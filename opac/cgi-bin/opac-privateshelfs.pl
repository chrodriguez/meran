#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::BookShelves;
use C4::AR::Catalogacion;
use C4::AR::Busquedas;
use C4::AR::Utilidades;

my $input=new CGI;


my  ($template, $borrowernumber, $cookie);

($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-privateshelfs.tmpl",
                             query => $input,
                             type => "opac",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1},
                         });


my $mail = C4::AR::Usuarios::getBorrower($borrowernumber)->{'emailaddress'};
$template->param(MAIL => $mail);

my $obj=$input->param('obj');
$obj=from_json_ISO($obj);

my $funcion= $obj->{'funcion'};
my $ini= $obj->{'ini'}||'';

my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);

my ($count, $resultId1) = &privateShelfs($borrowernumber,$ini,$cantR);

&C4::AR::Utilidades::crearPaginador($template, $count, $cantR, $pageNumber,$funcion,$t_params);

my %result;
my $nivel1;
my $autor;
my $id1;
my $comboItemTypes= "-1";
my @resultsarray;

for (my $i=0;$i<scalar(@$resultId1);$i++){

	$id1=$resultId1->[$i];
	$result{$i}->{'id1'}= $id1;
 	$nivel1= &buscarNivel1($id1);
	$result{$i}->{'titulo'}= $nivel1->{'titulo'};
	$autor= C4::AR::Busquedas::getautor($nivel1->{'autor'});
	$result{$i}->{'idAutor'}=$autor->{'id'};
	$result{$i}->{'nomCompleto'}= $autor->{'completo'};
	my @ediciones=&obtenerEdiciones($id1, $comboItemTypes);
	$result{$i}->{'grupos'}=\@ediciones;

	my @disponibilidad=&obtenerDisponibilidadTotal($id1, $comboItemTypes);
	$result{$i}->{'disponibilidad'}=\@disponibilidad;
	push (@resultsarray, $result{$i});
}


$template->param(SEARCH_RESULTS => \@resultsarray);
$template->param(numrecords => $count);
$template->param(pagetitle => "Favoritos");

$template->param(
			LibraryName => C4::Context->preference("LibraryName")
		);

output_html_with_http_headers $input, $cookie, $template->output;
