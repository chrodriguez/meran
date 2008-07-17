package C4::AR::Nivel2;


use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(

		&getEdicion
		&getVolume
		getUntitle

		&getIndice
		&insertIndice
);


=item

=cut

# FIXME Todavia no esta implementado en V3, viene de V2, ver si va a quedar
#para mostrar el indice del biblioitem
sub getIndice{

	my ($biblioitemnumber, $biblionumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query = " SELECT indice FROM biblioitems ";
	$query .= " WHERE biblioitemnumber =  ?";
	$query .= " AND biblionumber = ? ";
	
    	my $sth=$dbh->prepare($query);
    	$sth->execute($biblioitemnumber, $biblionumber);
    	my $result = $sth->fetchrow_hashref;
    	return ($result);
}

#para mostrar el indice del biblioitem
sub insertIndice{

	my ($biblioitemnumber, $biblionumber, $infoIndice) = @_;
	my $dbh = C4::Context->dbh;
	my $query = " UPDATE biblioitems ";
	$query .= " SET indice = ? ";
	$query .= " WHERE biblioitemnumber =  ?";
	$query .= " AND biblionumber = ? ";
	
    	my $sth=$dbh->prepare($query);
    	$sth->execute($infoIndice, $biblioitemnumber, $biblionumber);

}

=item
Esta funcion retorna la edicion segun un id2
=cut
sub getEdicion {
	my ($id2) = @_;
	
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"250","a","2");
}

=item
Esta funcion retorna el volumen segun un id2
=cut
sub getVolume {
	my($id2)= @_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"740","n","2");
}

=item
Esta funcion retorna el untitle segun un id2
=cut
sub getUntitle {
	my($id2)= @_;

	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id2,"245","b","1");
}

