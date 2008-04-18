package C4::AR::AnalysisBiblio;

#
# Este modulo sera el encargado del manejo de la Biblioteca Virtual
# pedidos, informes y multas seran manejados aqui. 
#
#

use strict;
require Exporter;

use C4::Context;
use C4::Biblio;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&BiblioAnalysisData
           &BiblioAnalysisUpdate
	   &BiblioAnalysisSingularData
           &BiblioAnalysisInsert
           &BiblioAnalysisDelete
	   &BiblioSingleAnalysisDelete
	   &BiblioAnalysisSearch
	   &getanalyticalautors
	   &BiblioAnalysisTypeSearch
	   &getKeywords
  	   &getKeywordsLike
	   &getKeywordID
	   );

#Recupero los datos del analisis
#

sub getKeywords{
	my $dbh = C4::Context->dbh;
	my $query ="SELECT * FROM keyword  ORDER BY keyword";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        my @results;
        my $result_array_ref=$sth->fetchrow_hashref;

	return $result_array_ref;
}

sub getKeywordID{
	my ($keyword)=@_;
	
	my $dbh = C4::Context->dbh;
	my $query ="SELECT idkeyword FROM keyword WHERE keyword = ? ";
        my $sth=$dbh->prepare($query);
        $sth->execute($keyword);
        my @results;
        my $result_array_ref=$sth->fetchrow_hashref;

	return $result_array_ref->{'idkeyword'};
}

sub getKeywordsLike{
	my ($dato)=@_;

	my $dbh = C4::Context->dbh;
	my $query ="SELECT * FROM keyword WHERE keyword like ? ORDER BY keyword";
        my $sth=$dbh->prepare($query);
        $sth->execute($dato.'%');

	my @results;
	while (my $data = $sth->fetchrow) {
		push(@results, $data); 
	} # while
	$sth->finish;
	return(@results);

}

