#!/usr/bin/perl

# $Id: modbibitem.pl,v 1.13 2003/03/26 04:25:48 wolfpac444 Exp $

#script to modify/delete groups

#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 18/4/00 by chris@katipo.co.nz

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

use strict;
require Exporter;

use C4::Search;
use C4::Output;
use C4::Koha;
use CGI;
use HTML::Template;
use C4::Date;
use C4::Biblio;
use C4::Catalogue;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::BookShelves;
use C4::AR::Utilidades;

my $input = new CGI;
my $bibitemnum=$input->param('bibitem');


my $responsable=$input->param('userloggedname');

my $data=bibitemdata($bibitemnum);
#$data->{'author'} = &getautor($data->{'author'});

my $biblio=$input->param('biblio');
my $submit=$input->param('submit.x');
my $from=$input->param('from');

if ($submit eq ''){
  print $input->redirect("deletebiblioitem.pl?biblioitemnumber=$bibitemnum&biblionumber=$biblio&responsable=$responsable&from=$from");
}

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => 'modbibitem.tmpl',
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {editcatalogue => 1},
    });




  #tuto para estantes virtuales
#todos los estantes
my %shelflabels;
my @shelftypes;
my $Cshelf;
#todos los subestantes
my %subshelflabels;
my @subshelftypes;
my $Csubshelf;
#los de este grupo
my $myshelfs;
my %myshelflabels;
my @myshelftypes;

   (%myshelflabels) = &getbookshelfItemsforList('public',$bibitemnum);
        foreach my $aux ( sort { $myshelflabels{$a} cmp $myshelflabels{$b} } keys(%myshelflabels)){
        push(@myshelftypes,$aux);}
        my $myshelfs=CGI::scrolling_list(-name      => 'newshelfbook',
                                        -id        => 'newshelfbook',
                                        -values    => \@myshelftypes,
                                        -labels    => \%myshelflabels,
                                        -size      => 10,
                                        -multiple  => 0,
                                 );




#Armo los select
 ( %shelflabels) = &getbookshelf;
  $shelflabels{''}= '          ';
my $inicializacion="";
my $valor="";
my $i= 0;
my @key=sort { noaccents($shelflabels{$a}) cmp noaccents($shelflabels{$b}) } keys(%shelflabels);
foreach my $estante (@key) {
        ( %subshelflabels) = &getbooksubshelf($estante);
        $inicializacion.= 'listaValues['.$i.'] = new Array();listaOptions['.$i.'] = new Array();';
        my $j= 0;

	my @subkey=sort { noaccents($subshelflabels{$a}) cmp noaccents($subshelflabels{$b}) } keys(%subshelflabels);
        foreach my $subestante  (@subkey) {
                 $valor.= 'listaValues['.$i.']['.$j.']=\''.$subestante.'\';listaOptions['.$i.']['.$j.']=\''.$subshelflabels{$subestante}.'\';';
                 $j+=1;
         }
         $i+=1;
 }

       foreach my $aux (@key){
       push(@shelftypes,$aux);}

       $Cshelf=CGI::scrolling_list(   -name      => 'shelfbook',
                               -id        => 'selectshelf',
                               -values    => \@shelftypes,
                               -labels    => \%shelflabels,
			       -class	=> 'inputFontNormal',
                               -size      => 10,
                               -multiple  => 0,
                               -defaults => 'es',
                                -onChange => 'cambiarListaDependiente(shelfbook,subshelfbook)'
                                );

   #fin de estantes virtuales






my %inputs;

		#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
#$inputs{'Author'}="text\t$data->{'author'}\t0";
#$inputs{'Title'}="text\t$data->{'title'}\t1";
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
  $dewey='';
}
$dewey=~ s/\.$//;
$inputs{'Class'}="text\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
$inputs{'URL'}="text\t$data->{'url'}\t4";
#$inputs{'Publisher'}="text\t$data->{'publishercode'}\t5";
#$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
#$inputs{'ISBN'}="text\t$data->{'isbn'}\t7";
$inputs{'Publication Year'}="text\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="text\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="text\t$data->{'illustration'}\t10";
$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
#$inputs{'Notes'}="textarea\t$data->{'notes'}\t15";
#$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="text\t$data->{'volumeddesc'}\t17";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";

$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";

$template->param( biblionumber => $data->{'biblionumber'},
		  title => $data->{'title'},
		  author => $data->{'author'},
		  description => $data->{'description'},
		  loggedinuser => $loggedinuser,
		);

my ($count,@bibitems)=bibitems2($data->{'biblionumber'});

my @bibitemloop;

for (my $i=0;$i<$count;$i++){
if ($bibitems[$i]->{'biblioitemnumber'} ne $data->{'biblioitemnumber'} ) 
	{
	my %line;
	$line{biblioitemnumber} = $bibitems[$i]->{'biblioitemnumber'};
	$line{description} = $bibitems[$i]->{'description'};
	#$line{isbn} = $bibitems[$i]->{'isbn'};
	push(@bibitemloop,\%line);
	}
		}
#Matias
#Tengo en cuenta el caso en que existe un unico grupo.
if ($count gt 1){$template->param(EXISTINGGROUP =>1);}
#
$template->param(bibitemloop =>\@bibitemloop);


#my $notesinput=$input->textfield(-name=>'Notes', -default=>$data->{'bnotes'}, -size=>20);
$template->param(bnotes=>$data->{'bnotes'});

$template->param(itemtype => $data->{'itemtype'});

