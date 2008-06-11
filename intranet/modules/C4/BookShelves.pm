# -*- tab-width: 8 -*-
# Please use 8-character tabs for this file (indents are every 4 characters)

package C4::BookShelves;

# $Id: BookShelves.pm,v 1.11.2.2 2004/02/19 10:15:41 tipaul Exp $

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
use DBI;
use C4::Search;
use C4::Context;
use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::BookShelves - Functions for manipulating Koha virtual bookshelves

=head1 SYNOPSIS

  use C4::BookShelves;

=head1 DESCRIPTION

This module provides functions for manipulating virtual bookshelves,
including creating and deleting bookshelves, and adding and removing
items to and from bookshelves.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&GetShelfList &GetShelfContents &AddToShelf &AddToShelfFromBiblio &getbookshelfNOItems &RemoveFromShelf &AddShelf &RemoveShelf &RemoveFromShelvesBiblio &getbookshelfItems &GetShelfContentsShelf &GetShelfName &GetShelfParent &existsShelf  &getbookshelfItemsforList &getbookshelf &getbooksubshelf  &privateShelfs &createPrivateShelf &gotShelf &addPrivateShelfs &delPrivateShelfs &getbookshelfLike &getbookshelfLikeCount  &getshelfListCount &shelfitemcount  &modshelf
);

my $dbh = C4::Context->dbh;

=item GetShelfList

  $shelflist = &GetShelfList();
  ($shelfnumber, $shelfhash) = each %{$shelflist};

Looks up the virtual bookshelves, and returns a summary. C<$shelflist>
is a reference-to-hash. The keys are the bookshelf numbers
(C<$shelfnumber>, above), and the values (C<$shelfhash>, above) are
themselves references-to-hash, with the following keys:

=over 4

=item C<$shelfhash-E<gt>{shelfname}>

A string. The name of the shelf.

=item C<$shelfhash-E<gt>{count}>

The number of books on that bookshelf.

=back

=cut
#'
# FIXME - Wouldn't it be more intuitive to return a list, rather than
# a reference-to-hash? The shelf number can be just another key in the
# hash.

