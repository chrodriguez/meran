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
use C4::AR::Utilidades;



my $input= new CGI;
#print $input->header;
#print $input->Dump;

my $shelfbook       = &verificarValor($input->param('shelfbook'));
my $subshelfbook    = &verificarValor($input->param('subshelfbook'));
my $shelfvalues     = &verificarValor($input->param('shelfvalues'));
my $newshelfvalues  = &verificarValor($input->param('newvalues'));


my $bibitemnum      = &verificarValor($input->param('bibitemnum'));
my $bibnum          = &verificarValor($input->param('bibnum'));
my $itemtype        = &verificarValor($input->param('item'));
my $url             = &verificarValor($input->param('url'));#URL
my $isbncode        = &verificarValor($input->param('isbncode'));#ISBNS
my $issn            = &verificarValor($input->param('issn'));#ISSN
my $lccn            = &verificarValor($input->param('lccn'));#Lccn
my $country         = &verificarValor($input->param('country'));#Pais
my $language	    = &verificarValor($input->param('language'));#Idioma
my $support         = &verificarValor($input->param('support'));#Idioma

my $publishercode   = &verificarValor($input->param('publisher'));#Editores
my $publicationdate = &verificarValor($input->param('publicationyear'));#Año de edicion
my $class           = &verificarValor($input->param('class'));#Tipo
my $illus           = &verificarValor($input->param('illustrations'));#Ilustraciones
my $pages           = &verificarValor($input->param('pages'));#Paginas
# my $volumeddesc     = checkinp($input->param('volumeddesc'));#Descripcion del volumen
my $volumeddesc     = &verificarValor($input->param('volumeddesc'));#Descripcion del volumen
my $volume	    = &verificarValor($input->param('volume'));#Volumen
my $notes           = &verificarValor($input->param('notes'));#Notas
my $size            = &verificarValor($input->param('size'));#Tamaño
my $place           = &verificarValor($input->param('place'));#Lugar
my $serie           = &verificarValor($input->param('serie'));#Serie
my $fasc            = &verificarValor($input->param('fasc'));#Fasciculo

my $classification  = &verificarValor($input->param('level'));#Nivel Bibliografico;
my $dewey;
my $subclass;
my $responsable    = &verificarValor($input->param('userloggedname'));
my $number         = &verificarValor($input->param('number'));#Numero de edicion

=item
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
	  issn		  => $issn?$issn:"",
	  lccn		  => $lccn?$lccn:"",
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
          seriestitle     => $serie?$serie:"",
	  country         => $country?$country:"",
	 language         => $language?$language:"",
         support          => $support?$support:"",
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
	  isbncode         => $isbncode?$isbncode:"",
	  issn		   => $issn?$issn:"",
	  lccn		  => $lccn?$lccn:"",
	  publishercode    => $publishercode?$publishercode:"",
	  publicationyear  => $publicationdate?$publicationdate:"",
	  classification   => $classification?$classification:"",
	  dewey            => $dewey?$dewey:"",
	  subclass         => $subclass?$subclass:"",
	  illus            => $illus?$illus:"",
	  pages            => $pages?$pages:"",
	  volumeddesc      => $volumeddesc?$volumeddesc:"",
	  volume           => $volume?$volume:"",
	  bnotes           => $notes?$notes:"",
          number           =>$number?$number:"",
          seriestitle      =>$serie?$serie:"",
	 country 	   => $country?$country:"",
	 language          => $language?$language:"",
         support           => $support?$support:"",
	 fasc              => $fasc?$fasc:"", 
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
	 isbncode         => $isbncode?$isbncode:"",
	 issn		  => $issn?$issn:"",
	 lccn		  => $lccn?$lccn:"",
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

=item
sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
=cut
