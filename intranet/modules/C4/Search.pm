package C4::Search;

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
use C4::Context;

#use C4::Reserves2;

	# FIXME - C4::Search uses C4::Reserves2, which uses C4::Search.
	# So Perl complains that all of the functions here get redefined.

use C4::AR::DictionarySearch; #Luciano: Busqueda por diccionario
use C4::AR::Reserves; 
use C4::AR::Issues;
use C4::AR::VirtualLibrary; #Matias: Bilbioteca Virtual
use C4::AR::AnalysisBiblio; #Matias: Analiticas
use Date::Manip;
use C4::Date;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.02;

=head1 NAME

C4::Search - Functions for searching the Koha catalog and other databases

=head1 SYNOPSIS

  use C4::Search;

  my ($count, @results) = catalogsearch($env, $type, $search, $num, $offset);

=head1 DESCRIPTION

This module provides the searching facilities for the Koha catalog and
other databases.

C<&catalogsearch> is a front end to all the other searches. Depending
on what is passed to it, it calls the appropriate search function.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
	&buscarCiudades2
	&getmaxissues
	&getmaxrenewals
	&newsearch
	&CatSearch
	&BornameSearch 
	&ItemInfo 
	&KeywordSearch 
	&subsearch
	&itemdata 
	&itemdata2
	&bibdata 
	&GetItems 
	&borrdata 
	&itemnodata 
	&itemcount
	&borrdata2 
	&NewBorrowerNumber 
	&bibitemdata 
	&borrissues
	&getboracctrecord 
	&ItemType 
	&itemissues 
	&subject 
	&subtitle
	&addauthor 
	&bibitems 
	&bibitems2 
	&barcodes 
	&findguarantees 
	&allissues
	&findguarantor 
	&getwebsites 
	&getwebbiblioitems 
	&catalogsearch 
	&itemcount2
	&itemcount3
	&itemcountbibitem
	&isbnsearch
	&isbnsearch2
 	&breedingsearch 
	&getallthemes 
	&getalllanguages 
	&getbranchname 
	&getborrowercategory 
	&infoitem 
	&itemsfrombiblioitem 
	&allitems 
	&allbibitems 
	&countitems  
	&groupinfo  
	&FindItemType 
	&FindVol
	&publisherList
	&isbnList

	&canDeleteBiblio
	&canDeleteBiblioitem
	&canDeleteItem
	&haveReserves
	&mailissues
	&mailreservas
	&firstbulk
	&editorsname

	&PersonNameSearch
	&persdata
	&getcitycategory 
	&isRegular
	&itemcountPorGrupos
	&Grupos
	&generarEstadoDeColeccion

	&mostrarProvincias	&darProvincia
	&mostrarCiudades	&darCiudad
	&mostrarDepartamentos	&darDepartamento
	&mostrarPaises		&darPais
	
	
	&getautor &getautoresAdicionales &getColaboradores
	
	&buscarCiudades
	&buscarCiudadesMasUsadas
        &getCountry
        &getSupport
        &getLanguage
	&getLevel
	
	&getAvail
	&getavails
	&availDetail
	&getavailsplus
	&availArray
	&bibitnfloan
	&bibavail

	&SearchSig
);
# make all your functions, whether exported or not;


=item newsearch
	my (@results) = newsearch($itemtype,$duration,$number_of_results,$startfrom);
c<newsearch> find biblio acquired recently (last 30 days)
=cut
sub newsearch {
	my ($itemtype,$duration,$num,$offset)=@_;

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT to_days( now( ) ) - to_days( dateaccessioned ) AS duration,  biblio.biblionumber, barcode, title, author, number AS editors, classification, itemtype, dewey, dateaccessioned, price, replacementprice
						FROM  biblio INNER JOIN  biblioitems ON  biblio.biblionumber = biblioitems.biblionumber 
						INNER JOIN items ON items.biblioitemnumber = biblioitems.biblioitemnumber 
					WHERE	to_days( now( ) ) - to_days( dateaccessioned ) < ? and itemtype=?
						ORDER BY duration ASC limit 0,20");
#Ahora limitamos a 20 pero habria que devolver los resultados paginandolios en ves de devolver solo los ultimos 20
	$sth->execute($duration,$itemtype);
	my $i=0;
	my @result;
	while (my $data = $sth->fetchrow_hashref) {
		if ($i>=$offset && $i<$num+$offset) {
			my ($counts) = itemcount2("", $data->{'biblionumber'}, 'intra');
			my $subject2=$data->{'subject'};
			$subject2=~ s/ /%20/g;
			$data->{'itemcount'}=$counts->{'total'};
			my $totalitemcounts=0;
			foreach my $key (keys %$counts){
				if ($key ne 'total'){	# FIXME - Should ignore 'order', too.
					#$data->{'location'}.="$key $counts->{$key} ";
					$totalitemcounts+=$counts->{$key};
					$data->{'locationhash'}->{$key}=$counts->{$key};
				}
			}
			my $locationtext='';
			my $locationtextonly='';
			my $notavailabletext='';
			foreach (sort keys %{$data->{'locationhash'}}) {
				if ($_ eq 'notavailable') {
					$notavailabletext="Not available";
					my $c=$data->{'locationhash'}->{$_};
					$data->{'not-available-p'}=$totalitemcounts;
					if ($totalitemcounts>1) {
					$notavailabletext.=" ($c)";
					$data->{'not-available-plural-p'}=1;
					}
				} else {
					$locationtext.="$_ ";
					my $c=$data->{'locationhash'}->{$_};
					if ($_ eq 'Perdidos') {
					$data->{'lost-p'}=$totalitemcounts;
					$data->{'lost-plural-p'}=1
							if $totalitemcounts > 1;
					} elsif ($_ eq 'Retirados') {
					$data->{'withdrawn-p'}=$totalitemcounts;
					$data->{'withdrawn-plural-p'}=1
							if $totalitemcounts > 1;
					} elsif ($_ eq 'Prestados') {
					$data->{'on-loan-p'}=$totalitemcounts;
					$data->{'on-loan-plural-p'}=1
							if $totalitemcounts > 1;
					} else {
					$locationtextonly.=$_;
					$locationtextonly.=" ($c), "
							if $totalitemcounts>1;
					}
					if ($totalitemcounts>1) {
					$locationtext.=" ($c), ";
					}
				}
			}
			if ($notavailabletext) {
				$locationtext.=$notavailabletext;
			} else {
				$locationtext=~s/, $//;
			}
			$data->{'location'}=$locationtext;
			$data->{'location-only'}=$locationtextonly;
			$data->{'subject2'}=$subject2;
			$data->{'use-location-flags-p'}=1; # XXX
			push @result,$data;
		}
		$i++
	}
	return($i,@result);

}

=item findguarantees

  ($num_children, $children_arrayref) = &findguarantees($parent_borrno);
  $child0_cardno = $children_arrayref->[0]{"cardnumber"};
  $child0_borrno = $children_arrayref->[0]{"borrowernumber"};

