#!/usr/bin/perl

# $Id: additem-nomarc.pl,v 1.2 2003/05/11 06:59:11 rangi Exp $

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

# $Log: additem-nomarc.pl,v $
# Revision 1.2  2003/05/11 06:59:11  rangi
# Mostly templated.
# Still needs some work
#

use CGI;
use strict;
use C4::Catalogue;
use C4::Biblio;
use C4::BookShelves;
use C4::Search; #Matias
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input        = new CGI;
my $biblionumber = $input->param('biblionumber');
my $bulk 	 = $input->param('bulk');
my $error        = $input->param('error');
my $maxbarcode;
my $isbn;
my $bibliocount;
my @biblios;
my $biblioitemcount;
my @biblioitems;
my $branchcount;
my @branches;
my %branchnames;
my $itemtypecount;
my @itemtypes;
my %itemtypedescriptions;
my @itemtypeselect;
my $CItems;
my %countrylabels;
my @countrytypes; 

my %supportlabels;
my @supporttypes;

my %shelflabels;
my @shelftypes;
my $Cshelf;

my %subshelflabels;
my @subshelftypes;
my $Csubshelf;


my %levellabels;
my @leveltypes;
my $Clevel;

my %langlabels;
my @langtypes;

  my $allsubtitles;
  my $additionals;
  my $allsubjects; 


if ( !$biblionumber ) {
    print $input->redirect('addbooks.pl');
}
else {

    ( $bibliocount, @biblios ) = &getbiblio($biblionumber);

    if ( !$bibliocount ) {
        print $input->redirect('addbooks.pl');
    }
    else {

        my $newinput = new CGI;
        my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name   => "acqui.simple/additem-nomarc.tmpl",
                query           => $newinput,
                type            => "intranet",
                authnotrequired => 0,
                flagsrequired   => { editcatalogue=>1 },
                debug           => 1,
            }
        );
       	( $biblioitemcount, @biblioitems ) = &getbiblioitembybiblionumber($biblionumber);
       	( $itemtypecount, @itemtypes ) = &getitemtypes;

#PARA LOS BRANCH
	my  $branch=$input->param('branch');
	($branch ||($branch=(split("_",(split(";",$cookie))[0]))[1]));
	my @select_branch;
	my %select_branches;
	my $branches;
	if((C4::Context->preference('selectHomeBranch'))){
		$branches=&C4::Koha::getbranches();
		foreach my $branch (keys %$branches) {
        		push @select_branch, $branch;
        		$select_branches{$branch} = $branches->{$branch}->{'branchname'};
		}
	}
	else{ #para crear el select solo con la biblioteca por defecto.
		push @select_branch, $branch;
		$select_branches{$branch} = &getbranchname($branch);
	}
	my $CGIbranch=CGI::scrolling_list(      -name      => 'homebranch',
                                        	-id        => 'homebranch',
                                        	-values    => \@select_branch,
						-defaults  => $branch,
                                        	-labels    => \%select_branches,
                                        	-size      => 1,
                                 	);
