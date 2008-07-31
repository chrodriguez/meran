package C4::AR::Nivel3;


use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&detalleDisponibilidad

	&detalleNivel3MARC
	&detalleNivel3OPAC
	&detalleNivel3
);


=item
detalleDisponibilidad
Devuelve la disponibilidad del item que viene por paramentro.
=cut
sub detalleDisponibilidad{
        my ($id3) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM availability WHERE id3 = ? ORDER BY date DESC";
        my $sth = $dbh->prepare($query);
        $sth->execute($id3);
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
			my $dato=$row->{$mapeo->{$llave}->{'campoTabla'}};
			$librarian=&C4::AR::Busquedas::getLibrarian($campo, $subcampo, $dato,$itemtype,$tipo,1);

			$marcResult[$i]->{'campo'}= $campo;
			$marcResult[$i]->{'subcampo'}= $subcampo;
			$marcResult[$i]->{'dato'}= $librarian->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};
	
			$i++;
		}
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){

 			$librarian=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},$itemtype,$tipo,1);

			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $librarian->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};

			$i++;
		}
		$sth->finish;
	}

	return(\@marcResult);
}


=item
detalleNivel3OPAC
Trae todos los datos del nivel 3, para poder verlos en el template.
=cut
sub detalleNivel3OPAC{
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;

	my ($infoNivel3,@nivel3)=&C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel3');
	my @nivel3Comp;
	my @results;
	my $i=0;
	my $id3;
	my $campo;
	my $subcampo;
	my $dato;
	my $librarian;
	my $getLib;

	$results[0]->{'nivel3'}=\@nivel3;

	$results[0]->{'id2'}= $id2;
	$results[0]->{'cantParaPrestamo'}= $infoNivel3->{'cantParaPrestamo'};
	$results[0]->{'cantParaSala'}= $infoNivel3->{'cantParaSala'};
	$results[0]->{'cantResevasActual'}= $infoNivel3->{'cantReservas'};
	foreach my $row(@nivel3){

		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$nivel3Comp[$i]->{'campo'}=$campo;
			$nivel3Comp[$i]->{'subcampo'}=$subcampo;
			$dato= $row->{$mapeo->{$llave}->{'campoTabla'}};
			$getLib= &C4::AR::Busquedas::getLibrarian($campo, $subcampo, "", $itemtype,$tipo,0);
			$nivel3Comp[$i]->{'librarian'}= $getLib->{'textPred'};
			$nivel3Comp[$i]->{'dato'}= $dato;
			$i++;
		}
		$id3=$row->{'id3'};
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		while (my $data=$sth->fetchrow_hashref){
			$nivel3Comp[$i]->{'campo'}=$data->{'campo'};
			$nivel3Comp[$i]->{'subcampo'}=$data->{'subcampo'};
			$getLib= &C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'}, $itemtype,$tipo,0);
			$nivel3Comp[$i]->{'librarian'}= $getLib->{'textPred'};
			$nivel3Comp[$i]->{'dato'}= $getLib->{'dato'};

			$i++;
		}
		$sth->finish;
	}
	return(\@results,\@nivel3Comp);
}


=item
detalleNivel3
Trae todos los datos del nivel 3, para poder verlos en el template.
=cut
sub detalleNivel3{
	my ($id2,$itemtype,$tipo)=@_;
	my $dbh = C4::Context->dbh;
	my ($infoNivel3,@nivel3)=&C4::AR::Busquedas::buscarNivel3PorId2YDisponibilidad($id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel3');
	my @nivel3Comp;
	my %llaves;
	my @results;
	my $i=0;
	my $id3;
	my $campo;
	my $subcampo;
	my $getLib;
	$results[0]->{'nivel3'}=\@nivel3;
	$results[0]->{'disponibles'}=$infoNivel3->{'cantParaPrestamo'};
	$results[0]->{'reservados'}=$infoNivel3->{'cantReservas'};
	$results[0]->{'prestados'}=0;#FALTA !!!!! CUANDO SE EMPIEZE CON LOS PRESTAMOS
	foreach my $row(@nivel3){
		foreach my $llave (keys %$mapeo){
			$campo=$mapeo->{$llave}->{'campo'};
			$subcampo=$mapeo->{$llave}->{'subcampo'};
			$getLib=&C4::AR::Busquedas::getLibrarian($campo, $subcampo, "",$itemtype,$tipo,0);
			$nivel3Comp[$i]->{'campo'}=$campo;
			$nivel3Comp[$i]->{'subcampo'}=$subcampo;
			$nivel3Comp[$i]->{'dato'}=$row->{$mapeo->{$llave}->{'campoTabla'}};
			$nivel3Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		$id3=$row->{'id3'};
		my $query="SELECT * FROM nivel3_repetibles WHERE id3=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id3);
		my $llave2;
		while (my $data=$sth->fetchrow_hashref){
			$llave2=$data->{'campo'}.",".$data->{'subcampo'};
			$getLib=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,$tipo,0);
			if(not exists($llaves{$llave2})){
				$llaves{$llave2}=$i;
				$nivel3Comp[$i]->{'campo'}=$data->{'campo'};
				$nivel3Comp[$i]->{'subcampo'}=$data->{'subcampo'};
				$nivel3Comp[$i]->{'dato'}=$getLib->{'dato'};
				$nivel3Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
				$i++;
			}
			else{
				my $separador=" ".$getLib->{'separador'}." " ||", ";
				my $pos=$llaves{$llave2};
				$nivel3Comp[$pos]->{'dato'}.=$separador.$getLib->{'dato'};
			}
		}
		$sth->finish;
	}
	return(\@results,\@nivel3Comp);
}
