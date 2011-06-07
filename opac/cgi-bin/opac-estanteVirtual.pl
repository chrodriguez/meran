#!/usr/bin/perl


use strict;
use CGI;
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::AR::Auth;

use C4::AR::Utilidades;

my $input = new CGI;
my $type='public';

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-estanteVirtual.tmpl",
								query => $input,
								type => "opac",
 	 							authnotrequired => 1,
# 								flagsrequired => {borrow => 1},
						});


my %shelflist;

my $obj=$input->param('obj');
$obj= &C4::AR::Utilidades::from_json_ISO($obj);

my $funcion= $obj->{'funcion'};
my $ini= $obj->{'ini'}||'';
my $count=0;

my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);

  %shelflist = &GetShelfList($type);
  ($count)= &getshelfListCount($type);

$t_params->{'paginador'}= &C4::AR::Utilidades::crearPaginador($count, $cantR, $pageNumber,$funcion,$t_params);
$t_params->{'LibraryName'}= C4::AR::Preferencias::getValorPreferencia("LibraryName")?;


my $color='';
my @shelvesloop;

my @key=sort { noaccents($shelflist{$a}->{'shelfname'}) cmp noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);


$ini= $ini*$cantR;
my $fin= $cantR-1+$ini;
my $cantEstantes= scalar(@key);
if($fin > $cantEstantes){
#si hay menos estantes para mostrar que renglones por pagina, el limite es la cantdad de estantes para mostrar
	$fin= $cantEstantes - 1;
}
my @keyAux=@key[$ini..$fin];

foreach my $element (@keyAux) {
		my %line;
		$line{'shelf'}=$element;
		#los datos del padre, sirve para la busqueda
#                 $line{'numberparent'}=$shelflist{$element}->{'numberparent'};
		#los datos del padre,sirve para la busqueda
#                 $line{'nameparent'}=$shelflist{$element}->{'nameparent'};
		$line{'shelfname'}=$shelflist{$element}->{'shelfname'};
		$line{'shelfbookcount'}=$shelflist{$element}->{'count'};
		$line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;

		push (@shelvesloop, \%line);
}

$t_params->{'shelvesloop'}= \@shelvesloop;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);