#FIN BRANCH

	#Matias para mostrar autores adicionales ("colaboradores"), materias , otro titulo
	my @autorPPAL= &getautor($biblios[0]->{'author'});
        my @autoresAdicionales=&getautoresAdicionales($biblionumber);
	my @colaboradores=&getColaboradores($biblionumber);
	

	my ($subtitlecount,$subtitles) =&subtitle($biblionumber);
	if ($subtitlecount) {
        $allsubtitles=" " . $subtitles->[0]->{'subtitle'};
        for (my $i = 1; $i < $subtitlecount; $i++) {
                $allsubtitles.= ", " . $subtitles->[$i]->{'subtitle'};
        } # for
	} # if

 	my ($subjectcount,$subjects) =&subject($biblionumber);
      if ($subjectcount) {
        $allsubjects=" " . $subjects->[0]->{'nombre'};
        for (my $i = 1; $i < $subjectcount; $i++) {
                $allsubjects.= ", " . $subjects->[$i]->{'nombre'};
        } # for
        } # if

	#MAtias

       #Agregado por Einar para armar los combos de additem-nomarc.tmpl
       (%countrylabels) = &getcountrytypes;
	foreach my $aux ( sort { $countrylabels{$a} cmp $countrylabels{$b} } keys(%countrylabels)){
	push(@countrytypes,$aux);}
	my $Ccountrys=CGI::scrolling_list(-name      => 'country',
                                        -id        => 'selectcountry',
                                        -values    => \@countrytypes,
                                        -labels    => \%countrylabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                        -defaults => 'AR'
                                 );

       #tuto para estantes virtuales
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
       push(@shelftypes,$aux);} # estaba $shelflabels{$aux} pero se necesita el codigo

       $Cshelf=CGI::scrolling_list(   -name      => 'shelfbook',
                               -id        => 'selectshelf',
                               -values    => \@shelftypes,
                               -labels    => \%shelflabels,
                               -size      => 10,
                               -multiple  => 0,
                               -defaults => 'es',
			  	-onChange => 'cambiarListaDependiente(shelfbook,subshelfbook)'
                                );

       #fin de estantes virtuales

	( %supportlabels) = &getsupporttypes;
	foreach my $aux ( sort { $supportlabels{$a} cmp $supportlabels{$b} } keys(%supportlabels)){
	push(@supporttypes,$aux);}

	my $defsup=C4::Context->preference("defaultsuport");
	my $Csupports=CGI::scrolling_list(-name      => 'support',
                                        -id        => 'selectsuport',
                                        -values    => \@supporttypes,
                                        -labels    => \%supportlabels,
                                        -size      => 1,
                                        -multiple  => 0,
					-defaults  => $defsup
                                 );
       ( %langlabels) = &getlanguages;
	foreach my $aux ( sort { $langlabels{$a} cmp $langlabels{$b} } keys(%langlabels)){
	push(@langtypes,$aux);}
	my $Clangs=CGI::scrolling_list(-name      => 'language',
                                        -id        => 'selectlang',
                                        -values    => \@langtypes,
                                        -labels    => \%langlabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                        -defaults => 'es'
                                 );

	#Matias: Nivel Bibliografico
	       ( %levellabels) = &getlevels;
        foreach my $aux ( sort { $levellabels{$a} cmp $levellabels{$b} } keys(%levellabels)){
        push(@leveltypes,$aux);}
	 my $deflev=C4::Context->preference("defaultlevel");
        my $Clevel=CGI::scrolling_list(-name      => 'level',
                                        -id        => 'selectlevel',
                                        -values    => \@leveltypes,
                                        -labels    => \%levellabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                        -defaults => $deflev
                                 );
	
	
	## Matias Fin



## Scroll de disponibilidades
my %availlabels;
my @availtypes;


 ( %availlabels) = &getavails;
        foreach my $aux ( sort { $availlabels{$a} cmp $availlabels{$b} } keys(%availlabels)){
        push(@availtypes,$aux);}
        my $Cavails=CGI::scrolling_list(-name      => 'unavailable',
                                        -id        => 'unavailable',
                                        -values    => \@availtypes,
                                        -defaults => 0,
                                        -labels    => \%availlabels,
                                        -size      => 1,
                                        -multiple  => 0,
                                 );



##

        for ( my $i = 0 ; $i < $itemtypecount ; $i++ ) {
            $itemtypedescriptions{ $itemtypes[$i]->{'itemtype'} } =
              $itemtypes[$i]->{'description'};
        }    # for

my $itemdef=C4::Context->preference("defaultitemtype");
  foreach my $aux ( sort { $itemtypedescriptions{$a} cmp $itemtypedescriptions{$b} } keys(%itemtypedescriptions)){
        push(@itemtypeselect,$aux);}
         $CItems=CGI::scrolling_list(-name      => 'itemtype',
                                        -id        => 'selectitem',
                                        -values    => \@itemtypeselect,
                                        -labels    => \%itemtypedescriptions,
                                        -size      => 1,
                                        -multiple  => 0,
                                        -defaults => $itemdef 
                                 );





        #	print $input->header;
        #	print startpage();
        #	print startmenu('acquisitions');



