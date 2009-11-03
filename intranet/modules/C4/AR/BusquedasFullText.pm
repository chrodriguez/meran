package C4::AR::BusquedasFullText;


use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;
use C4::AR::Reservas;
use C4::AR::Nivel1;
use C4::AR::Nivel2;
use C4::AR::Nivel3;
use C4::AR::PortadasRegistros;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		&busquedaAvanzada
);

=item
buscarDatoReferencia
Busca el valor del dato que viene de referencia. Es un id que apunta a una tupla de una tabla y se buscan los campos que el usuario introdujo para que se vean. Se concatenan con el separador que el mismo introdujo.
=cut
sub buscarDatoReferencia{
	my ($dato,$tabla,$campos,$separador)=@_;
	
	my $ident=C4::AR::Utilidades::obtenerIdentTablaRef($tabla);

	my $dbh = C4::Context->dbh;
	my @camposArr=split(/,/,$campos);
	my $i=0;
	my $strCampos="";
	foreach my $camp(@camposArr){
		$strCampos.=", ".$camp . " AS dato".$i." ";
		$i++;
	}
	$strCampos=substr($strCampos,1,length($strCampos));
	my $query=" SELECT ".$strCampos;
	$query .= " FROM ".$tabla;
	$query .= " WHERE ".$ident." = ?";

	my $sth=$dbh->prepare($query);
   	$sth->execute($dato);
	my $data=$sth->fetchrow_hashref;
	$strCampos="";
	my $llave;
	for(my $j=0;$j<$i;$j++){
		$llave="dato".$j;
		$strCampos.=$separador.$data->{$llave};
	}
	
	if ($separador ne ''){ #Si existe un separador quito el 1ro que esta de mas
		$strCampos=substr($strCampos,1,length($strCampos));
	}
	return($strCampos);
}



1;
__END__
