#!/usr/bin/perl


use strict;
use CGI;
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input = new CGI;
my $type='public';


my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "estanteVirtual.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
					});


my $themelang = $template->param('themelang');
open(A, ">>/tmp/debug.txt");
print A "opac-estantevirtual themeland $themelang \n";
close(A);

#Para mandar la dir de mail
# getpatroninformation DEPRECATED
my ($borr, $flags) = getpatroninformation(undef, $loggedinuser);
if ($borr and ($borr->{'emailaddress'})){  $template->param(MAIL =>$borr->{'emailaddress'} ); }

my %shelflist;

my $obj=$input->param('obj');
$obj= &C4::AR::Utilidades::from_json_ISO($obj);

my $funcion= $obj->{'funcion'};
my $ini= $obj->{'ini'}||'';
my $count=0;

my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);

  %shelflist = &GetShelfList($type);
  ($count)= &getshelfListCount($type);

&C4::AR::Utilidades::crearPaginador($template, $count, $cantR, $pageNumber,$funcion,$t_params);


$template->param({LibraryName => C4::AR::Preferencias->getValorPreferencia("LibraryName")});


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

$template->param(shelvesloop => \@shelvesloop);

output_html_with_http_headers $input, $cookie, $template->output;