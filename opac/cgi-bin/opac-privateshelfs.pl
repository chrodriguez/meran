#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::BookShelves;
use C4::AR::Catalogacion;
use C4::AR::Busquedas;

my $query=new CGI;


my  ($template, $borrowernumber, $cookie);

($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-privateshelfs.tmpl",
                             query => $query,
                             type => "opac",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1},
                         });


my $mail = C4::AR::Usuarios::getBorrower($borrowernumber)->{'emailaddress'};
$template->param(MAIL => $mail);


my $op=  $query->param('bookmarkOp');
my $number_of_results = 15;
my @results;
my $count;
my $pshelf=gotShelf($borrowernumber);
if( $pshelf eq 0){$pshelf=createPrivateShelf($borrowernumber);}

my $shelfvalues = $query->param('bookmarks');
my @val=split(/#/,$shelfvalues);

foreach my $biblio (@val){
	if ($op eq 'del'){ 
		delPrivateShelfs($pshelf,$biblio);
	}else{
		addPrivateShelfs($pshelf,$biblio);}
}

# uso privateShelfs2 para mantener la anterior, si esta bien sacar la vieja
my ($count, $resultId1) = &privateShelfs($borrowernumber);

my %result;
my $nivel1;
my @autor;
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

output_html_with_http_headers $query, $cookie, $template->output;
