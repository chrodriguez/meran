package C4::Biblio;
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
use C4::Context;
# use C4::Database;
use MARC::Record;
use C4::BookShelves;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
#
# don't forget MARCxxx subs are exported only for testing purposes. Should not be used
# as the old-style API and the NEW one are the only public functions.
#
@EXPORT = qw(

		&char_decode
		&obtenerReferenciaAutor

 );


=item
Se agrega este metodo para buscar el codigo que corresponde al autor en la tabla aurores.
=cut
sub obtenerReferenciaAutor{
my ($dbh,$autor) = @_;
$autor =~ s/\n+$//; #elimina los \n
$autor =~ s/\r+$//; #elimina los \r
$autor =~ s/\s+$//; #elimina el espacio del final
$autor =~ s/^\s+//; #elimina el espacio del principio

my $sth = $dbh->prepare("Select id from autores where completo=?");
$sth->execute($autor);
my $data   = $sth->fetchrow_arrayref;
unless($data){ #El autor no existe, entonces lo agrego a la tabla de autores
		my @ars=split(',',$autor); #separa el autor en apellido,nombre
        	foreach my $ar (@ars)  {
			my $aux=$ar;
			$aux =~ s/\n+$//; #elimina los \n
			$aux =~ s/\r+$//; #elimina los \r
			$aux=~ s/\s+$//; #elimina el espacio del final
			$aux=~ s/^\s+//; #elimina el espacio del principio
			$ar=$aux;
			}
		$sth = $dbh->prepare ("insert into autores (nombre,apellido,completo) 
					values (?,?,?);");
            	(($ars[0])||($ars[0]=''));
		(($ars[1])||($ars[1]=''));
	    	$sth->execute($ars[1],$ars[0],$autor);
            	$sth = $dbh->prepare("Select id from autores where completo=?");
	  	$sth->execute($autor);
	  	$data= $sth->fetchrow_arrayref;
	}
$sth->finish;
return $$data[0];
		
}





#MATIAS


#Funciones Adicionales para agregar dependencias
#



sub agregarColaboradores {
	my ($dbh,$bibnro,$additauth) = @_;
	my @ars=split(/^/,$additauth);
	my $sth;
	foreach my $ar (@ars)  {
        	my ($nombre,$funcion)=split('colaborando como:',$ar);
        	my $idCol=obtenerReferenciaAutor($dbh,$nombre);#Esto habria que cambiarlo si no corresponde que la misma tabla de referencia de autores sea la de colaboradores
		
		$funcion =~ s/^\s+//; #Quita los espacios al principio
		$funcion =~ s/\s+$//; #Quita los espacios al final
			
		($funcion ne ''||($funcion='indefinida'));
       		$sth = $dbh->prepare ("insert into colaboradores (biblionumber, idColaborador,tipo) values (?,?,?);");
	    	$sth->execute($bibnro,$idCol,$funcion);
	    	$sth->finish;
				
}}

  




#MATIAS

sub delcolaboradores {
    my ($dbh,$biblio)=@_;
    #   my $dbh   = C4Connect;
        my $sth = $dbh->prepare("Delete from colaboradores where biblionumber = ?");
	$sth->execute($biblio);
	$sth->finish;
    }


=cut
sub getbookshelf {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bookshelf where parent=0 ");
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
=cut





sub char_decode {
	# converts ISO 5426 coded string to ISO 8859-1
	# sloppy code : should be improved in next issue
	my ($string,$encoding) = @_ ;
	$_ = $string ;
# 	$encoding = C4::Context->preference("marcflavour") unless $encoding;
	if ($encoding eq "UNIMARC") {
		s/\xe1/�/gm ;
		s/\xe2/�/gm ;
		s/\xe9/�/gm ;
		s/\xec/�/gm ;
		s/\xf1/�/gm ;
		s/\xf3/�/gm ;
		s/\xf9/�/gm ;
		s/\xfb/�/gm ;
		s/\xc1\x61/�/gm ;
		s/\xc1\x65/�/gm ;
		s/\xc1\x69/�/gm ;
		s/\xc1\x6f/�/gm ;
		s/\xc1\x75/�/gm ;
		s/\xc1\x41/�/gm ;
		s/\xc1\x45/�/gm ;
		s/\xc1\x49/�/gm ;
		s/\xc1\x4f/�/gm ;
		s/\xc1\x55/�/gm ;
		s/\xc2\x41/�/gm ;
		s/\xc2\x45/�/gm ;
		s/\xc2\x49/�/gm ;
		s/\xc2\x4f/�/gm ;
		s/\xc2\x55/�/gm ;
		s/\xc2\x59/�/gm ;
		s/\xc2\x61/�/gm ;
		s/\xc2\x65/�/gm ;
		s/\xc2\x69/�/gm ;
		s/\xc2\x6f/�/gm ;
		s/\xc2\x75/�/gm ;
		s/\xc2\x79/�/gm ;
		s/\xc3\x41/�/gm ;
		s/\xc3\x45/�/gm ;
		s/\xc3\x49/�/gm ;
		s/\xc3\x4f/�/gm ;
		s/\xc3\x55/�/gm ;
		s/\xc3\x61/�/gm ;
		s/\xc3\x65/�/gm ;
		s/\xc3\x69/�/gm ;
		s/\xc3\x6f/�/gm ;
		s/\xc3\x75/�/gm ;
		s/\xc4\x41/�/gm ;
		s/\xc4\x4e/�/gm ;
		s/\xc4\x4f/�/gm ;
		s/\xc4\x61/�/gm ;
		s/\xc4\x6e/�/gm ;
		s/\xc4\x6f/�/gm ;
		s/\xc8\x45/�/gm ;
		s/\xc8\x49/�/gm ;
		s/\xc8\x65/�/gm ;
		s/\xc8\x69/�/gm ;
		s/\xc8\x76/�/gm ;
		s/\xc9\x41/�/gm ;
		s/\xc9\x4f/�/gm ;
		s/\xc9\x55/�/gm ;
		s/\xc9\x61/�/gm ;
		s/\xc9\x6f/�/gm ;
		s/\xc9\x75/�/gm ;
		s/\xca\x41/�/gm ;
		s/\xca\x61/�/gm ;
		s/\xd0\x43/�/gm ;
		s/\xd0\x63/�/gm ;
		# this handles non-sorting blocks (if implementation requires this)
		$string = nsb_clean($_) ;
	} elsif ($encoding eq "USMARC" || $encoding eq "MARC21") {
		if(/[\xc1-\xff]/) {
			s/\xe1\x61/�/gm ;
			s/\xe1\x65/�/gm ;
			s/\xe1\x69/�/gm ;
			s/\xe1\x6f/�/gm ;
			s/\xe1\x75/�/gm ;
			s/\xe1\x41/�/gm ;
			s/\xe1\x45/�/gm ;
			s/\xe1\x49/�/gm ;
			s/\xe1\x4f/�/gm ;
			s/\xe1\x55/�/gm ;
			s/\xe2\x41/�/gm ;
			s/\xe2\x45/�/gm ;
			s/\xe2\x49/�/gm ;
			s/\xe2\x4f/�/gm ;
			s/\xe2\x55/�/gm ;
			s/\xe2\x59/�/gm ;
			s/\xe2\x61/�/gm ;
			s/\xe2\x65/�/gm ;
			s/\xe2\x69/�/gm ;
			s/\xe2\x6f/�/gm ;
			s/\xe2\x75/�/gm ;
			s/\xe2\x79/�/gm ;
			s/\xe3\x41/�/gm ;
			s/\xe3\x45/�/gm ;
			s/\xe3\x49/�/gm ;
			s/\xe3\x4f/�/gm ;
			s/\xe3\x55/�/gm ;
			s/\xe3\x61/�/gm ;
			s/\xe3\x65/�/gm ;
			s/\xe3\x69/�/gm ;
			s/\xe3\x6f/�/gm ;
			s/\xe3\x75/�/gm ;
			s/\xe4\x41/�/gm ;
			s/\xe4\x4e/�/gm ;
			s/\xe4\x4f/�/gm ;
			s/\xe4\x61/�/gm ;
			s/\xe4\x6e/�/gm ;
			s/\xe4\x6f/�/gm ;
			s/\xe8\x45/�/gm ;
			s/\xe8\x49/�/gm ;
			s/\xe8\x65/�/gm ;
			s/\xe8\x69/�/gm ;
			s/\xe8\x76/�/gm ;
			s/\xe9\x41/�/gm ;
			s/\xe9\x4f/�/gm ;
			s/\xe9\x55/�/gm ;
			s/\xe9\x61/�/gm ;
			s/\xe9\x6f/�/gm ;
			s/\xe9\x75/�/gm ;
			s/\xea\x41/�/gm ;
			s/\xea\x61/�/gm ;
			# this handles non-sorting blocks (if implementation requires this)
			$string = nsb_clean($_) ;
		}
	}
	# also remove |
	$string =~ s/\|//g;
	return($string) ;
}

sub nsb_clean {
	my $NSB = '\x88' ;		# NSB : begin Non Sorting Block
	my $NSE = '\x89' ;		# NSE : Non Sorting Block end
	# handles non sorting blocks
	my ($string) = @_ ;
	$_ = $string ;
	s/$NSB/(/gm ;
	s/[ ]{0,1}$NSE/) /gm ;
	$string = $_ ;
	return($string) ;
}
		

END { }       # module clean-up code here (global destructor)


