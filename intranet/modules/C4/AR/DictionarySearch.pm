package C4::AR::DictionarySearch;

#
# Modulo que hace las busquedas por diccionario
#

use strict;
require Exporter;
use C4::Context;
use C4::Date;
use C4::AR::Utilidades;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&DictionaryKeywordSearch &DictionarySignatureSearch);

#sub noaccents {
#	my $word = @_[0];
#	my @chars = split(//,$word);
#	my $newstr = ""; 
#	foreach my $ch (@chars) {
#		if (ord($ch) == 225 || ord($ch) == 193) {$newstr.= 'a'} 
#		elsif (ord($ch) == 233 || ord($ch) == 201) {$newstr.= 'e'}
#		elsif (ord($ch) == 237 || ord($ch) == 205) {$newstr.= 'i'}
#		elsif (ord($ch) == 243 || ord($ch) == 211) {$newstr.= 'o'}
#		elsif (ord($ch) == 250 || ord($ch) == 218) {$newstr.= 'u'}
#		else {$newstr.= $ch}
#	} 
#	return(uc($newstr));
#}

sub make_query {
  my ($dbh,$query,$DictionaryCaseSensitive,$type)=@_;
  my @returnvalues;
  my $data_aux;
  my $count=0;
  my $sth=$dbh->prepare($query);
  $sth->execute();

  #Distingo las busquedas
  if ($type eq 'dictionary'){
  	while (my ($biblionumber,$data) = $sth->fetchrow_array) {
  		$data_aux= ($DictionaryCaseSensitive eq "yes")?$data:&noaccents($data); 
  		my %row = (keyword =>  $data_aux, biblionumber => $biblionumber);
  		push(@returnvalues,\%row);
  		$count+=1;
  		}							  
  	}
  else {
  	while (my ($biblionumber,$itemnumber,$data) = $sth->fetchrow_array) {
		$data_aux= ($DictionaryCaseSensitive eq "yes")?$data:&noaccents($data);	
		my %row = (keyword =>  $data_aux, biblionumber => $biblionumber, itemnumber => $itemnumber);
		push(@returnvalues,\%row);
		$count+=1;
  	}
  }

  $sth->finish;
  return($count,@returnvalues);
}

sub Grupos {
  my ($bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblioitems where biblionumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bibnum);
  my @result;
  my $res=0;
  my $data;
  while ( $data=$sth->fetchrow_hashref){
        $result[$res]{'biblioitemnumber'}=$data->{'biblioitemnumber'};
        $result[$res]{'edicion'}=$data->{'number'};
        $result[$res]{'publicationyear'}=$data->{'publicationyear'};
        $result[$res]{'volume'}=$data->{'volume'};
        my $query2="select count(*) as c from items where items.biblioitemnumber=?";
        if ($type ne 'intra'){
                $query2.=" and (wthdrawn=0 or wthdrawn is NULL)";
                            }
        my $sth2=$dbh->prepare($query2);
        $sth2->execute($data->{'biblioitemnumber'});
        my $aux;
        (($aux=($sth2->fetchrow_hashref)) && ($result[$res]{'cant'}=$aux->{'c'}));
        $res++;
        }
return (\@result);
}




