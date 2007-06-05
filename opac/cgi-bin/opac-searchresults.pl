#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Circulation::Circ2;
use C4::Interface::CGI::Output;
use HTML::Template;
use HTML::Template::Expr;
use C4::BookShelves;
use C4::AR::PdfGenerator;
my $query=new CGI;

#Orden
my $orden;
my %search;
my $forminputs;

if ($query->param('orden')){$orden=$query->param('orden');} else {$orden='title';}

my  ($template, $borrowernumber, $cookie);

#Tuto: Es una busqueda por Estante Virtual?
my $shelves=$query->param('shelves');

#Matias: Es una busqueda en la Biblioteca Virtual?
#my $virtual=$query->param('virtual');


#Matias: Es una busqueda por analiticas?
my $analytical= $query->param('analytical');
#


#Luciano: Es una busqueda por diccionario
my $dictionary=$query->param('dictionary');
my $dicdetail=$query->param('dicdetail');
($dicdetail) || ($dicdetail=0);
#
# get all the search variables
# we assume that C4::Search will validate these values for us
my @fields = ('keyword', 'subject', 'author', 'illustrator', 'itemnumber', 'isbn', 'date-before', 'date-after', 'class', 'dewey', 'branch', 'title', 'abstract', 'publisher','subjectitems', 'virtual', 'shelves'); #Matias: Agrego 'virtual'  

if (($shelves) || ($query->param('criteria') eq 'shelves')) {
	#es una busqueda por estantes virtuales, o avanzada o desde el borde superior de la pantalla
	if ($query->param('criteria') eq 'shelves'){$shelves=$query->param('searchinc');}
	print $query->redirect("/cgi-bin/koha/opac-shelves.pl?viewShelfItems=$shelves&startfrom=0");
	
} 


if ($query->param('virtual')) {#es una busqueda por biblioteca virtual
	($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "virtual/opac-virtualsearchresults.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				flagsrequired => {borrow => 1}
				});
	$search{'virtual'}= $query->param('virtual');

} elsif ($dictionary) {
	($template, $borrowernumber, $cookie)
		= get_templateexpr_and_user({template_name => "dictionary-search.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				flagsrequired => {borrow => 1}
				});
	$search{'dictionary'}= $dictionary;
	push @$forminputs, {field => 'dictionary' , value => $dictionary};
	$search{'dicdetail'}= $dicdetail;

}elsif ($analytical) {
        ($template, $borrowernumber, $cookie)
		= get_templateexpr_and_user({template_name => "opac-analytical-search.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				flagsrequired => {catalogue => 1},
				});
	 $search{'analytical'}= $analytical;
	 push @$forminputs, {field => 'analytical' , value => $analytical};
			 
}else {
	($template, $borrowernumber, $cookie)
		= get_templateexpr_and_user({template_name => "opac-searchresults.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				flagsrequired => {borrow => 1},
				});
#Matias: Para permitir buscar desde cualquier lugar importando opac-search.inc, o sea que se esta buscando desde la parte superior de la ventana
	my $searchinc=$query->param('searchinc');
	if ($searchinc){
		my $field=$query->param('criteria');
		$search{$field} = $searchinc;
		if ($field eq 'subjectitems') {
			$template->param(subjectsearch => $searchinc);
		}
		elsif ($field eq 'keyword'){
			$search{$field} = $query->param('words') unless $search{$field};
		}	
		if ($search{$field}) {
			push @$forminputs, {field => $field, value => $search{$field}};            
		}
	}else{
		#quiere decir que no es searchinc, entonces se esta haciendo una busqueda o simple o avanzada
		(($query->param('subject'))&&($template->param(subjectsearch =>$query->param('subject')))&&( push @$forminputs, {field => 'subjectitems' , value => $search{'subjectitems'}}));	
		(($search{'keyword'} = $query->param('keyword'))||($search{'keyword'} =$query->param('words')) );
		#Einar para el authorid
		my $value = $query->param('authorid');
		if ($value) {
		my @val=&getautor($value);
		$search{'authorid'} = $value;
		$template->param(AUTORID => \@val);
		push @$forminputs, {	field => 'authorid',
				value =>$value };

		}	
		foreach my $field (@fields) {
			$search{$field} = $query->param($field);
			if ($query->param($field)) {
				push @$forminputs, {field => $field, value => ($query->param($field))};
			}

		}

	} #Fin del if que define los parametros de busqueda

} 