C<&findguarantees> takes a borrower number (e.g., that of a patron
with children) and looks up the borrowers who are guaranteed by that
borrower (i.e., the patron's children).

C<&findguarantees> returns two values: an integer giving the number of
borrowers guaranteed by C<$parent_borrno>, and a reference to an array
of references to hash, which gives the actual results.

=cut
#'
sub findguarantees{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select cardnumber,borrowernumber, firstname, surname from borrowers where guarantor=?");
  $sth->execute($bornum);

  my @dat;
  while (my $data = $sth->fetchrow_hashref)
  {
    push @dat, $data;
  }
  $sth->finish;
  return (scalar(@dat), \@dat);
}

=item findguarantor

  $guarantor = &findguarantor($borrower_no);
  $guarantor_cardno = $guarantor->{"cardnumber"};
  $guarantor_surname = $guarantor->{"surname"};
  ...

C<&findguarantor> takes a borrower number (presumably that of a child
patron), finds the guarantor for C<$borrower_no> (the child's parent),
and returns the record for the guarantor.

C<&findguarantor> returns a reference-to-hash. Its keys are the fields
from the C<borrowers> database table;

=cut
#'
sub findguarantor{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select guarantor from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($data->{'guarantor'});
  $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item NewBorrowerNumber

  $num = &NewBorrowerNumber();

Allocates a new, unused borrower number, and returns it.

=cut
#'
# FIXME - This is identical to C4::Circulation::Borrower::NewBorrowerNumber.
# Pick one and stick with it. Preferably use the other one. This function
# doesn't belong in C4::Search.
sub NewBorrowerNumber {
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $data->{'max(borrowernumber)'}++;
  return($data->{'max(borrowernumber)'});
}

=item catalogsearch

  ($count, @results) = &catalogsearch($env, $type, $search, $num, $offset);

This is primarily a front-end to other, more specialized catalog
search functions: if C<$search-E<gt>{itemnumber}> or
C<$search-E<gt>{isbn}> is given, C<&catalogsearch> uses a precise
C<&CatSearch>. If $search->{subject} is given, it runs a subject
C<&CatSearch>. If C<$search-E<gt>{keyword}> is given, it runs a
C<&KeywordSearch>. Otherwise, it runs a loose C<&CatSearch>.

If C<$env-E<gt>{itemcount}> is 1, then C<&catalogsearch> also counts
the items for each result, and adds several keys:

=over 4

=item C<itemcount>

The total number of copies of this book.

=item C<locationhash>

This is a reference-to-hash; the keys are the names of branches where
this book may be found, and the values are the number of copies at
that branch.

=item C<location>

A descriptive string saying where the book is located, and how many
copies there are, if greater than 1.

=item C<subject2>

The book's subject, with spaces replaced with C<%20>, presumably for
HTML.

=back

=cut
#'
sub catalogsearch {


	my ($env,$type,$search,$num,$offset,$orden)=@_;
	my $dbh = C4::Context->dbh;
	#  foreach my $key (%$search){
	#    $search->{$key}=$dbh->quote($search->{$key});
	#  }
	my ($count,@results);

	#  print STDERR "Doing a search \n";
	if ($search->{'itemnumber'} || $search->{'isbn'} || $search->{'authorid'}){
	#	print STDERR "Haciendo una b&uacute;squeda precisa\n";
		($count,@results)=CatSearch($env,'precise',$search,$num,$offset,$orden,$type);
	} elsif ($search->{'subject'}){
		($count,@results)=CatSearch($env,'subject',$search,$num,$offset,$orden,$type);
	} elsif ($search->{'keyword'}){
		($count,@results)=&KeywordSearch($env,'keyword',$search,$num,$offset,$orden,$type);
	}elsif ($search->{'subjectitems'}){
                ($count,@results)=CatSearch($env,'subjectitems',$search,$num,$offset,$orden,$type);
	}elsif ($search->{'class'}){
		($count,@results)=CatSearch($env,'loose',$search,$num,$offset,$orden,$type);

        }elsif ($search->{'analytical'}){
	                ($count,@results)=BiblioAnalysisSearch($search->{'analytical'});
#Matias: Signatura Topografica
	}elsif ($search->{'signature'}){
	#($count,@results)=SearchSig($search->{'signature'});	
	 ($count,@results)=&DictionarySignatureSearch($env,$type,$search,$num,$offset);
	  return ($count,@results);
			 
#Matias: Biblioteca Virtual
	}elsif ($search->{'virtual'}){
                ($count,@results)=&VirtualKeywordSearch($env,'keyword',$search,$num,$offset);
#
#Luciano: Busqueda por diccionario
	}elsif ($search->{'dictionary'}){
                ($count,@results)=&DictionaryKeywordSearch($env,$type,$search,$num,$offset);
		return ($count,@results);
#
	} else {
		($count,@results)=CatSearch($env,'loose',$search,$num,$offset,$orden,$type);
	}

	if ($env->{itemcount} eq '1') {
			#Ocultar resultados en el opac de libros no disponibles

		foreach my $data (@results){

			($data->{'total'},$data->{'unavailable'},$data->{'counts'}) = itemcount3($data->{'biblionumber'}, $type);
			my $subject2=$data->{'subject'};
			$subject2=~ s/ /%20/g;
			($data->{'itemtype'},$data->{'description'},$data->{'search'})=FindItemType($data->{'biblioitemnumber'});
			if ($data->{'itemtype'} eq 'REV'){
			$data->{'revista'}=1;
			$data->{'descriptor'}= generarEstadoDeColeccion($data->{'biblionumber'});
			}
			else {($data->{'grupos'})=Grupos($data->{'biblionumber'},$type);}
		}
	}

	return ($count,@results);
}

=item KeywordSearch

  $search = { "keyword"	=> "One or more keywords",
	      "class"	=> "VID|CD",	# Limit search to fiction and CDs
	      "dewey"	=> "813",
	 };
  ($count, @results) = &KeywordSearch($env, $type, $search, $num, $offset);

C<&KeywordSearch> searches the catalog by keyword: given a string
(C<$search-E<gt>{"keyword"}> consisting of a space-separated list of
keywords, it looks for books that contain any of those keywords in any
of a number of places.

C<&KeywordSearch> looks for keywords in the book title (and subtitle),
series name, notes (both C<biblio.notes> and C<biblioitems.notes>),
and subjects.

C<$search-E<gt>{"class"}> can be set to a C<|> (pipe)-separated list of
item class codes (e.g., "F" for fiction, "JNF" for junior nonfiction,
etc.). In this case, the search will be restricted to just those
classes.

If C<$search-E<gt>{"class"}> is not specified, you may specify
C<$search-E<gt>{"dewey"}>. This will restrict the search to that
particular Dewey Decimal Classification category. Setting
C<$search-E<gt>{"dewey"}> to "513" will return books about arithmetic,
whereas setting it to "5" will return all books with Dewey code 5I<xx>
(Science and Mathematics).

C<$env> and C<$type> are ignored.

C<$offset> and C<$num> specify the subset of results to return.
C<$num> specifies the number of results to return, and C<$offset> is
the number of the first result. Thus, setting C<$offset> to 100 and
C<$num> to 5 will return results 100 through 104 inclusive.

=cut
#'
sub KeywordSearch {
  my ($env,$type,$search,$num,$offset,$orden,$from)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'keyword'}=~ s/ +$//;
  my @key=split(' ',$search->{'keyword'});
		# FIXME - Naive users might enter comma-separated
		# words, e.g., "training, animal". Ought to cope with
		# this.
  my $count=@key;
  my $i=1;
  my %biblionumbers;		# Set of biblionumbers returned by the
				# various searches.
  
  
  # FIXME - Ought to filter the stopwords out of the list of keywords.
  #	@key = map { !defined($stopwords{$_}) } @key;

  # FIXME - The way this code is currently set up, it looks for all of
  # the keywords first in (title, notes, seriestitle), then in the
  # subtitle, then in the subject. Thus, if you look for keywords
  # "science fiction", this search won't find a book with
  #	title    = "How to write fiction"
  #	subtitle = "A science-based approach"
  # Is this the desired effect? If not, then the first SQL query
  # should look in the biblio, subtitle, and subject tables all at
  # once. The way the first query is built can accomodate this easily.

  # Look for keywords in table 'biblio'.

  # Build an SQL query that finds each of the keywords in any of the
  # title, biblio.notes, or seriestitle. To do this, we'll build up an
  # array of clauses, one for each keyword.
  my $query;			# The SQL query
  my @clauses = ();		# The search clauses
  my @bind = ();		# The term bindings
#Tiempo
#use Time::HiRes qw(gettimeofday);
#open (L,">>/tmp/tiempo");
#my ($epoch, $usecs) = gettimeofday;
#my ($second, $minute, $hour) = localtime $epoch;
#printf L "antes de buscar %02d:%02d:%02d.%06d\n", $hour, $minute, $second, $usecs;

  $query = <<EOT;		# Beginning of the query
	SELECT	biblionumber
	FROM	biblio LEFT JOIN autores on  autores.id=biblio.author
	WHERE
EOT

  foreach my $keyword (@key)
  {
    my @subclauses = ();	# Subclauses, one for each field we're
				# searching on

    # For each field we're searching on, create a subclause that'll
    # match the current keyword in the current field.
    foreach my $field (qw(title notes seriestitle autores.completo))
    {
      push @subclauses,
	"$field LIKE ? OR $field LIKE ?";
	  push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
    }
    # (Yes, this could have been done as
    #	@subclauses = map {...} qw(field1 field2 ...)
    # )but I think this way is more readable.

    # Construct the current clause by joining the subclauses.
    push @clauses, "(" . join(")\n\tOR (", @subclauses) . ")";
  }
  # Now join all of the clauses together and append to the query.
  $query .= "(" . join(")\nAND (", @clauses) . ")";

  # FIXME - Perhaps use $sth->bind_columns() ? Documented as the most
  # efficient way to fetch data.
  my $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  # Now look for keywords in the 'bibliosubtitle' table.

  # Again, we build a list of clauses from the keywords.

  @clauses = ();
  @bind = ();
  $query = "SELECT biblionumber FROM bibliosubtitle WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
	"subtitle LIKE ? OR subtitle like ?";
	push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";

  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  # Look for the keywords in the notes for individual items
  # ('biblioitems.notes')

  # Again, we build a list of clauses from the keywords.
  @clauses = ();
  @bind = ();
  $query = "SELECT biblionumber FROM biblioitems WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
	"notes LIKE ? OR notes like ?";
	push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";

  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  # Look for keywords in the 'bibliosubject' table.

  # FIXME - The other queries look for words in the desired field that
  # begin with the individual keywords the user entered. This one
  # searches for the literal string the user entered. Is this the
  # desired effect?
  # Note in particular that spaces are retained: if the user typed
  #	science  fiction
  # (with two spaces), this won't find the subject "science fiction"
  # (one space). Likewise, a search for "%" will return absolutely
  # everything.
  # If this isn't the desired effect, see the previous searches for
  # how to do it.


  # Again, we build a list of clauses from the keywords.
  @clauses = ();
  @bind = ();
  $query = "Select biblionumber from bibliosubject where ";
  foreach my $keyword (@key)
  {
    push @clauses,
        " subject LIKE ? OR subject like ? ";
        push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";
  $query .= " group by biblionumber";
  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;
#Primero tengo que obtener los autores
  # Busqueda por autores adicionales.
  @clauses = ();
  @bind = ();
  $query="SELECT biblio.biblionumber
  	FROM autores
	inner join colaboradores on autores.id=colaboradores.idColaborador
	inner join biblio on colaboradores.biblionumber=biblio.biblionumber
	where	";
			
  foreach my $keyword (@key)
  {
    push @clauses,
        " autores.completo  LIKE ? OR autores.completo  like ? ";
        push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";
  $query .= " group by biblionumber";
  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;


#Ahora Colaboradores


  @clauses = ();
  @bind = ();
  $query= "SELECT biblio.biblionumber FROM 
  	   autores inner join additionalauthors  on autores.id=additionalauthors.author
	   inner join biblio on additionalauthors.biblionumber=biblio.biblionumber
	   where	";
			
  foreach my $keyword (@key)
  {
    push @clauses,
        " autores.completo  LIKE ? OR autores.completo  like ? ";
        push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";
  $query .= " group by biblionumber";
  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;

#Ahora Autores


  @clauses = ();
  @bind = ();
  $query= "SELECT biblio.biblionumber FROM 
  	   autores inner join biblio on autores.id=biblio.author
	   where	";
			
  foreach my $keyword (@key)
  {
    push @clauses,
        " autores.completo  LIKE ? OR autores.completo  like ? ";
        push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";
  $query .= " group by biblionumber";
  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;


=cut
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like ? group by biblionumber");
  $sth->execute("%$search->{'keyword'}%");

  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;
=cut
  my $i2=0;
  my $i3=0;
  my $i4=0;

  my @res2;
  my @res = keys %biblionumbers;
  $count=@res;

#Tiempo
#my ($epoch, $usecs) = gettimeofday;
#my ($second, $minute, $hour) = localtime $epoch;
#printf L "luego de buscar y antes de ordenar%02d:%02d:%02d.%06d\n", $hour, $minute, $second, $usecs;



############### Matias: Le doy el orden
my $j=0;
my $list='';
 my $query="select biblionumber from biblio where biblionumber IN (  ";
while ($j < $count){$query .= "'".$res[$j]."'";
if ($j+1 < $count){$query .=", ";}
$j++;
 }
$query .= " ) order by $orden ";
  my $sth=$dbh->prepare($query);
       $sth->execute();
  my @res; 

$count=0;  
while (my $data = $sth->fetchrow_hashref) {

	if (($from ne 'opac')||( bibavail($data->{'biblionumber'}) eq 1)||(C4::Context->preference("opacUnavail") eq 1)){ #Si viene de opac y no esta disponible no lo proceso	 
	     push(@res,$data->{'biblionumber'});
	     $count++;
	}	
	}

#Tiempo
#my ($epoch, $usecs) = gettimeofday;
#my ($second, $minute, $hour) = localtime $epoch;
#printf L "despues de ordenar %02d:%02d:%02d.%06d\n", $hour, $minute, $second, $usecs;
#close L;

###############

  $i=0;
  if ($search->{'class'}){
    while ($i2 <$count){

      my $query="select * from biblio left join  biblioitems on biblio.biblionumber=biblioitems.biblionumber  where
    biblio.biblionumber=?";
      my @bind = ($res[$i2]);
      if ($search->{'class'}){	# FIXME - Redundant
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= "and ( itemtype=?";
      push(@bind,$temp[0]);
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype=?";
        push(@bind,$temp[$i]);
      }
      $query.=")";
      }
       my $sth=$dbh->prepare($query);
       $sth->execute(@bind);
       if (my $data2=$sth->fetchrow_hashref){
         my $dewey= $data2->{'dewey'};
         my $subclass=$data2->{'subclass'};
         # FIXME - This next bit is bogus, because it assumes that the
         # Dewey code is a floating-point number. It isn't. It's
         # actually a string that mainly consists of numbers. In
         # particular, "4" is not a valid Dewey code, although "004"
         # is ("Data processing; Computer science"). Likewise, zeros
         # after the decimal are significant ("575" is not the same as
         # "575.0"; the latter is more specific). And "000" is a
         # perfectly good Dewey code ("General works; computer
         # science") and should not be interpreted to mean "this
         # database entry does not have a Dewey code". That's what
         # NULL is for.
         $dewey=~s/\.*0*$//;
         ($dewey == 0) && ($dewey='');
         ($dewey) && ($dewey.=" $subclass") ;
          $sth->finish;
	  my $end=$offset +$num;
	  if ($i4 <= $offset){
	    $i4++;
	  }
	  if ($i4 <=$end && $i4 > $offset){
	    $data2->{'dewey'}=$dewey;
	    $res2[$i3]=$data2;

            $i3++;
            $i4++;
	  } else {
#	    print $end;
	  }
	  $i++;
        }


     $i2++;
     } # while
     $count=$i;

   } else {
  # $search->{'class'} was not specified

  # FIXME - This is bogus: it makes a separate query for each
  # biblioitem, and returns results in apparently random order. It'd
  # be much better to combine all of the previous queries into one big
  # one (building it up a little at a time, of course), and have that
  # big query select all of the desired fields, instead of just
  # 'biblionumber'.

  while ($i2 < $num && $i2 < $count){
    my $query="select biblio.*, biblioitems.biblioitemnumber, volume, number, classification, itemtype, isbn, issn, dewey, subclass, publicationyear, publishercode, volumedate, volumeddesc, biblioitems.timestamp, illus, pages, biblioitems.notes, size, place, url, lccn, marc 
    from biblio left join  biblioitems on biblio.biblionumber=biblioitems.biblionumber  where
    biblio.biblionumber=? ";
    my @bind=($res[$i2+$offset]);

    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like ?)";
      push(@bind,"$search->{'dewey'}%");
    }

    my $sth=$dbh->prepare($query);


#    print $query;
    $sth->execute(@bind);
    if (my $data2=$sth->fetchrow_hashref){
        my $dewey= $data2->{'dewey'};
        my $subclass=$data2->{'subclass'};
	$dewey=~s/\.*0*$//;
        ($dewey == 0) && ($dewey='');
        ($dewey) && ($dewey.=" $subclass");
        $sth->finish;
	$data2->{'dewey'}=$dewey;

	$res2[$i]=$data2;
# $res2[$i]->{'biblionumber'}= $data2->{'biblionumber'};
#	$res2[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
        $i++;
    }

    $i2++;

  } #while
  } #else


 #Hay que agregar las analiticas
 my ($countanaliticas,@analiticas)= BiblioAnalysisSearch($search->{'keyword'});
 my $end=$offset +$num +1;

foreach my $aux (@analiticas) {
if (($count >= $offset) and ($count <= ($end))){
push(@res2,$aux);
	}
		$count++;
}				  
 ####Fin anliticas
close L;
return($count,@res2);
}

sub KeywordSearch2 {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'keyword'}=~ s/ +$//;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio,bibliosubtitle,biblioitems where
  biblio.biblionumber=biblioitems.biblionumber and
  biblio.biblionumber=bibliosubtitle.biblionumber and
  (((title like ? or title like ?)";
  my @bind=("$key[0]%","% $key[0]%");
  while ($i < $count){
    $query .= " and (title like ? or title like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
    $i++;
  }
  $query.= ") or ((subtitle like ? or subtitle like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.= " and (subtitle like ? or subtitle like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  $query.= ") or ((seriestitle like ? or seriestitle like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.=" and (seriestitle like ? or seriestitle like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  $query.= ") or ((biblio.notes like ? or biblio.notes like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblio.notes like ? or biblio.notes like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  $query.= ") or ((biblioitems.notes like ? or biblioitems.notes like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblioitems.notes like ? or biblioitems.notes like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  if ($search->{'keyword'} =~ /new zealand/i){
    $query.= "or (title like 'nz%' or title like '% nz %' or title like '% nz' or subtitle like 'nz%'
    or subtitle like '% nz %' or subtitle like '% nz' or author like 'nz %'
    or author like '% nz %' or author like '% nz')"
  }
  if ($search->{'keyword'} eq  'nz' || $search->{'keyword'} eq 'NZ' ||
  $search->{'keyword'} =~ /nz /i || $search->{'keyword'} =~ / nz /i ||
  $search->{'keyword'} =~ / nz/i){
    $query.= "or (title like 'new zealand%' or title like '% new zealand %'
    or title like '% new zealand' or subtitle like 'new zealand%' or
    subtitle like '% new zealand %'
    or subtitle like '% new zealand' or author like 'new zealand%'
    or author like '% new zealand %' or author like '% new zealand' or
    seriestitle like 'new zealand%' or seriestitle like '% new zealand %'
    or seriestitle like '% new zealand')"
  }
  $query .= "))";
  if ($search->{'class'} ne ''){
    my @temp=split(/\|/,$search->{'class'});
    my $count=@temp;
    $query.= "and ( itemtype=?";
    push(@bind,"$temp[0]");
    for (my $i=1;$i<$count;$i++){
      $query.=" or itemtype=?";
      push(@bind,"$temp[$i]");
     }
  $query.=")";
  }
  if ($search->{'dewey'} ne ''){
    $query.= "and (dewey like '$search->{'dewey'}%') ";
  }
   $query.="group by biblio.biblionumber";
   #$query.=" order by author,title";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
#FIXME: rewrite to use ? before uncomment
#    my $sti=$dbh->prepare("select dewey,subclass from biblioitems where biblionumber=$data->{'biblionumber'}
#    ");
#    $sti->execute;
#    my ($dewey, $subclass) = $sti->fetchrow;
    my $dewey=$data->{'dewey'};
    my $subclass=$data->{'subclass'};
    $dewey=~s/\.*0*$//;
    ($dewey == 0) && ($dewey='');
    ($dewey) && ($dewey.=" $subclass");
#    $sti->finish;
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey";
#      print $results[$i];
    $i++;
  }
  $sth->finish;
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like ? group by biblionumber");
  $sth->execute("%".$search->{'keyword'}."%");
  while (my $data=$sth->fetchrow_hashref){
    $query="Select * from biblio,biblioitems where
    biblio.biblionumber=? and
    biblio.biblionumber=biblioitems.biblionumber ";
    @bind=($data->{'biblionumber'});
    if ($search->{'class'} ne ''){
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= " and ( itemtype=?";
      push(@bind,$temp[0]);
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype=?";
        push(@bind,$temp[$i]);
      }
      $query.=")";

    }
    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like ?)";
      push(@bind,"$search->{'dewey'}%");
    }
    my $sth2=$dbh->prepare($query);
    $sth2->execute(@bind);
#    print $query;
    while (my $data2=$sth2->fetchrow_hashref){
      my $dewey= $data2->{'dewey'};
      my $subclass=$data2->{'subclass'};
      $dewey=~s/\.*0*$//;
      ($dewey == 0) && ($dewey='');
      ($dewey) && ($dewey.=" $subclass") ;
#      $sti->finish;
       $results[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
#      print $results[$i];
      $i++;
    }
    $sth2->finish;
  }
  my $i2=1;
  @results=sort @results;
  my @res;
  $count=@results;
  $i=1;
  if ($count > 0){
    $res[0]=$results[0];
  }
  while ($i2 < $count){
    if ($results[$i2] ne $res[$i-1]){
      $res[$i]=$results[$i2];
      $i++;
    }
    $i2++;
  }
  $i2=0;
  my @res2;
  $count=@res;
  while ($i2 < $num && $i2 < $count){
    $res2[$i2]=$res[$i2+$offset];
#    print $res2[$i2];
    $i2++;
  }
  $sth->finish;
#  $i--;
#  $i++;
  return($i,@res2);
}

=item CatSearch

  ($count, @results) = &CatSearch($env, $type, $search, $num, $offset);

C<&CatSearch> searches the Koha catalog. It returns a list whose first
element is the number of returned results, and whose subsequent
elements are the results themselves.

Each returned element is a reference-to-hash. Most of the keys are
simply the fields from the C<biblio> table in the Koha database, but
the following keys may also be present:

=over 4

=item C<illustrator>

The book's illustrator.

=item C<publisher>

The publisher.

=back

C<$env> is ignored.

C<$type> may be C<subject>, C<loose>, or C<precise>. This controls the
high-level behavior of C<&CatSearch>, as described below.

In many cases, the description below says that a certain field in the
database must match the search string. In these cases, it means that
the beginning of some word in the field must match the search string.
Thus, an author search for "sm" will return books whose author is
"John Smith" or "Mike Smalls", but not "Paul Grossman", since the "sm"
does not occur at the beginning of a word.

Note that within each search mode, the criteria are and-ed together.
That is, if you perform a loose search on the author "Jerome" and the
title "Boat", the search will only return books by Jerome containing
"Boat" in the title.

It is not possible to cross modes, e.g., set the author to "Asimov"
and the subject to "Math" in hopes of finding books on math by Asimov.

=head2 Loose search

If C<$type> is set to C<loose>, the following search criteria may be
used:

=over 4

=item C<$search-E<gt>{author}>

The search string is a space-separated list of words. Each word must
match either the C<author> or C<additionalauthors> field.

=item C<$search-E<gt>{title}>

Each word in the search string must match the book title. If no author
is specified, the book subtitle will also be searched.

=item C<$search-E<gt>{abstract}>

Searches for the given search string in the book's abstract.

=item C<$search-E<gt>{'date-before'}>

Searches for books whose copyright date matches the search string.
That is, setting C<$search-E<gt>{'date-before'}> to "1985" will find
books written in 1985, and setting it to "198" will find books written
between 1980 and 1989.

=item C<$search-E<gt>{title}>

Searches by title are also affected by the value of
C<$search-E<gt>{"ttype"}>; if it is set to C<exact>, then the book
title, (one of) the series titleZ<>(s), or (one of) the unititleZ<>(s) must
match the search string exactly (the subtitle is not searched).

If C<$search-E<gt>{"ttype"}> is set to anything other than C<exact>,
each word in the search string must match the title, subtitle,
unititle, or series title.

=item C<$search-E<gt>{class}>

Restricts the search to certain item classes. The value of
C<$search-E<gt>{"class"}> is a | (pipe)-separated list of item types.
Thus, setting it to "F" restricts the search to fiction, and setting
it to "CD|CAS" will only look in compact disks and cassettes.

=item C<$search-E<gt>{dewey}>

Searches for books whose Dewey Decimal Classification code matches the
search string. That is, setting C<$search-E<gt>{"dewey"}> to "5" will
search for all books in 5I<xx> (Science and mathematics), setting it
to "54" will search for all books in 54I<x> (Chemistry), and setting
it to "546" will search for books on inorganic chemistry.

=item C<$search-E<gt>{publisher}>

Searches for books whose publisher contains the search string (unlike
other search criteria, C<$search-E<gt>{publisher}> is a string, not a
set of words.

=back

=head2 Subject search

If C<$type> is set to C<subject>, the following search criterion may
be used:

=over 4

=item C<$search-E<gt>{subject}>

The search string is a space-separated list of words, each of which
must match the book's subject.

Special case: if C<$search-E<gt>{subject}> is set to C<nz>,
C<&CatSearch> will search for books whose subject is "New Zealand".
However, setting C<$search-E<gt>{subject}> to C<"nz football"> will
search for books on "nz" and "football", not books on "New Zealand"
and "football".

=back

=head2 Precise search

If C<$type> is set to C<precise>, the following search criteria may be
used:

=over 4

=item C<$search-E<gt>{item}>

Searches for books whose barcode exactly matches the search string.

=item C<$search-E<gt>{isbn}>

Searches for books whose ISBN exactly matches the search string.

=back

For a loose search, if an author was specified, the results are
ordered by author and title. If no author was specified, the results
are ordered by title.

For other (non-loose) searches, if a subject was specified, the
results are ordered alphabetically by subject.

In all other cases (e.g., loose search by keyword), the results are
not ordered.

=cut
#'
sub CatSearch  {
	my ($env,$type,$search,$num,$offset,$orden,$from)=@_;
	my $dbh = C4::Context->dbh;
	my $query = '';
	my @bind = ();
	my @results;
	my $searchAnaliticas=$search;
                         ##############################Matias(Materias)##################                                                                                                                             
                        if ($search->{'subjectitems'} ne ''){
                                                                                                                             
        $query="Select * from biblio inner join bibliosubject on
         biblio.biblionumber=bibliosubject.biblionumber where
          bibliosubject.subject= '".$search->{'subjectitems'}."'" ;

			}

                        #################################################################

	my $title = lc($search->{'title'});
	if ($type eq 'loose') {
	if ($search->{'author'} ne ''){
			my @key=split(' ',$search->{'author'});
			my $count=@key;
			my $i=1;
			$query="SELECT biblio.* , biblio.author as autorppal, biblio.biblionumber, biblioitems.biblioitemnumber, autores.completo as completo
			FROM biblio	
			left join biblioitems on biblioitems.biblionumber = biblio.biblionumber

			LEFT JOIN additionalauthors ON additionalauthors.biblionumber = biblio.biblionumber 
			LEFT JOIN colaboradores on colaboradores.biblionumber = biblio.biblionumber 
			LEFT JOIN autores on autores.id=additionalauthors.author
			or autores.id=biblio.author or autores.id=colaboradores.idColaborador 
							where
							((autores.completo like ? or autores.completo like ?
								)";
			@bind=("$key[0]%","% $key[0]%");
			while ($i < $count){
					$query .= " and (autores.completo like ? or autores.completo like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
				$i++;
					}
			$query .= ")";
			if ($search->{'title'} ne ''){
			
				if ($search->{'ttype'} eq 'exact'){ #EXACTA
					$query .="and (((biblio.title=? or biblio.unititle = ? or biblio.seriestitle = ?)";
					@bind=($search->{'title'},$search->{'title'},$search->{'title'});
						} else { #NORMAL
			
				my @key=split(' ',$search->{'title'});
				my $count=@key;
				my $i=0;
				$query.= " and (((title like ? or title like ?)";
				push(@bind,"$key[0]%","% $key[0]%");
				while ($i<$count){
					$query .= " and (title like ? or title like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
					$i++;
						}
				$query.=") or ((biblio.seriestitle like ? or biblio.seriestitle like ?)";
				push(@bind,"$key[0]%","% $key[0]%");
				for ($i=1;$i<$count;$i++){
					$query.=" and (biblio.seriestitle like ? or biblio.seriestitle like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
							}
				$query.=") or ((unititle like ? or unititle like ?)";
				push(@bind,"$key[0]%","% $key[0]%");
				for ($i=1;$i<$count;$i++){
					$query.=" and (unititle like ? or unititle like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
							}
				$query .= "))";
						
				}
				}
						
			if ($search->{'abstract'} ne ''){
				$query.= " and (abstract like ?)";
				push(@bind,"%$search->{'abstract'}%");
							}
			if ($search->{'date-before'} ne ''){
				$query.= " and (copyrightdate like ?)";
				push(@bind,"%$search->{'date-before'}%");
							 }
			$query.=" group by biblio.biblionumber";
			} else {
			if ($search->{'title'} ne '') {
				if ($search->{'ttype'} eq 'exact'){
					$query="select * from biblio
					where
					(biblio.title=? or biblio.unititle = ? or biblio.seriestitle = ? )";
					@bind=($search->{'title'},$search->{'title'},$search->{'title'});
						} else {
					my @key=split(' ',$search->{'title'});
					my $count=@key;
					my $i=1;
					$query="select biblio.biblionumber,author ,title,unititle,biblio.notes,abstract,serial,biblio.seriestitle,copyrightdate,biblio.timestamp,subtitle, biblioitems.biblioitemnumber  from biblio
					inner join biblioitems on biblioitems.biblionumber = biblio.biblionumber
					left join bibliosubtitle on
					biblio.biblionumber=bibliosubtitle.biblionumber
					where
					(((title like ? or title like ?)";
					@bind=("$key[0]%","% $key[0]%");
					while ($i<$count){
						$query .= " and (title like ? or title like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
						$i++;
							}
					$query.=") or ((subtitle like ? or subtitle like ?)";
					push(@bind,"$key[0]%","% $key[0]%");
					for ($i=1;$i<$count;$i++){
						$query.=" and (subtitle like ? or subtitle like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
								}
					$query.=") or ((biblio.seriestitle like ? or biblio.seriestitle like ?)";
					push(@bind,"$key[0]%","% $key[0]%");
					for ($i=1;$i<$count;$i++){
						$query.=" and (biblio.seriestitle like ? or biblio.seriestitle like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
								}
					$query.=") or ((unititle like ? or unititle like ?)";
					push(@bind,"$key[0]%","% $key[0]%");
					for ($i=1;$i<$count;$i++){
						$query.=" and (unititle like ? or unititle like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
								}
					
					$query .= "))";
							}
				if ($search->{'abstract'} ne ''){
					$query.= " and (abstract like ?)";
					push(@bind,"%$search->{'abstract'}%");
								}
				if ($search->{'date-before'} ne ''){
					$query.= " and (copyrightdate like ?)";
					push(@bind,"%$search->{'date-before'}%");
								}
			} elsif ($search->{'class'} ne ''){
				$query="select * from biblio left join biblioitems on biblio.biblionumber=biblioitems.biblionumber";
				my @temp=split(/\|/,$search->{'class'});
				my $count=@temp;
				$query.= " where ( itemtype=? ";
				@bind=($temp[0]);
				for (my $i=1;$i<$count;$i++){
					$query.=" or itemtype=?";
					push(@bind,$temp[$i]);
							}
				$query.=")";
				if ($search->{'illustrator'} ne ''){
					$query.=" and illus like ?";
					push(@bind,"%".$search->{'illustrator'}."%");
								}
				if ($search->{'dewey'} ne ''){
					$query.=" and biblioitems.dewey like ?";
					push(@bind,"$search->{'dewey'}%");
							}
			} elsif ($search->{'dewey'} ne ''){
				$query="select * from biblioitems,biblio
				where biblio.biblionumber=biblioitems.biblionumber
				and biblioitems.dewey like ?";
				@bind=("$search->{'dewey'}%");
			} elsif ($search->{'illustrator'} ne '') {
					$query="select * from biblioitems,biblio
				where biblio.biblionumber=biblioitems.biblionumber
				and biblioitems.illus like ?";
					@bind=("%".$search->{'illustrator'}."%");
			} elsif ($search->{'publisher'} ne ''){
				$query = "Select * from biblio,biblioitems where biblio.biblionumber
				=biblioitems.biblionumber and (publishercode like ?)";
				@bind=("%$search->{'publisher'}%");
			} elsif ($search->{'abstract'} ne ''){
				$query = "Select * from biblio where abstract like ?";
				@bind=("%$search->{'abstract'}%");
			} elsif ($search->{'date-before'} ne ''){
				$query = "Select * from biblio where copyrightdate like ?";
				@bind=("%$search->{'date-before'}%");
			}
			$query .=" group by biblio.biblionumber";
		}
	}
	if ($type eq 'subject'){
		my @key=split(' ',$search->{'subject'});
		my $count=@key;
		my $i=1;
		$query="select * from bibliosubject inner join  biblioitems on
(bibliosubject.biblionumber = biblioitems.biblionumber) where ( subject like ? or subject like ? or subject like ?)";
		@bind=("$key[0]%","% $key[0]%","%($key[0])%");
		while ($i<$count){
			$query.=" and (subject like ? or subject like ? or subject like ?)";
			push(@bind,"$key[$i]%","% $key[$i]%","%($key[$i])%");
			$i++;
		}

		if ($search->{'class'}){
				    $query.= "and ( itemtype=?)";
				    push(@bind,$search->{'class'});
				    }

		    }
	if ($type eq 'precise'){
	#falta autores.apellido as apellido,autores.nombre as nombre
	if ($search->{'authorid'} ne ''){
			@bind=($search->{'authorid'},$search->{'authorid'},$search->{'authorid'});
			$query="select *,biblio.author,biblio.biblionumber from
				biblio
				left join additionalauthors
				on additionalauthors.biblionumber =biblio.biblionumber
				left join colaboradores on colaboradores.biblionumber = biblio.biblionumber
				 where
				(biblio.author = ? or additionalauthors.author=?
				or colaboradores.idColaborador=?)";
			$query.=" group by biblio.biblionumber";
			}
	#EINARAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	if ($search->{'itemnumber'} ne ''){
	$query="select * from items right join biblio  on  items.biblionumber=biblio.biblionumber
	where  barcode like ? ";
	my $search2=uc $search->{'itemnumber'};
	@bind=($search2);									
					# FIXME - .= <<EOT;
		}
=item Se hace aparte
		if ($search->{'isbn'} ne ''){
			my $search2=uc $search->{'isbn'};
			my $sth1=$dbh->prepare("select * from biblioitems where isbn=?");
			$sth1->execute($search2);
			my $i2=0;
			while (my $data=$sth1->fetchrow_hashref) {
			
		 if (($from ne 'opac')||( bibavail($data->{'biblionumber'}) eq 1)){ #Si viene de opac y no esta disponible no lo proceso
 
				my $sth=$dbh->prepare("select * from biblio inner join biblioitems 
				on biblioitems.biblionumber = biblio.biblionumber
				where   biblio.biblionumber = ? ");
				$sth->execute($data->{'biblionumber'});
				# FIXME - There's already a $data in this scope.
				my $data=$sth->fetchrow_hashref;
				my ($dewey, $subclass) = ($data->{'dewey'}, $data->{'subclass'});
				# FIXME - The following assumes that the Dewey code is a
				# floating-point number. It isn't: it's a string.
				$dewey=~s/\.*0*$//;
				($dewey == 0) && ($dewey='');
				($dewey) && ($dewey.=" $subclass");
				$data->{'dewey'}=$dewey;
				$results[$i2]=$data;
				$i2++;
				$sth->finish;
		}	
		
			}
			$sth1->finish;
		}
=cut
	}
	if ($type ne 'precise' && $type ne 'subject'){
		#if ($search->{'author'} ne ''){
		#	$query .= " order by biblio.author,title";
		#} else {
			$query .= " order by biblio.$orden ";
		#}
	} else {
		if ($type eq 'subject'){
			$query .= "group by subject order by subject";
		}
	}

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my $count=1;
	my $i=0;
	my $limit= $num+$offset;
	while (my $data=$sth->fetchrow_hashref){

 if (($from ne 'opac')||( bibavail($data->{'biblionumber'}) eq 1)||(C4::Context->preference("opacUnavail") eq 1)){ #Si viene de opac y no esta disponible no lo proceso

# my $query="select dewey,subclass,publishercode from biblioitems where biblionumber=?";
 my $query="select dewey,subclass,publishercode from biblio left join biblioitems on biblio.biblionumber=biblioitems.biblionumber  where biblio.biblionumber=?";

		my @bind=($data->{'biblionumber'});
		if ($search->{'class'} ne ''){
			my @temp=split(/\|/,$search->{'class'});
			my $count=@temp;
			$query.= " and ( itemtype= ?";
			push(@bind,$temp[0]);
			for (my $i=1;$i<$count;$i++){
			$query.=" or itemtype=?";
			push(@bind,$temp[$i]);
			}
			$query.=")";
		}
		if ($search->{'dewey'} ne ''){
			$query.=" and dewey=? ";
			push(@bind,$search->{'dewey'});
		}
		if ($search->{'illustrator'} ne ''){
			$query.=" and illus like ?";
			push(@bind,"%$search->{'illustrator'}%");
		}
		if ($search->{'publisher'} ne ''){
			$query.= " and (publishercode like ?)";
			push(@bind,"%$search->{'publisher'}%");
		}

		my $sti=$dbh->prepare($query);
		$sti->execute(@bind);
		my $dewey;
		my $subclass;
		my $true=0;
		my $publishercode;
		my $bibitemdata;
		if ($bibitemdata = $sti->fetchrow_hashref()){
			$true=1;
			$dewey=$bibitemdata->{'dewey'};
			$subclass=$bibitemdata->{'subclass'};
			$publishercode=$bibitemdata->{'publishercode'};
		}
		#  print STDERR "$dewey $subclass $publishercode\n";
		# FIXME - The Dewey code is a string, not a number.
		$dewey=~s/\.*0*$//;
		($dewey == 0) && ($dewey='');
		($dewey) && ($dewey.=" $subclass");
		$data->{'dewey'}=$dewey;
		$data->{'publishercode'}=$publishercode;
		$sti->finish;
		if ($true == 1){
				$results[$i]=$data;
				$i++;
			$count++;
			} # if
		} #while
	}
	$sth->finish;
	$count--;

 #Hay que agregar las analiticas
  my ($countanaliticas,@analiticas)= BiblioAnalysisTypeSearch($searchAnaliticas,$type);

 foreach my $aux (@analiticas){
	 my $j=0;
	 if ($type eq 'subject'){#hay que sacar los repetidos
	  while (($j< $count)&&($results[$j]->{'subject'} ne $aux->{'subject'})) {$j++;} 
	 
	 if($j eq $count){
		 $results[$count]=$aux;
	         $count++;			 
	 		}
	 }
 	else{
		$results[$count]=$aux;
		$count++;		
		}
			}
 ####Fin anliticas 


#Filtro lo que hay que mostrar
 my $countFinal=0;
 my @resFinal;
   for ($i = $offset; (($i < $limit) && ($i < $count)); ++$i)
   { 
   $resFinal[$countFinal]=$results[$i];
   $countFinal++; }

	return($count,@resFinal);
}

sub updatesearchstats{
  my ($dbh,$query)=@_;

}

=item subsearch

  @results = &subsearch($env, $subject);

Searches for books that have a subject that exactly matches
C<$subject>.

C<&subsearch> returns an array of results. Each element of this array
is a string, containing the book's title, author, and biblionumber,
separated by tabs.

C<$env> is ignored.

=cut
#'
sub subsearch {
  # Antes ($env,$subject)=@_;
  my ($env,$subject,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblio inner join  bibliosubject on
  biblio.biblionumber=bibliosubject.biblionumber where
  bibliosubject.subject=? group by biblio.biblionumber
  order by biblio.title");
  $sth->execute($subject);
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    push @results, $data;
    $i++;
  }
  $sth->finish;
  



################  MATIAS  (Para que cuente los items y la ubicacion)       ##########################


if ($env->{itemcount} eq '1') {
                foreach my $data (@results){
                        my ($counts) = itemcount2($env, $data->{'biblionumber'}, 'intra');
                        my $subject2=$data->{'subject'};
                        $subject2=~ s/ /%20/g;
                        $data->{'itemcount'}=$counts->{'total'};
                        my $totalitemcounts=0;
                        foreach my $key (keys %$counts){
                                if ($key ne 'total'){   # FIXME - Should ignore 'order', too.
                                        #$data->{'location'}.="$key $counts->{$key} ";
                                        $totalitemcounts+=$counts->{$key};
                                        $data->{'locationhash'}->{$key}=$counts->{$key};
                                }
                        }
                        my $locationtext='';
    my $locationtextonly='';
                        my $notavailabletext='';
                        foreach (sort keys %{$data->{'locationhash'}}) {
                                if ($_ eq 'notavailable') {
                                        $notavailabletext="Not available";
                                       my $c=$data->{'locationhash'}->{$_};
                                        $data->{'not-available-p'}=$totalitemcounts;
                                        if ($totalitemcounts>1) {
                                        $notavailabletext.=" ($c)";
                                       $data->{'not-available-plural-p'}=1;
                                       }
                                } else {
                                        $locationtext.="$_";
                                        my $c=$data->{'locationhash'}->{$_};
                                        if ($_ eq 'Perdidos') {
                                        $data->{'lost-p'}=$totalitemcounts;
                                        $data->{'lost-plural-p'}=1
                                                        if $totalitemcounts > 1;
                                       } elsif ($_ eq 'Retirados') {
       $data->{'withdrawn-p'}=$totalitemcounts;
                                        $data->{'withdrawn-plural-p'}=1
                                                        if $totalitemcounts > 1;
                                        } elsif ($_ eq 'Prestados') {
                                        $data->{'on-loan-p'}=$totalitemcounts;
                                        $data->{'on-loan-plural-p'}=1
                                                        if $totalitemcounts > 1;
                                        } else {
                                        $locationtextonly.=$_;
                                   	$locationtextonly.=" ($c), "
                                                       if $totalitemcounts>1;
                                       }
                                       if ($totalitemcounts>1) {
                                        $locationtext.=" ($c), ";
                                        }
                                }
                        }
                        if ($notavailabletext) {
                                $locationtext.=$notavailabletext;
                        } else {
                                $locationtext=~s/, $//;
                        }
                        $data->{'location'}=$locationtext;
                        $data->{'location-only'}=$locationtextonly;
                        $data->{'subject2'}=$subject2;
                        $data->{'use-location-flags-p'}=1; # XXX
               }
       }


################################################




return(@results);
}

=item ItemInfo

  @results = &ItemInfo($env, $biblionumber, $type);

Returns information about books with the given biblionumber.

C<$type> may be either C<intra> or anything else. If it is not set to
C<intra>, then the search will exclude lost, very overdue, and
withdrawn items.

C<$env> is ignored.

C<&ItemInfo> returns a list of references-to-hash. Each element
contains a number of keys. Most of them are table items from the
C<biblio>, C<biblioitems>, C<items>, and C<itemtypes> tables in the
Koha database. Other keys include:

=over 4

=item C<$data-E<gt>{branchname}>

The name (not the code) of the branch to which the book belongs.

=item C<$data-E<gt>{datelastseen}>

This is simply C<items.datelastseen>, except that while the date is
stored in YYYY-MM-DD format in the database, here it is converted to
DD/MM/YYYY format. A NULL date is returned as C<//>.

=item C<$data-E<gt>{datedue}>

=item C<$data-E<gt>{class}>

This is the concatenation of C<biblioitems.classification>, the book's
Dewey code, and C<biblioitems.subclass>.

=item C<$data-E<gt>{ocount}>

I think this is the number of copies of the book available.

=item C<$data-E<gt>{order}>

If this is set, it is set to C<One Order>.

=back

=cut
#'
sub ItemInfo {
    my ($env,$biblionumber,$type) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT *,items.notforloan as itemnotforloan FROM items left join  biblio on biblio.biblionumber = items.biblionumber left join  biblioitems on biblioitems.biblioitemnumber = items.biblioitemnumber left join itemtypes on biblioitems.itemtype = itemtypes.itemtype WHERE items.biblionumber = ? ";
  if (($type ne 'intra')){
# &&(C4::Context->preference("opacUnavail") eq 0)){
    $query .= " and ((items.itemlost<>1 and items.itemlost <> 2)
    or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  $query .= " order by items.dateaccessioned desc";
    #warn $query;
  my $sth=$dbh->prepare($query);
  $sth->execute($biblionumber);
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    my $datedue = '';
    my $isth=$dbh->prepare("SELECT * FROM issues inner join  borrowers on issues.borrowernumber = borrowers.borrowernumber  WHERE itemnumber = ? AND returndate IS  NULL ");
    $isth->execute($data->{'itemnumber'});
    if (my $idata=$isth->fetchrow_hashref){
      $datedue ="Prestado a desde el".format_date($idata->{'date_due'});
    }
    if ($data->{'itemlost'} eq '2'){
        $datedue="<font color='red'>Muy Atrasado</font>";
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue="<font color='red'>Perdido</font>";
    }
    if ($data->{'wthdrawn'} eq '1'){
	$datedue="<font color='red'>Cancelado</font>";
    }
    if ($data->{'wthdrawn'} eq '2'){
             $datedue="<font color='orange'>Compartido</font>";
	         }
    if ($data->{'wthdrawn'} eq '3'){
             $datedue="<font color='orange'>Extension</font>";
    }

				
   if ($data->{'notforloan'} eq '1'){
            $datedue="<font color='blue'>Para Sala</font>";
    }

=item
    if ($datedue eq ''){
	$datedue="<font color='green'>Disponible</font>";
	my ($restype,$reserves)=CheckReserves($data->{'itemnumber'});
	if ($restype){
	    $datedue="<font color='green'>Reservado</font>";
	}
    }
=cut

    $isth->finish;
#get branch information.....
    my $bsth=$dbh->prepare("SELECT * FROM branches
                          WHERE branchcode = ?");
    $bsth->execute($data->{'holdingbranch'});
    if (my $bdata=$bsth->fetchrow_hashref){
	$data->{'branchname'} = $bdata->{'branchname'};
    }

    my $class = $data->{'classification'};# FIXME : $class is useless
    my $dewey = $data->{'dewey'};
    $dewey =~ s/0+$//;
    if ($dewey eq "000.") { $dewey = "";};	# FIXME - "000" is general books about computer science
    if ($dewey < 10){$dewey='00'.$dewey;}
    if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
    if ($dewey <= 0){
      $dewey='';
    }
    $dewey=~ s/\.$//;
    $class .= $dewey;
    if ($dewey ne ''){
      $class .= $data->{'subclass'};
    }
 #   $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$data->{'dewey'}";
    # FIXME - If $data->{'datelastseen'} is NULL, perhaps it'd be prettier
    # to leave it empty, rather than convert it to "//".
    # Also ideally this should use the local format for displaying dates.
    my $date=format_date($data->{'datelastseen'});
    $data->{'datelastseen'}=$date;
    $data->{'datedue'}=$datedue;
    $data->{'class'}=$class;
    $results[$i]=$data;
    $i++;
  }
 $sth->finish;
  #FIXME: ordering/indentation here looks wrong
  my $sth2=$dbh->prepare("Select * from aqorders where biblionumber=?");
  $sth2->execute($biblionumber);
  my $data;
  my $ocount;
  if ($data=$sth2->fetchrow_hashref){
    $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    if ($ocount > 0){
      $data->{'ocount'}=$ocount;
      $data->{'order'}="One Order";
      $results[$i]=$data;
    }
  }
  $sth2->finish;
  return(@results);
}

=item GetItems

  @results = &GetItems($env, $biblionumber);

Returns information about books with the given biblionumber.

C<$env> is ignored.

C<&GetItems> returns an array of strings. Each element is a
tab-separated list of values: biblioitemnumber, itemtype,
classification, Dewey number, subclass, ISBN, volume, number, and
itemdata.

Itemdata, in turn, is a string of the form
"I<barcode>C<[>I<holdingbranch>C<[>I<flags>" where I<flags> contains
the string C<NFL> if the item is not for loan, and C<LOST> if the item
is lost.

=cut
#'
sub GetItems {
   my ($env,$biblionumber)=@_;
   #debug_msg($env,"GetItems");
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("Select * from biblioitems where (biblionumber = ?)");
   $sth->execute($biblionumber);
   #debug_msg($env,"executed query");
   my $i=0;
   my @results;
   while (my $data=$sth->fetchrow_hashref) {
      #debug_msg($env,$data->{'biblioitemnumber'});
      my $dewey = $data->{'dewey'};
      $dewey =~ s/0+$//;
      my $line = $data->{'biblioitemnumber'}."\t".$data->{'itemtype'};
      $line .= "\t$data->{'classification'}\t$dewey";
      $line .= "\t$data->{'subclass'}\t$data->{isbn}";
      $line .= "\t$data->{'volume'}\t$data->{number}";
      my $isth= $dbh->prepare("select * from items where biblioitemnumber = ?");
      $isth->execute($data->{'biblioitemnumber'});
      while (my $idata = $isth->fetchrow_hashref) {
        my $iline = $idata->{'barcode'}."[".$idata->{'holdingbranch'}."[";
	if ($idata->{'notforloan'} == 1) {
	  $iline .= "NFL ";
	}
	if ($idata->{'itemlost'} == 1) {
	  $iline .= "LOST ";
	}
        $line .= "\t$iline";
      }
      $isth->finish;
      $results[$i] = $line;
      $i++;
   }
   $sth->finish;
   return(@results);
}

=item itemdata

  $item = &itemdata($barcode);

Looks up the item with the given barcode, and returns a
reference-to-hash containing information about that item. The keys of
the hash are the fields from the C<items> and C<biblioitems> tables in
the Koha database.

=cut
#'
sub itemdata {
  my ($barcode)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from items,biblioitems where barcode=?
  and items.biblioitemnumber=biblioitems.biblioitemnumber");
  $sth->execute($barcode);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

#########Matias
sub infoitem {
  my ($barcode)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from items where barcode=? ");
  $sth->execute($barcode);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}


sub itemsfrombiblioitem {
  my ($biblioitem)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblioitems,items where biblioitems.biblioitemnumber=?  and items.biblioitemnumber=biblioitems.biblioitemnumber;");
  $sth->execute($biblioitem);
 my @results;
my $i=0;
 while (my $data=$sth->fetchrow_hashref){$results[$i]=$data;
 	$i++;
	}
  $sth->finish;
  return(@results);
}


sub FindItemType {
  my ($biblioitem)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT itemtypes.itemtype, itemtypes.description,itemtypes.search FROM biblioitems, itemtypes WHERE biblioitems.biblioitemnumber =? AND itemtypes.itemtype = biblioitems.itemtype ;");
  $sth->execute($biblioitem);
 my $data=$sth->fetchrow_hashref;
return($data->{'itemtype'},$data->{'description'},$data->{'search'});
}

sub FindVol {
  my ($biblioitem)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT volume, volumeddesc FROM biblioitems  WHERE biblioitems.biblioitemnumber =?  ;");
  $sth->execute($biblioitem);
my $data=$sth->fetchrow_hashref;
return ( $data->{'volumeddesc'}, $data->{'volume'});

}


sub allitems {
  my ($bib,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from items where biblioitemnumber=? ");
  $sth->execute($bib);

  my @results;

  my $issue=0;
  my $available=0;
  my $notforloan=0;
  my $forloan=0;
  my $unavailable=0;
  my $shared=0;
  my $total=0;

#se recorren todos los items de biblionumber = $bib, y verifica el estado del item
  while (my $data=$sth->fetchrow_hashref){
    #Averigua el estado
    my $datedue = '';
    my $returndate = '';
    my $reminderdate='';
    my $issued=0;
    my $renew=0;	
    my $borr=0;

    ## Esta Prestado?? 
    my $isth=$dbh->prepare("SELECT  * FROM issues, borrowers , issuetypes WHERE itemnumber = ? AND returndate IS  NULL  AND issues.borrowernumber = borrowers.borrowernumber AND issuetypes.issuecode=issues.issuecode");
    $isth->execute($data->{'itemnumber'});
    if (my $idata=$isth->fetchrow_hashref){
    #el item esta prestado	
	$issued=1;  
	#me quedo con el usuario
	$borr=$idata->{'borrowernumber'};
      
	#si estoy en la intra muestro los datos del usuario que lo tiene
      	if ($type eq "intranet") { 
      	$datedue ="Prestado a <STRONG><A href='moremember.pl?bornum=".$idata->{'borrowernumber'}."'>".$idata->{'firstname'}." ".$idata->{'surname'}."</A><BR>".$idata->{'description'}."</STRONG>";
     	}
      	else {$datedue="<b>Prestado<b>";} #si estoy en el OPAC, muestro que esta prestado
      $returndate= format_date(vencimiento($data->{'itemnumber'}));
      $renew = &sepuederenovar2($borr, $data->{'itemnumber'});
      $issue++;
    }

   $isth->finish;
   ##

    ## Esta Reservado?? 
    my $rsth=$dbh->prepare("SELECT  * FROM reserves left join  borrowers on reserves.borrowernumber=borrowers.borrowernumber WHERE reserves.itemnumber = ? and constrainttype is NULL");
    $rsth->execute($data->{'itemnumber'});
    if (my $rdata=$rsth->fetchrow_hashref){
	$borr=$rdata->{'borrowernumber'};
	$reminderdate=format_date($rdata->{'reminderdate'});
      if ($type eq "intranet") { 
      $datedue ="Reservado a <STRONG><A href='moremember.pl?bornum=".$rdata->{'borrowernumber'}."'>".$rdata->{'firstname'}." ".$rdata->{'surname'}."</A></STRONG>"; 
      }
      else {$datedue="<b>Reservado<b>";}
    }
   $rsth->finish;
   ##
    
    if (($datedue eq '')&&($data->{'notforloan'} eq '1')){
        $datedue="<font size=2 color='blue'>SALA DE LECTURA</font>";
	$notforloan++;
	$available++;
    }

     if ($data->{'wthdrawn'} ne '0'){
             $datedue.="<font size=2 color='red'>".getAvail($data->{'wthdrawn'})->{'description'}."</font>";
	             if ($data->{'wthdrawn'} eq '2'){ $shared++;} # compartido
		     else {
		     if ($data->{'wthdrawn'} ne '3'){$unavailable++;}}
		     }
					   
 

    if ($datedue eq ''){
        $datedue="<font size=2 color='green'>PRESTAMO</font>";
        $available++;
	$forloan++;
    }

    my $forloan2;
    my $notforloan2;

    if ($data->{'wthdrawn'}){
	    $forloan2=0;
	    $notforloan2=0;
    } elsif ($data->{'notforloan'}){ 
	    $notforloan2=1;
	    $forloan2=0;
    } else {
	    $forloan2=1;
	    $notforloan2=0;
    }
		
    push(@results,{ bulk => $data->{"bulk"} , barcode => $data->{"barcode"}, datedue => $datedue, returndate => $returndate , reminderdate => $reminderdate , forloan => $forloan2 , notforloan => $notforloan2 , issued => $issued, wthdrawn => $data->{'wthdrawn'}, biblioitemnumber => $bib, itemnumber => $data->{'itemnumber'}, borr => $borr , renew=>$renew} );

  $total++;
  }
  $sth->finish;
  return($total,$available,$forloan,$notforloan,$unavailable,$issue,$shared,@results);
}

sub countitems {
#Cantidad de items de un biblioitem
  my ($bib,$bibit)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select count(*) from items where biblionumber=? and biblioitemnumber=? ");
  $sth->execute($bib,$bibit);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}


### cuenta las reserva que tiene un biblioitem 30/03/2007 VER SI ESTA BIEN!!!!!!!!!!!!!!! - Damian

sub Countreserve{
   my ($bibitemnumber)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("SELECT  count(*) as reservas
                       FROM reserves
                       WHERE biblioitemnumber =? AND constrainttype IS NULL");
   $sth->execute($bibitemnumber);
   my $data=$sth->fetchrow_hashref;
   return($data->{'reservas'});
}

#cuenta las reservas pendientes del grupo
sub CountreserveGrupo{
   my ($biblioitemnumber)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("SELECT count(*) as reservas from reserves 
	WHERE  reserves.biblioitemnumber = ? and reserves.constrainttype is NULL  and itemnumber is Null ");
   $sth->execute($biblioitemnumber);
   my $data=$sth->fetchrow_hashref;
   return($data->{'reservas'});
}

sub allbibitems {
#Todos los biblioitems de un biblio
  my ($bib,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT  *
                       FROM biblioitems
                       inner join itemtypes on biblioitems.itemtype = itemtypes.itemtype
                       WHERE biblionumber =? order by volume asc,number asc ");

  #my $sth=$dbh->prepare("SELECT  *
   #                       FROM biblioitems
#			  inner join itemtypes on biblioitems.itemtype = itemtypes.itemtype
#			  inner join biblio on biblioitems.biblionumber = biblio.biblionumber
 #                         WHERE biblioitems.biblionumber =?
 # ");                      
  $sth->execute($bib);

my $cantbibit=0;
my $cantunavail=0;
my @results;
my @resultsItems;
my $i=0;
 while (my $data=$sth->fetchrow_hashref){

	#los grupos que no tienen libros no se muestran en el OPAC
	if($type eq "opac"){
        my $sth2=$dbh->prepare("SELECT  * FROM items WHERE biblioitemnumber =? AND wthdrawn = 0 or wthdrawn is null or wthdrawn = 2 or wthdrawn = 7");
        $sth2->execute($data->{'biblioitemnumber'});
        	if(!$sth2->fetchrow_hashref){
           		next;
        	}
    	}

        $results[$i]=$data;
	$results[$i]->{'publishercode'}= publisherList($results[$i]->{'biblioitemnumber'},$dbh); #agregado por Luciano
	$results[$i]->{'isbncode'}= isbnList($results[$i]->{'biblioitemnumber'},$dbh); #agregado por Einar
	my @aux;

($results[$i]->{'total'},$results[$i]->{'available'},$results[$i]->{'fl'},$results[$i]->{'notfl'},$results[$i]->{'unav'},$results[$i]->{'issue'},$results[$i]->{'shared'},@aux)=allitems($data->{'biblioitemnumber'},$type);

	#Matias necesito la primera signatura topografica
	if(@aux ne 0){ $results[$i]->{'firstST'}=$aux[0]->{'bulk'}; }
	#

	$results[$i]->{'notforloan'}= ((($results[$i]->{'fl'}+$results[$i]->{'issue'}) eq 0) and ($results[$i]->{'notfl'} gt 0));

 	   if (($type ne 'intranet')&&(C4::Context->preference("avail") eq 0))
	#if (($type ne 'intranet'))
	       {
	       $results[$i]->{'unavailable'}=($results[$i]->{'total'} eq  $results[$i]->{'unav'});
	       # Para ver si todos los grupos estan deshabilitados
	       if ($results[$i]->{'unavailable'}){$cantunavail++;};
	       	}
				                          
	$cantbibit++;
 	#

	#bibitnfloan ($results[$i]->{'biblioitemnumber'},$type);	

	$results[$i]->{'items'}=\@aux;

#### Este if estaba comentado los descomente para que devuelva la cantidad de reservas que hay en en grupo.
if ($type eq "intranet") {$results[$i]->{'reserves'}= Countreserve($data->{'biblioitemnumber'}); }
else {$results[$i]->{'reserves'}= CountreserveGrupo($data->{'biblioitemnumber'});}

 #MAtias Lenguaje Pais y Soporte
        my $country=getCountry($results[$i]->{'idCountry'});
        $results[$i]->{'country'}= $country->{'printable_name'};
        $results[$i]->{'idCountry'}= $country->{'iso'};

        my $support=getSupport($results[$i]->{'idSupport'});
        $results[$i]->{'support'}= $support->{'description'};
        $results[$i]->{'idSupport'}= $support->{'idSupport'};

        my $language=getLanguage($results[$i]->{'idLanguage'});
        $results[$i]->{'language'}= $language->{'description'};
        $results[$i]->{'idLanguage'}= $language->{'idLanguage'};
        #

	my $level=getLevel($results[$i]->{'classification'});
        $results[$i]->{'classification'}= $level->{'description'};
        $results[$i]->{'idclass'}= $level->{'code'};
        #


	 $i++;
        }
  $sth->finish;

  return(@results);
}


sub groupinfo {
#Para ver cuantos items se pueden reservar del grupo  
	
    my ($env,$biblioitemnumber,$biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT items.itemnumber,items.barcode, items.biblionumber,items.biblioitemnumber,items.holdingbranch, items.datelastborrowed, 
				items.datelastseen  ,items.itemlost,items.wthdrawn,items.dateaccessioned, items.notforloan as itemnotforloan 
				FROM items, biblioitems WHERE items.biblionumber = ? 
                 AND biblioitems.biblioitemnumber = items.biblioitemnumber 
                 AND items.biblioitemnumber =? and ((items.itemlost<>1 and items.itemlost <> 2)
				 or items.itemlost is NULL)
			     and (items.wthdrawn <> 1 or items.wthdrawn is NULL) order by items.dateaccessioned desc";
    
  my $sth=$dbh->prepare($query);
  $sth->execute($biblionumber,$biblioitemnumber);
  my $i=0;
  
  my $available=0;
  my $lost=0;
  my $notloan=0;
  my $cancel=0;
  my $late=0;
  my $isu=0; #prestamos
  my $dates="";#Fechas
  my @branches;
  my $bi=0; #indice de branches
  while (my $data=$sth->fetchrow_hashref){
    my $datedue = '';
    my $isth=$dbh->prepare("Select * from issues where itemnumber = ? and returndate is null");
    $isth->execute($data->{'itemnumber'});

    if (my $idata=$isth->fetchrow_hashref){
      $datedue = format_date($idata->{'date_due'});
      $dates.=$data->{'barcode'}."(".$datedue.")<br> ";
      $isu++; #Prestados
    }
    if ($data->{'itemlost'} eq '2'){
        $datedue="<font color='red'>Muy Atrasado</font>";
		$late++;
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue="<font color='red'>Perdido</font>";
		$lost++;
    }
    if ($data->{'wthdrawn'} eq '1'){
        $datedue="<font color='red'>Cancelado</font>";
		$cancel++;
    }
    if ($data->{'notforloan'} eq '1'){
        $datedue="<font color='blue'>Para Sala</font>";
		$notloan++;
    }
    if ($datedue eq ''){
        $datedue="<font color='green'>Disponible</font>";
		$available++;
      }
    $isth->finish;

#get branch information.....
    my $bsth=$dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
    $bsth->execute($data->{'holdingbranch'});
    if (my $bdata=$bsth->fetchrow_hashref){
   my $find=0;
	for (my $j=0;$j<$bi;$j++) {

		if ($branches[$j]->{'branchcode'} eq  $bdata->{'branchcode'})
		      { $branches[$j]->{'count'}++;
			$find=1;		
			}
				}
	
	if ($find ne 1){ 
		     $branches[$bi]->{'branchcode'} = $bdata->{'branchcode'};
		     $branches[$bi]->{'branchname'} = $bdata->{'branchname'};
		     $branches[$bi]->{'count'} = 1;	
		     $bi++;
		}
		   			 }


  $i++;
  }
 $sth->finish;
my ($reserve, @reserves) ; # Findgroupreserve($biblioitemnumber,$biblionumber);

  return($available,$lost,$notloan,$cancel,$late,$isu,$dates,$reserve,@branches);
}





#########
=item bibdata

  $data = &bibdata($biblionumber, $type);

Returns information about the book with the given biblionumber.

C<$type> is ignored.

C<&bibdata> returns a reference-to-hash. The keys are the fields in
the C<biblio>, C<biblioitems>, and C<bibliosubtitle> tables in the
Koha database.

In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).

If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

=cut
#'
sub bibdata {
    my ($bibnum, $type) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("SELECT * ,biblio.seriestitle as cdu,  biblioitems.notes AS bnotes, 	biblio.notes
	FROM biblio
	LEFT JOIN biblioitems ON biblioitems.biblionumber = biblio.biblionumber
	LEFT JOIN bibliosubtitle ON biblio.biblionumber = bibliosubtitle.biblionumber
	WHERE biblio.biblionumber = ".$bibnum."
	ORDER BY biblioitems.biblioitemnumber LIMIT 0 , 30 ");
    $sth->execute();
    my $data;
    $data  = $sth->fetchrow_hashref;

    $sth->finish;
    $sth   = $dbh->prepare("Select * from bibliosubject where biblionumber = ?");
    $sth->execute($bibnum);
    while (my $dat = $sth->fetchrow_hashref){
        $data->{'subject'} .= "$dat->{'subject'}, ";
    } # while
	chop $data->{'subject'};
	chop $data->{'subject'};
    $sth->finish;
    $sth   = $dbh->prepare("Select * from additionalauthors where biblionumber = ?");
    $sth->execute($bibnum);
    while (my $dat = $sth->fetchrow_hashref){
        $data->{'additionalauthors'} .= "$dat->{'author'}, ";

    } # while
	chop $data->{'additionalauthors'};
	chop $data->{'additionalauthors'};
    $sth->finish;

	#Para mostrar el nivel bibliografico  
	 my $level=getLevel($data->{'classification'});
        $data->{'classification'}= $level->{'description'};
        $data->{'idclass'}= $level->{'code'};

	

    return($data);
} # sub bibdata

=item bibitemdata

  $itemdata = &bibitemdata($biblioitemnumber);

Looks up the biblioitem with the given biblioitemnumber. Returns a
reference-to-hash. The keys are the fields from the C<biblio>,
C<biblioitems>, and C<itemtypes> tables in the Koha database, except
that C<biblioitems.notes> is given as C<$itemdata-E<gt>{bnotes}>.

=cut
#'

sub bibitemdata {
    my ($bibitem) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select biblio.biblionumber,biblio.author,biblio.title,biblio.notes,biblioitems.notes as bnotes,biblioitems.biblioitemnumber, biblioitems.volume,biblioitems.number,biblioitems.classification ,biblioitems.isbn,biblioitems.isbn2,biblioitems.lccn ,biblioitems.issn,biblioitems.dewey ,biblioitems.subclass,biblioitems.publishercode, biblioitems.publicationyear ,biblioitems.volumeddesc, biblioitems.illus ,biblioitems.pages ,biblioitems.size, biblioitems.place ,biblioitems.url ,biblioitems.seriestitle,itemtypes.description, itemtypes.itemtype,biblioitems.idCountry, biblioitems.idSupport, biblioitems.idLanguage  
    
    from biblio inner join  biblioitems on  biblio.biblionumber = biblioitems.biblionumber 
        inner join itemtypes on biblioitems.itemtype = itemtypes.itemtype 
        where biblioitemnumber = ? ");
    my $data;

   $sth->execute($bibitem);
   $data = $sth->fetchrow_hashref;

   #MAtias Lenguaje Pais y Soporte
   my $country=getCountry($data->{'idCountry'});
   $data->{'country'}= $country->{'printable_name'};
   $data->{'idCountry'}= $country->{'iso'};

   my $support=getSupport($data->{'idSupport'});
   $data->{'support'}= $support->{'description'};
   $data->{'idSupport'}= $support->{'idSupport'};

   my $language=getLanguage($data->{'idLanguage'});
   $data->{'language'}= $language->{'description'};
   $data->{'idLanguage'}= $language->{'idLanguage'};


   my $level=getLevel($data->{'classification'});
        $data->{'classification'}= $level->{'description'};
        $data->{'idclass'}= $level->{'code'};

  $data->{'publishercode'}= publisherList($bibitem,$dbh); #agregado por Luciano
  $data->{'isbncode'}= isbnList($bibitem,$dbh); #agregado por Einar
	
  my $author=getautor($data->{'author'}); #agregado por Damian
  $data->{'author'}=$author->{'completo'}; #agregado por Damian
  
   #                                                                                

    $sth->finish;
    return($data);
} # sub bibitemdata


=item subject

  ($count, $subjects) = &subject($biblionumber);

Looks up the subjects of the book with the given biblionumber. Returns
a two-element list. C<$subjects> is a reference-to-array, where each
element is a subject of the book, and C<$count> is the number of
elements in C<$subjects>.

=cut
#'
sub subject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from bibliosubject where biblionumber=?");
  $sth->execute($bibnum);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item addauthor

  ($count, $authors) = &addauthors($biblionumber);

Looks up the additional authors for the book with the given
biblionumber.

Returns a two-element list. C<$authors> is a reference-to-array, where
each element is an additional author, and C<$count> is the number of
elements in C<$authors>.

=cut
#'
sub addauthor {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from additionalauthors where biblionumber=?");
  $sth->execute($bibnum);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item subtitle

  ($count, $subtitles) = &subtitle($biblionumber);

Looks up the subtitles for the book with the given biblionumber.

Returns a two-element list. C<$subtitles> is a reference-to-array,
where each element is a subtitle, and C<$count> is the number of
elements in C<$subtitles>.

=cut
#'
sub subtitle {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from bibliosubtitle where biblionumber=?");
  $sth->execute($bibnum);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item itemissues

  @issues = &itemissues($biblioitemnumber, $biblio);

Looks up information about who has borrowed the bookZ<>(s) with the
given biblioitemnumber.

C<$biblio> is ignored.

C<&itemissues> returns an array of references-to-hash. The keys
include the fields from the C<items> table in the Koha database.
Additional keys include:

=over 4

=item C<date_due>

If the item is currently on loan, this gives the due date.

If the item is not on loan, then this is either "Available" or
"Cancelled", if the item has been withdrawn.

=item C<card>

If the item is currently on loan, this gives the card number of the
patron who currently has the item.

=item C<timestamp0>, C<timestamp1>, C<timestamp2>

These give the timestamp for the last three times the item was
borrowed.

=item C<card0>, C<card1>, C<card2>

The card number of the last three patrons who borrowed this item.

=item C<borrower0>, C<borrower1>, C<borrower2>

The borrower number of the last three patrons who borrowed this item.

=back

=cut
#'
sub itemissues {
    my ($bibitem, $biblio)=@_;
    my $dbh   = C4::Context->dbh;
    # FIXME - If this function die()s, the script will abort, and the
    # user won't get anything; depending on how far the script has
    # gotten, the user might get a blank page. It would be much better
    # to at least print an error message. The easiest way to do this
    # is to set $SIG{__DIE__}.
    my $sth   = $dbh->prepare("Select * from items where
items.biblioitemnumber = ?")
      || die $dbh->errstr;
    my $i     = 0;
    my @results;

    $sth->execute($bibitem)
      || die $sth->errstr;

    while (my $data = $sth->fetchrow_hashref) {
        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $sth2   = $dbh->prepare("select * from issues,borrowers
where itemnumber = ?
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber");

        $sth2->execute($data->{'itemnumber'});
        if (my $data2 = $sth2->fetchrow_hashref) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
	    $data->{'borrower'}     = $data2->{'borrowernumber'};
        } else {
            if ($data->{'wthdrawn'} eq '1') {
                $data->{'date_due'} = 'Cancelled';
            } else {
                $data->{'date_due'} = 'Available';
            } # else
        } # else

        $sth2->finish;

        # Find the last 3 people who borrowed this item.
        $sth2 = $dbh->prepare("select * from issues, borrowers
						where itemnumber = ?
									and issues.borrowernumber = borrowers.borrowernumber
									and returndate is not NULL
									order by returndate desc,timestamp desc") || die $dbh->errstr;
        $sth2->execute($data->{'itemnumber'}) || die $sth2->errstr;
        #for (my $i2 = 0; $i2 < 2; $i2++) { # FIXME : error if there is less than 3 pple borrowing this item
 	my	$i2=0;
 	while (my $data2 = $sth2->fetchrow_hashref) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
		$i2++;
            } # if
        #} # for

        $sth2->finish;
        $results[$i] = $data;
        $i++;
    }

    $sth->finish;
    return(@results);
}

=item itemnodata

  $item = &itemnodata($env, $dbh, $biblioitemnumber);

Looks up the item with the given biblioitemnumber.

C<$env> and C<$dbh> are ignored.

C<&itemnodata> returns a reference-to-hash whose keys are the fields
from the C<biblio>, C<biblioitems>, and C<items> tables in the Koha
database.

=cut
#'
sub itemnodata {
  my ($env,$dbh,$itemnumber) = @_;
  $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select biblio.biblionumber,items.homebranch, items.itemnotes,items.notforloan ,items.itemlost,items.wthdrawn,items.bulk,items.barcode from (biblio left join items on biblio.biblionumber = items.biblionumber) left join  biblioitems on biblioitems.biblioitemnumber = items.biblioitemnumber   where items.itemnumber = ? ");
#  print $query;
  $sth->execute($itemnumber);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item BornameSearch

  ($count, $borrowers) = &BornameSearch($env, $searchstring, $type);

Looks up patrons (borrowers) by name.

C<$env> is ignored.

BUGFIX 499: C<$type> is now used to determine type of search.
if $type is "simple", search is performed on the first letter of the
surname only.

C<$searchstring> is a space-separated list of search terms. Each term
must match the beginning a borrower's surname, first name, or other
name.

C<&BornameSearch> returns a two-element list. C<$borrowers> is a
reference-to-array; each element is a reference-to-hash, whose keys
are the fields of the C<borrowers> table in the Koha database.
C<$count> is the number of elements in C<$borrowers>.

=cut
#'
#used by member enquiries from the intranet
#called by member.pl
sub BornameSearch  {
	my ($env,$searchstring,$type,$onlyCount,$orden,$startRecord,$numberOfRecords)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query;
	#Por si viene Vacio
	if ($orden eq ''){$orden='surname,firstname';}
	#

	if ($onlyCount) {
		$query = "Select count(*) from borrowers ";
	} else {
		$query = "Select * from borrowers ";
	}

	if($type eq "simple")	# simple search for one letter only
	{
		$query.="where surname like ? order by $orden";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
		@data=split(' ',$searchstring);
                $count=@data;
                $query.="where (surname like ? or surname like ?
		or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ?
		or  studentnumber like ? or  studentnumber like ?)";
                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%");

                for (my $i=1;$i<$count;$i++){
                $query=$query." and  (surname like ? or surname like ?
	     	or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ?
		or  studentnumber  like ? or  studentnumber like ? )";
	
                push(@bind,"$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
                }
                $query=$query."  order by $orden";
	}

	#### Add by Luciano to get pages of users insted of all the records ####
	if (defined $startRecord && defined $numberOfRecords) {
		$query.= " limit $startRecord,$numberOfRecords";
	}
	######

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	if ($onlyCount) {
	  my $cnt= $sth->fetchrow;
	  $sth->finish;
	  return ($cnt);
	} else {
	  my @results;
	  my $cnt=$sth->rows;
	  while (my $data=$sth->fetchrow_hashref){
	    push(@results,$data);
	  }
	  $sth->finish;
	  return ($cnt,\@results);
	}
}

=item borrdata

  $borrower = &borrdata($cardnumber, $borrowernumber);

Looks up information about a patron (borrower) by either card number
or borrower number. If $borrowernumber is specified, C<&borrdata>
searches by borrower number; otherwise, it searches by card number.

C<&borrdata> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.

=cut
#'
sub borrdata {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $sth;
  if ($bornum eq ''){
    $sth=$dbh->prepare("Select * from borrowers where cardnumber=?");
    $sth->execute($cardnumber);
  } else {
    $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  }
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  if ($data) {
  	return($data);
	} else { # try with firstname
		if ($cardnumber) {
			my $sth=$dbh->prepare("select * from borrowers where firstname=?");
			$sth->execute($cardnumber);
			my $data=$sth->fetchrow_hashref;
			$sth->finish;
			return($data);
		}
	}
	return undef;
}

=item borrissues

  ($count, $issues) = &borrissues($borrowernumber);

LoOKs up what the patron with the given borrowernumber has borrowed.

C<&borrissues> returns a two-element array. C<$issues> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields from the C<issues>, C<biblio>, and C<items> tables
in the Koha database. C<$count> is the number of elements in
C<$issues>.

=cut
#'
sub borrissues {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select *, issues.renewals as renewals2  
	from issues left join items  on items.itemnumber=issues.itemnumber 
	inner join  biblio on items.biblionumber=biblio.biblionumber 
	 where borrowernumber=?
	and issues.returndate is NULL order by date_due");
    $sth->execute($bornum);
  my @result;
  while (my $data = $sth->fetchrow_hashref) {
    push @result, $data;
  }
  $sth->finish;
  return(scalar(@result), \@result);
}

=item allissues

  ($count, $issues) = &allissues($borrowernumber, $sortkey, $limit);

Looks up what the patron with the given borrowernumber has borrowed,
and sorts the results.

C<$sortkey> is the name of a field on which to sort the results. This
should be the name of a field in the C<issues>, C<biblio>,
C<biblioitems>, or C<items> table in the Koha database.

C<$limit> is the maximum number of results to return.

C<&allissues> returns a two-element array. C<$issues> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields from the C<issues>, C<biblio>, C<biblioitems>, and
C<items> tables of the Koha database. C<$count> is the number of
elements in C<$issues>

=cut
#'
sub allissues {
  my ($bornum,$order,$limit)=@_;
  #FIXME: sanity-check order and limit
  my $dbh = C4::Context->dbh;
  my $query="Select * from issues,biblio,items,biblioitems
  where borrowernumber=? and
  items.biblioitemnumber=biblioitems.biblioitemnumber and
  items.itemnumber=issues.itemnumber and
  items.biblionumber=biblio.biblionumber order by $order";

  if ($limit !=0){
    $query.=" limit $limit";
  }
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute($bornum);
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){

    my $author=getautor($data->{'author'}); #Damian - 13/03/2007. Se ve el nombre y
    $data->{'author'} = $author->{'completo'}; #el id del autor.
    $data->{'id'} = $author->{'id'};

    $result[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@result);
}

=item borrdata2

  ($borrowed, $due, $fine) = &borrdata2($env, $borrowernumber);

Returns aggregate data about items borrowed by the patron with the
given borrowernumber.

C<$env> is ignored.

C<&borrdata2> returns a three-element array. C<$borrowed> is the
number of books the patron currently has borrowed. C<$due> is the
number of overdue items the patron currently has borrowed. C<$fine> is
the total fine currently due by the borrower.

=cut
#'
sub borrdata2 {
  my ($env,$bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from issues where borrowernumber='$bornum' and returndate is NULL";
    # print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $issues=0;
  my $overdues=0;
  
 #
 my $err= "Error con la fecha";
 my $hoy=C4::Date::format_date_in_iso(ParseDate("today"));
 my  $close = ParseDate(C4::Context->preference("close"));
if (Date::Manip::Date_Cmp($close,ParseDate("today"))<0){#Se paso la hora de cierre
	$hoy=C4::Date::format_date_in_iso(DateCalc($hoy,"+ 1 day",\$err));}
									 

 #
  while (my $data=$sth->fetchrow_hashref){
	          
	#Pregunto si esta vencido
        my $df=C4::Date::format_date_in_iso(vencimiento($data->{'itemnumber'}));
	if (Date::Manip::Date_Cmp($df,$hoy)<0){ $overdues++;}
	#
		  $issues++;
	  }
		    
 $sth->finish;
 # El resto lo dejo por  compatibilidad NO SE UTILIZA
  $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'");
  $sth->execute;
  my $data3=$sth->fetchrow_hashref;
  $sth->finish;
 #
return($overdues,$issues,$data3->{'sum(amountoutstanding)'});
}

=item getboracctrecord

  ($count, $acctlines, $total) = &getboracctrecord($env, $borrowernumber);

Looks up accounting data for the patron with the given borrowernumber.

C<$env> is ignored.

(FIXME - I'm not at all sure what this is about.)

C<&getboracctrecord> returns a three-element array. C<$acctlines> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields of the C<accountlines> table in the Koha database.
C<$count> is the number of elements in C<$acctlines>. C<$total> is the
total amount outstanding for all of the account lines.

=cut
#'
sub getboracctrecord {
   my ($env,$params) = @_;
   my $dbh = C4::Context->dbh;
   my @acctlines;
   my $numlines=0;
   my $sth=$dbh->prepare("Select * from accountlines where
borrowernumber=? order by date desc,timestamp desc");
#   print $query;
   $sth->execute($params->{'borrowernumber'});
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
   #FIXME before reinstating: insecure?
#      if ($data->{'itemnumber'} ne ''){
#        $query="Select * from items,biblio where items.itemnumber=
#	'$data->{'itemnumber'}' and biblio.biblionumber=items.biblionumber";
#	my $sth2=$dbh->prepare($query);
#	$sth2->execute;
#	my $data2=$sth2->fetchrow_hashref;
#	$sth2->finish;
#	$data=$data2;
 #     }
      $acctlines[$numlines] = $data;
      $numlines++;
      $total += $data->{'amountoutstanding'};
   }
   $sth->finish;
   return ($numlines,\@acctlines,$total);
}

=item itemcount

  ($count, $lcount, $nacount, $fcount, $scount, $lostcount,
  $mending, $transit,$ocount) =
    &itemcount($env, $biblionumber, $type);

Counts the number of items with the given biblionumber, broken down by
category.

C<$env> is ignored.

If C<$type> is not set to C<intra>, lost, very overdue, and withdrawn
items will not be counted.

C<&itemcount> returns a nine-element list:

C<$count> is the total number of items with the given biblionumber.

C<$lcount> is the number of items at the Levin branch.

C<$nacount> is the number of items that are neither borrowed, lost,
nor withdrawn (and are therefore presumably on a shelf somewhere).

C<$fcount> is the number of items at the Foxton branch.

C<$scount> is the number of items at the Shannon branch.

C<$lostcount> is the number of lost and very overdue items.

C<$mending> is the number of items at the Mending branch (being
mended?).

C<$transit> is the number of items at the Transit branch (in transit
between branches?).

C<$ocount> is the number of items that haven't arrived yet
(aqorders.quantity - aqorders.quantityreceived).

=cut
#'

# FIXME - There's also a &C4::Biblio::itemcount.
# Since they're all exported, acqui/acquire.pl doesn't compile with -w.
sub itemcount {
  my ($env,$bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items where
  biblionumber=? ";
  if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth=$dbh->prepare($query);
  #  print $query;
  $sth->execute($bibnum);
  my $count=0;
  my $lcount=0;
  my $nacount=0;
  my $fcount=0;
  my $scount=0;
  my $lostcount=0;
  my $mending=0;
  my $transit=0;
  my $ocount=0;
  while (my $data=$sth->fetchrow_hashref){
    $count++;

    my $sth2=$dbh->prepare("select * from issues,items where issues.itemnumber=
    ? and returndate is NULL
    and items.itemnumber=issues.itemnumber and ((items.itemlost <>1 and
    items.itemlost <> 2) or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)");
    $sth2->execute($data->{'itemnumber'});
    if (my $data2=$sth2->fetchrow_hashref){
       $nacount++;
    } else {
      if ($data->{'holdingbranch'} eq 'C' || $data->{'holdingbranch'} eq 'LT'){
        $lcount++;
      }
      if ($data->{'holdingbranch'} eq 'F' || $data->{'holdingbranch'} eq 'FP'){
        $fcount++;
      }
      if ($data->{'holdingbranch'} eq 'S' || $data->{'holdingbranch'} eq 'SP'){
        $scount++;
      }
      if ($data->{'itemlost'} eq '1'){
        $lostcount++;
      }
      if ($data->{'itemlost'} eq '2'){
        $lostcount++;
      }
      if ($data->{'holdingbranch'} eq 'FM'){
        $mending++;
      }
      if ($data->{'holdingbranch'} eq 'TR'){
        $transit++;
      }
    }
    $sth2->finish;
  }
#  if ($count == 0){
    my $sth2=$dbh->prepare("Select * from aqorders where biblionumber=?");
    $sth2->execute($bibnum);
    if (my $data=$sth2->fetchrow_hashref){
      $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    }
#    $count+=$ocount;
    $sth2->finish;
  $sth->finish;
  return ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount);
}

=item itemcount2

  $counts = &itemcount2($env, $biblionumber, $type);

Counts the number of items with the given biblionumber, broken down by
category.

C<$env> is ignored.

C<$type> may be either C<intra> or anything else. If it is not set to
C<intra>, then the search will exclude lost, very overdue, and
withdrawn items.

C<$&itemcount2> returns a reference-to-hash, with the following fields:

=over 4

=item C<total>

The total number of items with this biblionumber.

=item C<order>

The number of items on order (aqorders.quantity -
aqorders.quantityreceived).

=item I<branchname>

For each branch that has at least one copy of the book, C<$counts>
will have a key with the branch name, giving the number of copies at
that branch.

=back

=cut
#'
sub itemcount2NOUSADA {
  my ($env,$bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items,branches where
  biblionumber=? and items.holdingbranch=branches.branchcode";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth=$dbh->prepare($query);
  #  print $query;
  $sth->execute($bibnum);
  my %counts;
  $counts{'total'}=0;
  while (my $data=$sth->fetchrow_hashref){
    $counts{'total'}++;

    my $status;
    for my $test (
      [
	'Perdidos',
	'select * from items
	  where itemnumber=?
	    and not ((items.itemlost <>1 and items.itemlost <> 2)
		      or items.itemlost is NULL)'
      ], [
	'Retirados',
	'select * from items
	  where itemnumber=? and not (wthdrawn <> 1 or wthdrawn is NULL)'
      #], [
      #  'Para sala', "select * from items
      #    where items.itemnumber=? and notforloan = 1"
      ], [
	'Prestados', "select * from issues,items
	  where issues.itemnumber=? and returndate is NULL
	    and items.itemnumber=issues.itemnumber"
      ]
    ) {
	my($testlabel, $query2) = @$test;
	my $sth2=$dbh->prepare($query2);
	$sth2->execute($data->{'itemnumber'});
	$status = $testlabel if $sth2->fetchrow_hashref;
	$sth2->finish;
    	last if defined $status;
    }
    $status = $data->{'branchname'} unless defined $status;
    $counts{$status}++;
  }
  my $sth2=$dbh->prepare("Select * from aqorders where biblionumber=? and
  datecancellationprinted is NULL and quantity > quantityreceived");
  $sth2->execute($bibnum);
  if (my $data=$sth2->fetchrow_hashref){
      $counts{'order'}=$data->{'quantity'} - $data->{'quantityreceived'};
  }
  $sth2->finish;
  $sth->finish;
  return (\%counts);
}
=item
Esta funcion cuenta los grupos de un biblio 
=cut

sub itemcountPorGrupos{
#Einar
 my ($bibnum,$type)=@_;
 my $dbh = C4::Context->dbh;
 my $data;
 my @aux;
#Cantidad de ejemplares
 my $query2="select biblioitemnumber,volume from biblioitems where biblioitems.biblionumber=?";
 my $sth2=$dbh->prepare($query2);
 $sth2->execute($bibnum);
 my $cant=0; 
 while ($data=$sth2->fetchrow_hashref){
 my %aux2;
 $cant++;
 $query2="select count(*) as c from items where items.biblioitemnumber=?";
 if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.="(wthdrawn=0  or wthdrawn is NULL or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  }
  my $sth3=$dbh->prepare($query2);
  $sth3->execute($data->{'biblioitemnumber'});
  my $data2=$sth3->fetchrow_hashref;
  $aux2{'tomo'}=$data->{'volume'};
  $aux2{'cantidaddetomos'}=$data2->{'c'};
  push (@aux,\%aux2);
  }
  return($cant,\@aux);
  #Fin: Cantidad de ejemplares


}


sub itemcount2 {
#LUCIANO
  my ($env,$bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from branches order by branchname";
  my $sth=$dbh->prepare($query);
  $sth->execute();
  my %counts;

       
  #Cantidad de ejemplares
  my $query2="select count(*) as c from items where items.biblionumber=?";
  if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth2=$dbh->prepare($query2);
  $sth2->execute($bibnum);
  my $data=$sth2->fetchrow_hashref;
  $counts{'total'}=$data->{'c'};
  #Fin: Cantidad de ejemplares

  while ($data=$sth->fetchrow_hashref){
    my $status;

    #Cantidad de ejemplares en el branch
    my $query2="select count(*) as c from items where items.biblionumber=? and holdingbranch = ?";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute($bibnum,$data->{'branchcode'});
    my $data2=$sth2->fetchrow_hashref;
    my $cantXbranch= $data2->{'c'};
    $sth2->finish;

    #Candidad de ejemplares de sala del branch
    $query2="select count(*) as c from items where items.biblionumber=? and holdingbranch=? and notforloan = 1";
    $sth2=$dbh->prepare($query2);
    $sth2->execute($bibnum,$data->{'branchcode'});
    $data2=$sth2->fetchrow_hashref;
    my $cantXbranchNotForLoan= $data2->{'c'};
    $sth2->finish;

    #Cantidad de ejemplares prestados
    $query2= "select count(*) as c from issues,items
    where items.biblionumber=? and returndate is NULL and items.itemnumber=issues.itemnumber and  holdingbranch=?";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute($bibnum,$data->{'branchcode'});
    $data2=$sth2->fetchrow_hashref;
    my $cantPrestados= $data2->{'c'};
    $sth2->finish;

    if ($cantXbranch) { # Solo se muestra si la Unidad de Informacion tiene algun ejemplar
	
	$status = $data->{'branchcode'}.' (Total: '.$cantXbranch.', Prestados: '.$cantPrestados.', Sala: '.$cantXbranchNotForLoan.')';
    	$counts{$status}++;
    }

    $sth2->finish;
  }
  $sth->finish;
  return (\%counts);
}

=item
sub itemcount3 
Funcion reescrita por einar, la idea es reemplazar itemcount3 que hace muchos accesos a la bdd sin necesidad
itemcount3 es una funcion que recibe el bibnum y el type de busqueda (si es intranet o opac) y cuenta todos los items con es bibitem y el estado de ellos, cuantos hay en cada branchm cuantos hay en total, disponibles y cuantos prestados/reservados.
=cut

sub itemcount3 {

  my ($bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from branches";
  my $sth=$dbh->prepare($query);
  $sth->execute();
  my %counts;
  while (my $dataorig=$sth->fetchrow_hashref){
  		$counts{$dataorig->{'branchcode'}}{'nombre'}=$dataorig->{'branchcode'};
  	}
  #Cantidad de ejemplares
  my $query2="select holdingbranch, wthdrawn , notforloan, biblionumber from items where items.biblionumber=?";
  if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.=" and (wthdrawn=0 or wthdrawn is NULL or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  			}
  $sth=$dbh->prepare($query2);
  $sth->execute($bibnum);
  my $data;
  my $total=0;
  my $unavailable=0;
  #Fin: Cantidad de ejemplares
  #Los agrupo por holding branch
  while ($data=$sth->fetchrow_hashref) { 
        $counts{$data->{'holdingbranch'}}{'cantXbranch'}++; #Total
	
	if ($data->{'wthdrawn'} eq 2){ #COMPARTIDO
	 $counts{$data->{'holdingbranch'}}{'cantXbranchShared'}++;
	}else {
        if ($data->{'wthdrawn'} >0){
				$counts{$data->{'holdingbranch'}}{'cantXbranchUnavail'}++; #No Disponible 
				$unavailable++;	
				}else{ 
	if ($data->{'notforloan'}){
		$counts{$data->{'holdingbranch'}}{'cantXbranchNotForLoan'}++; # Para Sala
				}else{
		$counts{$data->{'holdingbranch'}}{'cantXbranchForLoan'}++; # Para Prestamo		
				}
				}
		}
				
  	$total++;
             } 
   #Cantidad de ejemplares prestados y/o reservados
   
   my $query2= "SELECT count( * ) AS c, holdingbranch
		FROM issues, items
		WHERE items.biblionumber = ? AND items.itemnumber = issues.itemnumber AND issues.returndate IS NULL
		GROUP BY holdingbranch";
   $sth=$dbh->prepare($query2);                     
   $sth->execute($bibnum);
   while ($data=$sth->fetchrow_hashref){
	$counts{$data->{'holdingbranch'}}{'prestados'}=$data->{'c'};
		}
  $sth->finish;


 my $query3= "SELECT count( * ) AS c, items.holdingbranch
		FROM reserves, biblioitems, items
		WHERE biblioitems.biblionumber = ? AND biblioitems.biblioitemnumber = items.biblioitemnumber AND 
		biblioitems.biblioitemnumber = reserves.biblioitemnumber AND reserves.constrainttype IS NULL  GROUP BY holdingbranch";
   $sth=$dbh->prepare($query3);
   $sth->execute($bibnum);
   while ($data=$sth->fetchrow_hashref){
        $counts{$data->{'holdingbranch'}}{'reservados'}=$data->{'c'};
                }
  $sth->finish;


my @results;
  foreach my $key (keys %counts){	
	if(($type eq 'opac')&&(C4::Context->preference("opacUnavail") eq 0)){ # Si no hay ninguno disponible no lo muestro en el opac
		if (($counts{$key}->{'cantXbranch'})&&($counts{$key}->{'cantXbranch'} gt $counts{$key}->{'cantXbranchUnavail'}))
			{push(@results,$counts{$key});}
			 }
	  else {($counts{$key}->{'cantXbranch'} && push(@results,$counts{$key}));}
	}
  return ($total,$unavailable,\@results);
	}



sub itemcountbibitem {

  my ($bibitem,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from branches";
  my $sth=$dbh->prepare($query);
  $sth->execute();
  my %counts;
  while (my $dataorig=$sth->fetchrow_hashref){
  		$counts{$dataorig->{'branchcode'}}{'nombre'}=$dataorig->{'branchcode'};
  	}
  #Cantidad de ejemplares
  my $query2="select holdingbranch, wthdrawn , notforloan, biblioitemnumber from items where items.biblioitemnumber=?";
  if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.=" and (wthdrawn=0 or wthdrawn is NULL or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  			}
  $sth=$dbh->prepare($query2);
  $sth->execute($bibitem);
  my $data;
  my $total=0;
  my $unavailable=0;
  #Fin: Cantidad de ejemplares
  #Los agrupo por holding branch
  while ($data=$sth->fetchrow_hashref) { 
        $counts{$data->{'holdingbranch'}}{'cantXbranch'}++; #Total
	
	if ($data->{'wthdrawn'} eq 2){ #COMPARTIDO
	 $counts{$data->{'holdingbranch'}}{'cantXbranchShared'}++;
	}else {
        if ($data->{'wthdrawn'} >0){
				$counts{$data->{'holdingbranch'}}{'cantXbranchUnavail'}++; #No Disponible 
				$unavailable++;	
				}else{ 
	if ($data->{'notforloan'}){
		$counts{$data->{'holdingbranch'}}{'cantXbranchNotForLoan'}++; # Para Sala
				}else{
		$counts{$data->{'holdingbranch'}}{'cantXbranchForLoan'}++; # Para Prestamo		
				}
				}
		}
				
  	$total++;
             } 
   #Cantidad de ejemplares prestados y/o reservados
   
   my $query2= "SELECT count( * ) AS c, holdingbranch
		FROM issues, items
		WHERE items.biblioitemnumber = ? AND items.itemnumber = issues.itemnumber AND issues.returndate IS NULL
		GROUP BY holdingbranch";
   $sth=$dbh->prepare($query2);                     
   $sth->execute($bibitem);
   while ($data=$sth->fetchrow_hashref){
	$counts{$data->{'holdingbranch'}}{'prestados'}=$data->{'c'};
		}
  $sth->finish;


 my $query3= "SELECT count( * ) AS c, items.holdingbranch
		FROM reserves, biblioitems, items
		WHERE biblioitems.biblioitemnumber = ? AND biblioitems.biblioitemnumber = items.biblioitemnumber AND 
		biblioitems.biblioitemnumber = reserves.biblioitemnumber AND reserves.constrainttype IS NULL  GROUP BY holdingbranch";
   $sth=$dbh->prepare($query3);
   $sth->execute($bibitem);
   while ($data=$sth->fetchrow_hashref){
        $counts{$data->{'holdingbranch'}}{'reservados'}=$data->{'c'};
                }
  $sth->finish;


my @results;
  foreach my $key (keys %counts){	
	if(($type eq 'opac')&&(C4::Context->preference("opacUnavail") eq 0)){ # Si no hay ninguno disponible no lo muestro en el opac
		if (($counts{$key}->{'cantXbranch'})&&($counts{$key}->{'cantXbranch'} gt $counts{$key}->{'cantXbranchUnavail'}))
			{push(@results,$counts{$key});}
			 }
	  else {($counts{$key}->{'cantXbranch'} && push(@results,$counts{$key}));}
	}
  return ($total,$unavailable,\@results);
	}


sub bibitnfloan {
#Cuenta si un grupo se puede o no prestar
  my ($bibitem,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $total=0;
  my $nfloan=0;
  my $data; 
  my $sth; 
#Cantidad de ejemplares
  my $query="select notforloan, biblioitemnumber from items where items.biblioitemnumber=? and (wthdrawn=0 or wthdrawn is NULL)";
  $sth=$dbh->prepare($query);
  $sth->execute($bibitem);
  #Fin: Cantidad de ejemplares
  while ($data=$sth->fetchrow_hashref) {
     	if ($data->{'notforloan'}){$nfloan++;}
        $total++;
             }
  return ($total eq $nfloan);
        }
sub bibavail {
#Todos los ejemplares del libro estan no disponibles?
  my ($bib)=@_;
  my $dbh = C4::Context->dbh;
  my $data;
  my $sth;  
  my $query="select count(itemnumber) as num from items where items.biblionumber=? and (wthdrawn=0 or wthdrawn is NULL or wthdrawn=2 or wthdrawn=7)"; #wthdrawn=2 es COMPARTIDO 
  $sth=$dbh->prepare($query);
  $sth->execute($bib);
  #Fin: Cantidad de ejemplares
  $data=$sth->fetchrow_hashref;
  if ($data->{'num'} gt 0){return(1);}
  return (0);
        }


=item ItemType
  $description = &ItemType($itemtype);

Given an item type code, returns the description for that type.

=cut
#'

# FIXME - I'm pretty sure that after the initial setup, the list of
# item types doesn't change very often. Hence, it seems slow and
# inefficient to make yet another database call to look up information
# that'll only change every few months or years.
#
# Much better, I think, to automatically build a Perl file that can be
# included in those scripts that require it, e.g.:
#	@itemtypes = qw( ART BCD CAS CD F ... );
#	%itemtypedesc = (
#		ART	=> "Art Prints",
#		BCD	=> "CD-ROM from book",
#		CD	=> "Compact disc (WN)",
#		F	=> "Free Fiction",
#		...
#	);
# The web server can then run a cron job to rebuild this file from the
# database every hour or so.
#
# The same thing goes for branches, book funds, book sellers, currency
# rates, printers, stopwords, and perhaps others.
sub ItemType {
  my ($type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select description from itemtypes where itemtype=?");
  $sth->execute($type);
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  return ($dat->{'description'});
}

=item bibitems

  ($count, @results) = &bibitems($biblionumber);

Given the biblionumber for a book, C<&bibitems> looks up that book's
biblioitems (different publications of the same book, the audio book
and film versions, etc.).

C<$count> is the number of elements in C<@results>.

C<@results> is an array of references-to-hash; the keys are the fields
of the C<biblioitems> and C<itemtypes> tables of the Koha database. In
addition, C<itemlost> indicates the availability of the item: if it is
"2", then all copies of the item are long overdue; if it is "1", then
all copies are lost; otherwise, there is at least one copy available.

=cut
#'
sub bibitems {
    my ($bibnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("SELECT biblioitems.*,
                        itemtypes.*,
                        MIN(items.itemlost)        as itemlost,
                        MIN(items.dateaccessioned) as dateaccessioned
                          FROM biblioitems, itemtypes, items
                         WHERE biblioitems.biblionumber     = ?
                           AND biblioitems.itemtype         = itemtypes.itemtype
                           AND biblioitems.biblioitemnumber = items.biblioitemnumber
                      GROUP BY items.biblioitemnumber");
    my $count = 0;
    my @results;
    $sth->execute($bibnum);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
        $count++;
    } # while
    $sth->finish;
    return($count, @results);
} # sub bibitems

#MAtias Mejore la funcion  no daba los biblioitems que no tenian items
sub bibitems2 {
    my ($bibnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("SELECT biblioitems.*,
                        itemtypes.*
                          FROM biblioitems, itemtypes
                         WHERE biblioitems.biblionumber     = ?
                           AND biblioitems.itemtype         = itemtypes.itemtype
                      ");
    my $count = 0;
    my @results;
    $sth->execute($bibnum);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
        $count++;
    } # while
    $sth->finish;
    return($count, @results);
} # sub bibitems

#


=item barcodes

  @barcodes = &barcodes($biblioitemnumber);

Given a biblioitemnumber, looks up the corresponding items.

Returns an array of references-to-hash; the keys are C<barcode> and
C<itemlost>.

The returned items include very overdue items, but not lost ones.

=cut
#'
sub barcodes{
    #called from request.pl
    my ($biblioitemnumber)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("SELECT barcode, itemlost, holdingbranch FROM items
                           WHERE biblioitemnumber = ?
                             AND (wthdrawn <> 1 OR wthdrawn IS NULL)");
    $sth->execute($biblioitemnumber);
    my @barcodes;
    my $i=0;
    while (my $data=$sth->fetchrow_hashref){
	$barcodes[$i]=$data;
	$i++;
    }
    $sth->finish;
    return(@barcodes);
}

=item getwebsites

  ($count, @websites) = &getwebsites($biblionumber);

Looks up the web sites pertaining to the book with the given
biblionumber.

C<$count> is the number of elements in C<@websites>.

C<@websites> is an array of references-to-hash; the keys are the
fields from the C<websites> table in the Koha database.

=cut
#'
sub getwebsites {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select * from websites where biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
        # FIXME - The URL scheme shouldn't be stripped off, at least
        # not here, since it's part of the URL, and will be useful in
        # constructing a link to the site. If you don't want the user
        # to see the "http://" part, strip that off when building the
        # HTML code.
        $data->{'url'} =~ s/^http:\/\///;	# FIXME - Leaning toothpick
						# syndrome
        $results[$count] = $data;
    	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebsites

=item getwebbiblioitems

  ($count, @results) = &getwebbiblioitems($biblionumber);

Given a book's biblionumber, looks up the web versions of the book
(biblioitems with itemtype C<WEB>).

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the
C<biblioitems> table of the Koha database.

=cut
#'
sub getwebbiblioitems {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select * from biblioitems where biblionumber = ?
and itemtype = 'WEB'");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
        $data->{'url'} =~ s/^http:\/\///;
        $results[$count] = $data;
        $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebbiblioitems


=item breedingsearch

  ($count, @results) = &breedingsearch($title,$isbn,$random);
C<$title> contains the title,
C<$isbn> contains isbn or issn,
C<$random> contains the random seed from a z3950 search.

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<marc_breeding> table of the Koha database.

=cut

sub breedingsearch {
	my ($title,$isbn,$z3950random) = @_;
	my $dbh   = C4::Context->dbh;
	my $count = 0;
	my ($query,@bind);
	my $sth;
	my @results;

	$query = "Select id,file,isbn,title,author from marc_breeding where ";
	if ($z3950random) {
		$query .= "z3950random = ?";
		@bind=($z3950random);
	} else {
	    @bind=();
		if ($title) {
			$query .= "title like ?";
			push(@bind,"$title%");
		}
		if ($title && $isbn) {
			$query .= " and ";
		}
		if ($isbn) {
			$query .= "isbn like ?";
			push(@bind,"$isbn%");
		}
	}
	$sth   = $dbh->prepare($query);
	$sth->execute(@bind);
	while (my $data = $sth->fetchrow_hashref) {
			$results[$count] = $data;
			$count++;
	} # while

	$sth->finish;
	return($count, @results);
} # sub breedingsearch


=item getalllanguages

  (@languages) = &getalllanguages();
  (@languages) = &getalllanguages($theme);

Returns an array of all available languages.

=cut

sub getalllanguages {
    my $type=shift;
    my $theme=shift;
    my $htdocs;
    my @languages;
    if ($type eq 'opac') {
	$htdocs=C4::Context->config('opachtdocs');
	if ($theme and -d "$htdocs/$theme") {
	    opendir D, "$htdocs/$theme";
	    foreach my $language (readdir D) {
		next if $language=~/^\./;
		next if $language eq 'all';
		push @languages, $language;
	    }
	    return sort @languages;
	} else {
	    my $lang;
	    foreach my $theme (getallthemes('opac')) {
		opendir D, "$htdocs/$theme";
		foreach my $language (readdir D) {
		    next if $language=~/^\./;
		    next if $language eq 'all';
		    $lang->{$language}=1;
		}
	    }
	    @languages=keys %$lang;
	    return sort @languages;
	}
    } elsif ($type eq 'intranet') {
	$htdocs=C4::Context->config('intrahtdocs');
	if ($theme and -d "$htdocs/$theme") {
	    opendir D, "$htdocs/$theme";
	    foreach my $language (readdir D) {
		next if $language=~/^\./;
		next if $language eq 'all';
		push @languages, $language;
	    }
	    return sort @languages;
	} else {
	    my $lang;
	    foreach my $theme (getallthemes('opac')) {
		opendir D, "$htdocs/$theme";
		foreach my $language (readdir D) {
		    next if $language=~/^\./;
		    next if $language eq 'all';
		    $lang->{$language}=1;
		}
	    }
	    @languages=keys %$lang;
	    return sort @languages;
	}
    } else {
	my $lang;
	my $htdocs=C4::Context->config('intrahtdocs');
	foreach my $theme (getallthemes('intranet')) {
	    opendir D, "$htdocs/$theme";
	    foreach my $language (readdir D) {
		next if $language=~/^\./;
		next if $language eq 'all';
		$lang->{$language}=1;
	    }
	}
	my $htdocs=C4::Context->config('opachtdocs');
	foreach my $theme (getallthemes('opac')) {
	    opendir D, "$htdocs/$theme";
	    foreach my $language (readdir D) {
		next if $language=~/^\./;
		next if $language eq 'all';
		$lang->{$language}=1;
	    }
	}
	@languages=keys %$lang;
	return sort @languages;
    }
}

=item getallthemes

  (@themes) = &getallthemes('opac');
  (@themes) = &getallthemes('intranet');

Returns an array of all available themes.

=cut

sub getallthemes {
    my $type=shift;
    my $htdocs;
    my @themes;
    if ($type eq 'intranet') {
	$htdocs=C4::Context->config('intrahtdocs');
    } else {
	$htdocs=C4::Context->config('opachtdocs');
    }
    opendir D, "$htdocs";
    my @dirlist=readdir D;
    foreach my $directory (@dirlist) {
	-d "$htdocs/$directory/en" and push @themes, $directory;
    }
    return @themes;
}



=item isbnsearch

  ($count, @results) = &isbnsearch($isbn,$title);

Given an isbn and/or a title, returns the biblios having it.
Used in acqui.simple, isbnsearch.pl only

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the
C<biblioitems> table of the Koha database.

=cut

sub isbnsearch {
    my ($isbn,$title) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my ($query,@bind);
    my $sth;
    my @results;

    $query = "Select distinct biblio.* from biblio left join biblioitems on biblio.biblionumber = biblioitems.biblionumber where";
	@bind=();
	if ($isbn) {
		$query .= " isbn=? ";
		@bind=($isbn);
	} else {
		if ($title) {
			$query .= " title like '".$title."%' ";
		}
	}

    $sth   = $dbh->prepare($query);

    $sth->execute(@bind);
    while (my $data = $sth->fetchrow_hashref) {
	#Agregado por Luciano
	$data->{'edition'}=  editorsname($data->{'biblionumber'});
	my ($locations)= itemcount2("",$data->{'biblionumber'},'intra');
	foreach my $loc (keys %$locations){
	  if ($loc ne 'total'){
		$data->{'location'}.= $loc.'<br>';
	  }
	}
	#Fin de lo agregado por Luciano
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub isbnsearch

sub isbnsearch2 {
#Busca por isbn en la tabla de referencia isbn
    my ($isbn,$title) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my ($query,@bind);
    my $sth;
    my @results;

    $query = "Select distinct biblio.* from biblio left join biblioitems on biblio.biblionumber = biblioitems.biblionumber left join isbns on biblioitems.biblioitemnumber=isbns.biblioitemnumber where ";      

	 @bind=();
        if ($isbn) {
                $query .= " isbns.isbn= '$isbn'";
        } else {
                if ($title) {
                        $query .= " biblio.title like '".$title."%' ";
                }
        }
  
    $sth   = $dbh->prepare($query);
    @bind=();    
    $sth->execute(@bind);
    while (my $data = $sth->fetchrow_hashref) {
        #Agregado por Luciano
        $data->{'edition'}=  editorsname($data->{'biblionumber'});
        my ($locations)= itemcount2("",$data->{'biblionumber'},'intra');
        foreach my $loc (keys %$locations){
          if ($loc ne 'total'){
                $data->{'location'}.= $loc.'<br>';
          }
        }
        #Fin de lo agregado por Luciano
        $results[$count] = $data;
        $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub isbnsearch2



=item getbranchname

  $branchname = &getbranchname($branchcode);

Given the branch code, the function returns the corresponding
branch name for a comprehensive information display

=cut

sub getbranchname
{
	my ($branchcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT branchname FROM branches WHERE branchcode = ?");
	$sth->execute($branchcode);
	my $branchname = $sth->fetchrow();
	$sth->finish();
	return $branchname;
} # sub getbranchname

=item getborrowercategory

  $description = &getborrowercategory($categorycode);

Given the borrower's category code, the function returns the corresponding
description for a comprehensive information display.

=cut

sub getborrowercategory
{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT description FROM categories WHERE categorycode = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	return $description;
} # sub getborrowercategory

#Cantidad  maxima de prestamos
sub getmaxissues {
	my ($issuetype) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT maxissues FROM issuetypes WHERE issuecode = ? ");
	$sth->execute($issuetype);
	my $max= $sth->fetchrow;
	$sth->finish;
	return $max;
}

#Cantidad  maxima de renovaciones
sub getmaxrenewals
{
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select value  from systempreferences where variable='maxrenewals'");
  $sth->execute();
  my $data=$sth->fetchrow();
  $sth->finish;
  return $data;
}
#fin agregado por Matias


#agregado por LUCIANO
sub editorsname {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblioitems where biblionumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bibnum);
  my @result;
  my $res='';
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'number'} || $data->{'publicationyear'} ){#|| $data->{'place'}) {
	$res.=$data->{'number'};
    	if ($data->{'publicationyear'} )#|| $data->{'place'}) {
    		{
                $res.=' (';
		#if ($data->{'publicationyear'}) {	
	        $res.=$data->{'publicationyear'};#.', '.$data->{'place'};
		#} else {
		#	$res.=$data->{'place'};
		}
		$res=~s/, $//;
		$res.='), ';
		
    	} 
	else {
    		$res.=', ';
	}
    }
		push(@result,$res);
		$res='';
  
  #Agregado para manejar el tema de que las ediciones estaban repetidas. por Tuto y Einar.
  my $i=0;
  my @result2=();
  my $res='';
  foreach my $auxiliar (@result){
      foreach my $auxiliar2 (@result2) {
		if ($auxiliar eq $auxiliar2){ $i=1;}
				        } 
	if ($i eq 0)	{push (@result2,$auxiliar);	
      				$res.=$auxiliar;}
			
      			else {$i=0;}
   } 

  $res=~s/, $//;
  return($res);
}
=item
agregado por EINAR
esta funcion devuelve los datos de los grupos a mostrar en una busaqueda dado un biblionumber
Esto incluye: biblioitemnumber,number (que es la edicion), publicationyear, volume y la cantidad de items que tiene ese grupo. 
=cut

sub Grupos {
  my ($bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblioitems where biblionumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bibnum);
  my @result;
  my $res=0;
  my $data;  
  while ( $data=$sth->fetchrow_hashref){
  	
	my $query2="select count(*) as c from items where items.biblioitemnumber=?";
 	if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    		$query2.=" and (wthdrawn=0 or wthdrawn is NULL  or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  			    }
	my $sth2=$dbh->prepare($query2);
  	$sth2->execute($data->{'biblioitemnumber'});
	
	my $aux=($sth2->fetchrow_hashref);
	
	if (($aux)&&($aux->{'c'} gt 0)){
	$result[$res]{'cant'}=$aux->{'c'};
	$result[$res]{'biblioitemnumber'}=$data->{'biblioitemnumber'};
        $result[$res]{'edicion'}=$data->{'number'};
        $result[$res]{'publicationyear'}=$data->{'publicationyear'};
        $result[$res]{'volume'}=$data->{'volume'};
	$res++;	
		}
	}
return (\@result);
}


sub generarEstadoDeColeccion
 {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="SELECT publicationyear, volume, fasc
  		FROM biblioitems
  		WHERE biblionumber = ?
  		ORDER BY publicationyear ASC , volume ASC , fasc ASC ";

  my $sth=$dbh->prepare($query);
  $sth->execute($bibnum);

  my $colect="";
  my $year=0;
  my $vol=0;
 while (my $data = $sth->fetchrow_hashref) {

if (($data->{'publicationyear'} ne $year) || ($data->{'volume'} ne $vol)){

  if (($year ne 0) && ($vol ne 0)) { $colect.=');<br>';}
 
  $colect.=$data->{'publicationyear'}.' '.$data->{'volume'}.'('.$data->{'fasc'};
  
  } else 
  {$colect.=','.$data->{'fasc'};}
 
 $year=$data->{'publicationyear'};
 $vol=$data->{'volume'};
  }

$colect.=')';

return $colect;
}


sub publisherList {
#Arama un listado alfabetico con todas las editoriales de un grupo separadas por coma (,)
        my ($biblioitemnumber, $dbh) = @_;
        my $sth = $dbh->prepare("select * from publisher where biblioitemnumber = ? order by publisher");
        $sth->execute($biblioitemnumber);
        my $result="";
        while (my $data = $sth->fetchrow_hashref) {
                $result.=$data->{'publisher'}.", ";
        }
        $result=~s/, $//;
        return($result);
}
#fin agregado por LUCIANO
sub isbnList {
#Arama un listado alfabetico con todas los isbn de un grupo separadas por coma (,)
        my ($biblioitemnumber, $dbh) = @_;
        my $sth = $dbh->prepare("select * from isbns where biblioitemnumber = ? ");
        $sth->execute($biblioitemnumber);
        my $result="";
        while (my $data = $sth->fetchrow_hashref) {
                $result.=$data->{'isbn'}.", ";
        }
        $result=~s/, $//;
        return($result);
}
#fin agregado por EINAR
#Matias Verificar que se puedan realizar las eliminaciones

sub canDeleteBiblio {
#Se puede borrar el Biblio? 
        my ($biblionumber) = @_;

	my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM biblio, items, issues 
		WHERE biblio.biblionumber = items.biblionumber AND items.itemnumber = issues.itemnumber 
		AND biblio.biblionumber = ?   AND issues.returndate IS NULL");
        $sth->execute($biblionumber);
        my $result="";
        if (my $data = $sth->fetchrow_hashref)
		{ $result=1} else { $result=0} 
        return($result); 
	}	


sub canDeleteBiblioitem {
#Se puede borrar el grupo?
        my ($biblioitemnumber) = @_;
                                                                                                                             
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM biblioitems,items ,issues WHERE 
                items.biblioitemnumber = biblioitems.biblioitemnumber AND items.itemnumber = issues.itemnumber 
		AND biblioitems.biblioitemnumber = ?  AND issues.returndate IS NULL");
        $sth->execute($biblioitemnumber);
        my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);
	}

sub canDeleteItem {
#Se puede borrar o poner no disponible el Item?
        my ($itemnumber) = @_;
                                                                                                                             
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM items, issues WHERE 
		items.itemnumber = issues.itemnumber AND items.itemnumber = ? AND issues.returndate IS NULL ");
        $sth->execute($itemnumber);
        my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);

}
=item 
Sacado por einar
sub haveReserves {
  my ($bibitemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT * FROM reserves, reserveconstraints
	WHERE reserves.biblionumber = reserveconstraints.biblionumber AND reserves.timestamp = reserveconstraints.timestamp AND 
	reserveconstraints.biblioitemnumber = ? AND 
	(reserves.found <> 'F' OR reserves.found IS NULL)");
    $sth->execute($bibitemnum);

 my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);

}
=cut

sub mailissues {
  	my ($branch)=@_;
  	my $dbh = C4::Context->dbh;
  	my $sth=$dbh->prepare("SELECT * 
	FROM issues
	LEFT JOIN borrowers ON borrowers.borrowernumber = issues.borrowernumber
	LEFT JOIN items ON items.itemnumber = issues.itemnumber
	LEFT JOIN biblio ON items.biblionumber = biblio.biblionumber
	WHERE issues.returndate IS NULL AND issues.date_due <= now( ) AND issues.branchcode = ? ");
    	$sth->execute($branch);
  	my @result;
  	my @datearr = localtime(time);
	my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];	
  	while (my $data = $sth->fetchrow_hashref) {
		#Para que solo mande mail a los prestamos vencidos
		$data->{'vencimiento'}=format_date(C4::AR::Issues::vencimiento($data->{'itemnumber'}));
		my $flag=Date::Manip::Date_Cmp($data->{'vencimiento'},$hoy);
		if ($flag lt 0){
			#Solo ingresa los prestamos vencidos a el arreglo a retornar
    			push @result, $data;
		}
  	}
  	$sth->finish;
  	return(scalar(@result), \@result);
}

sub mailreservas{
	my ($branch)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM reserves 
		INNER JOIN borrowers ON (reserves.borrowernumber=borrowers.borrowernumber) 
		LEFT JOIN items ON (reserves.itemnumber = items.itemnumber )
		INNER JOIN biblio ON (items.biblionumber = biblio.biblionumber)
		WHERE reserves.branchcode=? AND constrainttype IS NULL 
		AND items.biblionumber IS NOT NULL");
	$sth->execute($branch);
	my @result;
	while (my $data = $sth->fetchrow_hashref) {
		my $author=getautor($data->{'author'});
		$author=$author->{'completo'};
		$data->{'author'}=$author;
		push @result, $data;
	}
	$sth->finish;
	return(scalar(@result), \@result);

}

sub firstbulk {
  my ($bib)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT bulk FROM items WHERE biblionumber = ? ;");
    $sth->execute($bib);
  my $data = $sth->fetchrow;
  
  return($data);
}


#fin Matias


#Funciones Adicionales para manejar la compatibilidad con guarani, empezadas por Einar

#item PersonNameSearch

  #($count, $borrowers) = &PersonNameSearch($env, $searchstring, $type);

#Looks up patrons (borrowers) by name.
#'
#used by member enquiries from the intranet
#called by member.pl

sub PersonNameSearch  {
	my ($env,$searchstring,$type,$onlyCount,$orden,$startRecord,$numberOfRecords)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query;


#Por si viene Vacio
        if ($orden eq ''){$orden='surname,firstname';}
        #


	if ($onlyCount) {
                $query = "Select count(*) from persons ";
        } else {
                $query = "Select * from persons ";
        }

	if($type eq "simple")	# simple search for one letter only
	{
		$query.="where surname like ? order by $orden";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
   		@data=split(' ',$searchstring);
                $count=@data;
                $query.="where (surname like ? or surname like ?
		or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ? 
		or  studentnumber  like ? or  studentnumber like ? )";
                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%", "$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%" );

                for (my $i=1;$i<$count;$i++){
                $query=$query." and  (surname like ? or surname like ?
		  or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ?
                or  studentnumber  like ? or  studentnumber like ? )";

        	push(@bind,"$data[$i]%","% $data[$i]%", "$data[$i]%","% $data[$i]%", "$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
                }
                $query=$query."  order by $orden";
	}

        #### Add by Luciano to get pages of users insted of all the records ####
        if (defined $startRecord && defined $numberOfRecords) {
                $query.= " limit $startRecord,$numberOfRecords";
        }
        ######

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	if ($onlyCount) {
	  my $cnt= $sth->fetchrow;
	  $sth->finish;
	  return($cnt);
	} else {
	  my @results;
  	  my $cnt=$sth->rows;
	  while (my $data=$sth->fetchrow_hashref){
	  	push(@results,$data);
	  }
	  $sth->finish;
	  return ($cnt,\@results);
	}
}


sub persdata {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $sth;
  if ($bornum eq ''){
    $sth=$dbh->prepare("Select * from persons where cardnumber=?");
    $sth->execute($cardnumber);
  } else {
    $sth=$dbh->prepare("Select * from persons where personnumber=?");
  $sth->execute($bornum);
  }
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  if ($data) {
  	return($data);
	} else { # try with firstname
		if ($cardnumber) {
			my $sth=$dbh->prepare("select * from persons where firstname=?");
			$sth->execute($cardnumber);
			my $data=$sth->fetchrow_hashref;
			$sth->finish;
			return($data);
		}
	}
	return undef;
}
=item getcitycategory

  $description = &getcitycategory($citycode);

Given the city category code, the function returns the corresponding
description for a comprehensive information display.

=cut

sub getcitycategory
{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT NOMBRE FROM localidades WHERE LOCALIDAD = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	if ($description) {return $description;}
			else{return "";}
} # sub getcitycategory

sub isRegular
{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT regular FROM persons WHERE borrowernumber = ?");
        $sth->execute($bor);
        my $regular = $sth->fetchrow();
        $sth->finish();
        return $regular;
                       
} # sub getcitycategory

sub mostrarProvincias { 
	
	my ($pais) = @_;
        my $dbh = C4::Context->dbh;
	my $query="SELECT nombre,provincia  FROM provincias WHERE pais = ? order by nombre ";
        my $sth = $dbh->prepare($query);
        $sth->execute($pais);
	my %results;
	while (my $data=$sth->fetchrow_hashref){
		$results{$data->{'provincia'}}= $data->{'nombre'};
                }
	$sth->finish();
        return (%results);
                                                                                                                             
} 

sub darProvincia {
        
        my ($prov) = @_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT nombre  FROM provincias WHERE provincia = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($prov);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);

}


#########
#Dados un pais y una provincia me retorna todos los 
#departamentos de esa provincia
#
########
sub mostrarDepartamentos{

	my ($prov) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "Select nombre,dpto_partido
		     FROM dptos_partidos  as dp
                     WHERE dp.provincia= ?
                     ORDER BY dp.NOMBRE";
	my $sth = $dbh->prepare($query);
        $sth->execute($prov);
	my %results;
        while (my $data=$sth->fetchrow_hashref){
                $results{$data->{'dpto_partido'}}= $data->{'nombre'};
                }
        $sth->finish();
        return %results;
}

sub darDepartamento {

        my ($dep) = @_;
        my $dbh = C4::Context->dbh;
        my $query="Select nombre FROM dptos_partidos  WHERE dpto_partido = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($dep);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);
}


sub buscarCiudades{
        
        my ($ciudad) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT countries.name AS pais, provincias.nombre AS provincia, dptos_partidos.nombre AS partido, localidades.localidad as localidad,localidades.nombre AS nombre FROM localidades LEFT JOIN dptos_partidos ON localidades.DPTO_PARTIDO = dptos_partidos.DPTO_PARTIDO LEFT JOIN provincias ON dptos_partidos.provincia = provincias.provincia LEFT JOIN countries ON countries.code = provincias.pais WHERE localidades.nombre LIKE ? or localidades.nombre LIKE ? ORDER BY localidades.nombre";
	my $sth = $dbh->prepare($query);
        $sth->execute($ciudad.'%', '% '.$ciudad.'%');
        my @results;
        while (my $data=$sth->fetchrow_hashref){ push(@results,$data); }
          $sth->finish;
        return \@results;
}
#Miguel despues la saco
sub buscarCiudades2{
        
        my ($ciudad) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT countries.name AS pais, provincias.nombre AS provincia, dptos_partidos.nombre AS partido, localidades.localidad as localidad,localidades.nombre AS nombre FROM localidades LEFT JOIN dptos_partidos ON localidades.DPTO_PARTIDO = dptos_partidos.DPTO_PARTIDO LEFT JOIN provincias ON dptos_partidos.provincia = provincias.provincia LEFT JOIN countries ON countries.code = provincias.pais WHERE localidades.nombre LIKE ? or localidades.nombre LIKE ? ORDER BY localidades.nombre
	limit 0,10";
	my $sth = $dbh->prepare($query);
        $sth->execute($ciudad.'%', '% '.$ciudad.'%');
        my @results;
        while (my $data=$sth->fetchrow_hashref){ push(@results,$data); }
          $sth->finish;
        return @results;
}

####Para buscar a las localidades mas usadas las primeras 20######

sub buscarCiudadesMasUsadas{
	my $dbh = C4::Context->dbh;
        my $query = "SELECT count(localidad) AS maximas, countries.name AS pais, provincias.nombre AS provincia, dptos_partidos.nombre AS partido, localidades.localidad as localidad,localidades.nombre AS nombre
	FROM localidades LEFT JOIN dptos_partidos ON localidades.DPTO_PARTIDO = dptos_partidos.DPTO_PARTIDO LEFT JOIN provincias ON dptos_partidos.provincia = provincias.provincia LEFT JOIN countries ON countries.code = provincias.pais INNER JOIN borrowers ON (localidades.localidad = borrowers.city) GROUP BY localidad ORDER BY maximas DESC limit 0,20";
	my $sth = $dbh->prepare($query);
        $sth->execute();
        my @results;
        while (my $data=$sth->fetchrow_hashref){ push(@results,$data); }
          $sth->finish;
        return \@results;
}



###
#Dados una provincia y un departamento me devuelva todas las localidades
#
###
sub mostrarCiudades{
	
	my ($localidad) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT nombre,localidad FROM localidades  WHERE dpto_partido= ?  ORDER BY nombre";
	my $sth = $dbh->prepare($query);
        $sth->execute($localidad);
	my %results;
	while (my $data=$sth->fetchrow_hashref){
                $results{$data->{'localidad'}}= $data->{'nombre'};
                }
	$sth->finish();
        return %results;

}
sub darCiudad {

        my ($ciu) = @_;
        my $dbh = C4::Context->dbh;
        my $query="Select nombre FROM localidades  WHERE localidad = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($ciu);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);
}


sub mostrarPaises{
        my $dbh = C4::Context->dbh;
        my $query = "SELECT printable_name,code from countries  ORDER BY printable_name";
        my $sth = $dbh->prepare($query);
        $sth->execute();
         my %results;
        while (my $data=$sth->fetchrow_hashref){
                $results{$data->{'code'}}= $data->{'printable_name'};
                }

	$sth->finish();
        return %results;

}

sub darPais {

        my ($pais) = @_;
        my $dbh = C4::Context->dbh;
        my $query="Select printable_name FROM countries  WHERE code = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($pais);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);
}


sub  getCountry
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from countries where iso = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getSupport
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from supports where idSupport = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLanguage
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from languages where idLanguage = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLevel
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from bibliolevel where code = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}
#Manejo de Autores, colaboradores y autores adicionales para permitir el uso de control de autoridades
sub getautor{
    my ($idAutor) = @_;
    my @result;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select id,apellido,nombre,completo from autores where id = ?");
    $sth->execute($idAutor);
    my $data1 =$sth->fetchrow_hashref; 
    my @result;
    push(@result,$data1);
    $sth->finish();
    return($data1);
 }
sub getautoresAdicionales{
    my ($biblionumber) = @_;
    my @result;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select id,apellido, nombre, completo from autores inner join additionalauthors  on additionalauthors.author=autores.id where biblionumber= ?");
    $sth->execute($biblionumber);
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
      push(@results,$data);
      
    }
    $sth->finish();
    return(@results);
    }
sub getColaboradores{
    my ($biblionumber) = @_;
    my @result;
    my $dbh   = C4::Context->dbh;
    
    my $sth= $dbh->prepare("Select id,apellido,nombre,tipo from autores inner join colaboradores on colaboradores.idColaborador=autores.id where biblionumber = ?");
    $sth->execute($biblionumber);
     my @results2;
    while (my $data = $sth->fetchrow_hashref) {
       push(@results2,$data);
    }
    $sth->finish();
    return(@results2);
    
} # sub getbiblio



#Disponibilidad
sub getavails {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from unavailable");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'code'}}= $data->{'description'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getavails

#Disponibilidad
sub getavailsplus {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from unavailable");
  my %resultslabels;
	$resultslabels{0}= 'Disponible';	
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'code'}}= $data->{'description'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getavails

sub getAvail
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from unavailable where code = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Disponibilidad
sub availArray {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from unavailable");
  my @results;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    push(@results,$data->{'description'});
  } # while
  $sth->finish;
  return(scalar(@results),\@results);
} # sub availArray



sub availDetail
{
        my ($item) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "select * from availability where item = ? ORDER BY date DESC";
        my $sth = $dbh->prepare($query);
        $sth->execute($item);
	 my @results;
	my $i=0;
	 while (my $data=$sth->fetchrow_hashref){$results[$i]=$data; $i++; }
  	$sth->finish;
  	return(scalar(@results),\@results);
}

#Dado un itemnumber devuelve los datos del item
sub itemdata2
{       
        my ($itemnumber) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT barcode,homebranch,bulk,holdingbranch from items where itemnumber='$itemnumber' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}  


sub SearchSig
{
my ($signature) = @_;
my $dbh = C4::Context->dbh;
my $query = "SELECT distinct biblio.* from biblio inner join items on biblio.biblionumber=items.biblionumber  where items.bulk like ? or items.bulk like ? ; ";
my $sth = $dbh->prepare($query);
$sth->execute("$signature%","% $signature%");
 my @results;
 my $i=0;
 while (my $data=$sth->fetchrow_hashref){$results[$i]=$data; $i++; }
 $sth->finish;
 return(scalar(@results),@results);					   
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut


