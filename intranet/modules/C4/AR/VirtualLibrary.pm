package C4::AR::VirtualLibrary;

#
# Este modulo sera el encargado del manejo de la Biblioteca Virtual
# pedidos, informes y multas seran manejados aqui. 
#
#

use strict;
require Exporter;

use C4::Context;
use C4::Date;
use Date::Manip;



use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&virtualRequests 
 	   &allVirtualRequests
	   &virtualBibitems 
	   &virtualSearch 
	   &VirtualKeywordSearch
	   &CreateRequest
	&ConditionVirtualRequest
	&CompleteVirtualRequest
	&AquireVirtualRequest
	&DeleteVirtualRequest
	&requestsReport
	&completeReport
	&aquireReport
	&allRequests
	&canPrint
	&countPrint
	&canCopy
	&countCopy
	&requestType
	);

#Cuenta la cantidad de impresiones que solicito el usuario dentro del intervalo dado por "virtualprintrenew"
#
sub countPrint{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
	my $DAYSRENEW= C4::Context->preference("virtualprintrenew");

	my @datearr = localtime(time);
	my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	$today = C4::Date::format_date_in_iso($today,$dateformat);

#Se toman en cuenta solo los pedidos entregados entre la fecha calculada con la cantidad de dias que indica "virtualrenew" hasta hoy.
	my $err; 
	my $firstDate = DateCalc($today,"- ".$DAYSRENEW." days",\$err);
        $firstDate = C4::Date::format_date_in_iso($firstDate,$dateformat);
   
	my $query ="SELECT count( * ) as cantidad
			FROM virtual_request
			INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
			LEFT JOIN virtual_itemtypes ON virtual_itemtypes.itemtype = biblioitems.itemtype
			WHERE borrowernumber =? AND (
			(date_complete between '$firstDate' AND '$today') OR (
			(date_complete IS NULL) AND (date_request between '$firstDate' AND  '$today'))) 
			 AND virtual_itemtypes.requesttype = 'print' ;";

        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $cant;
        my $data=$sth->fetchrow_hashref;
   	$cant=$data->{'cantidad'};
	return $cant;
}


#Revisa si el usuario puede realizar una impresion
#
sub canPrint{
        my ($bor) = @_;
	my $cant= countPrint($bor);	
	my $MAX_PRINT = C4::Context->preference("maxvirtualprint");
	if ($cant >= $MAX_PRINT){return 0} else {return 1};
		}
#Revisa si el usuario puede realizar una copia
#
sub countCopy{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
        my $DAYSRENEW = C4::Context->preference("virtualcopyrenew");

        my @datearr = localtime(time);
        my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
        $today = C4::Date::format_date_in_iso($today,$dateformat);

#Se toman en cuenta solo los pedidos entregados entre la fecha calculada con la cantidad de dias que indica "virtualrenew" hasta hoy.
        my $err;
        my $firstDate = DateCalc($today,"- ".$DAYSRENEW." days",\$err);
        $firstDate = C4::Date::format_date_in_iso($firstDate,$dateformat);

        my $query ="



	SELECT count( * ) as cantidad
                        FROM virtual_request
                        INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
                        LEFT JOIN virtual_itemtypes ON virtual_itemtypes.itemtype = biblioitems.itemtype
                        WHERE borrowernumber =? AND (
                        (date_complete between '$firstDate' AND '$today' ) OR (
                        (date_complete IS NULL) AND (date_request between '$firstDate' AND '$today') 
                        )) AND virtual_itemtypes.requesttype = 'copy' ;";

        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $cant;
        my $data=$sth->fetchrow_hashref;
        $cant=$data->{'cantidad'};
        return $cant;
}

#Revisa si el usuario puede realizar una copia
#
sub canCopy{
        my ($bor) = @_;
        my $cant = countCopy($bor);
        my $MAX_COPY = C4::Context->preference("maxvirtualcopy");
        if ($cant >= $MAX_COPY){return 0} else {return 1};
                }


