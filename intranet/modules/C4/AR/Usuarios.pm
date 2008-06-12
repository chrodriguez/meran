package C4::AR::Usuarios;

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 
	&ListadoDeUsuarios
	&ListadoDePersonas
	&esRegular
	&estaSancionado
	&llegoMaxReservas
	&getBorrowerInfo
	&buscarBorrower
);


sub buscarBorrower {

	my ($busqueda) = @_;
	my $dbh = C4::Context->dbh;
	my $query;
	my $sth;
	$busqueda .= "%";

	my $query= " 	SELECT borrowernumber, surname, firstname, cardnumber, documentnumber, studentnumber 
			FROM borrowers
			WHERE (surname LIKE ?)OR(firstname LIKE ?)
			OR (cardnumber LIKE ?)OR(documentnumber LIKE ?)
			OR (studentnumber LIKE ?) ";

	
	$sth = $dbh->prepare($query);
	$sth->execute($busqueda, $busqueda, $busqueda, $busqueda, $busqueda);

	my @results;
	while (my $data = $sth->fetchrow_hashref) {
		push(@results, $data); 
	} # while
	$sth->finish;
	return(@results);
}

sub getBorrowerInfo {
# Devuelve toda la informacion del usuario segun un borrowernumber
	my ($borrowernumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query;
	my $sth;

	$query= "	SELECT borrowers.*,localidades.nombre as cityname , categories.description AS cat
			FROM borrowers LEFT JOIN categories ON categories.categorycode = borrowers.categorycode
			LEFT JOIN localidades ON localidades.localidad = borrowers.city
			WHERE borrowers.borrowernumber = ? ; ";

	$sth = $dbh->prepare($query);
	$sth->execute($borrowernumber);

	return ($sth->fetchrow_hashref);
}

sub esRegular {
#Verifica si un usuario es regular, todos los usuarios que no son estudiantes (ES), son regulares por defecto
        my ($bor) = @_;

        my $dbh = C4::Context->dbh;
	my $regular= 1; #Regular por defecto
        my $sth = $dbh->prepare(" SELECT regular FROM persons WHERE borrowernumber = ? AND categorycode='ES' " );
        $sth->execute($bor);
        my $reg = $sth->fetchrow();

	if (($reg eq 1) || ($reg eq 0)){$regular = $reg;}
        $sth->finish();
	
	return $regular;
	
}

sub llegoMaxReservas {
#Verifica si el usuario llego al maximo de las resevas que puede relizar sengun la preferencia del sistema
	my ($borrowernumber)=@_;

	my $cant= &C4::AR::Reservas::cant_reservas($borrowernumber);	

	return $cant >= C4::Context->preference("maxreserves");
}

sub estaSancionado {
#Verifica si un usuario esta sancionado segun un tipo de prestamo

	my ($borrowernumber,$issuecode)=@_;
	my $sancionado= 0;

	my @sancion= C4::AR::Sanctions::permitionToLoan($borrowernumber, $issuecode);

	if (($sancion[0]||$sancion[1])) { 
		$sancionado= 1;
	}

	return $sancionado;
}

=item ListadodeUsuarios

  ($cnt,\@results) = &ListadodeUsuarios($env,$searchstring,$type,$onlyCount);
  llamada por memberResult.pl
=cut
sub ListadoDeUsuarios  {
	my ($env,$searchstring,$type,$orden,$ini,$cantR)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query = "Select count(*) from borrowers b";
	my $query2 = "Select * from borrowers ";
	my $where;

	if($type eq "simple")	# simple search for one letter only
	{
		$where=" where surname like ? ";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
		@data=split(' ',$searchstring);
                $count=@data;
                $where=" where (surname like ? or surname like ?
		or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ?
		or  studentnumber like ? or  studentnumber like ?)";
                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%");

                for (my $i=1;$i<$count;$i++){
                	$where.=" and  (surname like ? or surname like ?
	     		or  firstname like ? or firstname like ?
                	or  documentnumber  like ? or  documentnumber like ?
                	or  cardnumber like ? or  cardnumber like ?
			or  studentnumber  like ? or  studentnumber like ? )";
	
                	push(@bind,"$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
                }

	}
	
	$query.=$where;
	$query2.=$where." order by ".$orden." limit ?,?";
	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my $cnt= $sth->fetchrow;
	$sth->finish;

	my $sth=$dbh->prepare($query2);
	$sth->execute(@bind,$ini,$cantR);
	my @results;
	while (my $data=$sth->fetchrow_hashref){
		push(@results,$data);
	}
	$sth->finish;

	return ($cnt,\@results);
}



=item
  ($cnt,\@results) = &ListadoDePersonas($env,$searchstring,$type,$onlyCount);
  llamada por member2Result.pl	
=cut

sub ListadoDePersonas  {
	my ($env,$searchstring,$type,$orden,$ini,$cantR)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query="Select count(*) from persons ";
	my $query2="Select * from persons ";
	my $where;
	if($type eq "simple")	# simple search for one letter only
	{
		$where="where surname like ? ";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
   		@data=split(' ',$searchstring);
                $count=@data;
                $where="where (surname like ? or surname like ?
		or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ? 
		or  studentnumber  like ? or  studentnumber like ? )";
                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%", "$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%" );

                for (my $i=1;$i<$count;$i++){
                	$where.=" and  (surname like ? or surname like ?
		  	or  firstname like ? or firstname like ?
                	or  documentnumber  like ? or  documentnumber like ?
                	or  cardnumber like ? or  cardnumber like ?
                	or  studentnumber  like ? or  studentnumber like ? )";

        		push(@bind,"$data[$i]%","% $data[$i]%", "$data[$i]%","% $data[$i]%", "$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
                }

	}

	$query.=$where;
	$query2.=$where." order by ".$orden." limit ?,?";

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my $cnt= $sth->fetchrow;
	$sth->finish;

	my $sth=$dbh->prepare($query2);
	$sth->execute(@bind,$ini,$cantR);
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	  	push(@results,$data);
	}
	$sth->finish;
	return ($cnt,\@results);
}


1