#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $query=new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-detail.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my $biblionumber=$query->param('bib');
$template->param(biblionumber => $biblionumber);
my $viewdetail = C4::Context->preference("viewDetail");

# change back when ive fixed request.pl
my @items                                 = &ItemInfo(undef, $biblionumber, 'opac');
my $dat                                   = &bibdata($biblionumber);
my ($subjectcount, $subject)     = &subject($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
#esta consulta no seria necesaria, ya que este resultado no se muestra en el tmpl
my ($websitecount, @websites)             = &getwebsites($biblionumber);

$dat->{'count'}=@items;

my @subjects;
#my $len= scalar(split(",",$dat->{'subject'}));
my $i= 1;
my $coma;
my $tema;
my $idTema;
my $nomTema;
foreach my $elem (@$subject) {
 if ($subjectcount==$i){$coma=""} else {$coma=","};
 my $tema;
 $tema->{'subject'}=$elem->{'id'};
 $tema->{'nomTema'}=$elem->{'nombre'};
 $tema->{'separator'}=$coma;
 for ($tema->{'nomTema'}) {s/^\s+//;} # delete the spaces at the begining of the string
	 push (@subjects,$tema);
 $i+=1;
}

$dat->{'SUBJECTS'} = \@subjects;

my @autorPPAL= &getautor($dat->{'author'});
my @autoresAdicionales=&getautoresAdicionales($biblionumber);
my @colaboradores=&getColaboradores($biblionumber);

$dat->{'author'} = \@autorPPAL;
$dat->{'ADDITIONAL'}= \@autoresAdicionales;
$dat->{'COLABS'}=\@colaboradores;

my @results = ($dat,);

my $resultsarray=\@results;
my $itemsarray=\@items;
my $webarray=\@webbiblioitems;
my $sitearray=\@websites;
my $subjectsarray=\@subjects;
#Matias
my @all=allbibitems($biblionumber,"opac");

#my $allarray=\@all;
my $i=0;
foreach my $tmp1 (@all){
             $all[$i]->{'SUBJECTS'}=  $dat->{'SUBJECTS'};
             #$all[$i]->{'subject'}=  $dat->{'subject'};
	     $all[$i]->{'author'}= \@autorPPAL;
	     $all[$i]->{'ADDITIONAL'}=\@autoresAdicionales;
	     $all[$i]->{'COLABS'}=\@colaboradores;
     $i++;
	        } 
my $allarray=\@all;
$template->param(BIBLIOITEMS=>$allarray);
foreach my $tmp (@results){
$template->param(unititle=>$tmp->{'unititle'});
$template->param(titulo=>$tmp->{'title'});

$template->param(cdu=>$tmp->{'cdu'});
$template->param(notas=>$tmp->{'notes'});
$template->param(abstracto=>$tmp->{'abstract'});
$template->param(clasificacion=>$tmp->{'classification'});
$template->param(url1=>$tmp->{'url'});
$template->param(lccn=>$tmp->{'lccn'});

}

if ($viewdetail eq 0) { #si es 0 es para ocultar el campo que en el tmp pregunta si existe el parametro ViewDetail
$template->param(ViewDetail=> 'SE VE EL CAMPO');
}
$template->param(BIBLIOITEMS=>$allarray);
#

$template->param(BIBLIO_RESULTS => $resultsarray);
#ITEM_RESULTS no esta en el tmpl, parece q esta de mas
$template->param(ITEM_RESULTS => $itemsarray);
$template->param(WEB_RESULTS => $webarray);
$template->param(SUBJECTS => $subjectsarray);
#SITE_RESULTS no esta en el tmpl, parece q esta de mas
$template->param(SITE_RESULTS => $sitearray,
		CirculationEnabled => C4::Context->preference("circulation"),
		LibraryName => C4::Context->preference("LibraryName"),
		pagetitle => "Detalle del registro"
);

output_html_with_http_headers $query, $cookie, $template->output;