#Tipo de requerimiento de un biblioitem
#
sub requestType{
        my ($bibnum) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT virtual_itemtypes.requesttype
                        FROM biblioitems LEFT JOIN virtual_itemtypes ON  virtual_itemtypes.itemtype = biblioitems.itemtype
                        WHERE biblioitems.biblioitemnumber = ? ";
        my $sth=$dbh->prepare($query);
        $sth->execute($bibnum);
        my $data=$sth->fetchrow_hashref;
	
        return ($data->{'requesttype'});
}


#Requerimientos de un usuario para un grupo
#
sub allVirtualRequests{
        my ($bibnum,$bor) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT virtual_request.borrowernumber, virtual_request.biblioitemnumber, virtual_itemtypes.requesttype
                        FROM virtual_request
                        INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
                        LEFT JOIN virtual_itemtypes ON  virtual_itemtypes.itemtype = biblioitems.itemtype
                        WHERE virtual_request.borrowernumber= ? AND virtual_request.biblioitemnumber = ?
                        ORDER BY virtual_request.date_request DESC";
        my $sth=$dbh->prepare($query);
        $sth->execute($bor,$bibnum);
        my $cant=0;
        while (my $data=$sth->fetchrow_hashref){
        $cant++;
         push(@results,$data);
        }
        return ($cant,@results);
}

#Requerimientos de un usuario
#
sub allRequests{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
        my @results;
        my $query ="SELECT virtual_request.biblioitemnumber, virtual_request.date_request,virtual_request.date_complete,virtual_request.condition ,virtual_itemtypes.requesttype, itemtypes.description, biblio.title, biblio.author, biblioitems.biblionumber, biblioitems.volume, biblioitems.volumeddesc,branches.branchname
FROM virtual_request
INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
INNER JOIN biblio ON biblio.biblionumber = biblioitems.biblionumber
LEFT JOIN virtual_itemtypes ON virtual_itemtypes.itemtype = biblioitems.itemtype
INNER JOIN itemtypes ON virtual_itemtypes.itemtype = itemtypes.itemtype
INNER JOIN branches ON branches.branchcode = virtual_request.branchcode
WHERE virtual_request.borrowernumber = ? AND virtual_request.date_aquire IS NULL
ORDER BY virtual_request.date_request DESC";
        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $cant=0;
        while (my $data=$sth->fetchrow_hashref){
        $cant++;

if($data->{'requesttype'} eq 'copy'){$data->{'copy'}=1;}else{$data->{'print'}=1;}
if ($data->{'condition'} eq 0){ $data->{'state'}='Falta Cumplir Condici&oacute;n'}
else{	if($data->{'date_complete'} eq '')
	{ $data->{'state'}='Pendiente'}
	else  { $data->{'state'}='<b>Cumplido ('.format_date($data->{'date_complete'},$dateformat).')</b>'};	
  	}

        push(@results,$data);
        }
        return ($cant,@results);
}

#Elimina un  Requerimiento
sub DeleteVirtualRequest {
                                                                                                                             
  my ($borrower,$bibnum, $ts) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="DELETE FROM virtual_request  Where borrowernumber = ?  and biblioitemnumber = ?  and timestamp = ? and date_complete IS NULL " ;
        my $sth=$dbh->prepare($query);
        $sth->execute($borrower,$bibnum,$ts);
}


#Cumple la condicion de un  Requerimiento
sub ConditionVirtualRequest {
                                                                                                                             
  my ($ts) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
       my $query ="UPDATE virtual_request SET condition = 1  WHERE timestamp = ? ";
                                                                                                                             
        my $sth=$dbh->prepare($query);
        $sth->execute($ts);
}

#Completa un  Requerimiento
sub CompleteVirtualRequest {
                                   
  my ($borrower,$bibnum, $ts,$branch,$date) = @_;
        my $dbh = C4::Context->dbh;
        my @results; 
       my $query ="UPDATE virtual_request SET date_complete = ?  WHERE borrowernumber = ? AND biblioitemnumber = ?  AND branchcode = ? AND timestamp = ? ";
 
        my $sth=$dbh->prepare($query);
        $sth->execute($date,$borrower,$bibnum,$branch, $ts);
}