sub BiblioAnalysisData{
        my ($bibnum, $bibitemnumber) = @_;
        my $dbh = C4::Context->dbh;
        my $query ="SELECT * FROM biblioanalysis  WHERE biblionumber=? and biblioitemnumber=?";
        my $sth=$dbh->prepare($query);
        $sth->execute($bibnum, $bibitemnumber);
        my @results;
        while (my $data=$sth->fetchrow_hashref){

	my  $sth2   = $dbh->prepare("Select * from analyticalsubject  where analyticalnumber = ?");
	 $sth2->execute($data->{'analyticalnumber'});
	 while (my $dat = $sth2->fetchrow_hashref){
	 	$data->{'subject'} .= "$dat->{'subject'}, ";
	 } # while
	 chop $data->{'subject'};
	 chop $data->{'subject'};
	 $sth2->finish;
	 
	 my @subjects;
	 my $len= scalar(split(",",$data->{'subject'}));
	 my $i= 1;
	 my $coma;
	 foreach my $elem (split(",",$data->{'subject'})) {
	         if ($len==$i){$coma=""} else {$coma=","};
		 for ($elem) {s/^\s+//;} # delete the spaces at the begining of the string
		 push(@subjects, {subject => $elem, separator => $coma});
		 $i+=1;
		 }
	 $data->{'SUBJECTS'} = \@subjects;

	 my  $sth3 = $dbh->prepare("	SELECT ak.idkeyword,ak.analyticalnumber,k.keyword 
					FROM analyticalkeyword ak INNER JOIN keyword k
					ON (ak.idkeyword = k.idkeyword)
					WHERE ak.analyticalnumber = ? ");

	 $sth3->execute($data->{'analyticalnumber'});

	 while (my $dat = $sth3->fetchrow_hashref){
	 	$data->{'keyword'} .= "$dat->{'keyword'}, ";
	 } # while
 	 chop $data->{'keyword'}; #quito la ultima ,

	 $sth3->finish;
					 
	 my @keywords;
	 my $len= scalar(split(",",$data->{'keyword'}));
	 my $i= 1;
	 my $coma;
	 foreach my $elem (split(",",$data->{'keyword'})) {
	         if ($len==$i){$coma=""} else {$coma=","};
		 for ($elem) {s/^\s+//;} # delete the spaces at the begining of the string
		 push(@keywords, {keyword => $elem, separator => $coma});
		 $i+=1;
		 }

	 $data->{'KEYWORDS'} = \@keywords;

	 my @autores=&getanalyticalautors($data->{'analyticalnumber'});
	 $data->{'analyticalauthor'}=\@autores;

         push(@results,$data);
        }

        return (@results);
}


sub BiblioAnalysisSingularData {
        my ($analitycalnumber) = @_;
        my $dbh = C4::Context->dbh;
        my $query ="SELECT * FROM biblioanalysis  WHERE analyticalnumber=?";
        my $sth=$dbh->prepare($query);
        $sth->execute($analitycalnumber);
        my @results;
        while (my $data=$sth->fetchrow_hashref){

	my  $sth2   = $dbh->prepare("Select * from analyticalsubject  where analyticalnumber = ?");
	 $sth2->execute($data->{'analyticalnumber'});
	 while (my $dat = $sth2->fetchrow_hashref){
	 $data->{'subject'} .= "$dat->{'subject'}, ";
	 } # while
	 chop $data->{'subject'};
	 chop $data->{'subject'};
	 $sth2->finish;
	 
	 my @subjects;
	 my $len= scalar(split(",",$data->{'subject'}));
	 my $i= 1;
	 my $coma;
	 foreach my $elem (split(",",$data->{'subject'})) {
	         if ($len==$i){$coma=""} else {$coma=","};
		 for ($elem) {s/^\s+//;} # delete the spaces at the begining of the string
		 push(@subjects, {subject => $elem, separator => $coma});
		 $i+=1;
		 }
	 $data->{'SUBJECTS'} = \@subjects;

	 my  $sth3 = $dbh->prepare("	SELECT ak.idkeyword,ak.analyticalnumber,k.keyword 
					FROM analyticalkeyword ak INNER JOIN keyword k
					ON (ak.idkeyword = k.idkeyword)
					WHERE ak.analyticalnumber = ? ");

	 $sth3->execute($data->{'analyticalnumber'});

my @keywords;

	  while (my $dat = $sth3->fetchrow_hashref){
	 	$data->{'keyword'} .= "$dat->{'keyword'}\n ";
		push(@keywords, $data);
	 } # while
=item

	 while (my $dat = $sth3->fetchrow_hashref){
	 	$data->{'keyword'} .= "$dat->{'keyword'}, ";
	 } # while
 	 chop $data->{'keyword'}; #quito la ultima ,

	 $sth3->finish;
#Miguel falta que los keywords se les agregue un ENTER					 
	 my @keywords;
	 my $len= scalar(split(",",$data->{'keyword'}));
	 my $i= 1;
	 my $coma;
	 foreach my $elem (split(",",$data->{'keyword'})) {
	         if ($len==$i){$coma=""} else {$coma="\n"};
		 for ($elem) {s/^\s+//;} # delete the spaces at the begining of the string
		 push(@keywords, {keyword => $elem, separator => $coma});
		 $i+=1;
		 }
=cut
	 $data->{'KEYWORDS'} = \@keywords;
					 
	 my @autores=&getanalyticalautors($data->{'analyticalnumber'});
	 $data->{'analyticalauthor'}=\@autores;

         push(@results,$data);
         }
        return (@results);
}

sub BiblioSingleAnalysisDelete 
{          my ($analyticalnumber)= @_;
	   my $dbh = C4::Context->dbh;
	   
	   &eliminarAnalyticalAutores($dbh,$analyticalnumber);
	   &eliminarAnalyticalMaterias($dbh,$analyticalnumber);
           my $query ="DELETE FROM biblioanalysis  WHERE analyticalnumber=? ";
           my $sth=$dbh->prepare ($query);
           $sth->execute($analyticalnumber);

}

sub BiblioAnalysisDelete 
{          my ($bibnum,$bibnumitems)= @_;
           my $dbh = C4::Context->dbh;
		
		my  $sth2   = $dbh->prepare("Select analyticalnumber FROM biblioanalysis WHERE biblionumber=? and biblioitemnumber=?");
		$sth2->execute($bibnum,$bibnumitems);
		while (my $dat = $sth2->fetchrow_hashref){
	             &eliminarAnalyticalAutores($dbh,$dat->{'analyticalnumber'});
		      &eliminarAnalyticalMaterias($dbh,$dat->{'analyticalnumber'});
				}
	   
           my $query ="DELETE FROM biblioanalysis WHERE biblionumber=? and biblioitemnumber=?";
           my $sth=$dbh->prepare ($query);
           $sth->execute($bibnum,$bibnumitems);

}


sub BiblioAnalysisUpdate 
{
	my ($analyticalnumber,$analyticaltitle,$analyticalunititle,$subjectheadings,$classification,$bibnum,$analyticalauthor,$bibnumitems,$parts,$time,$resumen,$url,$keywords)=@_;
	   
	my $dbh = C4::Context->dbh;
	&eliminarAnalyticalAutores($dbh,$analyticalnumber);
	&eliminarAnalyticalMaterias($dbh,$analyticalnumber);
	&eliminarAnalyticalKeywords($dbh,$analyticalnumber,$keywords);
           
	   
	my $sth=$dbh->prepare("	UPDATE biblioanalysis  SET analyticaltitle=?, biblionumber=?, 						analyticalunititle=?, biblioitemnumber=?, parts=?, classification=?,  	
				resumen=?, url=?
				WHERE analyticalnumber=? ");

        $sth->execute($analyticaltitle,$bibnum,$analyticalunititle,$bibnumitems,$parts,$classification,$resumen,$url,$analyticalnumber);
	$sth->finish;

	&agregarAnalyticalMaterias($dbh,$analyticalnumber,$subjectheadings);
	&agregarAnalyticalAutores($dbh,$analyticalnumber,$analyticalauthor);
	&agregarAnalyticalKeywords($dbh,$analyticalnumber,$keywords);
				
}

sub BiblioAnalysisInsert{
 	my ($analyticaltitle,$analyticalunititle,$subjectheadings,$classification,$bibnum,$analyticalauthor,$bibnumitems,$parts,$resumen,$url,$keywords)=@_;
 
 	my $dbh = C4::Context->dbh;
 	my $sth = $dbh->prepare("Select max(analyticalnumber) from biblioanalysis");
 	$sth->execute;
 	my $data = $sth->fetchrow_arrayref;
	my $analyticalnumber = $$data[0] + 1;
			  
 	my $query ="	INSERT INTO `biblioanalysis` 
        		( `analyticaltitle` , `biblionumber` , `analyticalunititle` , `biblioitemnumber` , `parts`,`classification` , `timestamp`,`analyticalnumber`,`resumen`,`url`) 
        		VALUES (?, ?, ?, ?, ?,?, NOW( ),?,?,?);";

 	my $sth=$dbh->prepare($query);
 	$sth->execute($analyticaltitle,$bibnum,$analyticalunititle,$bibnumitems,$parts,$classification,$analyticalnumber,$resumen,$url);

  	&agregarAnalyticalMaterias($dbh,$analyticalnumber,$subjectheadings);
  	&agregarAnalyticalAutores($dbh,$analyticalnumber,$analyticalauthor);
   	&agregarAnalyticalKeywords($dbh,$analyticalnumber,$keywords);

	$sth->finish;
}

sub eliminarAnalyticalKeywords{

   my ($dbh,$analyticalnumber)=@_;

   my $sth; 
   $sth=$dbh->prepare("DELETE FROM analyticalkeyword  WHERE analyticalnumber= ?;");
   $sth->execute($analyticalnumber);
   $sth->finish;			    
}

sub eliminarAnalyticalMaterias{

   my ($dbh,$analyticalnumber)=@_;
   my $sth; 
    $sth=$dbh->prepare("Delete from analyticalsubject  where analyticalnumber=?;");
    $sth->execute($analyticalnumber);
    $sth->finish;			    
}

sub eliminarAnalyticalAutores{
   my ($dbh,$analyticalnumber)=@_;
   my $sth; 
   $sth=$dbh->prepare("Delete from analyticalauthors  where analyticalnumber=?;");
   $sth->execute($analyticalnumber);
   $sth->finish;
}
		  
sub agregarAnalyticalKeywords{

        my ($dbh,$analyticalnumber,$keywords) =@_;
	my @ars=split(/^/,$keywords); #separa los \n
	my $sth;	
	foreach my $ar (@ars)  {
		my $aux=$ar;
		$aux =~ s/\n//; #elimina los \n
		$aux=~ s/\s+$//;#elimina el espacio del final
		if ($aux ne '') {

			$sth=$dbh->prepare("	SELECT count(*) 
						FROM analyticalkeyword ak INNER JOIN keyword k
						ON (ak.idkeyword = k.idkeyword) 
						WHERE ak.analyticalnumber = ? and k.keyword = ? ; ");

			$sth->execute($analyticalnumber,$aux);
			my $data=$sth->fetchrow;
			$sth->finish;
			if ($data eq 0) {

				$sth = $dbh->prepare ("	INSERT INTO analyticalkeyword 
							(analyticalnumber, idkeyword) 
							VALUES ( ? , ?); ");

				$sth->execute($analyticalnumber,getKeywordID(uc($aux)));
				$sth->finish;
=item
				$sth=$dbh->prepare("Select count(*) from catalogueentry  where catalogueentry=?;");
				$sth->execute($aux);
				my $data=$sth->fetchrow;
				$sth->finish;
				if ($data eq 0) {
					$sth = $dbh->prepare ("insert into catalogueentry  (catalogueentry, entrytype) values (? , 's');");
					$sth->execute($aux);
					$sth->finish;
				}
=cut
			}#end if ($data eq 0)
		} 
	}# foreach
}

sub agregarAnalyticalMaterias{

        my ($dbh,$analyticalnumber,$subjects) =@_;
	my @ars=split(/^/,$subjects); #separa los \n
	my $sth;	
	foreach my $ar (@ars)  {
		my $aux=$ar;
		$aux =~ s/\n//; #elimina los \n
		$aux=~ s/\s+$//;#elimina el espacio del final
		if ($aux ne '') {
			$sth=$dbh->prepare("Select count(*) from analyticalsubject  where analyticalnumber=? and subject=?;");
			$sth->execute($analyticalnumber,$aux);
			my $data=$sth->fetchrow;
			$sth->finish;
			if ($data eq 0) {
				$sth = $dbh->prepare ("insert into analyticalsubject (analyticalnumber, subject) values ( ? , ?);");
				$sth->execute($analyticalnumber,uc($aux));
				$sth->finish;
				$sth=$dbh->prepare("Select count(*) from catalogueentry  where catalogueentry=?;");
				$sth->execute($aux);
				my $data=$sth->fetchrow;
				$sth->finish;
				if ($data eq 0) {
					$sth = $dbh->prepare ("insert into catalogueentry  (catalogueentry, entrytype) values (? , 's');");
					$sth->execute($aux);
					$sth->finish;
				}
			}
		} 
	}# foreach
}

sub agregarAnalyticalAutores {
        my ($dbh,$analyticalnumber,$auth) = @_;
	my @ars=split(/^/,$auth);
	my $sth;
	foreach my $ar (@ars)  {
	  my $aux=$ar;
	  $aux =~ s/\n+$//; #elimina los \n
	  $aux =~ s/\r+$//; #elimina los \r
	  $aux =~ s/^\s+//; #Quita los espacios al principio
	  $aux =~ s/\s+$//; #Quita los espacios al final
													  
	my $idCol=obtenerReferenciaAutor($dbh,$aux);
	$sth = $dbh->prepare ("insert into analyticalauthors (analyticalnumber, author) values (?, ?);");
	$sth->execute($analyticalnumber,$idCol);
	$sth->finish;
}}

sub getanalyticalautors{
    	my ($analyticalnumber) = @_;
        my @result;
	my $dbh   = C4::Context->dbh;
	my $sth   = $dbh->prepare("Select id,apellido,nombre,completo from autores inner join analyticalauthors  on analyticalauthors.author=autores.id where analyticalnumber= ?");
	$sth->execute($analyticalnumber);
	my @results;
	while (my $data = $sth->fetchrow_hashref) {
		push(@results,$data);
	}
	$sth->finish();
	return(@results);
}
	
sub BiblioAnalysisSearch
{
my ($search) = @_;
my $dbh = C4::Context->dbh;
my @key=split(' ',$search);
my $count=@key;
my $query;                    # The SQL query
my @clauses = ();             # The search clauses
my @bind = ();                # The term bindings

$query = " SELECT distinct biblioanalysis.analyticalnumber, biblio.*,biblioitems.*,biblioanalysis.*,biblio.author as autorppal   from 
biblio left join biblioitems on biblio.biblionumber=biblioitems.biblionumber 
inner join biblioanalysis on biblioitems.biblioitemnumber=biblioanalysis.biblioitemnumber 
left join  analyticalauthors on biblioanalysis.analyticalnumber = analyticalauthors.analyticalnumber
inner join autores on analyticalauthors.author = autores.id
left join analyticalsubject on biblioanalysis.analyticalnumber = analyticalsubject.analyticalnumber
where ";
foreach my $keyword (@key)
  {
  my @subclauses = ();
  foreach my $field (qw(analyticaltitle analyticalunititle autores.completo analyticalsubject.subject))
  {
  push @subclauses,
  "$field LIKE ? OR $field LIKE ?";
  push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  push @clauses, "(" . join(")\n\tOR (", @subclauses) . ")";
  }
  $query .= "(" . join(")\nAND (", @clauses) . ")";
  
  my $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref)
  {
  	my $autorppal=  C4::Search::getautor($data->{'autorppal'});
  	$data->{'apellidoppal'}= $autorppal->{'apellido'};
  	$data->{'nombreppal'}= $autorppal->{'nombre'};
  	$data->{'completoppal'}=$autorppal->{'completo'}; 
  
  	my @autores=&getanalyticalautors($data->{'analyticalnumber'});
  	$data->{'analyticalauthor'}=\@autores;
	     
 	$results[$i]=$data;
  	$i++;
  }
# open(A, ">>/tmp/debug.txt");
# print A "desde analitcas \n";
# print A " cant ".scalar(@results)."\n";
  $sth->finish;
# close(A);
  return(scalar(@results),@results);
}


sub BiblioAnalysisTypeSearch
{
my ($search,$type) = @_;
my $dbh = C4::Context->dbh;
my @autor;
my @title;
my @subject;

my $query;                    # The SQL query
my @clauses = ();             # The search clauses
my @bind = ();                # The term bindings


if (($search->{'subjectitems'} ne '') or ($type eq 'subject')){
	$query = " SELECT distinct biblioanalysis.analyticalnumber, biblio.*,biblioitems.*,biblioanalysis.*,biblio.author as autorppal,analyticalsubject.subject   from biblio left join biblioitems on biblio.biblionumber=biblioitems.biblionumber 
	inner join biblioanalysis on biblioitems.biblioitemnumber=biblioanalysis.biblioitemnumber 
	left join  analyticalauthors on biblioanalysis.analyticalnumber = analyticalauthors.analyticalnumber
	inner join autores on analyticalauthors.author = autores.id
	left join analyticalsubject on biblioanalysis.analyticalnumber = analyticalsubject.analyticalnumber
	where ";	              

}
else {
$query = " SELECT distinct biblioanalysis.analyticalnumber, biblio.*,biblioitems.*,biblioanalysis.*,biblio.author as autorppal   from 
biblio left join biblioitems on biblio.biblionumber=biblioitems.biblionumber 
inner join biblioanalysis on biblioitems.biblioitemnumber=biblioanalysis.biblioitemnumber 
left join  analyticalauthors on biblioanalysis.analyticalnumber = analyticalauthors.analyticalnumber
inner join autores on analyticalauthors.author = autores.id
where ";
}

if ($search->{'subjectitems'} ne ''){
	$query .= "  analyticalsubject.subject= '".$search->{'subjectitems'}."'" ;	              
			}
else {
if ($type eq 'subject'){

 
  @subject=split(' ',$search->{'subject'});
  my $countS=@subject;
  my $i=1;
  $query.=" ( analyticalsubject.subject like ? or analyticalsubject.subject like ? or analyticalsubject.subject like ?)";
  @bind=("$subject[0]%","% $subject[0]%","%($subject[0])%");
  
  while ($i<$countS){
  $query.=" and (analyticalsubject.subject like ? or analyticalsubject.subject like ? or analyticalsubject.subject like ?)";
  push(@bind,"$subject[$i]%","% $subject[$i]%","%($subject[$i])%");
  $i++;													                 
  }															  

}

if ($search->{'author'} ne ''){
   @autor=split(' ',$search->{'author'});
      my $countA=@autor;
	foreach my $keyword (@autor)
  		{my @subclauses = ();
  		 foreach my $field (qw(autores.completo))
  			{push @subclauses, "$field LIKE ? OR $field LIKE ?";
  			 push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  			}
  		 push @clauses, "(" . join(")\n\tOR (", @subclauses) . ")";
  		 }
   	$query .= "(" . join(")\nAND (", @clauses) . ")";
}

if ($search->{'authorid'} ne ''){ 	 push(@bind,$search->{'authorid'}); 
					$query .= "(  autores.id = ? )";}

if ($search->{'title'} ne ''){
      my @title=split(' ',$search->{'title'});
            my $countT=@title;

	foreach my $keyword (@title)
  		{my @subclauses = ();
  		 foreach my $field (qw(analyticaltitle analyticalunititle))
  			{push @subclauses, "$field LIKE ? OR $field LIKE ?";
  			 push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  			}
  		 push @clauses, "(" . join(")\n\tOR (", @subclauses) . ")";
  		 }
   	$query .= "(" . join(")\nAND (", @clauses) . ")";
}

} #else

  my $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref)
  {
  my $autorppal=  C4::Search::getautor($data->{'autorppal'});
  $data->{'apellidoppal'}= $autorppal->{'apellido'};
  $data->{'nombreppal'}= $autorppal->{'nombre'}; 
  
  my @autores=&getanalyticalautors($data->{'analyticalnumber'});
  $data->{'analyticalauthor'}=\@autores;
	     
 $results[$i]=$data;
  $i++;}
  $sth->finish;
  return(scalar(@results),@results);
 }
