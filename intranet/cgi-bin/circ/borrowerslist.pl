#!/usr/bin/perl
# Please use 8-character tabs for this file (indents are every 4 characters)

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
use C4::Print;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;
use CGI::Util; 	# Para la función encode() (Nahuel)

my $query=new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0,{borrow => 1});

my %env;
my $missborrower;

my $bor = $query->param('borrnumber');
my $biblio = $query->param('bib');
my $bibit = $query->param('bibitem');
my $itemnumber = $query->param('itemnum');
my $barcode = $query->param('barcode');
my $issuetype = $query->param('issuetype');

my $MSG;
my $borrowerslist;
  
      my ($count,$borrowers)=BornameSearch(\%env,$bor,'web');
        my @borrowers=@$borrowers;
        if ($#borrowers == -1) {
		print $query->redirect("/cgi-bin/koha/detail.pl?bib=$biblio&type=intra&nouser=$bor");
        } elsif ($#borrowers == 0) {
		my $bornum= $borrowers[0]->{'borrowernumber'};
		print $query->redirect("/cgi-bin/koha/circ/item-borrow.pl?bib=$biblio&bibitem=$bibit&itemnum=$itemnumber&barcode=$barcode&borrnumber=$bornum&issuetype=$issuetype");
        } 

#Si llega aca es que hay una lista de borrowers

                $borrowerslist = \@borrowers;
        
		my @values;
		my %labels;
		my $CGIselectborrower;
       
		foreach (sort {$a->{'surname'}.$a->{'firstname'} cmp $b->{'surname'}.$b->{'firstname'}} @$borrowerslist){
                	push @values,$_->{'borrowernumber'};
                	$labels{$_->{'borrowernumber'}} ="$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})";
        			}
        	$CGIselectborrower=CGI::scrolling_list( -name     => 'borrnumber',
                                -values   => \@values,
                                -labels   => \%labels,
                                -size     => 7,
                                -multiple => 0 );


		my ($template, $loggedinuser, $cookie) = get_template_and_user
    		({
        	template_name   => 'circ/borrowerslist.tmpl',
        	query           => $query,
        	type            => "intranet",
        	authnotrequired => 0,
        	flagsrequired   => { circulate => 1 },
    		});


		$template->param(
                	CGIselectborrower => $CGIselectborrower,
			biblionumber => 	$biblio,
			biblioitemnumber => 	$bibit,
			itemnumber =>	$itemnumber, 
			barcode =>	$barcode
               		 );


output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