#Se adquiere el Requerimiento
sub AquireVirtualRequest {

  my ($borrower,$bibnum, $ts,$branch,$date) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
       my $query ="UPDATE virtual_request SET date_aquire = ?  WHERE borrowernumber = ? AND biblioitemnumber = ?  AND branchcode = ? AND timestamp = ? ";

        my $sth=$dbh->prepare($query);
        $sth->execute($date,$borrower,$bibnum,$branch, $ts);
}



#Crear un  Requerimiento
sub CreateRequest {

  my ($branch,$borrower,$bibnum,$date) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="INSERT INTO `virtual_request` ( `borrowernumber` , `biblioitemnumber` , `date_request` , `branchcode` , `timestamp` ) 
VALUES (?,?,?,?, NOW());" ;
        my $sth=$dbh->prepare($query);
        $sth->execute($borrower,$bibnum,$date,$branch);
}

#
#Requerimientos Actuales de un grupo
#
sub virtualRequests{
	my ($bibnum) = @_;
	my $dbh = C4::Context->dbh;
	my @results;
	my $query ="SELECT virtual_request.borrowernumber, virtual_request.date_request, virtual_request.timestamp, 
		virtual_request.biblioitemnumber,virtual_itemtypes.requesttype, biblio.title, biblio.author, borrowers.surname, borrowers.firstname, 
			biblioitems.volumeddesc, biblioitems.itemtype, branches.branchname , virtual_request.date_aquire ,
			virtual_request.date_complete  
			FROM virtual_request
			INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
			INNER JOIN biblio ON biblioitems.biblionumber = biblio.biblionumber
			INNER JOIN borrowers ON borrowers.borrowernumber = virtual_request.borrowernumber
			INNER JOIN branches ON branches.branchcode = virtual_request.branchcode
			INNER JOIN virtual_itemtypes on virtual_itemtypes.itemtype = biblioitems.itemtype
			WHERE virtual_request.date_aquire IS NULL 
			AND virtual_request.biblioitemnumber = ?
			ORDER BY virtual_request.date_request DESC";
	my $sth=$dbh->prepare($query);
	$sth->execute($bibnum);
	my $cant=0;
        while (my $data=$sth->fetchrow_hashref){
	$cant++;           
     	push(@results,$data);
        }
        return ($cant,@results);
}



#
#Requerimientos Actuales para una unidad de informacion
#
sub requestsReport{
        my ($branch) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT virtual_request.borrowernumber, virtual_request.date_request, virtual_request.timestamp, virtual_request.condition, virtual_request.biblioitemnumber,virtual_itemtypes.requesttype, biblio.title, biblio.author,biblio.biblionumber, borrowers.surname, borrowers.firstname,
                        biblioitems.volumeddesc, biblioitems.itemtype, branches.branchname, borrowers.emailaddress
                        FROM virtual_request
                        INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
                        INNER JOIN biblio ON biblioitems.biblionumber = biblio.biblionumber
                        INNER JOIN borrowers ON borrowers.borrowernumber = virtual_request.borrowernumber
                        INNER JOIN branches ON branches.branchcode = virtual_request.branchcode
			INNER JOIN virtual_itemtypes on virtual_itemtypes.itemtype = biblioitems.itemtype
                        WHERE virtual_request.date_complete IS NULL AND virtual_request.branchcode= ?
                        ORDER BY virtual_request.date_request DESC";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my $cant=0;
        while (my $data=$sth->fetchrow_hashref){
        $cant++;
        push(@results,$data);
        }
        return ($cant,@results);
}


