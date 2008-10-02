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
	&getBorrower
	&getBorrowerInfo
	&buscarBorrower
	&obtenerCategoria
	&obtenerCategorias
	&mailIssuesForBorrower
	&personData
	&BornameSearchForCard
	&NewBorrowerNumber
	&findguarantees
	&updateOpacBorrower
	&cambiarPassword
);


sub verficarPassword {

	my($params)=@_;

	my $error= 0;
	my $codMsg= '000';
	my @paraMens;

	if( !($error) && ($params->{'newpassword'} eq "") ){
	#password en blanco
		$error= 1;
		$codMsg= 'U314';
	}

	if( !($error) && ( $params->{'newpassword'} ne $params->{'newpassword1'} ) ){
	#las password no coinciden
		$error= 1;
		$codMsg= 'U315';
	}

	if( !($error) && ( length($params->{'newpassword'}) < C4::Context->preference("minPassLength") ) ){
	#la password no respeta la longitud minima
		$error= 1;
		$codMsg= 'U316';
	}

## FIXME faltaria seguir agregando validaciones, tales como:
# maxPassLength, Maximum length of the password
# * maxSpace Maximum number of white space characters

# *
# * minUpper Minimum number of uppercase characters
# * minLower Minimum number of lowercase characters
# * minNumeric Minimum number of numeric characters (0-9)
# * minAlphaNum Minimum number of alphanumeric characters
# * minAlpha Minimum number of alphabetic characters
# * minSymbol Minimum number of alphabetic characters

	return ($error, $codMsg,\@paraMens);
}

sub t_cambiarPassword {
	
	my($params)=@_;
	my $dbh = C4::Context->dbh;
# 	my ($error, $codMsg, $paraMens);

	my ($error,$codMsg,$paraMens)= &verficarPassword($params);

	if(!$error){
	#No hay error

		$dbh->{AutoCommit} = 0;  # enable transactions, if possible
		$dbh->{RaiseError} = 1;
	
		eval {
			($error, $codMsg, $paraMens)= cambiarPassword($params);	
			$dbh->commit;
		};
	
		if ($@){
			#Se loguea error de Base de Datos
			$codMsg= 'B420';
			&C4::AR::Mensajes::printErrorDB($@, $codMsg,"INTRA");
			eval {$dbh->rollback};
			#Se setea error para el usuario
			$error= 1;
			$codMsg= 'U313';
		}
		$dbh->{AutoCommit} = 1;

	}

	my $message= &C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);

	return ($error, $codMsg, $message);
}

