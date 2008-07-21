package C4::AR::Nivel3;


use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&detalleDisponibilidad
	&detalleNivel3MARC
);


=item

=cut

=item
detalleDisponibilidad
Devuelve la disponibilidad del item que viene por paramentro.
=cut
sub detalleDisponibilidad{
        my ($item) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM availability WHERE item = ? ORDER BY date DESC";
        my $sth = $dbh->prepare($query);
        $sth->execute($item);
	my @results;
	my $i=0;
	while (my $data=$sth->fetchrow_hashref){$results[$i]=$data; $i++; }
	$sth->finish;
	return(scalar(@results),\@results);
}

=item
detalleNivel3MARC
trae el nivel3 completo (nivel3 y nivel3_repetibles), para mostrar en MARC,
segun id3 pasado por parametro
=cut
sub detalleNivel3MARC{
	my ($id3,$itemtype,$tipo)=@_;

	my $dbh = C4::Context->dbh;
	my (@nivel3)=&C4::AR::Catalogacion::buscarNivel3($id3);
	my $disponibles;
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel3');
	my $i=0;
	my $dato;
	my $campo;
	my $subcampo;
	my $librarian;
	my @marcResult;
 	foreach my $row(@nivel3){

		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};

			$librarian=&C4::AR::Busquedas::getLibrarianMARCSubField($campo, $subcampo, 'opac');

			$marcResult[$i]->{'campo'}= $campo;
			$marcResult[$i]->{'subcampo'}= $subcampo;
			$marcResult[$i]->{'dato'}= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};
	
			$i++;
		}
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){

 			$librarian=&C4::AR::Busquedas::getLibrarianMARCSubField($data->{'campo'}, $data->{'subcampo'}, 'opac');

			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $data->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		$sth->finish;
	}

	return(\@marcResult);
}

