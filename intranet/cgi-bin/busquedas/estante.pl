#!/usr/bin/perl

use strict;
use CGI;
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::BookShelves;

my $input = new CGI;
# my $nameShelf = $input->param('viewShelfName');

my $obj=$input->param('obj');

if($obj ne ""){
	$obj=C4::AR::Utilidades::from_json_ISO($obj);
}

my $nameShelf = $obj->{'viewShelfName'};
my $funcion= $obj->{'funcion'};
my $buscoPor="";
my %shelflist;
my $type='public';#Estantes publicos

my ($template, $session, $t_params) = get_template_and_user ({
                                        template_name	=> 'busquedas/estante.tmpl',
                                        query		=> $input,
                                        type		=> "intranet",
                                        authnotrequired	=> 0,
                                        flagsrequired	=> { circulate => 1 },
    			 });

if ($nameShelf) { #Buscar por nombre

  	my (%shelflist) = &getbookshelfLike($nameShelf);
	$buscoPor ="Estante Virtual: ".$nameShelf ;
 
}
else { #Trae todos los del primer nivel
  %shelflist = &GetShelfList($type);
}

my @shelvesloop;
my @key=sort { C4::AR::Utilidades::noaccents($shelflist{$a}->{'shelfname'}) cmp C4::AR::Utilidades::noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);


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

$t_params->{'SEARCH_RESULTS'}= \@shelvesloop;
$t_params->{'buscoPor'}=$buscoPor;


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);