sub DictionaryKeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'dictionary'}=~ s/ +$//;
  my $count=0;
  my $countaux=0;
  my @returnvalues= ();
  my @returnaux;
  my $keyword= $search->{'dictionary'};
  my $dicdetail= $search->{'dicdetail'};
  my $condition;

  my $DictionaryCaseSensitive;
  if ($type eq 'intra') {
	$DictionaryCaseSensitive= C4::Context->preference("DictionaryCaseSensitive");
  } else{
	#En el opac ignoro la variable y pongo todos los resultados en mayúsculas y sin acentos
	$DictionaryCaseSensitive='no';
  }

  if ($dicdetail) {
    my $strComp= ($DictionaryCaseSensitive eq "yes")?" LIKE BINARY ":" = ";	
    $condition= $strComp."'".$keyword."'";
  } else {
    $condition= " LIKE '".$keyword."%'";
  }

  my @queries=(
    "SELECT biblionumber, title, unititle FROM biblio WHERE title".$condition,
    "SELECT biblio.biblionumber, autores.completo FROM biblio inner join autores on biblio.author = autores.id WHERE autores.completo".$condition,
    "SELECT biblionumber, subtitle FROM bibliosubtitle WHERE subtitle".$condition,
    "SELECT additionalauthors.biblionumber, autores.completo FROM additionalauthors inner join autores on additionalauthors.author = autores.id  WHERE autores.completo".$condition,
    "SELECT colaboradores.biblionumber, autores.completo FROM colaboradores inner join autores on colaboradores.idColaborador = autores.id  WHERE autores.completo".$condition,
    "SELECT biblionumber, subject FROM bibliosubject WHERE subject".$condition,
    "SELECT biblioitems.biblionumber, publisher.publisher FROM biblioitems INNER JOIN publisher 
	ON biblioitems.biblioitemnumber = publisher.biblioitemnumber
	WHERE publisher".$condition
  ) ;

  foreach my $query (@queries){
    ($countaux,@returnaux)= make_query($dbh,$query,$DictionaryCaseSensitive,'dictionary');
    $count+= $countaux;
    push(@returnvalues,@returnaux);
  }

  my @resultarray;
  my $index= 0;
  my $cantStr=0; #Se usa para contar los terminos repetidos
  my $res;
  my $res1;
  my $bib;
  my $size= scalar(@returnvalues);

  if (!$dicdetail) {

    my @results= sort { &noaccents($a->{keyword}) cmp &noaccents($b->{keyword}) } @returnvalues;

    while ($index < $size) {
      $res= $results[$index]->{keyword};
      $bib= $results[$index]->{biblionumber};
	
      while (($index < $size) && ($res eq $results[$index]->{keyword}) ) {
        $index+= 1;
        $cantStr+= 1;
      }
      $res1= $res;
      $res.= " (".$cantStr.")" if $cantStr > 1;
      my %row;
     if ($cantStr gt 1){
	%row = (keyword => $res, jump => 0, biblionumber => $bib, direct => 0, keyword2 => $res1, show => 0);
     }else{ 
#Si es unico lo muestro en detalle
	my $query="SELECT biblio.title,biblio.unititle, autores.completo FROM biblio inner join autores on biblio.author=autores.id WHERE biblio.biblionumber= ".$bib;
      	my $sth=$dbh->prepare($query);
      	$sth->execute();
      	my ($title,$unititle,$author) = $sth->fetchrow_array;
      	$sth->finish;

	%row = (keyword => $res, jump => 0, biblionumber => $bib, direct =>  1, keyword2 => $res1, show => 1, title => $title, unititle=>$unititle, author => $author,grupos => Grupos($bib,'intra'));}
   
      	push(@resultarray, \%row);
      	$cantStr= 0;
    }# end while ($index < $size) 

  } else {
    	my @results= @returnvalues;

    	while ($index < $size) {
      		$res= $results[$index]->{keyword};
      		$bib= $results[$index]->{biblionumber};


		my $query="SELECT biblio.title, biblio.unititle, autores.completo FROM biblio inner join autores on biblio.author=autores.id WHERE biblio.biblionumber= ".$bib;
      		my $sth=$dbh->prepare($query);
      		$sth->execute();
      		my ($title,$unititle,$author) = $sth->fetchrow_array;
      		$sth->finish;
      
      		my %row = (keyword => $res, jump => 0, biblionumber => $bib, direct => 1, title => $title,unititle => $unititle, author => $author, show => 1, grupos => Grupos($bib,'intra'));
      		push(@resultarray, \%row);
      		$index+=1;
    	}#end while ($index < $size)
    
 #Ordena en funcion del titulo y el autor, porque la palabra clave es siempre la misma (esto es para el detalle)
@resultarray= sort { &noaccents($a->{title}.$a->{author}) cmp &noaccents($b->{title}.$b->{author}) } @resultarray;
#  @resultarray= sort { &noaccents($a->{author}) cmp &noaccents($b->{author}) } @resultarray;

}

