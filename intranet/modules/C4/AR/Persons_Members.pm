package C4::AR::Persons_Members;

#package para el manejo de Persons y Borrowers realizado para agregar la compatibilidad con Guarani
#written 3/05/2005 by einar@info.unlp.edu.ar

require Exporter;
use strict;
use C4::Circulation::Circ2;
use C4::AR::Usuarios;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);
@EXPORT = qw(delmember delmembers addmembers sepuedeeliminar checkDocument addborrower updateborrower addperson updateperson);

#delmembers recibe un arreglo de personnumbers y lo que hace es deshabilitarlos de la lista de miembros de la biblioteca, se invoca desde member2.pl  


sub delmembers{
  my (@member)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from persons where personnumber=?");
  my $result='';
  
  foreach my $aux (@member){
  $sth->execute($aux);
  my $data=$sth->fetchrow_hashref;
  ### Commeted by Luciano ###
  #open L, ">>/tmp/tt";
  #printf L $data->{'borrowernumber'};
  #close L;
  ### ###
  if ($data->{'borrowernumber'}) { # Si no tiene borrowernumber no esta habilitado
		delmember($data->{'borrowernumber'});
	}
	else {
	$result.='El usuario con tarjeta id: '.$data->{'cardnumber'}.' NO se encuentra habilitado!!! <br>';
	}
    }
  $sth->finish;
  
  return ($result);}

# delmembers recibe un arreglo de personnumbers y lo que hace es habilitarlos en la lista de miembros de la biblioteca, se invoca desde member2.pl  

sub addmembers{
  my (@member)=@_;
  my $result='';
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from persons where personnumber=?");
  foreach my $aux (@member){
  $sth->execute($aux);
  my $data=$sth->fetchrow_hashref;

   #Verificar que ya no exista como borrower
   my $sth2=$dbh->prepare("Select * from borrowers where cardnumber=?");
   $sth2->execute($data->{'cardnumber'});
   if (!$sth2->fetchrow_hashref){#no existe, se agrega

	#Se puede habilitar usurios irregulares??
	my $habilitar_irregulares= C4::Context->preference("habilitar_irregulares");
	if (($habilitar_irregulares eq 0)&&($data->{'regular'} eq 0)&&($data->{'categorycode'} eq 'ES')){# No es regular y no se puede habilitar regulares
	 $result.='El usuario con tarjeta id: '.$data->{'cardnumber'}.' es IRREGULAR y no puede ser habilitado!!! <br>';
	}else{
   	$data->{'borrowernumber'}=addborrower($data); #Se agregar en borrower
	#Se actualiza la persona con el borrowernumber
  	my $sth3=$dbh->prepare("Update persons set borrowernumber=".$data->{'borrowernumber'}." where personnumber=?");
  	$sth3->execute($aux);  
  	$sth3->finish;
	}
	 } else {
	 $result.='El usuario con tarjeta id: '.$data->{'cardnumber'}.' ya se encuentra habilitado!!! <br>';
	 }
    $sth2->finish;
    }

  $sth->finish;

  
  return ($result);}

#delmembers recibe un numero de borrower y lo que hace es deshabilitarlos de la lista de miembros de la biblioteca, se invoca desde eliminar borrower y desde ls funcion delmembers 


sub delmember{
  my ($member)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($member);
  if(my @data=$sth->fetchrow_array){#Si existe, se elimina
  $sth->finish;
  $sth=$dbh->prepare("Insert into deletedborrowers values (".("?,"x(scalar(@data)-1))."?)");
  $sth->execute(@data);
  $sth->finish;
  $sth=$dbh->prepare("Delete from borrowers where borrowernumber=?");
  $sth->execute($member);
  $sth->finish;
  $sth=$dbh->prepare("Delete from reserves where borrowernumber=?");
  $sth->execute($member);
  $sth->finish;
  $sth=$dbh->prepare("Update persons set borrowernumber=NULL where borrowernumber=?");
  $sth->execute($member);
  $sth->finish;
 } 
  return (1);
}
sub addmember{
  return (1);
}

# recibe el borrowernumber y devuelve un codigo avisando si se puede o no borrar el borrower


sub sepuedeeliminar{
  my ($member)=@_;
  my %env;
  my $issues=C4::AR::Issues::prestamosPorUsuario($member);
  my $i=0;
  foreach (sort keys %$issues) {
    $i++;
  }
  my ($bor,$flags)=getpatroninformation(\%env, $member,'');
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from borrowers where guarantor=?");
  $sth->execute($member);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  my @codigo=(0,0,0,0);
  if ($i > 0 || $flags->{'CHARGES'} ne '' || $data ne '') {
    $codigo[3]=-1;
    if ($i > 0) {
      $codigo[0]=-1; #Items on Issue
    }
    if ($flags->{'CHARGES'} ne '') {
      $codigo[1]=-1; #Deudas con la biblioteca
    }
    if ($data ne '') {
      $codigo[2]=-1; #Guarantees
    }
    return @codigo;
  } else {
    return (1,1,1,1);
  }
}

