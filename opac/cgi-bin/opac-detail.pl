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


# change back when ive fixed request.pl
my @items                                 = &ItemInfo(undef, $biblionumber, 'opac');
my $dat                                   = &bibdata($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
my ($websitecount, @websites)             = &getwebsites($biblionumber);

$dat->{'count'}=@items;

my @subjects;
my $len= scalar(split(",",$dat->{'subject'}));
my $i= 1;
my $coma;
foreach my $elem (split(",",$dat->{'subject'})) {
        if ($len==$i){$coma=""} else {$coma=","};
        for ($elem) {s/^\s+//;} # delete the spaces at the begining of the string
        push(@subjects, {subject => $elem, separator => $coma});
        $i+=1;
}
$dat->{'SUBJECTS'} = \@subjects;

my @autorPPAL= &getautor($dat->{'author'});
my @autoresAdicionales=&getautoresAdicionales($biblionumber);
my @colaboradores=&getColaboradores($biblionumber);

$dat->{'author'} = \@autorPPAL;
$dat->{'ADDITIONAL'}= \@autoresAdicionales;
$dat->{'COLABS'}=\@colaboradores;

my $norequests = 1;
my $row = 1;
foreach my $itm (@items) {
    $norequests = 0 unless $itm->{'notforloan'};
    $itm->{$itm->{'publictype'}} = 1;
    if (($row % 2) == 0) {
	$itm->{'even'} = 1;
    }
    $row++;
}

my @subjects;
my $subject;
my @subj = split /, /,($dat->{'subject'});  #split returned string into array

foreach my $subjct (@subj) {
    $subject= {
	SUBJECTS => $subjct,
    };
    push @subjects, $subject;
}


$template->param(norequests => $norequests);

my @results = ($dat,);

my $resultsarray=\@results;
my $itemsarray=\@items;
my $webarray=\@webbiblioitems;
my $sitearray=\@websites;
my $subjectsarray=\@subjects;
#Matias
my @all=allbibitems($biblionumber,"opac");

my $allarray=\@all;
$template->param(BIBLIOITEMS=>$allarray);
#

$template->param(BIBLIO_RESULTS => $resultsarray);
$template->param(ITEM_RESULTS => $itemsarray);
$template->param(WEB_RESULTS => $webarray);
$template->param(SUBJECTS => $subjectsarray);
$template->param(SITE_RESULTS => $sitearray,
			     CirculationEnabled => C4::Context->preference("circulation"),
			     LibraryName => C4::Context->preference("LibraryName"),
			     pagetitle => "Detalle del registro"
);

output_html_with_http_headers $query, $cookie, $template->output;
