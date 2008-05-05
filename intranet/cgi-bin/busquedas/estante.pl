#!/usr/bin/perl

use strict;
use CGI;
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::AR::Utilidades;
use C4::BookShelves;

my $query = new CGI;
my $nameShelf = $query->param('viewShelfName');
my $buscoPor="";
my %shelflist;
my $type='public';#Estantes publicos

my ($template, $loggedinuser, $cookie)  = get_template_and_user({template_name => "busquedas/estante.tmpl",
							query => $query,
							type => "intranet",
							authnotrequired => 0,
							flagsrequired => {catalogue => 1},
						});

if ($nameShelf) { #Buscar por nombre

my $startfrom = 0;
if($query->param('startfrom')) {$startfrom = $query->param('startfrom');}
  (%shelflist) = &getbookshelfLike($nameShelf);

	$buscoPor ="Estante Virtual: ".$nameShelf ;
 
}
else { #Trae todos los del primer nivel
  %shelflist = &GetShelfList($type);
}

my @shelvesloop;
my @key=sort { noaccents($shelflist{$a}->{'shelfname'}) cmp noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);


foreach my $element (@key) {
		my %line;
		$line{'shelf'}=$element;
		$line{'shelfnumberParent'}=$shelflist{$element}->{'numberparent'};
		$line{'parentname'}=$shelflist{$element}->{'nameparent'};
		$line{'shelfname'}=$shelflist{$element}->{'shelfname'};
		$line{'shelfbookcount'}=$shelflist{$element}->{'count'};
		$line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;
		push (@shelvesloop, \%line);
}

$template->param(
		SEARCH_RESULTS => \@shelvesloop,
		buscoPor=>	$buscoPor
		);


output_html_with_http_headers $query, $cookie, $template->output;