sub checkDocument{
  my ($type,$nro,$tipo,$skipCardnumber)=@_;
  # skipCardnumber is the id of a borrower that must be skipped in this search
  my $dbh = C4::Context->dbh;
  my $query= "Select * from $tipo where documentnumber='$nro' and documenttype='$type'";
  if ($skipCardnumber) {
    $query.=" and cardnumber <> '$skipCardnumber'";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute();
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  if ($data) {
    return 1;
  } else {
    return 0;
  }
}


##############################################################################################################

#addborrober agrega un borrower nuevo

sub addborrower {

my ($data)=@_;

my $dbh = C4::Context->dbh;

$data->{'borrowernumber'}=&NewBorrowerNumber();

my $query="insert into borrowers (borrowernumber,title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
  	  firstname,altnotes,dateofbirth,contactname,emailaddress,textmessaging,dateenrolled,streetcity,
    	  altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
      	  initials,ethnicity,physstreet,branchcode,zipcode,homezipcode,documenttype,documentnumber,
	  lastchangepassword,changepassword,studentnumber)  
	  values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NULL,?,?)";

my $sth=$dbh->prepare($query);

$sth->execute($data->{'borrowernumber'},$data->{'title'},$data->{'expiry'},$data->{'cardnumber'},
   	$data->{'sex'},$data->{'ethnotes'},$data->{'address'},$data->{'faxnumber'},
	$data->{'firstname'},$data->{'altnotes'},$data->{'dateofbirth'},$data->{'contactname'},$data->{'emailaddress'},
	$data->{'textmessaging'},$data->{'joining'},$data->{'streetcity'},$data->{'altrelationship'},$data->{'othernames'},
	$data->{'phoneday'},$data->{'categorycode'},$data->{'city'},$data->{'area'},$data->{'phone'},
	$data->{'borrowernotes'},$data->{'altphone'},$data->{'surname'},$data->{'initials'},
	$data->{'ethnicity'},$data->{'streetaddress'},$data->{'branchcode'},$data->{'zipcode'},$data->{'homezipcode'},
	$data->{'documenttype'},$data->{'documentnumber'},$data->{'updatepassword'},$data->{'studentnumber'});
  $sth->finish;
  


# Curso de usuarios#
if (C4::Context->preference("usercourse"))  {
		my $sql2="";
		if ($data->{'usercourse'} eq 1)
		{$sql2= "Update borrowers set usercourse=NOW() where borrowernumber=? and usercourse is NULL ; ";}
		else
		{$sql2= "Update borrowers set usercourse=NULL where borrowernumber=? ;";}

		my $sth3=$dbh->prepare($sql2);
		$sth3->execute($data->{'borrowernumber'});
		$sth3->finish;
}
####################

  return ($data->{'borrowernumber'});
  }


#updateborrober actualiza un borrower

sub updateborrower {

my ($data)=@_;
my $dbh = C4::Context->dbh;

my $query="Update borrowers set 
		title=?,expiry=?,cardnumber=?,
		sex=?,ethnotes=?,streetaddress=?,faxnumber=?,
		firstname=?,altnotes=?,dateofbirth=?,contactname=?,emailaddress=?,
		textmessaging=?,dateenrolled=?,streetcity=?,altrelationship=?,othernames=?,
		phoneday=?,categorycode=?,city=?,area=?,phone=?,
		borrowernotes=?,altphone=?,surname=?,initials=?,physstreet=?,
		ethnicity=?,gonenoaddress=?,lost=?,debarred=?,
		branchcode =?,zipcode =?,homezipcode=?,
		documenttype =?,documentnumber=?,changepassword=?,studentnumber=?
	  where borrowernumber=?";

my $sth=$dbh->prepare($query);

   $sth->execute($data->{'title'},$data->{'expiry'},$data->{'cardnumber'},
  	$data->{'sex'},$data->{'ethnotes'},$data->{'address'},$data->{'faxnumber'},
	$data->{'firstname'},$data->{'altnotes'},$data->{'dateofbirth'},$data->{'contactname'},$data->{'emailaddress'},		
	$data->{'textmessaging'},$data->{'joining'},$data->{'streetcity'},$data->{'altrelationship'},$data->{'othernames'},
	$data->{'phoneday'},$data->{'categorycode'},$data->{'city'},$data->{'area'},$data->{'phone'},
	$data->{'borrowernotes'},$data->{'altphone'},$data->{'surname'},$data->{'initials'},$data->{'streetaddress'},
	$data->{'ethnicity'},$data->{'gna'},$data->{'lost'},$data->{'debarred'},
	$data->{'branchcode'},$data->{'zipcode'},$data->{'homezipcode'},
	$data->{'documenttype'},$data->{'documentnumber'},$data->{'updatepassword'},$data->{'studentnumber'},
	$data->{'borrowernumber'});


   $sth->finish;
  

# Curso de usuarios#
if (C4::Context->preference("usercourse"))  {
		my $sql2="";
		if ($data->{'usercourse'} eq 1)
		{$sql2= "Update borrowers set usercourse=NOW() where borrowernumber=? and usercourse is NULL ; ";}
		else
		{$sql2= "Update borrowers set usercourse=NULL where borrowernumber=? ;";}

		my $sth3=$dbh->prepare($sql2);
		$sth3->execute($data->{'borrowernumber'});
		$sth3->finish;
}
####################

  return (1);
}