#Matias para que los datos no se tengan que volver a llenar
if ($input->param('newvol')) 
	{
my $bibit=&bibitemdata($input->param('biblioitemnumber'));


#agregado para que quede el itemtype seleccionado
my $it;
$it=$bibit->{'itemtype'};

($it) || ($it=C4::Context->preference("defaultitemtype"));

for ( my $i = 0 ; $i < $itemtypecount ; $i++ ) 
	{
  $itemtypes[$i]->{'selected'}  = ($itemtypes[$i]->{'itemtype'} eq $it) ;
	}

#LUCIANO arma un listado de editores roba tuto
my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare("select * from publisher where biblioitemnumber = ".$bibit->{'biblioitemnumber'}." order by publisher");
$sth->execute;
my @publoop;
while (my $data = $sth->fetchrow_hashref) 
	{
        my %line;
        $line{publisher}=$data->{'publisher'};
	push(@publoop,\%line);
	}
$template->param(publoop => \@publoop);
#FIN: LUCIANO robado por tuto


#armar el listado de isbns correspondiente al bilioitemnumber
$sth = $dbh->prepare("select * from isbns where biblioitemnumber = ".$bibit->{'biblioitemnumber'});
$sth->execute;
my @isbnloop;
                                                                                                                             
while (my $data = $sth->fetchrow_hashref) 
	{
        my %line;
        $line{isbn}=$data->{'isbn'};
	push(@isbnloop,\%line);
	}
$template->param(isbnloop => \@isbnloop);
#FIN: armado de isbn 

                  


$bibit->{'bulk'} = $bulk;

##Hasta aca

$template->param(
   biblionumber      => $bibit->{'biblionumber'},
   bulk      	     => $bibit->{'bulk'},
   #isbn              => $bibit->{'isbn'},
   #isbn2	     => $bibit->{'isbn2'},	
   publicationyear   => $bibit->{'publicationyear'},
   place             => $bibit->{'place'},
   illus             => $bibit->{'illus'},
   additionalauthors => $input->param('additionalauthors'),
   subjectheadings   => $input->param('subjectheadings'),
#   publishercode     => $input->param('publishercode'),  
   url               => $bibit->{'url'},
   dewey             => $bibit->{'dewey'},
   issn              => $bibit->{'issn'},
   lccn              => $bibit->{'lccn'},
   volume            => $bibit->{'volume'},
   number            => $bibit->{'number'},
   volumeddesc       => $bibit->{'volumeddesc'},
   pages             => $bibit->{'pages'},
   size              => $bibit->{'size'},
   serie             => $bibit->{'seriestitle'},
   bnotes            => $bibit->{'bnotes'}
                 );}
 # Matias

