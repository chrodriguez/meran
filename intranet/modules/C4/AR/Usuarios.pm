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
);
=item ListadodeUsuarios

  ($cnt,\@results) = &ListadodeUsuarios($env,$searchstring,$type,$onlyCount);
  llamada por memberResult.pl
=cut
sub ListadoDeUsuarios  {
	my ($env,$searchstring,$type,$onlyCount)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query;

	if ($onlyCount) {
		$query = "Select count(*) from borrowers b";
	} else {
		$query = "Select * from borrowers ";
	}

	if($type eq "simple")	# simple search for one letter only
	{
		$query.=" where surname like ? ";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
		@data=split(' ',$searchstring);
                $count=@data;
                $query.=" where (surname like ? or surname like ?
		or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ?
		or  studentnumber like ? or  studentnumber like ?)";
                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%");

                for (my $i=1;$i<$count;$i++){
                	$query=$query." and  (surname like ? or surname like ?
	     		or  firstname like ? or firstname like ?
                	or  documentnumber  like ? or  documentnumber like ?
                	or  cardnumber like ? or  cardnumber like ?
			or  studentnumber  like ? or  studentnumber like ? )";
	
                	push(@bind,"$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
                }

	}

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	if ($onlyCount) {
	  my $cnt= $sth->fetchrow;
	  $sth->finish;
	  return ($cnt);
	} else {
	  my @results;
	  my $cnt=$sth->rows;
	  while (my $data=$sth->fetchrow_hashref){
	    push(@results,$data);
	  }
	  $sth->finish;
	  return ($cnt,\@results);
	}
}



=item
  ($cnt,\@results) = &ListadoDePersonas($env,$searchstring,$type,$onlyCount);
  llamada por member2Result.pl	
=cut

sub ListadoDePersonas  {
	my ($env,$searchstring,$type,$onlyCount)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query;

	if ($onlyCount) {
                $query = "Select count(*) from persons ";
        } else {
                $query = "Select * from persons ";
        }

	if($type eq "simple")	# simple search for one letter only
	{
		$query.="where surname like ? ";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
   		@data=split(' ',$searchstring);
                $count=@data;
                $query.="where (surname like ? or surname like ?
		or  firstname like ? or firstname like ?
                or  documentnumber  like ? or  documentnumber like ?
                or  cardnumber like ? or  cardnumber like ? 
		or  studentnumber  like ? or  studentnumber like ? )";
                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%", "$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%" );

                for (my $i=1;$i<$count;$i++){
                	$query=$query." and  (surname like ? or surname like ?
		  	or  firstname like ? or firstname like ?
                	or  documentnumber  like ? or  documentnumber like ?
                	or  cardnumber like ? or  cardnumber like ?
                	or  studentnumber  like ? or  studentnumber like ? )";

        		push(@bind,"$data[$i]%","% $data[$i]%", "$data[$i]%","% $data[$i]%", "$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
                }

	}


	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	if ($onlyCount) {
	  my $cnt= $sth->fetchrow;
	  $sth->finish;
	  return($cnt);
	} else {
	  my @results;
  	  my $cnt=$sth->rows;
	  while (my $data=$sth->fetchrow_hashref){
	  	push(@results,$data);
	  }
	  $sth->finish;
	  return ($cnt,\@results);
	}
}


sub esRegular{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT regular FROM persons WHERE borrowernumber = ?");
        $sth->execute($bor);
        my $regular = $sth->fetchrow();
        $sth->finish();
        return $regular;
}
