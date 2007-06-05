#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

# $Id: moredetail.pl,v 1.23 2003/09/11 22:03:43 rangi Exp $

# Copyright 2000-2003 Katipo Communications
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

use HTML::Template;
use strict;
require Exporter;
use C4::Koha;
use CGI;
use C4::Search;
use C4::Catalogue;
use C4::Output; # contains gettemplate
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;

my $query=new CGI;

# FIXME  subject is not exported to the template?
my $subject=$query->param('subject');

# if its a subject we need to use the subject.tmpl
my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ($subject? 'catalogue/subject.tmpl':
				      'catalogue/moredetail.tmpl'),
	query           => $query,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {catalogue => 1},
    });



#Matias: Mensajes
my $msg=$query->param('msg');
if ($msg ne ""){
my $msgtext="";
  if ($msg eq "noitemdelete"){$msgtext="No es posible eliminar el item debido a que se encuentra prestado.";}
	elsif ($msg eq "noitemsdelete"){$msgtext="No fue posible eliminar alg&uacute;n item.";} 
   		elsif ($msg eq "nobiblioitemdelete"){$msgtext="No es posible eliminar el grupo debido a que contiene items que se encuentran prestados.";}

   $template->param(MSG => $msgtext);

        }
#fin Matias



# get variables

my $biblionumber=$query->param('bib');
my $title=$query->param('title');
my $bi=$query->param('bi');

my $data=bibitemdata($bi);
my $dewey = $data->{'dewey'};
# FIXME Dewey is a string, not a number, & we should use a function
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
      $dewey='';
}
$dewey=~ s/\.$//;
$data->{'dewey'}=$dewey;

my @results;

my (@items)=itemissues($bi);
my $count=@items;
$data->{'count'}=$count;
my ($order,$ordernum)=getorder($bi,$biblionumber);

my $env;
$env->{itemcount}=1;

$results[0]=$data;

foreach my $item (@items){
#MATIAS	linea 105 saque una porqueria que se habia colado
  my $notforloan=0;
  my $wthdrawn=0;	
   
  if ($item->{'wthdrawn'} eq 0) {$item->{'wthdrawn'}="<font align='center' size='2' color='green'>DISPONIBLE</font><br>";}
     else {$wthdrawn=1;
	$item->{'wthdrawn'}="<font align='center' size='2' color='red'>NO DISPONIBLE</font><br>(<font align='center359  	G' size='1' color='red'>".
    $item->{'wthdrawn'}->{'description'}."</font>)";}

  if ($item->{'notforloan'} eq 1 ) {$notforloan=1;
				$item->{'notforloan'}="<font align='center' size='2'  color='blue'>SALA DE LECTURA</font>";}
				else { $item->{'notforloan'}="<font align='center' size='2'  color='green'>PRESTAMO</font>"; }

    $item->{'replacementprice'}+=0.00;
    my $year=substr($item->{'timestamp0'},0,4);
    my $mon=substr($item->{'timestamp0'},4,2);
    my $day=substr($item->{'timestamp0'},6,2);
    $item->{'timestamp0'}="$day/$mon/$year";
    $item->{'dateaccessioned'} = format_date($item->{'dateaccessioned'});
    $item->{'datelastseen'} = format_date($item->{'datelastseen'});
    $item->{'ordernumber'} = $ordernum;
    $item->{'booksellerinvoicenumber'} = $order->{'booksellerinvoicenumber'};

    # FIXME untranslatable strings

#MATIAS
	 if (($wthdrawn eq 0)and($item->{'date_due'} ne 'Available')){
	 $item->{'issue'}="<font color='red'><b>Actualmente en prestamo a:</b> <a href=/cgi-bin/koha/moremember.pl?bornum=$item->{'borrower'}>$item->{'card'}</a></font><br>";
			}
		 	
}

$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => \@items);
$template->param(loggedinuser => $loggedinuser);
#LUCIANO arma un listado de editores
my $dbh = C4::Context->dbh;
my $publishers= publisherList($bi,$dbh);
$template->param(publisher => $publishers);
#FIN: LUCIANO



output_html_with_http_headers $query, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