sub cambiarPassword{

	my ($params) = @_;
	my $dbh = C4::Context->dbh;

	my ($error,$codMsg,$paraMens);
	$error= 0;
	
	my %env;
	my ($borrower,$flags)= C4::Circulation::Circ2::getpatroninformation($params->{'usuario'},'');

	$params->{'userid'}= $borrower->{'userid'};
	$params->{'surename'}= $borrower->{'surename'};
	$params->{'firstname'}= $borrower->{'firstname'};

	my $digest= C4::Auth::md5_base64($params->{'newpassword'});
	my $dbh=C4::Context->dbh;
	#Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
	#Then we need to tell the user and have them create a new one.
## FIXME el userid parece que no se usa!!!!!!!!!!!!!	
	my $sth2=$dbh->prepare("	SELECT * 
					FROM borrowers 
					WHERE userid=? AND borrowernumber != ?");

	$sth2->execute($params->{'userid'},$params->{'usuario'});
	
	if ( ($params->{'userid'} ne '') && ($sth2->fetchrow) ) {
	#ya existe el userid
		$error= 1;
		$codMsg= 'U311';
		$paraMens->[0]= $params->{'userid'};
		$paraMens->[1]= $params->{'surename'};
		$paraMens->[2]= $params->{'firstname'};

	}else {
		#Esta todo bien, se puede actualizar la informacion
		my $sth=$dbh->prepare("	UPDATE borrowers SET userid=?, password=? 
					WHERE borrowernumber=? ");

		$sth->execute($params->{'userid'}, $digest, $params->{'usuario'});
		
		my $sth3=$dbh->prepare("	SELECT cardnumber FROM borrowers 
						WHERE borrowernumber = ? ");

		$sth3->execute($params->{'usuario'});

		if (my $cardnumber= $sth3->fetchrow) {
		#Se actualiza el ldap
## FIXME no se para que se le pasa el $template
			my $template; 
			if (C4::Membersldap::addupdateldapuser($dbh,$cardnumber,$digest,$template)){
# 				$template->param(errorldap => 1);
			}
		}

		$codMsg= 'U312';
	}

	return ($error,$codMsg,$paraMens);
}


sub buscarBorrower{
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

sub getBorrower{
	my ($borrowernumber) = @_;

	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM borrowers WHERE borrowernumber=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber);

	return ($sth->fetchrow_hashref);
}

sub getBorrowerInfo {
# Devuelve toda la informacion del usuario segun un borrowernumber
	my ($borrowernumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query;
	my $sth;

	$query= "	SELECT borrowers.*,localidades.nombre as cityname , categories.description AS categoria
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
        my $sth = $dbh->prepare(" 	SELECT regular 
					FROM persons 
					WHERE borrowernumber = ? AND categorycode='ES' " );
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

=item
obtenerCategoria
Obtiene la categoria de un usuario en particular.
=cut
# FIXME ES NECESARIO EL SELECT en la tabla persons!!!!!!!!!!
sub obtenerCategoria{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT categorycode FROM persons WHERE borrowernumber = ?");
        $sth->execute($bor);
        my $condicion = $sth->fetchrow();
	if (not $condicion){
		$sth = $dbh->prepare("SELECT categorycode FROM borrowers WHERE borrowernumber = ?");
       		$sth->execute($bor);
        	$condicion = $sth->fetchrow();
			}
	$sth->finish();
        return $condicion;
} 

sub obtenerCategorias {
    my $dbh = C4::Context->dbh;

    my $sth=$dbh->prepare("SELECT categorycode,description FROM categories ORDER BY description");
    $sth->execute();
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'categorycode'};
      $labels{$data->{'categorycode'}}=$data->{'description'};
    }
    $sth->finish;

    return(\@codes,\%labels);
}


sub mailIssuesForBorrower{
  	my ($branch,$bornum)=@_;

  	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
  	my $sth=$dbh->prepare("SELECT * 
				FROM issues
				LEFT JOIN nivel3 n3 ON n3.id3 = issues.id3
				LEFT JOIN nivel1 n1 ON n3.id1 = n1.id1
				WHERE issues.returndate IS NULL AND issues.date_due <= now( ) 
				AND issues.branchcode = ? AND issues.borrowernumber = ? ");
    	$sth->execute($branch,$bornum);
  	my @result;
  	my @datearr = localtime(time);
	my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];	
  	while (my $data = $sth->fetchrow_hashref) {
		#Para que solo mande mail a los prestamos vencidos
		$data->{'vencimiento'}=format_date(C4::AR::Issues::vencimiento($data->{'id3'}),$dateformat);
		my $flag=Date::Manip::Date_Cmp($data->{'vencimiento'},$hoy);
		if ($flag lt 0){
			#Solo ingresa los prestamos vencidos a el arreglo a retornar
    			push @result, $data;
		}
  	}
  	$sth->finish;

  	return(scalar(@result), \@result);
}

=item
personData
Busca los datos de una persona, que viene como parametro.
=cut
# FIXME SE USA EN moremember2.pl y memberentry2.pl POR AHI SE PUEDE BORRAR
sub personData {
  	my ($bornum)=@_;
 	my $dbh = C4::Context->dbh;
  	my $sth=$dbh->prepare("Select * from persons where personnumber=?");
  	$sth->execute($bornum);

  	my $data=$sth->fetchrow_hashref;
  	$sth->finish;

  	return($data);
}


=item
BornameSearchForCard
Busca todos los usuarios, con sus datos, entre un par de nombres o legajo para poder crear los carnet.
=cut
sub BornameSearchForCard{
	my ($surname1,$surname2,$category,$branch,$orden,$regular,$legajo1,$legajo2) = @_;
	my @bind=();
	my $dbh = C4::Context->dbh;
	my $query = "SELECT borrowers.*,categories.description AS categoria FROM borrowers LEFT JOIN categories ON categories.categorycode = borrowers.categorycode WHERE borrowers.branchcode = ? ";
	push (@bind,$branch);

	if (($category ne '')&& ($category ne 'Todos')) {
		$query.= " AND borrowers.categorycode = ? ";
		push (@bind,$category);
	}
	if (($surname1 ne '') || ($surname2 ne '')){
		if ($surname2 eq ''){ 
			$query.= " AND borrowers.surname LIKE ? ";
                       	push (@bind,"$surname1%"); 
		}
		else{
			$query.= " AND borrowers.surname BETWEEN ? AND ? ";
                	push (@bind,$surname1,$surname2);
		}
	}
	if (($legajo1 ne '') || ($legajo2 ne '')){
		if ($legajo2 eq '') {
			$query.= " AND borrowers.studentnumber LIKE ? ";
                       	push (@bind,"$legajo1%"); 
		}
		else{
			$query.= " AND borrowers.studentnumber BETWEEN ? AND ? ";
                	push (@bind,$legajo1,$legajo2);
		}
	}

	if ($orden ne ''){$query.= " ORDER BY  borrowers.$orden ASC ";}
	else {$query.= " ORDER BY  borrowers.surname ASC ";}

	my $sth = $dbh->prepare($query);
	$sth->execute(@bind);
 	my @results;
 	my $i=-1;
 	while (my $data=$sth->fetchrow_hashref){
		my $reg=  &C4::AR::Usuarios::esRegular($data->{'borrowernumber'});
		my $pasa=1;

		if (($regular ne '')&&($regular ne 'Todos')){ #Se tiene que filtrar por regularidad??
 	  		if (($data->{'categorycode'} ne 'ES') || ($reg ne $regular)){$pasa=0;}
		}
		if ($pasa == 1){ #Pasa el filtro
			$i++; 
			$results[$i]=$data; 
			$results[$i]->{'city'}=C4::AR::Busquedas::getNombreLocalidad($results[$i]->{'city'});
			if ($results[$i]->{'categorycode'} eq 'ES'){
				$results[$i]->{'regular'}= $reg;
				if ($results[$i]->{'regular'} eq 1){
					$results[$i]->{'regular'}="<font color='green'>Regular</font>";
				}
				elsif($results[$i]->{'regular'} eq 0){
					$results[$i]->{'regular'}="<font color='red'>Irregular</font>";
				}
			}
			else{$results[$i]->{'regular'}="---";};
		}
	}
 	$sth->finish;
 	return(scalar(@results),@results);
}

=item 
NewBorrowerNumber
Devulve el maximo borrowernumber
Posiblemente no se usa o no sierve!!!!!!! VER!!!!!!!!!!!!
=cut
sub NewBorrowerNumber{
  	my $dbh = C4::Context->dbh;
  	my $sth=$dbh->prepare("SELECT MAX(borrowernumber) FROM borrowers");
  	$sth->execute;
  	my $data=$sth->fetchrow_hashref;
  	$sth->finish;
  	$data->{'max(borrowernumber)'}++;
  	return($data->{'max(borrowernumber)'});
}

=item 
findguarantees

  ($num_children, $children_arrayref) = &findguarantees($parent_borrno);
  $child0_cardno = $children_arrayref->[0]{"cardnumber"};
  $child0_borrno = $children_arrayref->[0]{"borrowernumber"};

C<&findguarantees> takes a borrower number (e.g., that of a patron
with children) and looks up the borrowers who are guaranteed by that
borrower (i.e., the patron's children).

C<&findguarantees> returns two values: an integer giving the number of
borrowers guaranteed by C<$parent_borrno>, and a reference to an array
of references to hash, which gives the actual results.

SE USA EN insertdata.pl ----- VER!!!!!!!!!!!!!!!!!!!!
POSIBLEMENTE SE PUEDA BORRAR !!!!! BUSCA HIJOS!!!!!!!
=cut
sub findguarantees{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT cardnumber,borrowernumber, firstname, surname FROM borrowers WHERE guarantor=?");
  $sth->execute($bornum);

  my @dat;
  while (my $data = $sth->fetchrow_hashref)
  {
    push @dat, $data;
  }
  $sth->finish;
  return (scalar(@dat), \@dat);
}

sub updateOpacBorrower{
	my($update) = @_;
	my $dbh = C4::Context->dbh;
	my $query="UPDATE borrowers SET streetaddress=?, faxnumber=?, firstname=?, emailaddress=?, 
		city=?, phone=?, surname=? WHERE borrowernumber=?";

	my $sth=$dbh->prepare($query);
  	$sth->execute($update->{'streetaddress'},$update->{'faxnumber'},$update->{'firstname'},$update->{'emailaddress'},$update->{'city'},$update->{'phone'},$update->{'surname'},$update->{'borrowernumber'});
	$sth->finish;
}





1;