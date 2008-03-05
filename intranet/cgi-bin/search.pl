#!/usr/bin/perl

# $Id: search.pl,v 1.32.2.3 2004/02/26 10:23:03 tipaul Exp $
# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# $Log: search.pl,v $
# Revision 2.0.0.0  2004/02/26 10:23:03  Einar
# modificando las busquedas por autor y autores adicionales y colaboradores para permitir control de autoridades
#
# Revision 1.32.2.3  2004/02/26 10:23:03  tipaul
# porting inventory feature to rel_2_0, from HEAD
#
# Revision 1.32.2.2  2004/01/13 17:33:39  tipaul
# removing useless (& buggy here) checkauth
#
# Revision 1.32.2.1  2003/12/19 17:28:42  tipaul
# fix for 683
#
# Revision 1.32  2003/06/11 18:37:55  tonnesen
# Using boolean_preference instead of preference for 'marc' setting
#
# Revision 1.31  2003/05/11 07:31:37  rangi
# Removing duplicate use C4::Auth
#

use strict;
require Exporter;
use CGI;
use C4::Auth;
use HTML::Template;
use HTML::Template::Expr;
use C4::Context;
use C4::Search;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Estadisticas;

my $query=new CGI;
my $type=$query->param('type');

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $orden;
if ($query->param('orden')){$orden=$query->param('orden');} else {$orden='title';}


my $subject=$query->param('subjectitems');

#Matias: Es una busqueda por analiticas?
my $analytical=$query->param('analytical');
#

#Matias: Es una busqueda por signatura topografica?
my $signature=$query->param('signature');
#

#Matias: Es una busqueda por ISBN?
my $isbn=$query->param('isbn');
#
if ($isbn) {#es una busqueda por isbn
  print $query->redirect("/cgi-bin/koha/isbn.pl?isbn=$isbn");
        }



#Matias: Es una busqueda en la Biblioteca Virtual?
my $virtual=$query->param('virtual');
#
#Tuto: Es una busqueda por Estante Virtual?
my $shelves=$query->param('shelves');
#

if ($shelves) {#es una busqueda por estantes virtuales
  print $query->redirect("/cgi-bin/koha/shelves.pl?viewShelfName=$shelves&startfrom=0");
	}


#Luciano: Es una busqueda por diccionario
my $dictionary=$query->param('dictionary');
my $dicdetail=$query->param('dicdetail');
($dicdetail) || ($dicdetail=0);
#

