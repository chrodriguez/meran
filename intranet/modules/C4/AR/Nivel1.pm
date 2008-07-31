package C4::AR::Nivel1;

use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&buscarNivel1PorId3

	&getAutoresAdicionales
	&getColaboradores
	&getUnititle

	&detalleNivel1
	&detalleNivel1MARC
	&detalleNivel1OPAC

);


=item

=cut

=item
buscarNivel1PorId3
Devuelve los datos del nivel 1 a partir de un id3
=cut
sub buscarNivel1PorId3{
        my ($id3) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT n1.*,a.* FROM nivel1 n1 INNER JOIN nivel3 n3 ON n1.id1 = n3.id1 
		     LEFT JOIN autores a ON n1.autor = a.id WHERE id3=? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($id3);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}



sub getAutoresAdicionales(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}


sub getColaboradores(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}

=item
Esta funcion retorna el untitle segun un id1
=cut
sub getUnititle {
	my($id1)= @_;
	return C4::AR::Busquedas::buscarDatoDeCampoRepetible($id1,"245","b","1");
}

sub detalleNivel1MARC{
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my $i=0;
	my $autor= $nivel1->{'autor'};
	
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	my $librarian= &C4::AR::Busquedas::getLibrarian('245', 'a',$nivel1->{'titulo'},'ALL',$tipo,1);
	$nivel1Comp[$i]->{'librarian'}=  $librarian->{'liblibrarian'}; 
	$i++;

	$autor= &C4::AR::Busquedas::getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM nivel1_repetibles WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data=$sth->fetchrow_hashref){
		$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
		$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
		$librarian= &C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},'ALL',$tipo,1);
		$nivel1Comp[$i]->{'dato'}= $librarian->{'dato'};
		$nivel1Comp[$i]->{'librarian'}= $librarian->{'liblibrarian'}; 
	
		$i++;
	}
	$sth->finish;
	return @nivel1Comp;
}

sub detalleNivel1OPAC{
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my $i=0;
	my $getLib;
	my $autor= $nivel1->{'autor'};
	
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	$getLib= &C4::AR::Busquedas::getLibrarian('245', 'a',$nivel1->{'titulo'}, 'ALL',$tipo,0);
	$nivel1Comp[$i]->{'librarian'}= $getLib->{'textPred'};
	$i++;

	$autor= &C4::AR::Busquedas::getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100"; #$autor->{'campo'}; se va a sacar de aca
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM nivel1_repetibles WHERE id1=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	while(my $data=$sth->fetchrow_hashref){
		$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
		$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
		$getLib= &C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'},$data->{'dato'}, 'ALL',$tipo,0);
		$nivel1Comp[$i]->{'librarian'}= $getLib->{'textPred'};
		$nivel1Comp[$i]->{'dato'}= $getLib->{'dato'};
		$i++;
	}
	$sth->finish;
	return @nivel1Comp;
}

=item
detalleNivel1
Trae todo los datos del nivel 1 para poder verlos en el template.
=cut
sub detalleNivel1{
	my ($id1, $nivel1,$tipo)= @_;
	my $dbh = C4::Context->dbh;
	my @nivel1Comp;
	my %llaves;
	my $i=0;
	my $autor= $nivel1->{'autor'};
	my $getLib=&C4::AR::Busquedas::getLibrarian('245', 'a', "",'ALL',$tipo,0);
	$nivel1Comp[$i]->{'campo'}= "245";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $nivel1->{'titulo'};
	$nivel1Comp[$i]->{'librarian'}= $getLib->{'liblibrarian'};
	$i++;

	$autor= &C4::AR::Busquedas::getautor($autor);
	$nivel1Comp[$i]->{'campo'}= "100";
	$nivel1Comp[$i]->{'subcampo'}= "a";
	$nivel1Comp[$i]->{'dato'}= $autor->{'completo'}; 
	$nivel1Comp[$i]->{'librarian'}= "Autor";
	$i++;

#trae nive1_repetibles
	my $query="SELECT * FROM nivel1_repetibles WHERE id1=? ORDER BY campo,subcampo";
	my $sth=$dbh->prepare($query);
        $sth->execute($id1);
	my $llave;
	while(my $data=$sth->fetchrow_hashref){
		$llave=$data->{'campo'}.",".$data->{'subcampo'};
		my $getLib=&C4::AR::Busquedas::getLibrarian($data->{'campo'}, $data->{'subcampo'}, $data->{'dato'},'ALL',$tipo,0);
		if(not exists($llaves{$llave})){
			$llaves{$llave}=$i;
			$nivel1Comp[$i]->{'campo'}= $data->{'campo'};
			$nivel1Comp[$i]->{'subcampo'}= $data->{'subcampo'};
			$nivel1Comp[$i]->{'dato'}= $getLib->{'dato'};
			$nivel1Comp[$i]->{'librarian'}=$getLib->{'liblibrarian'};
			$i++;
		}
		else{
			my $separador=" ".$getLib->{'separador'}." " ||", ";
			my $pos=$llaves{$llave};
			$nivel1Comp[$pos]->{'dato'}.=$separador.$getLib->{'dato'};
		}
	}
	$sth->finish;
	return @nivel1Comp;
}
