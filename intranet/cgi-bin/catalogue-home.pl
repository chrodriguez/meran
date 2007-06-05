#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use C4::Catalogue;
use C4::Biblio;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "catalogue/catalogue-home.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });



#Matias: Esta habilitada la Biblioteca Virtual?
my $virtuallibrary=C4::Context->preference("virtuallibrary");
$template->param(virtuallibrary => $virtuallibrary);
#


my ($branchcount,@branches)=branches();
my ($itemtypecount,@itemtypes)=getitemtypes();

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
 

$template->param(classlist => $classlist,
						type => 'intranet',
		 branches=>\@branches,
		 itemtypes=>\@itemtypes);

output_html_with_http_headers $query, $cookie, $template->output;