# if it's a subject we need to use the subject.tmpl
my ($template, $loggedinuser, $cookie);
if ($subject) {
 	($template, $loggedinuser, $cookie)
   		= get_templateexpr_and_user({template_name => "catalogue/subject.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });
} elsif ($virtual) {
	#hay que revisarlo EINAR
  ($template, $loggedinuser, $cookie)
                = get_templateexpr_and_user({template_name => "virtual/virtualsearchresults.tmpl",
                             query => $query,
                             type => "intranet",
                             authnotrequired => 0,
                             flagsrequired => {catalogue => 1},
                             debug => 1,
                             });

} elsif ($dictionary) {
	
  ($template, $loggedinuser, $cookie)
                = get_templateexpr_and_user({template_name => "dictionary-search.tmpl",
                             query => $query,
                             type => "intranet",
                             authnotrequired => 0,
                             flagsrequired => {catalogue => 1},
                             debug => 1,
                             });


} elsif ($signature) {
	
  ($template, $loggedinuser, $cookie)
                = get_templateexpr_and_user({template_name => "signature-search.tmpl",
                             query => $query,
                             type => "intranet",
                             authnotrequired => 0,
                             flagsrequired => {catalogue => 1},
                             debug => 1,
                             });



}elsif ($analytical) {
 	($template, $loggedinuser, $cookie)
		= get_templateexpr_and_user({template_name => "catalogue/analytical-search.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

}else {
 	($template, $loggedinuser, $cookie)
		= get_templateexpr_and_user({template_name => "catalogue/searchresults.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });
}

# %env
# Additional parameters for &catalogsearch
my %env = (
	itemcount	=> 1,	# If set to 1, &catalogsearch enumerates
				# the results found and returns the number
				# of items found, where they're located,
				# etc.
	);

# get all the search variables
# we assume that C4::Search will validate these values for us
my %search;			# Search terms. If the key is "author",
				# then $search{author} is the author the
				# user is looking for.

my @forminputs;			# This is used in the form template.
my $value = $query->param('authorid');
if ($value) {
my @val=&getautor($value);
$search{'authorid'} = $value;
$template->param(AUTORID => \@val);
push @forminputs, {	field => 'authorid',
			value =>$value };

} else{
my $value = $query->param('subjectid');
if ($value) {
my @val=&getTema($value);
$search{'subjectid'} = $val[0]{'id'};
$template->param(SUBJECTID => \@val);
push @forminputs, {	field => 'subjectid',
			value =>$val[0]{'id'},
			descripcion=>$val[0]{'nombre'} };

}}
	
foreach my $term (qw(keyword subject author illustrator itemnumber
		     date-before class dewey branch title abstract
		     publisher ttype dictionary dicdetail subjectitems virtual analytical signature))  #Los X (ya no se cuantos son) ultimos los agregue yo(Matias)
{
	my $value = $query->param($term);
	next unless defined $value && $value ne "";
				# Skip blank search terms
	$search{$term} = $value;
	push @forminputs, {	field => $term,
				value =>$value };
}

$template->param(FORMINPUTS => \@forminputs);

# whats this for?
# I think it is (or was) a search from the "front" page...   [st]
$search{'front'}=$query->param('front');

#cantidad de resultados que se van a mostrar
my $num=cantidadRenglones();
my @results;
my $count;

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();

if (($query->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
} else {
	$ini= ($query->param('ini')-1)* $cantR;
	$pageNumber= $query->param('ini');
};
#FIN inicializacion
$num= $num + $ini;

my ($count,@results)=catalogsearch($loggedinuser,\%env,'intra',\%search,$num,$ini,$orden);

my @numeros= &armarPaginas($count, $pageNumber);
my $paginas = scalar(@numeros)||1;

my $pagActual = $query->param('ini')||1;

if ( $count > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pagActual+1;
        if ($sig <= $paginas){
                 $template->param(
                                displaynext    =>'1',
                                sig   => $sig);
        };
        if ($sig > 2 ){
                my $ant = $pagActual-1;
                $template->param(
                                displayprev     => '1',
                                ant     => $ant)}
}

$template->param( 	paginas   => $paginas,
			actual    => $pagActual,
			cantidad  => $count,
			numbers   => \@numeros
		);



#*****************************************Fin Paginador*************************************************


# $num= $num + $ini;
# ($count,@results)=catalogsearch($loggedinuser,\%env,'intra',\%search,$num,$ini,$orden);

################### AGREGADO POR LUCIANO ##########################
if (($dictionary)||($signature)) {

  $template->param(SEARCH_RESULTS => \@results);
  #$template->param(searchdesc => 'diccionario');
  $template->param(numrecords => $count);
 
} else {
###################################################################

my $n= 1;
my $resultsarray;

foreach my $result (@results) {
    # set up the even odd elements....
    ((($n % 2) && ($result->{'clase'} = 'par' ))|| ($result->{'clase'}='impar'));
    $n++;
if (! $search{'subjectitems'}){    
if ($result->{'analyticalnumber'} ne ''){
    my $autorppal=  C4::Search::getautor($result->{'autorppal'});
    $result->{'apellidoppal'}= $autorppal->{'apellido'};
    $result->{'nombreppal'}= $autorppal->{'nombre'};
    $result->{'completo'}=$autorppal->{'completo'};
 
    my @autores=C4::AR::AnalysisBiblio::getanalyticalautors($result->{'analyticalnumber'});
    $result->{'analyticalauthor'}=\@autores;
} else {
    my @aux=&getautor($result->{'author'});
    $result->{'id'}=$result->{'author'};
    $result->{'nombre'}=$aux[0]->{'nombre'};
    $result->{'apellido'}=$aux[0]->{'apellido'};
    $result->{'nomCompleto'}=$aux[0]->{'completo'};		
    }
   
   
    ($result->{'copyrightdate'}==0) && ($result->{'copyrightdate'}='');
}
    ($type eq 'opac') ? ($result->{'opac'}=1) : ($result->{'opac'}=0);

    push (@$resultsarray, $result);

}

($resultsarray) || (@$resultsarray=());
$num=10;


$template->param(startfrom => $startfrom+1);
($startfrom+$num<=$count) ? ($template->param(endat =>( $startfrom+$num))) : ($template->param(endat => $count));
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$num<$count) ? ($startfrom+$num) : (-1);
my $prevstartfrom=($startfrom-$num>=0) ? ($startfrom-$num): (-1);
$template->param(nextstartfrom => $nextstartfrom);
my $displaynext=1;
my $displayprev=0;
($nextstartfrom==-1) ? ($displaynext=0) : ($displaynext=1);
($prevstartfrom==-1) ? ($displayprev=0) : ($displayprev=1);
$template->param(displaynext => $displaynext);
$template->param(displayprev => $displayprev);
($type eq 'opac') ? ($template->param(opac => 1)) : ($template->param(opac => 0));
$template->param(prevstartfrom => $prevstartfrom);
#$template->param(search => $search);
#$template->param(searchdesc => $searchdesc);
$template->param(SEARCH_RESULTS => $resultsarray);
#$template->param(includesdir => $includes);

#Matias: Orden del resultado
$template->param(orden => $orden);
#

my @numbers = ();
if ($count>$num) {
    for (my $i=0; $i<(($count/$num)); $i++) {
	    if ($search{"title"})
	    {
		push @forminputs, { line => "title=$search{title}"};
	    }
	    my $highlight=0;
	    ($startfrom==(($i)*($num))) && ($highlight=1);
	 my $formelements='';
	    foreach (@forminputs) {
		my $line=$_->{line};
		$formelements.="$line&";
	    }
	    $formelements=~s/ /+/g;

	 my $break=0;
        if ((($i+1) % 45) eq 0){$break=1;}

	    push @numbers, { number => $i+1, highlight => $highlight , FORMELEMENTS => $formelements, FORMINPUTS => \@forminputs, startfrom => (($i)*($num)), opac => (($type eq 'opac') ? (1) : (0)), break => $break };
	
    }
}

$template->param(numbers => \@numbers);
if (C4::Context->boolean_preference('marc') eq '1') {
	$template->param(script => "MARCdetail.pl");
} else {
	$template->param(script => "detail.pl");
}

} ############ Del if agragado por Luciano

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

