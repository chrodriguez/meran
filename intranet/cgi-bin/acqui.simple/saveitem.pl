#!/usr/bin/perl

# $Id: saveitem.pl,v 1.8 2003/05/04 03:16:15 rangi Exp $

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

use CGI;
use strict;
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use C4::BookShelves;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;



my $input            = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});
my $editBook	     =$input->param('editbook');
my $barcode          = $input->param('barcode');
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');
my $responsable      = $input->param('userloggedname');

my $shelfbook        = $input->param('shelfbook');
my $subshelfbook        = $input->param('subshelfbook');
my $shelfvalues        = $input->param('shelfvalues');
my $newshelf       = $input->param('newshelf');


###Disponibilidad
my $wthdrawn=0;
if ($input->param('withdrawn') eq 1) {$wthdrawn=$input->param('unavailable');}
##

my $item             = {
    biblionumber     => $biblionumber,
    biblioitemnumber => $biblioitemnumber?$biblioitemnumber:"",
    homebranch       => $input->param('homebranch'),
    holdingbranch    => $input->param('homebranch'), #esta es la linea que agregue
    replacementprice => $input->param('replacementprice')?$input->param('replacementprice'):"",
    #Agregado el bulk por Einar, el bulk es la signatura topografica 
    bulk        => $input->param('bulk')?$input->param('bulk'):"",
    #Corregido el notes por el itemsnotes porque las notas del item son el items note
    itemnotes        => $input->param('itemnotes')?$input->param('itemnotes'):"",
    #Agregado por Einar, para saber si es para sala o si esta perdido o si esta withdrawn y modificado por Matias
    notforloan        => $input->param('notforloan')?$input->param('notforloan'):"",
    wthdrawn        => $wthdrawn,
}; # my $item

my $biblioitem       = {
    biblionumber      => $biblionumber,
    itemtype          => $input->param('itemtype'),
    isbncode          => $input->param('isbncode')?$input->param('isbncode'):"",
    #isbn2             => $input->param('isbnSec')?$input->param('isbnSec'):"",#ISBN secundario para algunos casos especiales
    publishercode     => $input->param('publishercode')?$input->param('publishercode'):"",
    publicationyear   => $input->param('publicationyear')?$input->param('publicationyear'):"",
    place             => $input->param('place')?$input->param('place'):"",
    #Country, language, support y series fueron agregados por Einar.
    seriestitle             => $input->param('serie')?$input->param('serie'):"",
    support           => $input->param('support')?$input->param('support'):"",
    country           => $input->param('country')?$input->param('country'):"",
    language          => $input->param('language')?$input->param('language'):"",
    classification    => $input->param('level')?$input->param('level'):"",
    illus             => $input->param('illus')?$input->param('illus'):"",
    url               => $input->param('url')?$input->param('url'):"",
    dewey             => $input->param('dewey')?$input->param('dewey'):"",
    issn              => $input->param('issn')?$input->param('issn'):"",
    lccn              => $input->param('lccn')?$input->param('lccn'):"",
    volume            => $input->param('volume')?$input->param('volume'):"",
    number            => $input->param('number')?$input->param('number'):"",
    volumeddesc       => $input->param('volumeddesc')?$input->param('volumeddesc'):"",
    pages             => $input->param('pages')?$input->param('pages'):"",
    size              => $input->param('size')?$input->param('size'):"",
    bnotes            => $input->param('notes')?$input->param('notes'):"",
    indice 	     => $input->param('indice')?$input->param('indice'):"",
    
}; # my biblioitem
my $newgroup = 0;
my $website  = 0;
my $count;
my @results;
my $tipo=$input->param('tipo');
#Matias Para agregar un nuevo volumen sin perder los datos
my $newvol = 0;
if ($tipo eq 'newvol') {$newvol = 1;}
if (($tipo eq 'newgroup')or ($tipo eq 'newvol')) {
	$newgroup = 1;
    	if ($biblioitem->{'itemtype'} eq "WEB") {$website = 1;} 
						}
###Matias Fin 

# Agregado por Einar para permitir multiples barcodes
my @barcodes=split(/,/,$barcode);
my $cantB=@barcodes;

for (my $i=0;$i<$cantB;$i++){
    $barcodes[$i]=~ s/^\s+//; #espacios al principio
      $barcodes[$i]=~ s/\s+$//; #espacios al final
        }


