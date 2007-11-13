#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::BookShelves;

my $query=new CGI;


my  ($template, $borrowernumber, $cookie);

($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-privateshelfs.tmpl",
                             query => $query,
                             type => "opac",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1},
                         });
my $borrdata=&borrdata('',$borrowernumber);
my $mail = $borrdata->{'emailaddress'};
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
if ($op eq 'del'){ delPrivateShelfs($pshelf,$biblio);}  else{addPrivateShelfs($pshelf,$biblio);}
	}

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

($count, @results) = privateShelfs($borrowernumber ,$number_of_results,$startfrom);
my $num = 1;
foreach my $res (@results) { $num++;}

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
$template->param(borrower => $borrowernumber);
$template->param(SEARCH_RESULTS => $resultsarray);

$template->param(pagetitle => "Favoritos");

my $numbers;
@$numbers = ();
if ($count>$number_of_results) {
    for (my $i=0; $i<($count/$number_of_results); $i++) {
	my $highlight=0;
	my $break=0;
	my $themelang = $template->param('themelang');
	($startfrom==($i*$number_of_results)) && ($highlight=1);
	if ((($i+1) % 29) eq 0){$break=1;}
	push @$numbers, { number => $i+1, highlight => $highlight , break => $break, startfrom => (($i)*$number_of_results) };
   }
}

$template->param(numbers => $numbers,
			     LibraryName => C4::Context->preference("LibraryName"));

output_html_with_http_headers $query, $cookie, $template->output;