my @apellidosCompuestos;
my @apellidosSimples;

# open(A, ">>/tmp/debug.txt");
# print A "antes del foreach \n";
#Miguel hay autores que estan pasando vacios
  foreach my $query (@resultarray){

	my @dataApellido = split(",", $query->{'author'});
	my @dataKeyword = split(",", $query->{'keyword'});

# print A " \n";
# print A "title: $query->{'title'} \n";
# print A "keyword: $query->{'keyword'} \n";
# print A "author: $query->{'author'} \n";
# print A "primer parte del apellido: @dataApellido[0] \n";
 	my @primerParte= split(" ",@dataApellido[0]);
	my @primerParteKeyword= split(" ", @dataKeyword[0]);

  	if( (scalar(@primerParte) gt 1)||(scalar(@primerParteKeyword) gt 1) ){
	#el apellido es compuesto
# print A "Apellido compuesto \n";
# $query->{'author'}= $query->{'author'}."------COMPUESTO";
		push(@apellidosCompuestos, $query);
	}else{
		push(@apellidosSimples, $query);
	}
# print A " \n";

  }

push(@apellidosSimples, @apellidosCompuestos);
my @resultarray= @apellidosSimples;

close(A);

  if ($size) {
    my $middle= (scalar(@resultarray) - (scalar(@resultarray) % 2)) / 2;
    $resultarray[$middle-1]->{jump}= 1;
  }

    return($count, @resultarray);
}