$template->param(url => $data->{'url'});
$template->param(
								dewey => $dewey,
								publishercode => $data->{'publishercode'},
								place => $data->{'place'},
								isbncode => $data->{'isbncode'},
								publicationyear => $data->{'publicationyear'},
								pages => $data->{'pages'},
								illustration => $data->{'illus'},
								volumeddesc => $data->{'volumeddesc'},
								volume => $data->{'volume'},
								size => $data->{'size'},
								issn => $data->{'issn'},
								lccn => $data->{'lccn'},
                                                                number => $data->{'number'},
								serie => $data->{'seriestitle'},
								biblionumber => $data->{'biblionumber'},
								biblioitemnumber => $data->{'biblioitemnumber'});

my (@items)=itemissues($data->{'biblioitemnumber'});
#print @items;
my @itemloop;
my $count=@items;
for (my $i=0;$i<$count;$i++){
	my %line;
  	$items[$i]->{'datelastseen'} = format_date($items[$i]->{'datelastseen'});
	$line{barcode}=$items[$i]->{'barcode'};
	$line{itemnumber}=$items[$i]->{'itemnumber'};
	$line{biblionumber}=$data->{'biblionumber'};
	$line{biblioitemnumber}=$data->{'biblioitemnumber'};
	$line{holdingbranch}=$items[$i]->{'holdingbranch'};
	$line{datelastseen}=$items[$i]->{'datelastseen'};
	push(@itemloop,\%line);
}
$template->param(itemloop => \@itemloop);
############MAtias 
my @itemtypes;
my  $itemtypecount;
  ( $itemtypecount, @itemtypes ) = &getitemtypes;
my %item_labels;
my @item_values;

#LUCIANO arma un listado de editores
my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare("select * from publisher where biblioitemnumber = ".$data->{'biblioitemnumber'}." order by publisher");
$sth->execute;
my @publoop;
while (my $data = $sth->fetchrow_hashref) {
	my %line;
	$line{publisher}=$data->{'publisher'};
	push(@publoop,\%line);
}
$template->param(publoop => \@publoop);
#FIN: LUCIANO
$sth = $dbh->prepare("select * from isbns where biblioitemnumber = ".$data->{'biblioitemnumber'});
$sth->execute;
my @isbnloop;
while (my $data = $sth->fetchrow_hashref) {
	my %line;
	$line{isbn}=$data->{'isbn'};
	push(@isbnloop,\%line);
}
$template->param(isbnloop => \@isbnloop);

for ( my $i=0;$i<$itemtypecount;$i++)
	{ $item_labels{$itemtypes[$i]->{'itemtype'}}=$itemtypes[$i]->{'description'};
	  @item_values[$i]=$itemtypes[$i]->{'itemtype'}; }
                                                                                                                            
my $CGIitemtype=CGI::scrolling_list( -name     => 'item',
                        -values   => \@item_values,
                        -defaults => $data->{'itemtype'}, #agregado para setear la opcion por defecto
                        -labels   => \%item_labels,
                        -size     => 1,
                        -multiple => 0 );


$template->param( CGIitemtype =>$CGIitemtype);
###############Matias

#Agregado por Einar para armar los combos de additem-nomarc.tmpl
my %countrylabels;
my @countrytypes;
my %supportlabels;
my @supporttypes;
my %langlabels;
my @langtypes;

#Matias nivel bibliografico
my %levellabels;
my @leveltypes;

       (%countrylabels) = &getcountrytypes;
        foreach my $aux ( sort { $countrylabels{$a} cmp $countrylabels{$b} } keys(%countrylabels)){
        push(@countrytypes,$aux);}
        my $Ccountrys=CGI::scrolling_list(-name      => 'country',
                                        -id        => 'selectcountry',
                                        -values    => \@countrytypes,
					-defaults => $data->{'idCountry'}, #agregado para setear la opcion por defecto
                                        -labels    => \%countrylabels,
                                        -size      => 1,
                                        -multiple  => 0,
					);
        ( %supportlabels) = &getsupporttypes;
        foreach my $aux ( sort { $supportlabels{$a} cmp $supportlabels{$b} } keys(%supportlabels)){
        push(@supporttypes,$aux);}
        my $Csupports=CGI::scrolling_list(-name      => 'support',
                                        -id        => 'selectcountry',
                                        -values    => \@supporttypes,
                                        -defaults => $data->{'idSupport'}, #agregado para setear la opcion por defecto
					-labels    => \%supportlabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );
       ( %langlabels) = &getlanguages;
        foreach my $aux ( sort { $langlabels{$a} cmp $langlabels{$b} } keys(%langlabels)){
        push(@langtypes,$aux);}
        my $Clangs=CGI::scrolling_list(-name      => 'language',
                                        -id        => 'selectcountry',
                                        -values    => \@langtypes,
					 -defaults => $data->{'idLanguage'}, #agregado para setear la opcion por defecto
                                        -labels    => \%langlabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );
	
#fin EINAR
#Matias Nivel Bibliografico

  ( %levellabels) = &getlevels;
        foreach my $aux ( sort { $levellabels{$a} cmp $levellabels{$b} } keys(%levellabels)){
        push(@leveltypes,$aux);}
        my $Clevel=CGI::scrolling_list(-name      => 'level',
                                        -id        => 'selectlevel',
                                        -values    => \@leveltypes,
                                         -defaults => $data->{'idclass'}, #agregado para setear la opcion por defecto
                                        -labels    => \%levellabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );


#Fin nivel



      $template->param(
            SUPPORTTYPES => $Csupports,
            LANGTYPES => $Clangs,
	    LEVELTYPES => $Clevel,
            COUNTRYTYPES => $Ccountrys,
	    SHELFS => $myshelfs,
	    BOOKSHELF => $Cshelf,
            inicializaciones => $inicializacion, #agregado del guardoImpo..
            valores          => $valor    #idem anterior
		);
print "Content-Type: text/html\n\n", $template->output;

