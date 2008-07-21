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

		&detalleNivel2MARC
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


=item
detalleNivel2MARC
Busca el nivel 2 segun id1 y id2, al resultado le agrega el nivel 1 y nivel 3
=cut
sub detalleNivel2MARC{
	my($id1,$id2,$id3,$tipo,$nivel1)=@_;
	my $dbh = C4::Context->dbh;
	#Busca el nivel 2 segun id1 e id2, (retorna solo uno)
	my @nivel2=&C4::AR::Catalogacion::buscarNivel2PorId1Id2($id1,$id2);
	my $mapeo=&C4::AR::Busquedas::buscarMapeo('nivel2');
	my $id2;
	my $itemtype;
	my $tipoDoc;
	my $campo;
	my $subcampo;
	my @results;
	my $librarian;	
	my $j=0;

	foreach my $row(@nivel2){
		my $i=0;
		my @marcResult;
		$marcResult[0]->{'campo'}= "";
		$marcResult[0]->{'librarian'}= "";
		my @marcTags;
		my @found;
		my $indMarcTag=0;
		$id2=$row->{'id2'};
		$itemtype=$row->{'itemtype'};
		$tipoDoc=$row->{'tipo_documento'};
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
		my $query="SELECT * FROM nivel2_repetibles WHERE id2=?";
		my $sth=$dbh->prepare($query);
        	$sth->execute($id2);
		while (my $data=$sth->fetchrow_hashref){
# my $getLib=&getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, $itemtype,'intra');
			$librarian=&C4::AR::Busquedas::getLibrarianMARCSubField($data->{'campo'}, $data->{'subcampo'},'opac');
			$marcResult[$i]->{'campo'}= $data->{'campo'};
			$marcResult[$i]->{'subcampo'}= $data->{'subcampo'};
			$marcResult[$i]->{'dato'}= $data->{'dato'};
			$marcResult[$i]->{'librarian'}= $librarian->{'liblibrarian'};
# 			$marcResult[$i]->{'dato'}= $getLib->{'dato'};
# 			$marcResult[$i]->{'librarian'}= $getLib->{'liblibrarian'};

			$i++;
		}
		$sth->finish;

		#Busca datos de nivel 3 solo del ID pasado por parametro
		my($marcResult3)=&C4::AR::Nivel3::detalleNivel3MARC($id3,$itemtype,$tipo);


#  		#agrego el nivel 1
		push (@marcResult, @$nivel1);
		#concateno el marcResult de nivel 2 con sus marcResult de nivel 3
 		push (@marcResult, @$marcResult3);

		@marcResult = sort {$a->{'campo'} cmp $b->{'campo'} 
						|| 
				$a->{'subcampo'} cmp $b->{'subcampo'}} (@marcResult);


		my $campoAnt;
		my $cant= scalar(@marcResult);
		my $ind= 0;
		my @marcResult2;
		my $fin= 0;
		my $i= 0;
		my $ind= 0;
		my $nombreCampo;
		my $cant= scalar(@marcResult);
#se agregan los encabezados MARC

		while ($i< $cant) {

			$campoAnt= $marcResult[$i]->{'campo'};
			$nombreCampo= &C4::AR::Catalogacion::buscarNombreCampoMarc($campoAnt);
 			$marcResult2[$ind]->{'campoMARC'}= $campoAnt;
 			$marcResult2[$ind]->{'nombreCampo'}= $nombreCampo;
			$ind++;

			while( ($campoAnt eq $marcResult[$i]->{'campo'}) && ($i < $cant) ){
				$campoAnt= @marcResult[$i]->{'campo'};

				$marcResult2[$ind]->{'campo'}= $marcResult[$i]->{'campo'};
				$marcResult2[$ind]->{'subcampo'}= $marcResult[$i]->{'subcampo'};
				$marcResult2[$ind]->{'dato'}= $marcResult[$i]->{'dato'};
				$marcResult2[$ind]->{'librarian'}= $marcResult[$i]->{'librarian'};

				$ind++;
				$i++;
			}
		}

		
		$results[$j]->{'marcResult'}= \@marcResult2;
		$results[$j]->{'id2'}=$id2;
		$results[$j]->{'itemtype'}=$itemtype;
		$results[$j]->{'tipoDoc'}=$tipoDoc;
		$j++;
	}

	return(@results);
}