if (C4::Context->preference("EnabledMailSystem")){
	my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
	if ($borr->{'emailaddress'}){$template->param(MAIL =>$borr->{'emailaddress'} ); }
}

#ttype es el metodo de busqueda, si es exacto o no
(($search{'ttype'} = $query->param('ttype') )&& (push @$forminputs, {field => 'ttype', value => $search{'ttype'}}));

#Luciano: Busqueda por diccionario
#if ($dictionary){
#	$search{'dictionary'}= $dictionary;
#	push @$forminputs, {field => 'dictionary' , value => $dictionary};
#	$search{'dicdetail'}= $dicdetail;
#}
#

@$forminputs=() unless $forminputs;

$template->param(FORMINPUTS => $forminputs);

# do the searchs ....
my $env;
$env->{itemcount}=1;
my $number_of_results;
(($number_of_results = $query->param('cantidad'))||($number_of_results=15));
(($number_of_results gt 300)&&($number_of_results=300));
my @results;
my $count;
my $startfrom = $query->param('startfrom');

($count, @results) = &catalogsearch($env,'opac',\%search,$number_of_results,$startfrom,$orden);


################### AGREGADO POR LUCIANO ##########################
if ($dictionary) {
                                                                                                                             
  $template->param(SEARCH_RESULTS => \@results);
  $template->param(numrecords => $count);
                                                                                                                             
} else {
###################################################################

my $num = 1;
foreach my $res (@results) {
    ((($num % 2) && ($res->{'clase'} = 'par' ))|| ($res->{'clase'}='impar'));
    $num++;
    my @aux=&getautor($res->{'author'});
    $res->{'id'}=$res->{'author'};
    $res->{'nomCompleto'}=$aux[0]->{'completo'};
    $res->{'nombre'}=$aux[0]->{'nombre'};
    $res->{'apellido'}=$aux[0]->{'apellido'};
}

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

# sorting out which results to display.
$template->param(startfrom => $startfrom+1);
($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$number_of_results)) : ($template->param(endat => $count));
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$number_of_results<$count) ? ($startfrom+$number_of_results) : (-1);
my $prevstartfrom=($startfrom-$number_of_results>=0) ? ($startfrom-$number_of_results) : (-1);
$template->param(nextstartfrom => $nextstartfrom);
my $displaynext=($nextstartfrom==-1) ? 0 : 1;
my $displayprev=($prevstartfrom==-1) ? 0 : 1;
$template->param(displaynext => $displaynext);
$template->param(displayprev => $displayprev);
$template->param(prevstartfrom => $prevstartfrom);

$template->param(SEARCH_RESULTS => $resultsarray);

#Matias: Orden del resultado
$template->param(orden => $orden);
#


$template->param(pagetitle => "Resultados de la b&uacute;squeda");

my $numbers;
@$numbers = ();
if ($count>$number_of_results) {
    for (my $i=0; $i<($count/$number_of_results); $i++) {
	my $highlight=0;
	my $break=0;
	($startfrom==($i*$number_of_results)) && ($highlight=1);
	if ((($i+1) % 29) eq 0){$break=1;}
	push @$numbers, { number => $i+1, highlight => $highlight , break => $break, startfrom => (($i)*$number_of_results) };
   }
}

$template->param(numbers => $numbers,
			     LibraryName => C4::Context->preference("LibraryName"),
);

} ############ Del if agragado por Luciano


output_html_with_http_headers $query, $cookie, $template->output;