sub getshelfListCount{
my ($type)=@_;
my $dbh   = C4::Context->dbh;
  my $sth4=$dbh->prepare("SELECT     count(bookshelf.shelfnumber)as count2
                                                                FROM            bookshelf WHERE bookshelf.type=? and  bookshelf.parent=? "   );

  $sth4->execute($type,0);
(my $count2)=$sth4->fetchrow;
return($count2);
        
}   

sub getbookshelfLikeCount{
my ($nameShelf)=@_;
my $dbh   = C4::Context->dbh;
  my $sth4=$dbh->prepare("SELECT     count(bookshelf.shelfnumber)as count2
                                                                FROM            bookshelf

                                                               WHERE (shelfname LIKE ? or shelfname LIKE ?)
                                                             "   );

  $sth4->execute("$nameShelf%", "$nameShelf %");
(my $count2)=$sth4->fetchrow;
return($count2);

}

sub getbookshelfLike {
  my ($nameShelf) = @_;
  
  my $dbh   = C4::Context->dbh;
=item
  my $sth =$dbh->prepare("	SELECT bookshelf.shelfnumber, bookshelf.shelfname, bookshelf.parent,
                          	count(shelfcontents.biblioitemnumber) as count
                                FROM bookshelf
                                LEFT JOIN shelfcontents
                                ON bookshelf.shelfnumber = shelfcontents.shelfnumber WHERE (shelfname LIKE ? or shelfname LIKE ?)
                                GROUP BY bookshelf.shelfnumber order by bookshelf.shelfname ASC ".$limit);
=cut

  my ($nameShelf) = @_;
  
  my $dbh   = C4::Context->dbh;

  my $sth =$dbh->prepare("SELECT bookshelf.shelfnumber, bookshelf.shelfname, bookshelf.parent,
                          count(shelfcontents.id2) as count
                          FROM  bookshelf
                          LEFT JOIN shelfcontents
                          ON bookshelf.shelfnumber = shelfcontents.shelfnumber WHERE (shelfname LIKE ? or shelfname LIKE ?)
                          GROUP BY bookshelf.shelfnumber order by bookshelf.shelfname ASC ");



  $sth->execute("$nameShelf%", "$nameShelf %");
  my %resultslabels;
  $sth->execute;
  my $i;
  $i=1;
  my $sth2=$dbh->prepare("	SELECT count(*) as countshelf FROM bookshelf 
				WHERE ( bookshelf.type = ? ) AND (bookshelf.parent =?)");

  my $sth3=$dbh->prepare("	SELECT shelfnumber as numberparent,shelfname as nameparent 
				FROM bookshelf  
				WHERE shelfnumber=? AND type=?");

open(A, ">>/tmp/debug.txt");
print A "BookShelves  \n";
    while (my ($shelfnumber, $shelfname,$shelfparent,$count) = $sth->fetchrow) {
        $sth2->execute('public',$shelfnumber);
        my $shelfnameparent;
        $sth3->execute($shelfparent, 'public');
        ($shelfparent, $shelfnameparent)=$sth3->fetchrow;
        $resultslabels{$shelfnumber}->{'numberparent'}=$shelfparent;
        $resultslabels{$shelfnumber}->{'nameparent'}=$shelfnameparent;
print A "$shelfname \n";
        $resultslabels{$shelfnumber}->{'shelfname'}=$shelfname;
        $resultslabels{$shelfnumber}->{'count'}=$count;
        $resultslabels{$shelfnumber}->{'countshelf'}=$sth2->fetchrow;
        $i=$i+1;
    }
close(A);
  $sth->finish;
  return(%resultslabels);
} 


sub getbookshelf {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bookshelf where parent=0 and type='public' ORDER BY shelfname ASC");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'shelfnumber'}}= $data->{'shelfname'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getbookshelf

sub getbooksubshelf {
my ($shelf) = @_;
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bookshelf where parent=? ");
  my %resultslabels;
  $sth->execute($shelf);
   while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'shelfnumber'}}= $data->{'shelfname'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getbooksubshelf



sub getbookshelfItems {
  my ($type,$id2)=@_;
  my $dbh   = C4::Context->dbh;
  #my $sth   = $dbh->prepare("select bookshelf.shelfnumber, bookshelf.shelfname from bookshelf,shelfcontents where (shelfcontents.shelfnumber=bookshelf.shelfnumber) and (bookshelf.type = ?) and (shelfcontents.biblioitemnumber=?)");
  my $sth   = $dbh->prepare("SELECT bs2.shelfname AS parentname, bs.shelfname, bs.shelfnumber, bs2.shelfnumber AS shelfnumberParent
                                FROM bookshelf AS bs
                                LEFT JOIN bookshelf AS bs2 ON bs2.shelfnumber = bs.parent
                                INNER JOIN shelfcontents ON bs.shelfnumber = shelfcontents.shelfnumber
                                WHERE ( bs.type = ?  ) AND ( shelfcontents.id2 = ? )");
  my %resultslabels;
  $sth->execute($type,$id2);
  while (my ($parentname, $shelfname, $shelfnumber,$shelfnumberParent) = $sth->fetchrow){
  $resultslabels{$shelfnumber}->{'shelfnumberParent'}= $shelfnumberParent;
  $resultslabels{$shelfnumber}->{'parentname'}= $parentname;
  $resultslabels{$shelfnumber}->{'shelfnumber'}= $shelfnumber;
  $resultslabels{$shelfnumber}->{'shelfname'}= $shelfname;
  } # while
  $sth->finish;
  return(%resultslabels);
}

sub getbookshelfItemsforList {
  my ($type,$id2)=@_;
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("SELECT bs2.shelfname AS parentname, bs.shelfname, bs.shelfnumber
				FROM bookshelf AS bs
				LEFT JOIN bookshelf AS bs2 ON bs2.shelfnumber = bs.parent
				INNER JOIN shelfcontents ON bs.shelfnumber = shelfcontents.shelfnumber
				WHERE ( bs.type = ?  ) AND ( shelfcontents.id2 = ? )");
  my %resultslabels;
  $sth->execute($type,$id2);
  while (my $data = $sth->fetchrow_hashref) {
	my $name='';
	if ($data->{'parentname'}){$name=$data->{'parentname'}.'->'.$data->{'shelfname'};} else {$name=$data->{'shelfname'};}	
    $resultslabels{$data->{'shelfnumber'}}= $name;
  } # while
  $sth->finish;
  return(%resultslabels);
}


sub getbookshelfNOItems {
  my ($type,$lista)=@_;
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bookshelf where (bookshelf.type= ?) and (shelfnumber NOT IN ($lista))");
  my %resultslabels;
  $sth->execute();
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'shelfnumber'}}= $data->{'shelfname'};
  } # while
  $sth->finish;
  return(%resultslabels);
} 


sub GetShelfList {
    my($type)=@_;
    
    my $sth=$dbh->prepare("SELECT		bookshelf.shelfnumber, bookshelf.shelfname,
							count(shelfcontents.id2) as count
								FROM		bookshelf
								LEFT JOIN	shelfcontents
								ON		bookshelf.shelfnumber = shelfcontents.shelfnumber WHERE (bookshelf.type=?) and (bookshelf.parent=0)
								GROUP BY	bookshelf.shelfnumber order by bookshelf.shelfname ASC ");

    $sth->execute($type);
    my %shelflist;
        my $sth2=$dbh->prepare("Select count(*) as countshelf FROM bookshelf WHere ( bookshelf.type = ? ) AND ( bookshelf.parent =?)");
    while (my ($shelfnumber, $shelfname,$count) = $sth->fetchrow) {
        $sth2->execute($type,$shelfnumber);

	$shelflist{$shelfnumber}->{'shelfname'}=$shelfname;
	$shelflist{$shelfnumber}->{'count'}=$count;
        $shelflist{$shelfnumber}->{'countshelf'}=$sth2->fetchrow;

    }
$sth->finish;
$sth2->finish;
return(%shelflist);
}

=item GetShelfContents

  $itemlist = &GetShelfContents($env, $shelfnumber);

Looks up information about the contents of virtual bookshelf number
C<$shelfnumber>.

Returns a reference-to-array, whose elements are references-to-hash,
as returned by C<&getiteminformation>.

I don't know what C<$env> is.

=cut
#'
sub GetShelfContentsShelf{
my ($type,$shelfnumbershelf)=@_;
my %shelfcontentshelf;
my $sth2;
my $sth=$dbh->prepare("SELECT bookshelf.shelfnumber, bookshelf.shelfname,
                                                        count(shelfcontents.id2) as count
                                                                FROM            bookshelf
                                                                LEFT JOIN       shelfcontents
                                                                ON              bookshelf.shelfnumber = shelfcontents.shelfnumber WHERE (bookshelf.type=?) and (bookshelf.parent=?)
                                                                GROUP BY        bookshelf.shelfnumber order by shelfname");
#my $sth=$dbh->prepare("SELECT bookshelf.shelfnumber, bookshelf.shelfname FROM bookshelf WHere ( bookshelf.type =  'public' ) AND ( bookshelf.parent =? )ORDER  BY shelfname");
$sth->execute($type,$shelfnumbershelf);
# my @results;
          $sth2=$dbh->prepare("Select count(*) as countShelf FROM bookshelf WHere ( bookshelf.type =  ? ) AND ( bookshelf.parent =? )ORDER  BY shelfname");
        while (my ($shelfnumber,$shelfname,$count) = $sth->fetchrow) {
          $shelfcontentshelf{$shelfnumber}->{'shelfnumber'}=$shelfnumber;
          $sth2->execute($type,$shelfnumber);

          $shelfcontentshelf{$shelfnumber}->{'shelfname'}=$shelfname;
          $shelfcontentshelf{$shelfnumber}->{'count'}=$count;
         $shelfcontentshelf{$shelfnumber}->{'countshelf'}=$sth2->fetchrow;


         }
	$sth2->finish;
	$sth->finish;
	return(%shelfcontentshelf);

}

sub GetShelfName
{
my ($shelfnumber) = @_;
my $sth=$dbh->prepare("select shelfname from bookshelf  where shelfnumber=?");
$sth->execute($shelfnumber);
my $aux=$sth->fetchrow;
$sth->finish;
return($aux);
}

sub GetShelfParent
{
my ($type,$shelfnumberP) = @_;
my $sth=$dbh->prepare("select parent from bookshelf  where shelfnumber=? and type=?");
$sth->execute($shelfnumberP, $type);

my $parent=$sth->fetchrow;
my $sth1=$dbh->prepare("SELECT               bookshelf.shelfnumber, bookshelf.shelfname,
                                                        count(shelfcontents.biblioitemnumber) as count
                                                                FROM            bookshelf
                                                                LEFT JOIN       shelfcontents
                                                                ON              bookshelf.shelfnumber = shelfcontents.shelfnumber WHERE (bookshelf.type=?) and (bookshelf.shelfnumber=?)
                                                                GROUP BY        bookshelf.shelfnumber order by shelfname");
$sth1->execute($type,$parent);
my %shelfparent;
my $sth2=$dbh->prepare("Select count(*) as countShelf FROM bookshelf WHERE ( bookshelf.type =  'public' ) AND ( bookshelf.parent =? )ORDER  BY shelfname");
while (my ($shelfnumber,$shelfname, $count) = $sth1->fetchrow){
  $shelfparent{$shelfnumber}->{'shelfnumber'}=$shelfnumber;
  $sth2->execute($shelfnumber);
  $shelfparent{$shelfnumber}->{'count'}=$count;
  $shelfparent{$shelfnumber}->{'countshelf'}=$sth2->fetchrow;
  $shelfparent{$shelfnumber}->{'shelfname'}=$shelfname;

}
$sth->finish;
$sth1->finish;
$sth2->finish;

return(%shelfparent);

}


sub GetShelfContents {
    my ($type,$shelfnumber) = @_;
    my %contentlist;           
    my $sth=$dbh->prepare("SELECT nivel1.titulo as title,  nivel1.id1 as id1, nivel2.id2 as id2, nivel1.autor as author, nivel2.ciudad_publicacion as place, nivel2.anio_publicacion as publicationyear  FROM ((shelfcontents LEFT JOIN nivel2 ON shelfcontents.id = nivel2.id2) LEFT JOIN nivel1 ON nivel2.id1=nivel1.id1) WHERE ( shelfnumber =? )");
    $sth->execute($shelfnumber);
	my @results;
  	my $i=0;
        while (my ($title,$id1,$id2,$author, $place,$publicationyear ) = $sth->fetchrow) {
          $contentlist{$id2}->{'title'}=$title;
	#  $contentlist{$biblioitemnumber}->{'unititle'}=$unititle;
        #  $contentlist{$id2}->{'biblioitemnumber'}=$biblioitemnumber;
        #  $contentlist{$id2}->{'biblionumber'}=$biblionumber;
          $contentlist{$id2}->{'editors'}= "($publicationyear)";
	  my $aut=C4::Search::getautor($author);
	  $contentlist{$id2}->{'completo'}=$aut->{'completo'};
          $contentlist{$id2}->{'apellido'}=$aut->{'apellido'};
	  $contentlist{$id2}->{'nombre'}=$aut->{'nombre'};
	  $contentlist{$id2}->{'id'}=$aut->{'id'};
	  $contentlist{$id2}->{'id1'}=$id1;
	  $contentlist{$id2}->{'id2'}=$id2;
          $contentlist{$id2}->{'place'}=$place;

# 	  if ($volume){$biblioitemlist{$id2}->{'editors'}.=" t. ".$volume;}
          $i++;
         }
	$sth->finish;
        return($i,%contentlist);

}

=item AddToShelf

  &AddToShelf($env, $itemnumber, $shelfnumber);

Adds item number C<$itemnumber> to virtual bookshelf number
C<$shelfnumber>, unless that item is already on that shelf.

C<$env> is ignored.

=cut
#'
sub AddToShelf {
	my ($id2, $shelfnumber) = @_;
 	return unless $id2;
        my $sth1 = $dbh->prepare("select id2 from nivel2 where id2=?");
        $sth1->execute($id2);
        if ($sth1->rows){

	my $sth2=$dbh->prepare("select * from shelfcontents where shelfnumber=? and id2=?");

	$sth2->execute($shelfnumber, $id2);
	if ($sth2->rows) {
# already on shelf
	} else {
		my $sth3=$dbh->prepare("insert into shelfcontents (shelfnumber, id2, flags) values (?, ?, 0)");
		$sth3->execute($shelfnumber, $id2);
		$sth3->finish;
	}
	$sth2->finish;
	}

$sth1->finish;
}



sub AddToShelfFromBiblio {
#	my ($env, $biblioitemnumber, $shelfnumber) = @_;
#	return unless $biblioitemnumber;
#	my $sth = $dbh->prepare("select biblioitemnumber from biblioitems where biblioitemnumber=?");
#	$sth->execute($biblioitemnumber);
#	my ($biblioitemnumber2) = $sth->fetchrow;
	#my $sth=$dbh->prepare("select * from shelfcontents where shelfnumber=? and biblioitemnumber=?");
	#my $sth->execute($shelfnumber, $biblioitemnumber2);
#	if ($sth->rows) {
# already on shelf
#	} else {
#		$sth=$dbh->prepare("insert into shelfcontents (shelfnumber, biblioitemnumber, flags) values (?, ?, 0)");
#		$sth->execute($shelfnumber, $biblioitemnumber2);
#	}
}

=item RemoveFromShelf

  &RemoveFromShelf($env, $itemnumber, $shelfnumber);

Removes item number C<$itemnumber> from virtual bookshelf number
C<$shelfnumber>. If the item wasn't on that bookshelf to begin with,
nothing happens.

C<$env> is ignored.

=cut
#'
sub RemoveFromShelf {
    my ($id2, $shelfnumber) = @_;
    my $sth=$dbh->prepare("delete from shelfcontents where shelfnumber=? and id=?");
    $sth->execute($shelfnumber,$id2);
    $sth->finish;
}

#eliminar de todos los estantes virtuales un libro dado
sub RemoveFromShelvesBiblio {
    my ($id2) = @_;
    my $sth=$dbh->prepare("delete from shelfcontents where id=?");
    $sth->execute($id2);
    $sth->finish;
}

=item AddShelf

  ($status, $msg) = &AddShelf($env, $shelfname);

Creates a new virtual bookshelf with name C<$shelfname>.

Returns a two-element array, where C<$status> is 0 if the operation
was successful, or non-zero otherwise. C<$msg> is "Done" in case of
success, or an error message giving the reason for failure.

C<$env> is ignored.

=cut
#'
# FIXME - Perhaps this could/should return the number of the new bookshelf
# as well?
sub AddShelf {
    my ($shelfname,$type,$shelfnumberP) = @_;
    my $sth=$dbh->prepare('select * from bookshelf where parent=? and shelfname=?');
    $sth->execute($shelfnumberP,$shelfname);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;

    if ($data) 
	{return (0) }
    else {	 	
   my $sth2=$dbh->prepare('select  max(shelfnumber) as number from bookshelf');
    $sth2->execute;
    my $data   = $sth2->fetchrow;
    my $numbers = $data + 1;
    $sth2->finish;

   my  $sth3=$dbh->prepare("insert into bookshelf (shelfnumber,shelfname,type,parent) values (?,?,?,?)");
    $sth3->execute($numbers,$shelfname,$type,$shelfnumberP);
   $sth3->finish;

    return ($numbers);
    }}


sub existsShelf
{
 my ($shelfname,$shelfnumberP,) = @_;
    my $sth=$dbh->prepare("select * from bookshelf where shelfname=? and parent=?");
        $sth->execute($shelfname,$shelfnumberP);
    return($sth->rows);


}
=item RemoveShelf

  ($status, $msg) = &RemoveShelf($env, $shelfnumber);

Deletes virtual bookshelf number C<$shelfnumber>. The bookshelf must
be empty.

Returns a two-element array, where C<$status> is 0 if the operation
was successful, or non-zero otherwise. C<$msg> is "Done" in case of
success, or an error message giving the reason for failure.

C<$env> is ignored.

=cut
#'
sub RemoveShelf {
    my ($shelfnumber) = @_;
    my $sth=$dbh->prepare("select count(*) from shelfcontents where shelfnumber=?");
    $sth->execute($shelfnumber);
    my $count=$sth->fetchrow;

    my $sth1=$dbh->prepare("select count(*) from bookshelf where parent=?");
    $sth1->execute($shelfnumber);
    my $count1=$sth1->fetchrow;

    if (($count gt 0) || ($count1 gt 0)) {
        $sth->finish;
        $sth1->finish;
	return ("El estante contiene grupos o subestantes relacionados. Por favor eliminelos y despues borre el estante.");
    } else {
	$sth=$dbh->prepare("delete from bookshelf where shelfnumber=?");
	$sth->execute($shelfnumber);
        $sth->finish;
        $sth1->finish;
	return (0);
    }
}

=item
sub privateShelfs {
    my ($bor,$num,$start) = @_;	
    my $count=0;
    my $sth2=$dbh->prepare("SELECT  count(*)  FROM  bookshelf  INNER  JOIN shelfcontents ON                             
                                bookshelf.shelfnumber = shelfcontents.shelfnumber   WHERE bookshelf.shelfname = $bor 
                           and bookshelf.type='private';");
	 $sth2->execute();
	my $total= $sth2->fetchrow;

    my $fin=$start+$num;
    my @results;
    my $sth=$dbh->prepare("SELECT  biblio.*  FROM  (bookshelf  INNER  JOIN shelfcontents ON				
				bookshelf.shelfnumber = shelfcontents.shelfnumber) INNER JOIN biblio ON 
				biblio.biblionumber=shelfcontents.biblioitemnumber  WHERE bookshelf.shelfname = $bor 
			   AND bookshelf.type='private' limit $start ,$fin ;");
        $sth->execute();
 
       while (my $data=$sth->fetchrow_hashref) {

#----			
			my $author=&C4::Search::getautor($data->{'author'}); #Damian. Para mostrar 
        		$data->{'completo'} = $author->{'completo'}; #el nombre del autor y no el id.
			$data->{'nombre'} = $author->{'nombre'};
			$data->{'apellido'} = $author->{'apellido'};

                        ($data->{'total'},$data->{'unavailable'},$data->{'counts'}) = &C4::Search::itemcount3($data->{'biblionumber'}, 'opac');
                        my $subject2=$data->{'subject'};
                        $subject2=~ s/ /%20/g;

                        ($data->{'grupos'})=&C4::Search::Grupos( $data->{'biblionumber'},'opac');
			 push(@results,$data);
                         $count++;
     			}
#----
	$sth->finish;
        return($total,@results);
	}
=cut

sub privateShelfs {
 	my ($bor) = @_;
	my $count= 0;
	my $query = " 	SELECT id2 FROM  bookshelf  INNER  JOIN shelfcontents 
			ON (bookshelf.shelfnumber = shelfcontents.shelfnumber)
			WHERE bookshelf.shelfname = ?
			AND bookshelf.type='private'  ";

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare($query);
	$sth->execute($bor);
	my @resultsId1=();

	while(my $data=$sth->fetchrow_hashref){
		push(@resultsId1, $data->{'id2'});
		$count++;
	}

	$sth->finish;
	return ($count, \@resultsId1);
}

sub createPrivateShelf {
    my ($bor) = @_;

    my $sth=$dbh->prepare('select  max(shelfnumber) as number from bookshelf');
    $sth->execute;
    my $data   = $sth->fetchrow;
    my $numbers = $data + 1;
	$sth->finish;

    my $sth2=$dbh->prepare("Insert into bookshelf values ($numbers ,$bor,'private',0);");
        $sth2->execute();
    $sth2->finish;
  return($numbers);      
  }

sub gotShelf {
    my ($bor) = @_;
    my $sth=$dbh->prepare("select shelfnumber  from bookshelf where type='private' and shelfname= $bor  ");
    $sth->execute;
    my $res=$sth->fetchrow;
    $sth->finish;
 if ($res) {return ($res);}else{return 0;}
     
	}

sub addPrivateShelfs {
    my ($shelf, $id2) = @_;
    my $sth1=$dbh->prepare("select  count(*)  from shelfcontents where shelfnumber=? and id2 = ? ");
    $sth1->execute($shelf, $id2);
   if ($sth1->fetchrow eq 0){
    my $sth2=$dbh->prepare("insert into shelfcontents values (?,?,0) ");
    $sth2->execute($shelf,$id2);
    $sth2->finish;
	}
    $sth1->finish;
        }

sub delPrivateShelfs {
   my ($shelf, $id2) = @_;
    my $sth=$dbh->prepare("delete from shelfcontents where shelfnumber=? and id2= ? ");
    $sth->execute($shelf,$id2);
    $sth->finish;
	}

sub shelfitemcount{
 my ($shelf) = @_;

  my $dbh = C4::Context->dbh;

  #Cantidad de ejemplares
  my $query2="select nivel3.wthdrawn, nivel3.notforloan from nivel3 inner join shelfcontents on nivel3.id2  = shelfcontents.id WHERE  shelfcontents.shelfnumber = ?";
 
 my $sth=$dbh->prepare($query2);
    $sth->execute($shelf);
	
  my $data;
  my $ejemplares=0;
  my $unavailable=0;
  my $forloan=0;
  my $notforloan=0;
  while ($data=$sth->fetchrow_hashref) {
        if ($data->{'wthdrawn'} >0){$unavailable++;}
	else{if ($data->{'notforloan'}){$notforloan++;}else{$forloan++;}}
        $ejemplares++;}


  my $query3="SELECT count( DISTINCT nivel2.id1 )
		FROM nivel2
		INNER JOIN shelfcontents ON nivel2.id2 = shelfcontents.id
		WHERE shelfcontents.shelfnumber = ?";
 my $sth3=$dbh->prepare($query3);
    $sth3->execute($shelf);
 my $titulos=$sth3->fetchrow;

  return ($titulos,$ejemplares,$unavailable,$forloan,$notforloan);

}

sub modshelf {
   my ($shelfnumber, $shelfname) = @_;
       my $sth=$dbh->prepare("update  bookshelf set shelfname=? where shelfnumber=? ");
       $sth->execute($shelfname,$shelfnumber);
	$sth->finish;
	               }
		       

END { }       # module clean-up code here (global destructor)

1;

#
# $Log: BookShelves.pm,v $
# Revision 1.11.2.2  2004/02/19 10:15:41  tipaul
# new feature : adding book to bookshelf from biblio detail screen.
#
# Revision 1.11.2.1  2004/02/06 14:16:55  tipaul
# fixing bugs in bookshelves management.
#
# Revision 1.11  2003/12/15 10:57:08  slef
# DBI call fix for bug 662
#
# Revision 1.10  2003/02/05 10:05:02  acli
# Converted a few SQL statements to use ? to fix a few strange SQL errors
# Noted correct tab size
#
# Revision 1.9  2002/10/13 08:29:18  arensb
# Deleted unused variables.
# Removed trailing whitespace.
#
# Revision 1.8  2002/10/10 04:32:44  arensb
# Simplified references.
#
# Revision 1.7  2002/10/05 09:50:10  arensb
# Merged with arensb-context branch: use C4::Context->dbh instead of
# &C4Connect, and generally prefer C4::Context over C4::Database.
#
# Revision 1.6.2.1  2002/10/04 02:24:43  arensb
# Use C4::Connect instead of C4::Database, C4::Connect->dbh instead
# C4Connect.
#
# Revision 1.6  2002/09/23 13:50:30  arensb
# Fixed missing bit in POD.
#
# Revision 1.5  2002/09/22 17:29:17  arensb
# Added POD.
# Added some FIXME comments.
# Removed useless trailing whitespace.
#
# Revision 1.4  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.3  2002/07/02 17:48:06  tonnesen
# Merged in updates from rel-1-2
#
# Revision 1.2.2.1  2002/06/26 20:46:48  tonnesen
# Inserting some changes I made locally a while ago.
#
#

__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
