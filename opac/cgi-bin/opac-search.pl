#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
# use C4::Database;
use HTML::Template;

my $classlist='';

my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select search,itemtype from itemtypes order by search");
$sth->execute;
my ($search2,$itemtypelist) = $sth->fetchrow;

while (my ($search,$itemtype) = $sth->fetchrow) {

        if ($search eq $search2){
	                $itemtypelist.="|".$itemtype;
			        }else{
				$classlist.="<option value=\"$itemtypelist\">$search2</option>\n";
				$search2=$search;
				$itemtypelist=$itemtype;
				}
			}
			#Falta el ultimo;
$classlist.="<option value=\"$itemtypelist\">$search2</option>\n";
#
 
#my $listShelf='';

#my $dbh=C4::Context->dbh;
#my $sth=$dbh->prepare("select shelfname,shelfnumber from bookshelf order by shelfname");
#$sth->execute;
#while (my ($shelfname,$shelfnumber) = $sth->fetchrow) {
 #   $listShelf.="<option value=\"$shelfnumber\">$shelfname</option>\n";
#}


my $query = new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-search.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });
#Matias: Esta habilitada la Biblioteca Virtual?
my $virtuallibrary=C4::Context->preference("virtuallibrary");
$template->param(virtuallibrary => $virtuallibrary);
#

$template->param(comboItemTypes => $classlist,
			     pagetitle => "Buscar bibliograf&iacute;a", 
			     LibraryName => C4::Context->preference("LibraryName"),
);

#$template->param(listshelf => $listShelf,
#);





$template->param(hiddesearch => 1);

output_html_with_http_headers $query, $cookie, $template->output;