#
#Requerimientos Completos para una unidad de informacion
#
sub completeReport{
        my ($branch) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT virtual_request.borrowernumber, virtual_request.date_request,virtual_request.date_complete, virtual_request.timestamp,
                virtual_request.biblioitemnumber,virtual_itemtypes.requesttype, biblio.title, biblio.author,biblio.biblionumber, borrowers.surname, borrowers.firstname,
                        biblioitems.volumeddesc, biblioitems.itemtype, branches.branchname, borrowers.emailaddress
                        FROM virtual_request
                        INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
                        INNER JOIN biblio ON biblioitems.biblionumber = biblio.biblionumber
                        INNER JOIN borrowers ON borrowers.borrowernumber = virtual_request.borrowernumber
                        INNER JOIN branches ON branches.branchcode = virtual_request.branchcode
                        INNER JOIN virtual_itemtypes on virtual_itemtypes.itemtype = biblioitems.itemtype
                        WHERE virtual_request.date_complete IS NOT NULL AND virtual_request.date_aquire IS NULL AND virtual_request.branchcode= ?
                        ORDER BY virtual_request.date_request DESC";
        my $sth=$dbh->prepare($query);
        $sth->execute($branch);
        my $cant=0;
        while (my $data=$sth->fetchrow_hashref){
        $cant++;
        push(@results,$data);
        }
        return ($cant,@results);
}

#
#Registro de ejemplares adquiridos
#
sub aquireReport{
        my ($bor, $order , $limit) = @_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="SELECT virtual_request.borrowernumber, virtual_request.date_request,virtual_request.date_complete, virtual_request.date_aquire , virtual_request.timestamp, virtual_request.biblioitemnumber,virtual_itemtypes.requesttype, biblio.title, biblio.author,biblio.biblionumber, borrowers.surname, borrowers.firstname,
                        biblioitems.volumeddesc, biblioitems.itemtype, branches.branchname, borrowers.emailaddress
                        FROM virtual_request
                        INNER JOIN biblioitems ON virtual_request.biblioitemnumber = biblioitems.biblioitemnumber
                        INNER JOIN biblio ON biblioitems.biblionumber = biblio.biblionumber
                        INNER JOIN borrowers ON borrowers.borrowernumber = virtual_request.borrowernumber
                        INNER JOIN branches ON branches.branchcode = virtual_request.branchcode
                        INNER JOIN virtual_itemtypes on virtual_itemtypes.itemtype = biblioitems.itemtype
                        WHERE virtual_request.date_aquire IS NOT NULL AND virtual_request.borrowernumber = ?
                        ORDER BY $order $limit";
        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $cant=0;
        while (my $data=$sth->fetchrow_hashref){
        $cant++;
        push(@results,$data);
        }
        return ($cant,@results);
}


#Grupos Virtuales

sub virtualBibitems {
    my ($bibnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("SELECT biblioitems. * , virtual_itemtypes. * , itemtypes.description
				FROM biblioitems
				LEFT JOIN virtual_itemtypes ON biblioitems.itemtype = virtual_itemtypes.itemtype
				LEFT JOIN itemtypes ON virtual_itemtypes.itemtype = itemtypes.itemtype
				WHERE biblioitems.biblionumber = ? AND biblioitems.itemtype = virtual_itemtypes.itemtype ");
    my $count = 0;
    my @results;
    $sth->execute($bibnum);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
        $count++;
    } # while
    $sth->finish;
    return($count, @results);
}  

sub virtualSearch{
		my ($env,$search)=@_;
                my $dbh = C4::Context->dbh;
	        my $query = '';
        	my @bind = ();
	        my @results;

		if ($search->{'virtual'} ne ''){
        	$query="Select * from biblio inner join biblioitems on
         		biblio.biblionumber=biblioitems.biblionumber  
			left join virtual_itemtypes on biblionumber.itemtype= virtual_itemtypes.itemtype";
                                
		}

}

sub VirtualKeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'virtual'}=~ s/ +$//;
  my @key=split(' ',$search->{'virtual'});
  my $count=@key;
  my $i=1;
  my %biblionumbers;            # Set of biblionumbers returned by the various searches.
  my $query;                    # The SQL query
  my @clauses = ();             # The search clauses
  my @bind = ();                # The term bindings
  