sub DictionarySignatureSearch {
  my ($env,$type,$search,$fin,$inicio)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'signature'}=~ s/ +$//;
  my $count=0;
  my $countaux=0;
  my @returnvalues= ();
  my @returnaux;
  my $keyword= $search->{'signature'};
  my $dicdetail= $search->{'dicdetail'};
  my $condition;

  my $DictionaryCaseSensitive;
  if ($type eq 'intra') {
	$DictionaryCaseSensitive= C4::Context->preference("DictionaryCaseSensitive");
  } else{
	#En el opac ignoro la variable y pongo todos los resultados en mayúsculas y sin acentos
	$DictionaryCaseSensitive='no';
  }

  if ($dicdetail) {
    my $strComp= ($DictionaryCaseSensitive eq "yes")?" LIKE BINARY ":" = ";	
    $condition= $strComp."'".$keyword."'";
  } else {
    $condition= " LIKE '".$keyword."%'";
  }

  #para calcular la cantidad total de resultados  
  my $qTotalFilas= "SELECT count(*) as cant FROM items WHERE bulk ".$condition;
  my $sth=$dbh->prepare($qTotalFilas);
  $sth->execute();
  my $data=$sth->fetchrow_hashref;
  my $countTotal= $data->{'cant'};

  my $q= "SELECT biblionumber,itemnumber,bulk FROM items WHERE bulk ".$condition;

  my @queries=($q);

  foreach my $query (@queries){
    	($countaux,@returnaux)= make_query($dbh,$query,$DictionaryCaseSensitive,'signature');
    	#$count+= $countaux;
    	push(@returnvalues,@returnaux);
  }

  my @resultarray;
  my $index= 0;
  my $cantStr=0; #Se usa para contar los terminos repetidos
  my $res;
  my $res1;
  my $it;
  my $bib;
  my $size= scalar(@returnvalues);
 # my $unique;
 

  my @results= sort { &noaccents($a->{keyword}) cmp &noaccents($b->{keyword}) } @returnvalues;

  if (!$dicdetail) {
    while ($index < $size) {
      	$res= $results[$index]->{keyword};
      	$it= $results[$index]->{itemnumber};
      	$bib= $results[$index]->{biblionumber};
	#$unique=1;
	
	my @auxarray;

      	while (($index < $size) && ($res eq $results[$index]->{keyword}) ) {

        	my $exists=0;
		foreach my $aux (@auxarray){ 
			if($aux->{'biblionumber'} eq $results[$index]->{biblionumber}){
				$exists=1;
			}
		}

		if ($exists eq 0){

	 		push(@auxarray, $results[$index]);

			$bib=$results[$index]->{biblionumber};
	 		$cantStr+= 1;
		}
		$index+= 1;
      	}#end while

      	$res1= $res;
      	$res.= " (".$cantStr.")" if $cantStr > 1;
       	$count+= $cantStr;
  
  	#Si es unico lo muestro en detalle
      	my $query= "SELECT bulk,title,unititle,author FROM items inner join biblio on items.biblionumber=biblio.biblionumber WHERE itemnumber =".$it;
      	my $sth=$dbh->prepare($query);
      	$sth->execute();
     
	my $data = $sth->fetchrow_hashref;
	my $autor=C4::Search::getautor($data->{'author'});
	$data->{'author'}=$autor->{'completo'};
	$sth->finish;
	my $direct=1;
	
	if ($cantStr gt 1) {$direct=0;}

	my %row = (keyword => $res, jump => 0 , biblionumber=>$bib, itemnumber => $it, direct => $direct, bulk => $data->{'bulk'},title => $data->{'title'},unititle => $data->{'unititle'},author => $data->{'author'}, keyword2 => $res1, show => 1);


   
      	push(@resultarray, \%row);
      	$cantStr= 0;
   }#end while ($index < $size)

} else {
    my @results= @returnvalues;
	$bib='';
    while ($index < $size) {
    	#Si exist el biblionumber no lo proceso
	my $exists=0;
	foreach my $aux (@resultarray){ 
		if($aux->{'biblionumber'} eq $results[$index]->{biblionumber}){
			$exists=1;}
	}	

	if ($exists eq 0){
		$count++; # Se va a agregar
      		$res= $results[$index]->{keyword};
      		$it= $results[$index]->{itemnumber};
      		$bib= $results[$index]->{biblionumber};
     
      		my $query= "SELECT bulk,title,unititle,author FROM items inner join biblio on items.biblionumber=biblio.biblionumber WHERE itemnumber = ".$it;
      		my $sth=$dbh->prepare($query);
      		$sth->execute();
       		#my ($bulk) = $sth->fetchrow_array;
      		my $data = $sth->fetchrow_hashref;
      		my $autor=C4::Search::getautor($data->{'author'});
      		$data->{'author'}=$autor->{'completo'};

      		$sth->finish;
      		my %row = (keyword => $res, jump => 0 , biblionumber=>$bib, itemnumber => $it, direct => 1, bulk => $data->{'bulk'},title => $data->{'title'},unititle => $data->{'unititle'},author => $data->{'author'});
      		push(@resultarray, \%row);
    
    	}
   	$index+=1;
   }

}#fin else



$countTotal= scalar(@resultarray);

if ($size) {
    my $middle= (scalar(@resultarray) - (scalar(@resultarray) % 2)) / 2;
    $resultarray[$middle-1]->{jump}= 1;
}

my @finalresults= sort { &noaccents($a->{keyword}) cmp &noaccents($b->{keyword}) } @resultarray;

my %row;
my @finalresults2;
my $tope= scalar(@finalresults);

#se pagina el resultado (se filtra info del arreglo)
#Miguel - No se puede paginar de otro modo
for (my $i=$inicio; ($i < $fin and $i < $tope); $i++){
	push(@finalresults2, @finalresults[$i]);
}

# return($count,@finalresults);
# return($countTotal,@finalresults);
return($countTotal,@finalresults2);
}