#Matias: Mensajes similares a los de detail.pl al agregarle la  posibilidad de editar y borrar
my $msg=$input->param('msg');
if ($msg ne ""){
my $msgtext="";
   if ($msg eq "noempty")       {
        $msgtext="El libro tiene ".$input->param('noemptycount')." ejemplar/es, por favor borrelo/s antes de eliminar el libro.";
        }
   elsif ($msg eq "nobiblioitemdelete")       {
        $msgtext="No es posible eliminar el grupo debido a que contiene items que se encuentran prestados.";
        }
if ($msg eq "havereservesgroup")       {
        $msgtext="Exist&iacute;an reservas sobre el grupo eliminado que fueron dadas de baja !!!" ;
        }
                                                                                                                             
                                                                                                                             
   $template->param(MSG => $msgtext);
                                                                                                                             
}
#fin Matias



        if ( $error eq "nobarcode" ) {
            $template->param( NOBARCODE => 1 );
        }
        elsif ( $error eq "nobiblioitem" ) {
            $template->param( NOBIBLIOITEM => 1 );
        }
	   elsif ( $error eq "signatureinuse" ) {
	               $template->param( SIGNATUREINUSE => 1 ,
		       			 bulk            => $input->param('bulk'));
		               }
        elsif ( $error eq "barcodeinuse" ) {
		my $it;
		$it=$input->param('itemtype');

		for ( my $i = 0 ; $i < $itemtypecount ; $i++ ) {
  		$itemtypes[$i]->{'selected'}  =  ($itemtypes[$i]->{'itemtype'} eq $it);}
            	$template->param( 
		BARCODEINUSE	=> 1,
                shelf           =>$input->param('bookshelf'),
		barcode		=> $input->param('barcode'),
   		bulk            => $input->param('bulk'),
	 	itemnotes	=> $input->param('itemnotes'),
		replacementprice=> $input->param('replacementprice'),
		BarcoderepetidoS=> $input->param('BarcoderepetidoS'),
    		itemtype          => $input->param('itemtype'),
    		isbncode              => $input->param('isbncode'),
    		#isbn2             => $input->param('isbn2'),
    		publishercode     => $input->param('publishercode'),
    		publicationyear   => $input->param('publicationyear'),
    		place             => $input->param('place'),
    		illus             => $input->param('illus'),
    		additionalauthors => $input->param('additionalauthors'),
    		subjectheadings   => $input->param('subjectheadings'),
    		url               => $input->param('url'),
    		#dewey             => $input->param('dewey'),
    		issn              => $input->param('issn'),
    		lccn              => $input->param('lccn'),
    		volume            => $input->param('volume'),
    		number            => $input->param('number'),
    		volumeddesc       => $input->param('volumeddesc'),
    		pages             => $input->param('pages'),
    		size              => $input->param('size'),
    		bnotes            => $input->param('bnotes'),
    		serie             => $input->param('seriestitle'),
    		support           => $input->param('support'),
    		country           => $input->param('country'),
    		language          => $input->param('language'),
	

		);
        }    # elsif
		elsif($error eq "none"){
	$template->param(ADDBARCODES => $input->param('barcodesAgregados'));
				    }
        for ( my $i = 0 ; $i < $biblioitemcount ; $i++ ) {
            if ( $biblioitems[$i]->{'itemtype'} eq "WEB" ) {
                $biblioitems[$i]->{'WEB'} = 1;

            }
            #$biblioitems[$i]->{'dewey'} =~ /(\d*\.\d\d)/;
            #$biblioitems[$i]->{'dewey'} = $1;
        
	#Matias:  Comentado para que no muestre los items  
	    #my ( $itemcount, @items ) =
            #  &getitemsbybiblioitem( $biblioitems[$i]->{'biblioitemnumber'} );
            #$biblioitems[$i]->{'items'} = \@items;
       
	 }    # for
        $template->param(
            BIBNUM    => $biblionumber,
            AUTHOR    => \@autorPPAL,
            UNITITLE    => $biblios[0]->{'unititle'},
            SUBTITLE    => $allsubtitles,
            ABSTRACT     => $biblios[0]->{'abstract'},
	    SUBJECT => $allsubjects,
            CDU    => $biblios[0]->{'seriestitle'},	
            TITLE     => $biblios[0]->{'title'},
            ADDITIONAL => \@autoresAdicionales,
	    COLABS => \@colaboradores,
            NOTES     => $biblios[0]->{'notes'},
            BIBITEMS  => \@biblioitems,
            BRANCHES  => $CGIbranch,
            ITEMTYPES => $CItems,
            SUPPORTTYPES => $Csupports,
            LANGTYPES => $Clangs,
            BOOKSHELF => $Cshelf,
            COUNTRYTYPES => $Ccountrys,
	    BIBLIOLEVELS => $Clevel, #Nivel Biliografico
	 inicializaciones => $inicializacion, #agregado del guardoImpo..
           valores          => $valor,    #idem anterior
	Cavails => $Cavails, disableDisp => 1  #Disponibilidad
        );

	if (!$bulk) 	{$template->param(   bulk    => $biblios[0]->{'seriestitle'});}

	#Valores Por Defecto
	my @defaults=&obtenerDefaults();

	#Recorro para quitar los espacios que no puedo manejar en javascript
	foreach my $def (@defaults) {
	  if(($def->{'campo'} eq 'notes')or($def->{'campo'} eq 'isbn')or($def->{'campo'} eq 'publishercode'))
	  	{$def->{'valor'}=~ s/\n/@#@/g;
		 $def->{'valor'}=~ s/\r//g;}
	}

	$template->param( DEFAULTS    => \@defaults);

        output_html_with_http_headers $newinput, $cookie, $template->output;
    }}
