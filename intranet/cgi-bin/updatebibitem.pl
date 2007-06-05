#!/usr/bin/perl

# $Id: updatebibitem.pl,v 1.12 2003/10/22 20:20:48 rangi Exp $

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
use C4::Biblio;
use C4::Output;
use C4::Search;
use C4::BookShelves;



my $input= new CGI;
#print $input->header;
#print $input->Dump;

my $shelfbook        = $input->param('shelfbook');
my $subshelfbook        = $input->param('subshelfbook');
my $shelfvalues        = $input->param('shelfvalues');
my $newshelfvalues       = $input->param('newvalues');


my $bibitemnum      = checkinp($input->param('bibitemnum'));
my $bibnum          = checkinp($input->param('bibnum'));
my $itemtype        = checkinp($input->param('item'));
my $url             = checkinp($input->param('url'));#URL
my $isbncode            = checkinp($input->param('isbncode'));#ISBNS
my $issn            = $input->param('issn');#ISSN
my $lccn            = $input->param('lccn');#Lccn
my $country         = $input->param('country');#Pais
my $language	    = $input->param('language');#Idioma
my $support        = $input->param('support');#Idioma

my $publishercode   = checkinp($input->param('publisher'));#Editores
my $publicationdate = checkinp($input->param('publicationyear'));#Año de edicion
my $class           = checkinp($input->param('class'));#Tipo
my $illus           = checkinp($input->param('illustrations'));#Ilustraciones
my $pages           = checkinp($input->param('pages'));#Paginas
my $volumeddesc     = checkinp($input->param('volumeddesc'));#Descripcion del volumen
my $volume	    = checkinp($input->param('volume'));#Volumen
my $notes           = $input->param('notes');#Notas
my $size            = checkinp($input->param('size'));#Tamaño
my $place           = checkinp($input->param('place'));#Lugar
my $serie           = $input->param('serie');#Serie
my $fasc           = $input->param('fasc');#Fasciculo

my $classification  = $input->param('level');#Nivel Bibliografico;
my $dewey;
my $subclass;
my $responsable    = $input->param('userloggedname');
my $number         =  $input->param('number');#Numero de edicion

=cut
if ($itemtype ne 'NF') {
  $classification=$class;
} # if

if ($class =~/[0-9]+/) {
#   print $class;
   $dewey= $class;
   $dewey=~ s/[a-z]+//gi;
   my @temp;
   if ($class =~ /\./) {
     @temp=split(/[0-9]+\.[0-9]+/,$class);
   } else {
     @temp=split(/[0-9]+/,$class);
   } # else
   $classification=$temp[0];
   $subclass=$temp[1];
#   print $classification,$dewey,$subclass;
} else {
  $dewey='';
  $subclass='';
} # else
=cut



# my (@items) = &itemissues($bibitemnum); #Esto no anda muy bien
 my (@items) = itemsfrombiblioitem($bibitemnum);
#MAtias 

#print @items;
my $count   = @items;
#print $count;
my @barcodes;


my $existing=$input->param('existing');