#addperson agrega un person nuevo

sub addperson {

my ($data)=@_;

my $dbh = C4::Context->dbh;



my $query="insert into persons (borrowernumber,title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
  	  firstname,altnotes,dateofbirth,contactname,emailaddress,textmessaging,dateenrolled,streetcity,
    	  altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
      	  initials,ethnicity,physstreet,branchcode,zipcode,homezipcode,documenttype,documentnumber,studentnumber) 
	  values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

my $sth=$dbh->prepare($query);

$sth->execute($data->{'borrowernumber'},$data->{'title'},$data->{'expiry'},$data->{'cardnumber'},
   	$data->{'sex'},$data->{'ethnotes'},$data->{'address'},$data->{'faxnumber'},
	$data->{'firstname'},$data->{'altnotes'},$data->{'dateofbirth'},$data->{'contactname'},$data->{'emailaddress'},
	$data->{'textmessaging'},$data->{'joining'},$data->{'streetcity'},$data->{'altrelationship'},$data->{'othernames'},
	$data->{'phoneday'},$data->{'categorycode'},$data->{'city'},$data->{'area'},$data->{'phone'},
	$data->{'borrowernotes'},$data->{'altphone'},$data->{'surname'},$data->{'initials'},
	$data->{'ethnicity'},$data->{'streetaddress'},$data->{'branchcode'},$data->{'zipcode'},$data->{'homezipcode'},
		  $data->{'documenttype'},$data->{'documentnumber'},$data->{'studentnumber'});
  $sth->finish;
 
#Averiguo el id de persona que se inserto
  my $sth2=$dbh->prepare("Select * from persons where cardnumber=?");
     $sth2->execute($data->{'cardnumber'});
  my $person=$sth2->fetchrow_hashref;
     $sth2->finish;
  return ($person->{'personnumber'});
  }


#updateperson actualiza un person

sub updateperson {

my ($data)=@_;
my $dbh = C4::Context->dbh;
my $query="Update persons set 
		title=?,expiry=?,cardnumber=?,
		sex=?,ethnotes=?,streetaddress=?,faxnumber=?,
		firstname=?,altnotes=?,dateofbirth=?,contactname=?,emailaddress=?,
		textmessaging=?,dateenrolled=?,streetcity=?,altrelationship=?,othernames=?,
		phoneday=?,categorycode=?,city=?,area=?,phone=?,
		borrowernotes=?,altphone=?,surname=?,initials=?,physstreet=?,
		ethnicity=?,gonenoaddress=?,lost=?,debarred=?,
		branchcode =?,zipcode =?,homezipcode=?,
		documenttype =?,documentnumber=?,studentnumber=?,borrowernumber=?
	  where personnumber=?";

my $sth=$dbh->prepare($query);

   $sth->execute($data->{'title'},$data->{'expiry'},$data->{'cardnumber'},
   	$data->{'sex'},$data->{'ethnotes'},$data->{'address'},$data->{'faxnumber'},
	$data->{'firstname'},$data->{'altnotes'},$data->{'dateofbirth'},$data->{'contactname'},$data->{'emailaddress'},
	$data->{'textmessaging'},$data->{'joining'},$data->{'streetcity'},$data->{'altrelationship'},$data->{'othernames'},
	$data->{'phoneday'},$data->{'categorycode'},$data->{'city'},$data->{'area'},$data->{'phone'},
	$data->{'borrowernotes'},$data->{'altphone'},$data->{'surname'},$data->{'initials'},$data->{'streetaddress'},
	$data->{'ethnicity'},$data->{'gna'},$data->{'lost'},$data->{'debarred'},
	$data->{'branchcode'},$data->{'zipcode'},$data->{'homezipcode'},
	$data->{'documenttype'},$data->{'documentnumber'},$data->{'studentnumber'},
	$data->{'borrowernumber'},$data->{'personnumber'});

   $sth->finish;
  
  return (1);
}

