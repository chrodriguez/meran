#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params, $cookie)= get_template_and_user({
                                    template_name => "opac-search.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => {borrow => 1},
             });

my $classlist='';
## FIXME usar combo de utilidades o crear funcion que devuelva el combo
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


my $virtuallibrary=C4::Context->preference("virtuallibrary");

$t_params->{'virtuallibrary'}= $virtuallibrary;
$t_params->{'comboItemTypes'}= $classlist;
$t_params->{'pagetitle'}= "Buscar bibliograf&iacute;a";
$t_params->{'LibraryName'}= C4::Context->preference("LibraryName");
$t_params->{'hiddesearch'}= 1;

C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);
