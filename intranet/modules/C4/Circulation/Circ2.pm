# -*- tab-width: 8 -*-
# Please use 8-character tabs for this file (indents are every 4 characters)

package C4::Circulation::Circ2;

# $Id: Circ2.pm,v 1.65.2.5 2004/03/24 21:05:09 joshferraro Exp $

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz


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
# use warnings;
require Exporter;
use C4::AR::Reservas;
use C4::AR::Busquedas;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Circulation::Circ2 - Koha circulation module

=head1 SYNOPSIS

  use C4::Circulation::Circ2;

=head1 DESCRIPTION

The functions in this module deal with circulation, issues, and
returns, as well as general information about the library.
Also deals with stocktaking.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(

	&getpatroninformation
	&getiteminformation

	
	&listitemsforinventory 
	&listitemsforinventorysigtop

	&getmaxbarcode
	&getminbarcode
	&barcodesbytype

	&insertHistoricCirculation

	&getDataBiblioItems

);



#Miguel - No se si existe ya esta funcion!!!!!!!!!!!!!!!!!!!
sub getDataBiblioItems{
	my ($id2)=@_;

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("	SELECT id1 FROM nivel2 WHERE id2 = ? ");
	$sth->execute($id2);
	my $dataBiblioItems= $sth->fetchrow_hashref;
	return $dataBiblioItems;
}

=item
Registra Movimiento
=cut

sub insertHistoricCirculation {
  my ($type,$borrowernumber,$responsable,$id1,$id2,$id3,$branchcode,$issuetype,$end_date)=@_;
	
  my $dbh = C4::Context->dbh;

  my $sth=$dbh->prepare("	INSERT INTO historicCirculation(type,borrowernumber,responsable,date,id1,
				id2,id3,branchcode,issuetype,end_date)
  				VALUES (?,?,?,NOW(),?,?,?,?,?,?) ");

  $sth->execute($type,$borrowernumber,$responsable,$id1,$id2,$id3,$branchcode,$issuetype,$end_date);
	
  return;
}

=item
SE USA EN EL REPORTE DEL INVENTARIO, SE PODRIA PASAR AL PM ESTADISTICAS (inventory.pl) TAMBIEN SE USA EN barcodesbytype FUNCION QUE ESTA MAS ABAJO.
=cut
sub getmaxbarcode {
 my ($branch) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT MAX(barcode) as max FROM nivel3 WHERE barcode IS NOT NULL AND barcode <> '' AND homebranch = ?");
	$sth->execute($branch);
	my $res= ($sth->fetchrow_hashref)->{'max'};
	return $res;
}

=item
SE USA EN EL REPORTE DEL INVENTARIO, SE PODRIA PASAR AL PM ESTADISTICAS (inventory.pl), TAMBIEN SE USA EN barcodesbytype FUNCION QUE ESTA MAS ABAJO.
=cut
sub getminbarcode {
 my ($branch) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT MIN(barcode) as min FROM nivel3 where barcode IS NOT NULL AND barcode <> '' AND homebranch = ?");
	$sth->execute($branch);
	my $res= ($sth->fetchrow_hashref)->{'min'};
	return $res;
	}




=item
SE USA EN EL REPORTE DE BARCODES POR TIPO - PERO NO SE SI ANDA SE PUEDE PASAR A ESTADISTICAS.PM
=cut
sub barcodesbytype {
	my ($branch) = @_;
	
	my $clase='par';
	my @results;
	my $row;
	$row->{'tipo'}='TODOS';
	$row->{'minimo'}=&getminbarcode($branch);
	$row->{'maximo'}=&getmaxbarcode($branch);
	if (($row->{'minimo'} ne '') or ($row->{'maximo'} ne ''))  {push @results,$row };

	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT itemtype FROM itemtypes;");
	$sth->execute();
	
	while (my $it = $sth->fetchrow_hashref) {
		my $row;	
		$row->{'tipo'}=$it->{'itemtype'};	

		my $inicio=$branch."-".$it->{'itemtype'}."-%";
		
		my $sth2 = $dbh->prepare("SELECT MIN(barcode) AS min FROM nivel3 WHERE barcode IS NOT NULL AND barcode <> '' AND homebranch = ? AND barcode LIKE ? ");
		$sth2->execute($branch,$inicio);
	 	$row->{'minimo'} = ($sth2->fetchrow_hashref)->{'min'};

		my $sth3 = $dbh->prepare("SELECT MAX(barcode) AS max FROM nivel3 WHERE barcode IS NOT NULL AND barcode <> '' AND homebranch = ? AND barcode LIKE ? ");
		$sth3->execute($branch,$inicio);
	 	$row->{'maximo'} = ($sth3->fetchrow_hashref)->{'max'};

		if (($row->{'minimo'} ne '') or ($row->{'maximo'} ne ''))  {push @results,$row };
		$sth2->finish;
		$sth3->finish;
	}
	 $sth->finish;
	return @results;
}