$query = <<EOT;               # Beginning of the query
        SELECT  biblio.biblionumber
       FROM    biblio left join  biblioitems on biblio.biblionumber=biblioitems.biblionumber
        inner join virtual_itemtypes on biblioitems.itemtype= virtual_itemtypes.itemtype
        WHERE
EOT
  foreach my $keyword (@key)
  {
    my @subclauses = ();        # Subclauses, one for each field we're searching on
    
   # For each field we're searching on, create a subclause that'll
    # match the current keyword in the current field.
    foreach my $field (qw(title biblio.notes biblioitems.seriestitle author))
    {
      push @subclauses,
        "$field LIKE ? OR $field LIKE ?";
          push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
    }
    # Construct the current clause by joining the subclauses.
    push @clauses, "(" . join(")\n\tOR (", @subclauses) . ")";
  }
  # Now join all of the clauses together and append to the query.
  $query .= "(" . join(")\nAND (", @clauses) . ")";
  
  my $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;
  
# Now look for keywords in the 'bibliosubtitle' table.
  # Again, we build a list of clauses from the keywords.
  @clauses = ();
  @bind = ();
  $query = "SELECT bibliosubtitle.biblionumber FROM bibliosubtitle 
	left join  biblioitems on bibliosubtitle.biblionumber=biblioitems.biblionumber
        inner join virtual_itemtypes on biblioitems.itemtype= virtual_itemtypes.itemtype
	WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
        "subtitle LIKE ? OR subtitle like ?";
        push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";
  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
{
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;                                                                                                                                                                                                                                             # Look for keywords in the 'bibliosubject' table.
  $sth=$dbh->prepare("Select bibliosubject.biblionumber from bibliosubject  
	left join  biblioitems on bibliosubject.biblionumber=biblioitems.biblionumber
        inner join virtual_itemtypes on biblioitems.itemtype= virtual_itemtypes.itemtype
	where subject like ? group by biblionumber");
  $sth->execute("%$search->{'virtual'}%");
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
        $biblionumbers{$_} = 1;         # Add these results to the set
    }
  }
  $sth->finish;
  
  my $i2=0;
  my $i3=0;
  my $i4=0;
  my @res2;
  my @res = keys %biblionumbers;
  $count=@res;
  $i=0;

  while ($i2 < $num && $i2 < $count){
    my $query="select biblio.*, biblioitems.biblioitemnumber, volume, number, classification, biblioitems.itemtype, 
		isbn, issn, dewey, subclass, publicationyear, publishercode, volumedate, volumeddesc, biblioitems.timestamp,
		 illus, pages, biblioitems.notes, size, place, url, lccn, marc ,
		virtual_itemtypes.requesttype
    from biblio left join  biblioitems on biblio.biblionumber=biblioitems.biblionumber  
	inner join virtual_itemtypes on biblioitems.itemtype= virtual_itemtypes.itemtype
	where biblio.biblionumber=?";
    my @bind=($res[$i2+$offset]);
    
    my $sth=$dbh->prepare($query);
#    print $query;
    $sth->execute(@bind);
	
# Para el tipo de pedidos
my $rt='';
my $add=0;
    while (my $data2=$sth->fetchrow_hashref){
       if ($add eq 0) {$res2[$i]=$data2;
		        $res2[$i]->{'requesttype'}=$data2->{'requesttype'};

			$add=1;
			$i++;}
      if ($rt eq ''){
		$rt=$data2->{'requesttype'};
		
	}elsif ($rt ne $data2->{'requesttype'})
			{$rt='Para Imprimir y Copiar'}
			
		  }

	if ($rt eq 'print'){$rt='Para Imprimir'}
	elsif ($rt eq 'copy'){$rt='Para Copiar'} 

	$res2[$i-1]->{'requesttype'}=$rt;			
    $i2++;
 					 }
  return($count,@res2);
}