if (! $biblionumber) {
    print $input->redirect('addbooks.pl');
} elsif ((! $newgroup) && (! $biblioitemnumber)) {
    print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&error=nobiblioitem");
} else {

    if ($website) {
	&newbiblioitem($biblioitem,$responsable);
  #original   } elsif (&checkitems(1,$barcode)) {
    } else {
	#Aca esta la funcion que arma la lista de los barcodes repetidos Einar.
	my $BarcoderepetidoS='';
	my $SignaturaRepetidas=0;
	if ($wthdrawn ne 2){ #MATIAS:  SI NO ES UN ITEM COMPARTIDO SE CHEQUEA EL BARCODE Y LA SIGNATURA

	foreach my $aux(@barcodes){
		if (checkitems(1,$aux)){
			if ($BarcoderepetidoS){$BarcoderepetidoS.=','.$aux;}
			else{$BarcoderepetidoS=$aux;}
		}#if checkitems
	}#foreach

	#Busca si esta siendo utilizada la signatura topografica en otro registro que no sea el propio.
	 $SignaturaRepetidas=&signaturaUtilizada($input->param('bulk'),$biblionumber);	

	 }#es Compartido?




	
	if (($BarcoderepetidoS)or($SignaturaRepetidas gt 0)){
	#checkitems(scalar(@barcodes),@barcodes));
	#aca deberia mandar todos los barcodes que estan mal Einar
	my $error;
	if ($BarcoderepetidoS){$error='barcodeinuse';}else{$error='signatureinuse'}
	print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&error=".$error."&bulk=".$input->param('bulk')."&itemnotes=".$input->param('itemnotes')."&replacementprice=".$input->param('replacementprice')."&BarcoderepetidoS=".$BarcoderepetidoS."&serie=".$input->param('serie')."&barcode=".$barcode."&itemtype=".$input->param('itemtype')."&isbncode=".$input->param('isbncode')."&publishercode=".$input->param('publishercode')."&publicationyear=".$input->param('publicationyear')."&place=".$input->param('place')."&support=".$input->param('support')."&country=".$input->param('country')."&language=".$input->param('language')."&illus=".$input->param('illus')."&additionalauthors=".$input->param('additionalauthors')."&subjectheadings=".$input->param('subjectheadings')."&url=".$input->param('url')."&dewey=".$input->param('dewey')."&subclass=".$input->param('subclass')."&issn=".$input->param('issn')."&lccn=".$input->param('lccn')."&volume=".$input->param('volume')."&number=".$input->param('number')."&volumeddesc=".$input->param('volumeddesc')."&pages=".$input->param('pages')."&size=".$input->param('size')."&bnotes=".$input->param('notes'));

    } else {
	if (! $barcode){
    		        #@barcodes=("generar",1);
    			@barcodes=('generar',$input->param('cantidadItems')||1);
	}
	if ($newgroup) {
	    $biblioitemnumber = &newbiblioitem($biblioitem,$responsable);
	    $item->{'itemtype'}=$input->param('itemtype');
	    $item->{'biblioitemnumber'} = $biblioitemnumber;
	} # if
	#return($itemnumber,$error,$barcode);
	 else{
	    $item->{'itemtype'}=&obtenerBiblioitemType($biblioitemnumber);
	 }
	#En @barcodes2 recibo todos los barcodes que se agregaron, y en errors los errores que se produjeron
	my ($errors,$barcodes2)=&newitems($item, $responsable,@barcodes);
	#tengo que agregar con el biblioitemnumber los estante virtuales
        #Lista de estantes
        #Primero borro de todos los estantes existentes  ese grupo
        my @val=split(/#/,$shelfvalues);
        my $i=0;
        foreach my $shelf (@val){
        my @new=split(/@/,$shelf);
        if ($new[1]){
                my $parent=$new[1];
                if ( $new[1] eq 'top'){$parent='0';}    

                my $snum =AddShelf(my $env,$new[0],'public',$new[1]);   
                AddToShelf(my $env,$biblioitemnumber, $snum);
                }else{AddToShelf(my $env,$biblioitemnumber, $new[0]);}
                }
#fin estante virtual


#MATIAS  ES UNA CAGADA YA LO SE!!!!

if ($newvol) { print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&newvol=1&biblioitemnumber=$biblioitemnumber&additionalauthors=".$input->param('additionalauthors')."&subjectheadings=".$input->param('subjectheadings'));
}else { print $input->redirect("additem-nomarc.pl?biblionumber=".$biblionumber."&barcodesAgregados=".$barcodes2."&error=none"); }
###

} } } # else