=item
SE USA EN EL REPORTE DEL INVENTARIO, SE PODRIA PASAR AL PM ESTADISTICAS
=cut

sub listitemsforinventory {
	my ($minlocation,$maxlocation,$branch,$ini,$fin,$orden) = @_;
	my $branchcode=  $branch || C4::Context->preference('defaultbranch');
	my $dbh = C4::Context->dbh;
	# unititle,number,
	my $sth = $dbh->prepare("SELECT id3, barcode, signatura_topografica, titulo, autor, anio_publicacion, n3.id2, n2.id1, n3.homebranch
	FROM (( nivel3 n3 INNER JOIN nivel2 n2 ON n3.id2 = n2.id2) INNER JOIN nivel1 n1 ON n1.id1 = n2.id1)
	WHERE (barcode BETWEEN ? AND ?) AND n3.homebranch= ? ORDER BY barcode, titulo ");
		
	$sth->execute($minlocation,$maxlocation,$branchcode);
	
	my @results;
	while (my $row = $sth->fetchrow_hashref) {
# 		$row->{'publisher'}=getpublishers($row->{'biblioitemnumber'});
		$row->{'autor'}=C4::AR::Busquedas::getautor($row->{'autor'});
		$row->{'completo'}=($row->{'autor'})->{'completo'}; #para dar el orden
		push @results,$row;
	}

	if ($orden){
	# Da el ORDEN al arreglo
	my @sorted = sort { $a->{$orden} cmp $b->{$orden} } @results;
	@results=@sorted;
	}

	my $cantReg=scalar(@results);

#Se chequean si se quieren devolver todos
	if(($cantReg > $fin)&&($fin ne "todos")){
		my $cantFila=$fin-1+$ini;
		my @results2;
		if($cantReg < $cantFila ){
			@results2=@results[$ini..$cantReg];
		}
		else{
			@results2=@results[$ini..$fin-1+$ini];
		}

		return($cantReg,@results2);
	}
        else{
		return ($cantReg,@results);
	}

}

=item
SE USA EN EL REPORTE DEL INVENTARIO, SE PODRIA PASAR AL PM ESTADISTICAS
=cut
sub listitemsforinventorysigtop {
	my ($sigtop,$orden) = @_;
	my $dbh = C4::Context->dbh;
	#FALTA unititle,number es la edicion,
	my $sth = $dbh->prepare("SELECT id3, barcode, signatura_topografica, titulo, autor, anio_publicacion, n3.id2, n1.id1 as id1
	FROM ((nivel3 n3 INNER JOIN nivel2 n2 ON n3.id2 = n2.id2) INNER JOIN nivel1 n1 ON n1.id1 = n2.id1)
	WHERE signatura_topografica LIKE ?
	ORDER BY barcode, titulo");
		
	$sth->execute($sigtop."%");
	
	my @results;
	while (my $row = $sth->fetchrow_hashref) {
# 		$row->{'publisher'}=getpublishers($row->{'biblioitemnumber'});
		$row->{'id'}=$row->{'autor'};
		$row->{'autor'}=C4::AR::Busquedas::getautor($row->{'autor'});
		push @results,$row;
	}
	
	if ($orden){
	# Da el ORDEN al arreglo
	my @sorted = sort { $a->{$orden} cmp $b->{$orden} } @results;
	@results=@sorted;
	}

	return @results;
}


=item getpatroninformation

  ($borrower, $flags) = &getpatroninformation($env, $borrowernumber,
					$cardnumber);

Looks up a patron and returns information about him or her. If
C<$borrowernumber> is true (nonzero), C<&getpatroninformation> looks
up the borrower by number; otherwise, it looks up the borrower by card
number.

C<$env> is effectively ignored, but should be a reference-to-hash.

C<$borrower> is a reference-to-hash whose keys are the fields of the
borrowers table in the Koha database. In addition,
C<$borrower-E<gt>{flags}> is the same as C<$flags>.

C<$flags> is a reference-to-hash giving more detailed information
about the patron. Its keys act as flags: if they are set, then the key
is a reference-to-hash that gives further details:

  if (exists($flags->{LOST}))
  {
	  # Patron's card was reported lost
	  print $flags->{LOST}{message}, "\n";
  }

Each flag has a C<message> key, giving a human-readable explanation of
the flag. If the state of a flag means that the patron should not be
allowed to borrow any more books, then it will have a C<noissues> key
with a true value.

The possible flags are:

=over 4

=item CHARGES

Shows the patron's credit or debt, if any.

=item GNA

(Gone, no address.) Set if the patron has left without giving a
forwarding address.

=item LOST

Set if the patron's card has been reported as lost.

=item DBARRED

Set if the patron has been debarred.

=item NOTES

Any additional notes about the patron.

=item ODUES

Set if the patron has overdue items. This flag has several keys:

C<$flags-E<gt>{ODUES}{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

C<$flags-E<gt>{ODUES}{itemlist}> is a string giving a text listing of
the overdue items, one per line.

=item WAITING

Set if any items that the patron has reserved are available.

C<$flags-E<gt>{WAITING}{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

=cut
sub getpatroninformation {
	my ($borrowernumber,$cardnumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query;
	my $sth;
	if ($borrowernumber) {
		$sth = $dbh->prepare("SELECT borrowers.*,localidades.nombre as cityname , categories.description AS cat
					FROM borrowers
					LEFT JOIN categories ON categories.categorycode = borrowers.categorycode
					LEFT JOIN localidades on localidades.localidad=borrowers.city
					WHERE borrowers.borrowernumber = ? ;");
		$sth->execute($borrowernumber);
	} elsif ($cardnumber) {
		$sth = $dbh->prepare("select * from borrowers where cardnumber=?");
		$sth->execute($cardnumber);
	} else {
		#$env->{'apierror'} = "invalid borrower information passed to getpatroninformation subroutine";
		# FIXME VER CON LOS CODIGO DE ERROR DEL PM DE MENSAJES!!!!!!!
		return("error");
	}

open(A, ">>/tmp/debug");
print A "antes del while \n";
# 	$env->{'mess'} = $query;
	my $borrower = $sth->fetchrow_hashref;

	my $flags = patronflags($borrower);
	my $accessflagshash;

	$sth=$dbh->prepare("SELECT bit,flag FROM userflags");
	$sth->execute;
	while (my ($bit, $flag) = $sth->fetchrow) {
print A "flag: $flag  bit: $bit \n";
print A "borrower flag: ".$borrower->{'flags'}." \n";
		if ( $borrower->{'flags'} & 2**$bit ) {
			$accessflagshash->{$flag}=1;
print A "entro al if\n";
print A "accessflag de CIRC2: ".$accessflagshash->{$flag}."\n";
		}
	}
	$sth->finish;
	$borrower->{'flags'}=$flags;
close(A);
	return ($borrower, $flags, $accessflagshash);
}

=item getiteminformation

  $item = &getiteminformation($id3, $barcode);

Looks up information about an item, given either its item number or
its barcode. If C<$itemnumber> is a nonzero value, it is used;
otherwise, C<$barcode> is used.

C<$env> is effectively ignored, but should be a reference-to-hash.

C<$item> is a reference-to-hash whose keys are fields from the biblio,
items, and biblioitems tables of the Koha database. It may also
contain the following keys:

=over 4

=item C<date_due>

The due date on this item, if it has been borrowed and not returned
yet. The date is in YYYY-MM-DD format.

=item C<loanlength>

The length of time for which the item can be borrowed, in days.

=item C<notforloan>

True if the item may not be borrowed.

=back

=cut
#'
sub getiteminformation {
# returns a hash of item information given either the itemnumber or the barcode
	my ($id3, $barcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	if ($id3) {
		$sth=$dbh->prepare("	SELECT * 
					FROM nivel1 n1 INNER JOIN nivel2 n2 ON n1.id1 = n2.id1 
					INNER JOIN nivel3 n3 ON  n2.id2=n3.id2 
					WHERE n3.id3=? ");
		$sth->execute($id3);
	} elsif ($barcode) {
		#Cuando se busca por barcode puede darse el caso de tener repetidos con disponibilidad "Compartido"
		$sth=$dbh->prepare("	SELECT * 
					FROM nivel1 n1 INNER JOIN nivel2 n2 ON n1.id1 = n2.id1 
					INNER JOIN nivel3 n3 ON  n2.id2=n3.id2 
					WHERE n3.barcode=? AND n3.wthdrawn <> 2 ;");

		$sth->execute($barcode);
	} else {
		# $env->{'apierror'}="subroutine must be called with either an itemnumber or a barcode";
		# FIXME VER CON LOS CODIGO DE ERROR DEL PM DE MENSAJES!!!!!!!
		return("error");
	}
	my $iteminformation=$sth->fetchrow_hashref;
	$sth->finish;
	if ($iteminformation) {
		$sth=$dbh->prepare("	SELECT date_due, borrowers.borrowernumber, issuetypes.issuecode,
					issuetypes.description AS issuedescription, categorycode 
					FROM issues INNER JOIN borrowers 
					ON issues.borrowernumber = borrowers.borrowernumber 
					INNER JOIN issuetypes ON issuetypes.issuecode = issues.issuecode 
					WHERE id3=? AND returndate IS NULL ");

		$sth->execute($iteminformation->{'id3'});
		my ($date_due, $borrowernumber, $issuecode, $issuedescription, $categorycode) = $sth->fetchrow;
		
		#Obtengo los datos del autor
		my $autor=C4::AR::Busquedas::getautor($iteminformation->{'autor'});
		$iteminformation->{'autor'}=$autor->{'completo'};

		$iteminformation->{'date_due'}=$date_due;
		$iteminformation->{'categorycode'}=$categorycode;
		$iteminformation->{'borrowernumber'}=$borrowernumber;
		$iteminformation->{'issuecode'}=$issuecode;
		$iteminformation->{'issuedescription'}=$issuedescription;
		$sth->finish;
		($iteminformation->{'dewey'} == 0) && ($iteminformation->{'dewey'}='');
		$sth=$dbh->prepare("	SELECT * FROM itemtypes WHERE itemtype=? ");
		$sth->execute($iteminformation->{'tipo_documento'});
		my $itemtype=$sth->fetchrow_hashref;
		$iteminformation->{'loanlength'}=$itemtype->{'loanlength'};
		$iteminformation->{'notforloan'}=$itemtype->{'notforloan'} unless $iteminformation->{'notforloan'};
		$sth->finish;
	}
	return($iteminformation);
}

# Not exported
#
# NOTE!: If you change this function, be sure to update the POD for
# &getpatroninformation.
#
# $flags = &patronflags($patron);
#
# $flags->{CHARGES}
#		{message}	Message showing patron's credit or debt
#		{noissues}	Set if patron owes >$5.00
#         {GNA}			Set if patron gone w/o address
#		{message}	"Borrower has no valid address"
#		{noissues}	Set.
#         {LOST}		Set if patron's card reported lost
#		{message}	Message to this effect
#		{noissues}	Set.
#         {DBARRED}		Set is patron is debarred
#		{message}	Message to this effect
#		{noissues}	Set.
#         {NOTES}		Set if patron has notes
#		{message}	Notes about patron
#         {ODUES}		Set if patron has overdue books
#		{message}	"Yes"
#		{itemlist}	ref-to-array: list of overdue books
#		{itemlisttext}	Text list of overdue items
#         {WAITING}		Set if there are items available that the
#				patron reserved
#		{message}	Message to this effect
#		{itemlist}	ref-to-array: list of available items
sub patronflags {
# Original subroutine for Circ2.pm
	my %flags;
	my ($patroninformation) = @_;
	my $amount = 0;#checkaccount($env, $patroninformation->{'borrowernumber'}, $dbh);
	if ($amount > 0) {
		my %flaginfo;
		my $noissuescharge = C4::Context->preference("noissuescharge");
		$flaginfo{'message'}= sprintf "Debe \$%.02f", $amount;
		if ($amount > $noissuescharge) {
		$flaginfo{'noissues'} = 1;
		}
		$flags{'CHARGES'} = \%flaginfo;
	} elsif ($amount < 0){
	my %flaginfo;
	$flaginfo{'message'} = sprintf "Tiene cr&eacute;dito por \$%.02f", -$amount;
		$flags{'CHARGES'} = \%flaginfo;
	}
	if ($patroninformation->{'gonenoaddress'} == 1) {
		my %flaginfo;
		$flaginfo{'message'} = 'El usuario no tiene una direcci&oacute;n v&aacute;lida.';
		$flaginfo{'noissues'} = 1;
		$flags{'GNA'} = \%flaginfo;
	}
	if ($patroninformation->{'lost'} == 1) {
		my %flaginfo;
		$flaginfo{'message'} = 'La tarjeta de identificaci&oacute;n del usuario fue reportada como perdida.';
		$flaginfo{'noissues'} = 1;
		$flags{'LOST'} = \%flaginfo;
	}
	if ($patroninformation->{'debarred'} == 1) {
		my %flaginfo;
		$flaginfo{'message'} = 'Usuario ha sido excluido.';
		$flaginfo{'noissues'} = 1;
		$flags{'DBARRED'} = \%flaginfo;
	}
	if ($patroninformation->{'borrowernotes'}) {
		my %flaginfo;
		$flaginfo{'message'} = "$patroninformation->{'borrowernotes'}";
		$flags{'NOTES'} = \%flaginfo;
	}
	my ($odues, $itemsoverdue)
			= checkoverdues($patroninformation->{'borrowernumber'});
	if ($odues > 0) {
		my %flaginfo;
		$flaginfo{'message'} = "Yes";
		$flaginfo{'itemlist'} = $itemsoverdue;
		foreach (sort {$a->{'date_due'} cmp $b->{'date_due'}} @$itemsoverdue) {
		$flaginfo{'itemlisttext'}.="$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";
		}
		$flags{'ODUES'} = \%flaginfo;
	}
	my ($nowaiting, $itemswaiting)
			= &C4::AR::Reservas::CheckWaiting($patroninformation->{'borrowernumber'});
	if ($nowaiting > 0) {
		my %flaginfo;
		$flaginfo{'message'} = "Items reservados disponibles";
		$flaginfo{'itemlist'} = $itemswaiting;
		$flags{'WAITING'} = \%flaginfo;
	}
	return(\%flags);
}

# Not exported
sub checkoverdues {
# From Main.pm, modified to return a list of overdueitems, in addition to a count
  #checks whether a borrower has overdue items
	my ($bornum)=@_;
	my @datearr = localtime;
	my $today = ($datearr[5] + 1900)."-".($datearr[4]+1)."-".$datearr[3];
	my @overdueitems;
	my $count = 0;
	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT * FROM issues i INNER JOIN nivel3 n3 ON (i.id3 = n3.id3)
				INNER JOIN nivel2 n2 ON (n3.id2 = n2.id2)
				INNER JOIN nivel1 n1 ON (n3.id1 = n1.id1)
				WHERE i.borrowernumber  = ? AND i.returndate IS NULL AND i.date_due < ?");
	$sth->execute($bornum,$today);
	while (my $data = $sth->fetchrow_hashref) {
	push (@overdueitems, $data);
	$count++;
	}
	$sth->finish;
	return ($count, \@overdueitems);
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