if ($existing eq 'yes'){
#  print "yes";
  my $group=$input->param('existinggroup');

  #go thru items assing selected ones to group
  for (my $i=0;$i<$count;$i++){
    my $temp="check_group_".$items[$i]->{'barcode'};
    my $barcode=$input->param($temp);


    if ($barcode ne ''){
	#Matias
         my $auxitem=   infoitem($items[$i]->{'barcode'});
            $auxitem->{'bibitemnum'}=$group;
if ($auxitem->{'lost'} eq '') {$auxitem->{'lost'}=0;} # Matias : lo agrego para que realice bien la consulta
          moditem($auxitem,$responsable);
	####   
		   
    }#if
  }#for
  $bibitemnum=$group;

} else {
#=cut Matias : Se quita la funcionalidad de modificar el grupo y al elegir algunos ejemplares se crea uno nuevo para esos
    my $flag;
    my $flag2;
    for (my $i=0;$i<$count;$i++){
      my $temp="check_group_".$items[$i]->{'barcode'};
      $barcodes[$i]=$input->param($temp);

	  if ($barcodes[$i] eq ''){
        $flag="notall";
      } else {
        $flag2="leastone";
      }#if
   } #for
   my $loan;

   if ($flag eq 'notall' && $flag2 eq 'leastone'){
      $bibitemnum = &newbiblioitem({
	  biblionumber    => $bibnum,
	  itemtype        => $itemtype?$itemtype:"",
	  url             => $url?$url:"",
	  isbncode        => $isbncode?$isbncode:"",
	  publishercode   => $publishercode?$publishercode:"",#Editor
	  publicationyear => $publicationdate?$publicationdate:"",
	  volumeddesc     => $volumeddesc?$volumeddesc:"",
	  volume     	  => $volume?$volume:"",
	  classification  => $classification?$classification:"",
	  dewey           => $dewey?$dewey:"",
	  subclass        => $subclass?$subclass:"",
	  illus           => $illus?$illus:"",
	  pages           => $pages?$pages:"",
	  notes           => $notes?$notes:"",
	  size            => $size?$size:"",
          number          => $number?$number:"",
          seriestitle            => $serie?$serie:"",
	  country => $country?$country:"",
	 language        => $language?$language:"",
         support        => $support?$support:"",
	  place           => $place?$place:"" ,
	   fasc           => $fasc?$fasc:"" });

      if ($itemtype =~ /REF/){
        $loan=1;
      } else {
        $loan=0;
      }
      for (my $i=0;$i<$count;$i++){
        if ($barcodes[$i] ne ''){
#Matias
 my $auxitem=   infoitem($items[$i]->{'barcode'});
 $auxitem->{'bibitemnum'}=$bibitemnum;
if ($auxitem->{'lost'} eq '') {$auxitem->{'lost'}=0;} # Matias : lo agrego para que realice bien la consulta
          moditem($auxitem,$responsable);
#### 
	}
      }

   } elsif ($flag2 eq 'leastone') {
      &modbibitem({
	  biblioitemnumber => $bibitemnum,
	  biblionumber     => $bibnum,
	  itemtype         => $itemtype?$itemtype:"",
	  url              => $url?$url:"",
	  isbncode             => $isbncode?$isbncode:"",
	  publishercode    => $publishercode?$publishercode:"",
	  publicationyear  => $publicationdate?$publicationdate:"",
	  classification   => $classification?$classification:"",
	  dewey            => $dewey?$dewey:"",
	  subclass         => $subclass?$subclass:"",
	  illus            => $illus?$illus:"",
	  pages            => $pages?$pages:"",
	  volumeddesc      => $volumeddesc?$volumeddesc:"",
	  volume          => $volume?$volume:"",
	  bnotes            => $notes?$notes:"",
          number           =>$number?$number:"",
          seriestitle            =>$serie?$serie:"",
	 country => $country?$country:"",
	 language        => $language?$language:"",
         support        => $support?$support:"",
	 fasc        => $fasc?$fasc:"", 
	#Matias notes x bnotes
	  size             => $size?$size:"",
	  place            => $place?$place:"" },$responsable);
      if ($itemtype =~ /REF/){
        $loan=1;
      } else {
        $loan=0;
      }
	for (my $i=0;$i<$count;$i++){
	  if ($barcodes[$i] ne ''){	
#Matias

my $auxitem=   infoitem($items[$i]->{'barcode'});            
 $auxitem->{'bibitemnum'}=$bibitemnum;
if ($auxitem->{'lost'} eq '') {$auxitem->{'lost'}=0;} # Matias : lo agrego para que realice bien la consulta
          moditem($auxitem,$responsable);

####
	  }
	}

   } else {

#=cut

     &modbibitem({
         biblioitemnumber => $bibitemnum,
	 biblionumber     => $bibnum,
	 itemtype         => $itemtype?$itemtype:"",
	 url              => $url?$url:"",
	 isbncode             => $isbncode?$isbncode:"",
	 publishercode    => $publishercode?$publishercode:"",
         publicationyear  => $publicationdate?$publicationdate:"",
         classification   => $classification?$classification:"",
         dewey            => $dewey?$dewey:"",
         subclass         => $subclass?$subclass:"",
         illus            => $illus?$illus:"",
         pages            => $pages?$pages:"",
         volumeddesc      => $volumeddesc?$volumeddesc:"",
   	 volume          => $volume?$volume:"",
	#Matias notes x bnotes
         bnotes            => $notes?$notes:"",
         size             =>  $size?$size:"",
         number           =>  $number?$number:"",
         seriestitle     => $serie?$serie:"",
	 country 	=> $country?$country:"",
         language        => $language?$language:"",
	 support        => $support?$support:"",
	 fasc       => $fasc?$fasc:"",
	 place            => $place?$place:"" },$responsable);
        
  } # else


#tengo que agregar con el biblioitemnumber los estante virtuales
        #Lista de estantes
	#Primero borro de todos los estantes existentes  ese grupo
	RemoveFromShelvesBiblio(my $env,$bibitemnum);

	my @val=split(/#/,$shelfvalues);
	my $i=0;
        foreach my $shelf (@val){ 
        my @new=split(/@/,$shelf);	
	if ($new[1]){
		my $parent=$new[1];
		if ( $new[1] eq 'top'){$parent='0';}
	
		my $snum =AddShelf(my $env,$new[0],'public',$new[1]);	
		AddToShelf(my $env,$bibitemnum, $snum);
		}else{AddToShelf(my $env,$bibitemnum, $new[0]);}
		}
#fin estante virtual




   updatePublishers($bibitemnum,$publishercode); #Agregado por Luciano para actualizar los editores en la tabla publisher
   updateISBNs($bibitemnum,$isbncode);
close L;

}
#print $input->redirect("moredetail.pl?type=intra&bib=$bibnum&bi=$bibitemnum");

print $input->redirect("detail.pl?type=intra&bib=$bibnum");

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}

