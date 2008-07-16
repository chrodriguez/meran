package C4::Search;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::AR::DictionarySearch; #Luciano: Busqueda por diccionario
use C4::AR::Reservas; 
use C4::AR::Busquedas; 
use C4::AR::Issues;
use C4::AR::VirtualLibrary; #Matias: Bilbioteca Virtual
use C4::AR::AnalysisBiblio; #Matias: Analiticas
use C4::AR::Utilidades;
use Date::Manip;
use C4::Date;
use C4::Koha;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.02;


@ISA = qw(Exporter);
@EXPORT = qw(
&buscarCiudades	
&BornameSearchForCard
&itemdata3
&bibdata
&borrdata
&NewBorrowerNumber
&borrissues
&findguarantees
&itemcountbibitem
&breedingsearch




	
	
	
	
	
	&allbibitems 
	&countitems  
	&groupinfo  
	&FindItemType 
	&FindVol
	&publisherList
	&isbnList
	&obtenerCategoria
	&canDeleteBiblio
	&canDeleteBiblioitem
	&canDeleteItem
	&haveReserves
	&mailissues
	&mailissuesforborrower
	&mailreservas
	&firstbulk
	&editorsname

	&PersonNameSearch
	&persdata
	&getcitycategory 
	&itemcountPorGrupos
	&Grupos
	&generarEstadoDeColeccion

	&mostrarProvincias	&darProvincia
	&mostrarCiudades	&darCiudad
	&mostrarDepartamentos	&darDepartamento
	&mostrarPaises		&darPais
	
	
	 &getautoresAdicionales &getColaboradores
	
	
        &getCountry
        &getSupport
        &getLanguage
	&getLevel
	&getTema
	&getAvail
	&getavails
	&availDetail
	&getavailsplus
	&availArray
	&bibitnfloan
	&bibavail

	&SearchSig
);
# make all your functions, whether exported or not;

=item
NO SE USAN
&getwebsites 
&getboracctrecord

&buscarCiudades2
&buscarCiudadesMasUsadas
&getmaxissues
&getmaxrenewals
&newsearch
&CatSearch
&BornameSearch
&ItemInfo
&KeywordSearch
&subsearch
&itemdata
&itemdata2
&GetItems
&itemnodata
&itemcount
&borrdata2
&bibitemdata
&ItemType
&itemissues
&subtitle
&addauthor
&bibitems
&bibitems2
&barcodes
&allissues
&findguarantor
&getwebbiblioitems
&catalogsearch
&itemcount2
&itemcount3
&isbnsearch
&isbnsearch2
&getallthemes
&getalllanguages
&getbranchname
&getallborrowercategorys
&infoitem
&itemsfrombiblioitem
&allitems

=cut




=item
buscarCiudades
Busca las ciudades con todas la relaciones. Se usa para el autocomplete en la parte de agregar usuario.
=cut
sub buscarCiudades{
        my ($ciudad) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT countries.name AS pais, provincias.nombre AS provincia, dptos_partidos.nombre AS partido, localidades.localidad as localidad,localidades.nombre AS nombre FROM localidades LEFT JOIN dptos_partidos ON localidades.DPTO_PARTIDO = dptos_partidos.DPTO_PARTIDO LEFT JOIN provincias ON dptos_partidos.provincia = provincias.provincia LEFT JOIN countries ON countries.code = provincias.pais WHERE localidades.nombre LIKE ? or localidades.nombre LIKE ? ORDER BY localidades.nombre";
	my $sth = $dbh->prepare($query);
        $sth->execute($ciudad.'%', '% '.$ciudad.'%');
        my @results;
	my $cant;
        while (my $data=$sth->fetchrow_hashref){ 
		push(@results,$data); 
		$cant++;
	}
	$sth->finish;
	return ($cant, \@results);
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
			$results[$i]->{'city'}=getcity($results[$i]->{'city'});
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
itemdata3
Dado un itemnumber devuelve los datos del item (titulo y autor) 
SE PUEDE RENOMBRAR o USAR OTRA FUNCION!!!!!!
=cut
sub itemdata3{
        my ($id3) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT titulo, autor FROM nivel3 n3 RIGHT JOIN nivel1 n1 ON n3.id1 = n1.id1 WHERE id3=? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($id3);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
	$res->{'autor'}=getautor($res->{'autor'})->{'completo'};
        return $res;
}

=item bibdata
  $data = &bibdata($biblionumber, $type);
Returns information about the book with the given biblionumber.
C<$type> is ignored.
C<&bibdata> returns a reference-to-hash. The keys are the fields in
the C<biblio>, C<biblioitems>, and C<bibliosubtitle> tables in the
Koha database.
In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).
If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

POSIBLEMENTE NO SE USE MAS, VER!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
SE USA PARA LOS PL DE ANALITICAS. (addanalysis.pl y opac-analysis.pl)
=cut
#'
sub bibdata {
    my ($bibnum, $type) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("SELECT * ,biblio.seriestitle as cdu,  biblioitems.notes AS bnotes, 	biblio.notes
	FROM biblio
	LEFT JOIN biblioitems ON biblioitems.biblionumber = biblio.biblionumber
	LEFT JOIN bibliosubtitle ON biblio.biblionumber = bibliosubtitle.biblionumber
	WHERE biblio.biblionumber = ".$bibnum."
	ORDER BY biblioitems.biblioitemnumber LIMIT 0 , 30 ");
    $sth->execute();
    my $data;
    $data  = $sth->fetchrow_hashref;

    $sth->finish;
=item
    $sth   = $dbh->prepare("Select * from bibliosubject where biblionumber = ?");
    $sth->execute($bibnum);
    while (my $dat = $sth->fetchrow_hashref){
        $data->{'subject'} .= "$dat->{'subject'}, ";
    } # while
	chop $data->{'subject'};
	chop $data->{'subject'};
    $sth->finish;
    $sth   = $dbh->prepare("Select * from additionalauthors where biblionumber = ?");
    $sth->execute($bibnum);
    while (my $dat = $sth->fetchrow_hashref){
        $data->{'additionalauthors'} .= "$dat->{'author'}, ";

    } # while
	chop $data->{'additionalauthors'};
	chop $data->{'additionalauthors'};
    $sth->finish;
=cut
	#Para mostrar el nivel bibliografico  
	 my $level=getLevel($data->{'classification'});
        $data->{'classification'}= $level->{'description'};
        $data->{'idclass'}= $level->{'code'};

	

    return($data);
} # sub bibdata

=item borrdata

  $borrower = &borrdata($cardnumber, $borrowernumber);

Looks up information about a patron (borrower) by either card number
or borrower number. If $borrowernumber is specified, C<&borrdata>
searches by borrower number; otherwise, it searches by card number.

C<&borrdata> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.
POSIBLEMENTE SE PUEDE CAMBIAR POR ALGUNA FUNCION QUE SE ENCUENTRA EN EL PM DE USUARIOS.
=cut
#'
sub borrdata {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $sth;
  if ($bornum eq ''){
    $sth=$dbh->prepare("SELECT * FROM borrowers WHERE cardnumber=?");
    $sth->execute($cardnumber);
  } else {
    $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  }
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  if ($data) {
  	return($data);
	} else { # try with firstname
		if ($cardnumber) {
			my $sth=$dbh->prepare("select * from borrowers where firstname=?");
			$sth->execute($cardnumber);
			my $data=$sth->fetchrow_hashref;
			$sth->finish;
			return($data);
		}
	}
	return undef;
}

=item 
NewBorrowerNumber
  $num = &NewBorrowerNumber();
Allocates a new, unused borrower number, and returns it.
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
borrissues

SE USA EN UN SOLO LUGAR ----- sever.pl (ESTE pl NO SE SI SE USA O SIRVE PARA ALGO).
=cut
sub borrissues {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select *, issues.renewals as renewals2  
	from issues left join items  on items.itemnumber=issues.itemnumber 
	inner join  biblio on items.biblionumber=biblio.biblionumber 
	 where borrowernumber=?
	and issues.returndate is NULL order by date_due");
    $sth->execute($bornum);
  my @result;
  while (my $data = $sth->fetchrow_hashref) {
    push @result, $data;
  }
  $sth->finish;
  return(scalar(@result), \@result);
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
=cut
sub findguarantees{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select cardnumber,borrowernumber, firstname, surname from borrowers where guarantor=?");
  $sth->execute($bornum);

  my @dat;
  while (my $data = $sth->fetchrow_hashref)
  {
    push @dat, $data;
  }
  $sth->finish;
  return (scalar(@dat), \@dat);
}


=item
loguearBusqueda
Guarda en la base de datos el tipo de busqueda que se realizo y que se busco.
=cut
sub loguearBusqueda{
	my ($borrowernumber,$env,$type,$search)=@_;

	my $dbh = C4::Context->dbh;

	my $old_pe = $dbh->{PrintError}; # save and reset
	my $old_re = $dbh->{RaiseError}; # error-handling
	$dbh->{AutoCommit} = 0;  # enable transactions, if possible
  	$dbh->{RaiseError} = 0; #si lo dejo, para la aplicacion y muestra error

	#comienza la transaccion
	{

	my $query = "	INSERT INTO `busquedas` ( `borrower` , `fecha` )
			VALUES ( ?, NOW( ));";
	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber);

	my $query2= "SELECT MAX(idBusqueda) as idBusqueda FROM busquedas";
	$sth=$dbh->prepare($query2);
	$sth->execute();

	my $id=$sth->fetchrow;

	my $query3;
	my $campo;
	my $valor;

	my $desde= "INTRA";
	if($type eq "opac"){
		$desde= "OPAC";
	}

	$query3= "	INSERT INTO `historialBusqueda` (`idBusqueda` , `campo` , `valor`, `tipo`)
			VALUES (?, ?, ?, ?);";

	$sth=$dbh->prepare($query3);


	if($search->{'keyword'} ne ""){
		$sth->execute($id, 'keyword', $search->{'keyword'}, $desde);
	}

	if($search->{'dictionary'} ne ""){
		$sth->execute($id, 'dictionary', $search->{'dictionary'}, $desde);
	}

	if($search->{'virtual'} ne ""){
		$sth->execute($id, 'virtual', $search->{'virtual'}, $desde);
	}

	if($search->{'signature'} ne ""){
		$sth->execute($id, 'signature', $search->{'signature'}, $desde);
	}	

	if($search->{'analytical'} ne ""){
		$sth->execute($id, 'analytical', $search->{'analytical'}, $desde);
	}

	if($search->{'itemnumber'} ne ""){
		$sth->execute($id, 'itemnumber', $search->{'itemnumber'}, $desde);
	}

	if($search->{'class'} ne ""){
		$sth->execute($id, 'class', $search->{'class'}, $desde);
	}

	if($search->{'subjectitems'} ne ""){
		$sth->execute($id, 'subjectitems', $search->{'subjectitems'}, $desde);
	}

	if($search->{'isbn'} ne ""){
		$sth->execute($id, 'isbn', $search->{'isbn'}, $desde);
	}

	if($search->{'subjectid'} ne ""){
		$sth->execute($id, 'subjectid', $search->{'subjectid'}, $desde);
	}

	if($search->{'author'} ne ""){
		$sth->execute($id, 'author', $search->{'author'}, $desde);
	}

	if($search->{'title'} ne ""){
		$sth->execute($id,'title', $search->{'title'}, $desde);
	}
		

	$dbh->commit ();
	};
	$dbh->rollback () if $@;    # rollback if transaction failed
	$dbh->{AutoCommit} = 1;    # restore auto-commit mode

	#falta ver bien el tema de la transaccion, pq si no se dispara el error y la segunda consulta falla
	#se hace rollback solo de la segunda
}

=item
itemcountbibitem
SE USA SOLAMENTE EN opac-shelves.pl
VER SI QUEDA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
=cut
sub itemcountbibitem {

  my ($bibitem,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from branches";
  my $sth=$dbh->prepare($query);
  $sth->execute();
  my %counts;
  while (my $dataorig=$sth->fetchrow_hashref){
  		$counts{$dataorig->{'branchcode'}}{'nombre'}=$dataorig->{'branchcode'};
  	}
  #Cantidad de ejemplares
  my $query2="select holdingbranch, wthdrawn , notforloan, biblioitemnumber from items where items.biblioitemnumber=?";
  if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.=" and (wthdrawn=0 or wthdrawn is NULL or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  			}
  $sth=$dbh->prepare($query2);
  $sth->execute($bibitem);
  my $data;
  my $total=0;
  my $unavailable=0;
  #Fin: Cantidad de ejemplares
  #Los agrupo por holding branch
  while ($data=$sth->fetchrow_hashref) { 
        $counts{$data->{'holdingbranch'}}{'cantXbranch'}++; #Total
	
	if ($data->{'wthdrawn'} eq 2){ #COMPARTIDO
	 $counts{$data->{'holdingbranch'}}{'cantXbranchShared'}++;
	}else {
        if ($data->{'wthdrawn'} >0){
				$counts{$data->{'holdingbranch'}}{'cantXbranchUnavail'}++; #No Disponible 
				$unavailable++;	
				}else{ 
	if ($data->{'notforloan'}){
		$counts{$data->{'holdingbranch'}}{'cantXbranchNotForLoan'}++; # Para Sala
				}else{
		$counts{$data->{'holdingbranch'}}{'cantXbranchForLoan'}++; # Para Prestamo		
				}
				}
		}
				
  	$total++;
             } 
   #Cantidad de ejemplares prestados y/o reservados
   
   my $query2= "SELECT count( * ) AS c, holdingbranch
		FROM issues, items
		WHERE items.biblioitemnumber = ? AND items.itemnumber = issues.itemnumber AND issues.returndate IS NULL
		GROUP BY holdingbranch";
   $sth=$dbh->prepare($query2);                     
   $sth->execute($bibitem);
   while ($data=$sth->fetchrow_hashref){
	$counts{$data->{'holdingbranch'}}{'prestados'}=$data->{'c'};
		}
  $sth->finish;


 my $query3= "SELECT count( * ) AS c, items.holdingbranch
		FROM reserves, biblioitems, items
		WHERE biblioitems.biblioitemnumber = ? AND biblioitems.biblioitemnumber = items.biblioitemnumber AND 
		biblioitems.biblioitemnumber = reserves.biblioitemnumber AND reserves.constrainttype IS NULL  GROUP BY holdingbranch";
   $sth=$dbh->prepare($query3);
   $sth->execute($bibitem);
   while ($data=$sth->fetchrow_hashref){
        $counts{$data->{'holdingbranch'}}{'reservados'}=$data->{'c'};
                }
  $sth->finish;


my @results;
  foreach my $key (keys %counts){	
	if(($type eq 'opac')&&(C4::Context->preference("opacUnavail") eq 0)){ # Si no hay ninguno disponible no lo muestro en el opac
		if (($counts{$key}->{'cantXbranch'})&&($counts{$key}->{'cantXbranch'} gt $counts{$key}->{'cantXbranchUnavail'}))
			{push(@results,$counts{$key});}
			 }
	  else {($counts{$key}->{'cantXbranch'} && push(@results,$counts{$key}));}
	}
  return ($total,$unavailable,\@results);
}

=item breedingsearch

  ($count, @results) = &breedingsearch($title,$isbn,$random);
C<$title> contains the title,
C<$isbn> contains isbn or issn,
C<$random> contains the random seed from a z3950 search.

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<marc_breeding> table of the Koha database.

=cut


=item
breedingsearch
SE DEJO POR QUE SE USA EN ALGO DE z3950
VER SI SE PUEDE BORRAR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
=cut
sub breedingsearch {
	my ($title,$isbn,$z3950random) = @_;
	my $dbh   = C4::Context->dbh;
	my $count = 0;
	my ($query,@bind);
	my $sth;
	my @results;

	$query = "Select id,file,isbn,title,author from marc_breeding where ";
	if ($z3950random) {
		$query .= "z3950random = ?";
		@bind=($z3950random);
	} else {
	    @bind=();
		if ($title) {
			$query .= "title like ?";
			push(@bind,"$title%");
		}
		if ($title && $isbn) {
			$query .= " and ";
		}
		if ($isbn) {
			$query .= "isbn like ?";
			push(@bind,"$isbn%");
		}
	}
	$sth   = $dbh->prepare($query);
	$sth->execute(@bind);
	while (my $data = $sth->fetchrow_hashref) {
			$results[$count] = $data;
			$count++;
	} # while

	$sth->finish;
	return($count, @results);
} # sub breedingsearch












#SubjectSearch
# busca los temas
#
sub SubjectSearch
{
# open (L,">/tmp/tiempo3");
my ($env,$type,$search,$num,$offset,$orden,$from)=@_;
# printf L $offset."offset\n";
# printf L $num."num\n";
# printf L $type."type\n";
# printf L $search."searnch\n";
# printf L $from."from\n";
# printf L $search->{'subjectitems'}."ppp";


my $dbh = C4::Context->dbh;
my $query = '';
my @bind = ();
my @results;
my @key=split(' ',$search->{'subjectitems'});

my $count=@key;

my $i=1;
#$query="SELECT * FROM temas where((temas.nombre like ? or temas.nombre like ?)";
# $query="Select distinct temas.id, temas.nombre from bibliosubject inner join temas on temas.id=bibliosubject.subject where((temas.nombre like ? or temas.nombre like ?)";

$query="Select distinct temas.id, temas.nombre from temas where((temas.nombre like ? or temas.nombre like ?)";

@bind=("$key[0]%","% $key[0]%");

while ($i < $count){
	$query .= " and (temas.nombre like ? or temas.nombre like ?)";
	push(@bind,"$key[$i]%","% $key[$i]%");
	$i++;
}
$query .= ")";

my $sth=$dbh->prepare($query);
$sth->execute(@bind);
 
my $i=0;
my $limit= $num+$offset;

while (my $data=$sth->fetchrow_hashref){
    push @results, $data;
    $i++;
}

$sth->finish;

my $count=$i;


my $countFinal=0;
my @resFinal;
($offset||($offset=0));


for ($i = $offset; (($i < $limit) && ($i < $count)); ++$i)
{ 
# printf L $i."nro\n";
# printf L $results[$i]{'id'}."nro\n";
	$resFinal[$countFinal]=$results[$i];
	$countFinal++; 
}
# close L;
# print A "offset $offset limit $limit  count $count \n";

return($count,@resFinal);

} 


#AnalyticalKeywordSearch
# busca los temas
#
sub AnalyticalKeywordSearch{

my ($env,$type,$search,$num,$offset,$orden,$from)=@_;

my $dbh = C4::Context->dbh;
my $query = '';
my @bind = ();
my @results;
my @key=split(' ',$search->{'analyticalkeyword'});

my $count=@key;

my $i=1;
#$query="SELECT * FROM temas where((temas.nombre like ? or temas.nombre like ?)";
# $query="Select distinct temas.id, temas.nombre from bibliosubject inner join temas on temas.id=bibliosubject.subject where((temas.nombre like ? or temas.nombre like ?)";

$query="Select distinct temas.id, temas.nombre from temas where((temas.nombre like ? or temas.nombre like ?)";

@bind=("$key[0]%","% $key[0]%");

while ($i < $count){
	$query .= " and (temas.nombre like ? or temas.nombre like ?)";
	push(@bind,"$key[$i]%","% $key[$i]%");
	$i++;
}
$query .= ")";

my $sth=$dbh->prepare($query);
$sth->execute(@bind);
 
my $i=0;
my $limit= $num+$offset;

while (my $data=$sth->fetchrow_hashref){
    push @results, $data;
    $i++;
}

$sth->finish;

my $count=$i;


my $countFinal=0;
my @resFinal;
($offset||($offset=0));


for ($i = $offset; (($i < $limit) && ($i < $count)); ++$i)
{ 
# printf L $i."nro\n";
# printf L $results[$i]{'id'}."nro\n";
	$resFinal[$countFinal]=$results[$i];
	$countFinal++; 
}
# close L;
# print A "offset $offset limit $limit  count $count \n";

return($count,@resFinal);

} 


#http://127.0.0.1/cgi-bin/koha/opac-searchresults.pl?orden=title&startfrom=15&subjectitems=economia
#http://127.0.0.1/cgi-bin/koha/opac-searchresults.pl?criteria=subjectitems&searchinc=economia&se.x=40&se.y=16&se=Buscar



sub updatesearchstats{
  my ($dbh,$query)=@_;

}


sub FindItemType {
  my ($biblioitem)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT itemtypes.itemtype, itemtypes.description,itemtypes.search FROM biblioitems, itemtypes WHERE biblioitems.biblioitemnumber =? AND itemtypes.itemtype = biblioitems.itemtype ;");
  $sth->execute($biblioitem);
 my $data=$sth->fetchrow_hashref;
return($data->{'itemtype'},$data->{'description'},$data->{'search'});
}

sub FindVol {
  my ($biblioitem)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT volume, volumeddesc FROM biblioitems  WHERE biblioitems.biblioitemnumber =?  ;");
  $sth->execute($biblioitem);
my $data=$sth->fetchrow_hashref;
return ( $data->{'volumeddesc'}, $data->{'volume'});

}


sub countitems {
#Cantidad de items de un biblioitem
  my ($bib,$bibit)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select count(*) from items where biblionumber=? and biblioitemnumber=? ");
  $sth->execute($bib,$bibit);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}


### cuenta las reserva que tiene un biblioitem 30/03/2007 VER SI ESTA BIEN!!!!!!!!!!!!!!! - Damian
### ESTA EN C4::AR::Reservas, SE TIENE QUE BORRAR!!!!!!! Y MODIFICAR EN TODOS LOS LADOS DONDE SE LLAMA.
### NO SE USA MAS EN LA VERSION NUEVA, SE USA LA NUEVA, SE DEJA POR LAS DUDAS, EN LA LIMPIEZA BORRAR.
sub Countreserve{
   my ($bibitemnumber)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("SELECT  count(*) as reservas
                       FROM reserves
                       WHERE biblioitemnumber =? AND constrainttype IS NULL");
   $sth->execute($bibitemnumber);
   my $data=$sth->fetchrow_hashref;
   return($data->{'reservas'});
}

#cuenta las reservas pendientes del grupo
### NO SE USA MAS EN LA VERSION NUEVA, SE DEJA POR LAS DUDAS, EN LA LIMPIEZA BORRAR.
sub CountreserveGrupo{
   my ($biblioitemnumber)=@_;
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("SELECT count(*) as reservas from reserves 
	WHERE  reserves.biblioitemnumber = ? and reserves.constrainttype is NULL  and itemnumber is Null ");
   $sth->execute($biblioitemnumber);
   my $data=$sth->fetchrow_hashref;
   return($data->{'reservas'});
}

sub allbibitems {
#Todos los biblioitems de un biblio
  my ($bib,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT  *
                       FROM biblioitems
                       inner join itemtypes on biblioitems.itemtype = itemtypes.itemtype
                       WHERE biblionumber =? order by volume asc,number asc ");

  #my $sth=$dbh->prepare("SELECT  *
   #                       FROM biblioitems
#			  inner join itemtypes on biblioitems.itemtype = itemtypes.itemtype
#			  inner join biblio on biblioitems.biblionumber = biblio.biblionumber
 #                         WHERE biblioitems.biblionumber =?
 # ");                      
  $sth->execute($bib);

my $cantbibit=0;
my $cantunavail=0;
my @results;
my @resultsItems;
my $i=0;
 while (my $data=$sth->fetchrow_hashref){

	#los grupos que no tienen libros no se muestran en el OPAC
	if($type eq "opac"){
        my $sth2=$dbh->prepare("SELECT  * FROM items WHERE biblioitemnumber =? AND wthdrawn = 0 or wthdrawn is null or wthdrawn = 2 or wthdrawn = 7");
        $sth2->execute($data->{'biblioitemnumber'});
        	if(!$sth2->fetchrow_hashref){
           		next;
        	}
    	}

        $results[$i]=$data;
	$results[$i]->{'publishercode'}= publisherList($results[$i]->{'biblioitemnumber'},$dbh); #agregado por Luciano
	$results[$i]->{'isbncode'}= isbnList($results[$i]->{'biblioitemnumber'},$dbh); #agregado por Einar
	my @aux;

($results[$i]->{'total'},$results[$i]->{'fl'},$results[$i]->{'notfl'},$results[$i]->{'unav'},$results[$i]->{'issue'},$results[$i]->{'issuenfl'},$results[$i]->{'reserve'},$results[$i]->{'shared'},$results[$i]->{'copy'},@aux)=allitems($data->{'biblioitemnumber'},$type);

	
	#Los disponibles son los prestados + los reservados + los que se pueden prestar + los de sala
$results[$i]->{'available'}= $results[$i]->{'issue'}+$results[$i]->{'issuenfl'} + $results[$i]->{'reserve'} + $results[$i]->{'fl'} + $results[$i]->{'notfl'};

	#Matias necesito la primera signatura topografica
	if(@aux ne 0){ $results[$i]->{'firstST'}=$aux[0]->{'bulk'}; }
	#
	#Si son todos para sala los disponibles esta solo disponible para sala (Se tiene en cuenta los prestados en sala en este momento!!!)
	$results[$i]->{'notforloan'}= ((($results[$i]->{'available'} - ($results[$i]->{'notfl'}+$results[$i]->{'issuenfl'})) eq 0) and (($results[$i]->{'notfl'}+$results[$i]->{'issuenfl'}) gt 0));
	
	#Son todos compartidos?
	$results[$i]->{'allshared'} = (($results[$i]->{'shared'} gt 0) and ($results[$i]->{'available'} eq 0));
	
	#Son todos para copiar?
	$results[$i]->{'allcopy'} = (($results[$i]->{'copy'} gt 0) and ($results[$i]->{'available'} eq 0));

	#Son todos no disponibles?
	$results[$i]->{'allunavail'}= ($results[$i]->{'total'} eq  $results[$i]->{'unav'});


	   if (($type ne 'intranet')&&(C4::Context->preference("opacUnavail") eq 0))
	       {$results[$i]->{'unavailable'}=($results[$i]->{'total'} eq  $results[$i]->{'unav'});
	       # Para ver si todos los grupos estan deshabilitados
	       if ($results[$i]->{'unavailable'}){$cantunavail++;};
	       	}
	


	$cantbibit++;
 	#

	#bibitnfloan ($results[$i]->{'biblioitemnumber'},$type);	

	$results[$i]->{'items'}=\@aux;
	
# Miguel - Se pidio que se muestre la misma cant de reservas en la INTRA y en el OPAC
=item
#### Este if estaba comentado los descomente para que devuelva la cantidad de reservas que hay en en grupo.
if ($type eq "intranet") {$results[$i]->{'reserves'}= Countreserve($data->{'biblioitemnumber'}); }
else {$results[$i]->{'reserves'}= CountreserveGrupo($data->{'biblioitemnumber'});}
=cut

	$results[$i]->{'reserves'}= Countreserve($data->{'biblioitemnumber'});

 #MAtias Lenguaje Pais y Soporte
        my $country=getCountry($results[$i]->{'idCountry'});
        $results[$i]->{'country'}= $country->{'printable_name'};
        $results[$i]->{'idCountry'}= $country->{'iso'};

        my $support=getSupport($results[$i]->{'idSupport'});
        $results[$i]->{'support'}= $support->{'description'};
        $results[$i]->{'idSupport'}= $support->{'idSupport'};

        my $language=getLanguage($results[$i]->{'idLanguage'});
        $results[$i]->{'language'}= $language->{'description'};
        $results[$i]->{'idLanguage'}= $language->{'idLanguage'};
        #

	my $level=getLevel($results[$i]->{'classification'});
        $results[$i]->{'classification'}= $level->{'description'};
        $results[$i]->{'idclass'}= $level->{'code'};
        #


	 $i++;
        }
  $sth->finish;

  return(@results);
}


sub groupinfo {
#Para ver cuantos items se pueden reservar del grupo  
	
    my ($env,$biblioitemnumber,$biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $dateformat = C4::Date::get_date_format();
    my $query = "SELECT items.itemnumber,items.barcode, items.biblionumber,items.biblioitemnumber,items.holdingbranch, items.datelastborrowed, 
				items.datelastseen  ,items.itemlost,items.wthdrawn,items.dateaccessioned, items.notforloan as itemnotforloan 
				FROM items, biblioitems WHERE items.biblionumber = ? 
                 AND biblioitems.biblioitemnumber = items.biblioitemnumber 
                 AND items.biblioitemnumber =? and ((items.itemlost<>1 and items.itemlost <> 2)
				 or items.itemlost is NULL)
			     and (items.wthdrawn <> 1 or items.wthdrawn is NULL) order by items.dateaccessioned desc";
    
  my $sth=$dbh->prepare($query);
  $sth->execute($biblionumber,$biblioitemnumber);
  my $i=0;
  
  my $available=0;
  my $lost=0;
  my $notloan=0;
  my $cancel=0;
  my $late=0;
  my $isu=0; #prestamos
  my $dates="";#Fechas
  my @branches;
  my $bi=0; #indice de branches
  while (my $data=$sth->fetchrow_hashref){
    my $datedue = '';
    my $isth=$dbh->prepare("Select * from issues where itemnumber = ? and returndate is null");
    $isth->execute($data->{'itemnumber'});

    if (my $idata=$isth->fetchrow_hashref){
      $datedue = format_date($idata->{'date_due'},$dateformat);
      $dates.=$data->{'barcode'}."(".$datedue.")<br> ";
      $isu++; #Prestados
    }
    if ($data->{'itemlost'} eq '2'){
        $datedue="<font color='red'>Muy Atrasado</font>";
		$late++;
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue="<font color='red'>Perdido</font>";
		$lost++;
    }
    if ($data->{'wthdrawn'} eq '1'){
        $datedue="<font color='red'>Cancelado</font>";
		$cancel++;
    }
    if ($data->{'notforloan'} eq '1'){
        $datedue="<font color='blue'>Para Sala</font>";
		$notloan++;
    }
    if ($datedue eq ''){
        $datedue="<font color='green'>Disponible</font>";
		$available++;
      }
    $isth->finish;

#get branch information.....
    my $bsth=$dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
    $bsth->execute($data->{'holdingbranch'});
    if (my $bdata=$bsth->fetchrow_hashref){
   my $find=0;
	for (my $j=0;$j<$bi;$j++) {

		if ($branches[$j]->{'branchcode'} eq  $bdata->{'branchcode'})
		      { $branches[$j]->{'count'}++;
			$find=1;		
			}
				}
	
	if ($find ne 1){ 
		     $branches[$bi]->{'branchcode'} = $bdata->{'branchcode'};
		     $branches[$bi]->{'branchname'} = $bdata->{'branchname'};
		     $branches[$bi]->{'count'} = 1;	
		     $bi++;
		}
		   			 }


  $i++;
  }
 $sth->finish;
my ($reserve, @reserves) ; # Findgroupreserve($biblioitemnumber,$biblionumber);

  return($available,$lost,$notloan,$cancel,$late,$isu,$dates,$reserve,@branches);
}








=item
Esta funcion cuenta los grupos de un biblio 
=cut

sub itemcountPorGrupos{
#Einar
 my ($bibnum,$type)=@_;
 my $dbh = C4::Context->dbh;
 my $data;
 my @aux;
#Cantidad de ejemplares
 my $query2="select biblioitemnumber,volume from biblioitems where biblioitems.biblionumber=?";
 my $sth2=$dbh->prepare($query2);
 $sth2->execute($bibnum);
 my $cant=0; 
 while ($data=$sth2->fetchrow_hashref){
 my %aux2;
 $cant++;
 $query2="select count(*) as c from items where items.biblioitemnumber=?";
 if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.="(wthdrawn=0  or wthdrawn is NULL or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  }
  my $sth3=$dbh->prepare($query2);
  $sth3->execute($data->{'biblioitemnumber'});
  my $data2=$sth3->fetchrow_hashref;
  $aux2{'tomo'}=$data->{'volume'};
  $aux2{'cantidaddetomos'}=$data2->{'c'};
  push (@aux,\%aux2);
  }
  return($cant,\@aux);
  #Fin: Cantidad de ejemplares


}




sub bibitnfloan {
#Cuenta si un grupo se puede o no prestar
  my ($bibitem,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $total=0;
  my $nfloan=0;
  my $data; 
  my $sth; 
#Cantidad de ejemplares
  my $query="select notforloan, biblioitemnumber from items where items.biblioitemnumber=? and (wthdrawn=0 or wthdrawn is NULL)";
  $sth=$dbh->prepare($query);
  $sth->execute($bibitem);
  #Fin: Cantidad de ejemplares
  while ($data=$sth->fetchrow_hashref) {
     	if ($data->{'notforloan'}){$nfloan++;}
        $total++;
             }
  return ($total eq $nfloan);
        }
sub bibavail {
#Todos los ejemplares del libro estan no disponibles?
  my ($bib)=@_;
  my $dbh = C4::Context->dbh;
  my $data;
  my $sth;  
  my $query="select count(itemnumber) as num from items where items.biblionumber=? and (wthdrawn=0 or wthdrawn is NULL or wthdrawn=2 or wthdrawn=7)"; #wthdrawn=2 es COMPARTIDO 
  $sth=$dbh->prepare($query);
  $sth->execute($bib);
  #Fin: Cantidad de ejemplares
  $data=$sth->fetchrow_hashref;
  if ($data->{'num'} gt 0){return(1);}
  return (0);
        }


=item getwebsites

  ($count, @websites) = &getwebsites($biblionumber);

Looks up the web sites pertaining to the book with the given
biblionumber.

C<$count> is the number of elements in C<@websites>.

C<@websites> is an array of references-to-hash; the keys are the
fields from the C<websites> table in the Koha database.

=cut
#'NO SE USA!!!!!!!!!!!!!!!!11************************!!!!!!!!!!!!!!!!
sub getwebsites {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select * from websites where biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
        # FIXME - The URL scheme shouldn't be stripped off, at least
        # not here, since it's part of the URL, and will be useful in
        # constructing a link to the site. If you don't want the user
        # to see the "http://" part, strip that off when building the
        # HTML code.
        $data->{'url'} =~ s/^http:\/\///;	# FIXME - Leaning toothpick
						# syndrome
        $results[$count] = $data;
    	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebsites





#agregado por LUCIANO
sub editorsname {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblioitems where biblionumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bibnum);
  my @result;
  my $res='';
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'number'} || $data->{'publicationyear'} ){#|| $data->{'place'}) {
	$res.=$data->{'number'};
    	if ($data->{'publicationyear'} )#|| $data->{'place'}) {
    		{
                $res.=' (';
		#if ($data->{'publicationyear'}) {	
	        $res.=$data->{'publicationyear'};#.', '.$data->{'place'};
		#} else {
		#	$res.=$data->{'place'};
		}
		$res=~s/, $//;
		$res.='), ';
		
    	} 
	else {
    		$res.=', ';
	}
    }
		push(@result,$res);
		$res='';
  
  #Agregado para manejar el tema de que las ediciones estaban repetidas. por Tuto y Einar.
  my $i=0;
  my @result2=();
  my $res='';
  foreach my $auxiliar (@result){
      foreach my $auxiliar2 (@result2) {
		if ($auxiliar eq $auxiliar2){ $i=1;}
				        } 
	if ($i eq 0)	{push (@result2,$auxiliar);	
      				$res.=$auxiliar;}
			
      			else {$i=0;}
   } 

  $res=~s/, $//;
  return($res);
}
=item
agregado por EINAR
esta funcion devuelve los datos de los grupos a mostrar en una busaqueda dado un biblionumber
Esto incluye: biblioitemnumber,number (que es la edicion), publicationyear, volume y la cantidad de items que tiene ese grupo. 
=cut

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
  	
	my $query2="select count(*) as c from items where items.biblioitemnumber=?";
 	if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    		$query2.=" and (wthdrawn=0 or wthdrawn is NULL  or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  			    }
	my $sth2=$dbh->prepare($query2);
  	$sth2->execute($data->{'biblioitemnumber'});
	
	my $aux=($sth2->fetchrow_hashref);
	
	if (($aux)&&($aux->{'c'} gt 0)){
	$result[$res]{'cant'}=$aux->{'c'};
	$result[$res]{'biblioitemnumber'}=$data->{'biblioitemnumber'};
        $result[$res]{'edicion'}=$data->{'number'};
        $result[$res]{'publicationyear'}=$data->{'publicationyear'};
        $result[$res]{'volume'}=$data->{'volume'};
	$res++;	
		}
	}
return (\@result);
}


sub generarEstadoDeColeccion
 {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="SELECT publicationyear, volume, fasc
  		FROM biblioitems
  		WHERE biblionumber = ?
  		ORDER BY publicationyear ASC , volume ASC , fasc ASC ";

  my $sth=$dbh->prepare($query);
  $sth->execute($bibnum);

  my $colect="";
  my $year=0;
  my $vol=0;
 while (my $data = $sth->fetchrow_hashref) {

if (($data->{'publicationyear'} ne $year) || ($data->{'volume'} ne $vol)){

  if (($year ne 0) && ($vol ne 0)) { $colect.=');<br>';}
 
  $colect.=$data->{'publicationyear'}.' '.$data->{'volume'}.'('.$data->{'fasc'};
  
  } else 
  {$colect.=','.$data->{'fasc'};}
 
 $year=$data->{'publicationyear'};
 $vol=$data->{'volume'};
  }

$colect.=')';

return $colect;
}


sub publisherList {
#Arama un listado alfabetico con todas las editoriales de un grupo separadas por coma (,)
        my ($biblioitemnumber, $dbh) = @_;
        my $sth = $dbh->prepare("select * from publisher where biblioitemnumber = ? order by publisher");
        $sth->execute($biblioitemnumber);
        my $result="";
        while (my $data = $sth->fetchrow_hashref) {
                $result.=$data->{'publisher'}.", ";
        }
        $result=~s/, $//;
        return($result);
}
#fin agregado por LUCIANO
sub isbnList {
#Arama un listado alfabetico con todas los isbn de un grupo separadas por coma (,)
        my ($biblioitemnumber, $dbh) = @_;
        my $sth = $dbh->prepare("select * from isbns where biblioitemnumber = ? ");
        $sth->execute($biblioitemnumber);
        my $result="";
        while (my $data = $sth->fetchrow_hashref) {
                $result.=$data->{'isbn'}.", ";
        }
        $result=~s/, $//;
        return($result);
}
#fin agregado por EINAR
#Matias Verificar que se puedan realizar las eliminaciones

sub canDeleteBiblio {
#Se puede borrar el Biblio? 
        my ($biblionumber) = @_;

	my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM biblio, items, issues 
		WHERE biblio.biblionumber = items.biblionumber AND items.itemnumber = issues.itemnumber 
		AND biblio.biblionumber = ?   AND issues.returndate IS NULL");
        $sth->execute($biblionumber);
        my $result="";
        if (my $data = $sth->fetchrow_hashref)
		{ $result=1} else { $result=0} 
        return($result); 
	}	


sub canDeleteBiblioitem {
#Se puede borrar el grupo?
        my ($biblioitemnumber) = @_;
                                                                                                                             
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM biblioitems,items ,issues WHERE 
                items.biblioitemnumber = biblioitems.biblioitemnumber AND items.itemnumber = issues.itemnumber 
		AND biblioitems.biblioitemnumber = ?  AND issues.returndate IS NULL");
        $sth->execute($biblioitemnumber);
        my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);
	}

sub canDeleteItem {
#Se puede borrar o poner no disponible el Item?
        my ($itemnumber) = @_;
                                                                                                                             
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM items, issues WHERE 
		items.itemnumber = issues.itemnumber AND items.itemnumber = ? AND issues.returndate IS NULL ");
        $sth->execute($itemnumber);
        my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);

}
=item 
Sacado por einar
sub haveReserves {
  my ($bibitemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT * FROM reserves, reserveconstraints
	WHERE reserves.biblionumber = reserveconstraints.biblionumber AND reserves.timestamp = reserveconstraints.timestamp AND 
	reserveconstraints.biblioitemnumber = ? AND 
	(reserves.found <> 'F' OR reserves.found IS NULL)");
    $sth->execute($bibitemnum);

 my $result="";
        if (my $data = $sth->fetchrow_hashref)
                { $result=1} else { $result=0}
        return($result);

}
=cut

sub mailissues {
  	my ($branch)=@_;
  	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
  	my $sth=$dbh->prepare("SELECT * 
	FROM issues
	LEFT JOIN borrowers ON borrowers.borrowernumber = issues.borrowernumber
	LEFT JOIN nivel3 n3 ON n3.id3 = issues.id3
	LEFT JOIN nivel1 n1 ON n3.id1 = n1.id1
	WHERE issues.returndate IS NULL AND issues.date_due <= now( ) AND issues.branchcode = ? ");
    	$sth->execute($branch);
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

sub mailissuesforborrower {
  	my ($branch,$bornum)=@_;
  	my $dbh = C4::Context->dbh;
	my $dateformat = C4::Date::get_date_format();
  	my $sth=$dbh->prepare("SELECT * 
	FROM issues
	LEFT JOIN nivel3 n3 ON n3.id3 = issues.id3
	LEFT JOIN nivel1 n1 ON n3.id1 = n1.id1
	WHERE issues.returndate IS NULL AND issues.date_due <= now( ) AND issues.branchcode = ? AND issues.borrowernumber = ? ");
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

sub mailreservas{
	my ($branch)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * FROM reserves 
		INNER JOIN borrowers ON (reserves.borrowernumber=borrowers.borrowernumber) 
		LEFT JOIN items ON (reserves.itemnumber = items.itemnumber )
		INNER JOIN biblio ON (items.biblionumber = biblio.biblionumber)
		WHERE reserves.branchcode=? AND constrainttype IS NULL 
		AND items.biblionumber IS NOT NULL");
	$sth->execute($branch);
	my @result;
	while (my $data = $sth->fetchrow_hashref) {
		my $author=getautor($data->{'author'});
		$author=$author->{'completo'};
		$data->{'author'}=$author;
		push @result, $data;
	}
	$sth->finish;
	return(scalar(@result), \@result);

}

sub firstbulk {
  my ($bib)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT bulk FROM items WHERE biblionumber = ? ;");
    $sth->execute($bib);
  my $data = $sth->fetchrow;
  
  return($data);
}


#fin Matias


#Funciones Adicionales para manejar la compatibilidad con guarani, empezadas por Einar

#item PersonNameSearch

  #($count, $borrowers) = &PersonNameSearch($env, $searchstring, $type);

#Looks up patrons (borrowers) by name.
#'
#used by member enquiries from the intranet
#called by member.pl

sub PersonNameSearch  {
	my ($env,$searchstring,$type,$onlyCount,$orden,$startRecord,$numberOfRecords)=@_;
	my $dbh = C4::Context->dbh;
	my $count; 
	my @data;
	my @bind=();
	my $query;


#Por si viene Vacio
        if ($orden eq ''){$orden='surname,firstname';}
        #


	if ($onlyCount) {
                $query = "Select count(*) from persons ";
        } else {
                $query = "Select * from persons ";
        }

	if($type eq "simple")	# simple search for one letter only
	{
		$query.="where surname like ? order by $orden";
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
                $query=$query."  order by $orden";
	}

        #### Add by Luciano to get pages of users insted of all the records ####
        if (defined $startRecord && defined $numberOfRecords) {
                $query.= " limit $startRecord,$numberOfRecords";
        }
        ######

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


sub persdata {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $sth;
  if ($bornum eq ''){
    $sth=$dbh->prepare("Select * from persons where cardnumber=?");
    $sth->execute($cardnumber);
  } else {
    $sth=$dbh->prepare("Select * from persons where personnumber=?");
  $sth->execute($bornum);
  }
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  if ($data) {
  	return($data);
	} else { # try with firstname
		if ($cardnumber) {
			my $sth=$dbh->prepare("select * from persons where firstname=?");
			$sth->execute($cardnumber);
			my $data=$sth->fetchrow_hashref;
			$sth->finish;
			return($data);
		}
	}
	return undef;
}
=item getcitycategory

  $description = &getcitycategory($citycode);

Given the city category code, the function returns the corresponding
description for a comprehensive information display.

=cut

sub getcitycategory
{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT NOMBRE FROM localidades WHERE LOCALIDAD = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	if ($description) {return $description;}
			else{return "";}
} # sub getcitycategory

sub obtenerCategoria
{
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
                       
} # sub getcitycategory

sub mostrarProvincias { 
	
	my ($pais) = @_;
        my $dbh = C4::Context->dbh;
	my $query="SELECT nombre,provincia  FROM provincias WHERE pais = ? order by nombre ";
        my $sth = $dbh->prepare($query);
        $sth->execute($pais);
	my %results;
	while (my $data=$sth->fetchrow_hashref){
		$results{$data->{'provincia'}}= $data->{'nombre'};
                }
	$sth->finish();
        return (%results);
                                                                                                                             
} 

sub darProvincia {
        
        my ($prov) = @_;
        my $dbh = C4::Context->dbh;
        my $query="SELECT nombre  FROM provincias WHERE provincia = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($prov);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);

}


#########
#Dados un pais y una provincia me retorna todos los 
#departamentos de esa provincia
#
########
sub mostrarDepartamentos{

	my ($prov) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "Select nombre,dpto_partido
		     FROM dptos_partidos  as dp
                     WHERE dp.provincia= ?
                     ORDER BY dp.NOMBRE";
	my $sth = $dbh->prepare($query);
        $sth->execute($prov);
	my %results;
        while (my $data=$sth->fetchrow_hashref){
                $results{$data->{'dpto_partido'}}= $data->{'nombre'};
                }
        $sth->finish();
        return %results;
}

sub darDepartamento {

        my ($dep) = @_;
        my $dbh = C4::Context->dbh;
        my $query="Select nombre FROM dptos_partidos  WHERE dpto_partido = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($dep);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);
}

###
#Dados una provincia y un departamento me devuelva todas las localidades
#
###
sub mostrarCiudades{
	
	my ($localidad) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT nombre,localidad FROM localidades  WHERE dpto_partido= ?  ORDER BY nombre";
	my $sth = $dbh->prepare($query);
        $sth->execute($localidad);
	my %results;
	while (my $data=$sth->fetchrow_hashref){
                $results{$data->{'localidad'}}= $data->{'nombre'};
                }
	$sth->finish();
        return %results;

}
sub darCiudad {

        my ($ciu) = @_;
        my $dbh = C4::Context->dbh;
        my $query="Select nombre FROM localidades  WHERE localidad = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($ciu);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);
}


sub mostrarPaises{
        my $dbh = C4::Context->dbh;
        my $query = "SELECT printable_name,code from countries  ORDER BY printable_name";
        my $sth = $dbh->prepare($query);
        $sth->execute();
         my %results;
        while (my $data=$sth->fetchrow_hashref){
                $results{$data->{'code'}}= $data->{'printable_name'};
                }

	$sth->finish();
        return %results;

}

sub darPais {

        my ($pais) = @_;
        my $dbh = C4::Context->dbh;
        my $query="Select printable_name FROM countries  WHERE code = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($pais);
        my $data=$sth->fetchrow;
        $sth->finish();
        return ($data);
}


sub  getCountry
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from countries where iso = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getSupport
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from supports where idSupport = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLanguage
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from languages where idLanguage = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

sub getLevel
{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from bibliolevel where code = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}


 sub getautoresAdicionales{
    my ($biblionumber) = @_;
    my @result;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select id,apellido, nombre, completo from autores inner join additionalauthors  on additionalauthors.author=autores.id where biblionumber= ?");
    $sth->execute($biblionumber);
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
      push(@results,$data);
      
    }
    $sth->finish();
    return(@results);
}

sub getColaboradores{
    my ($biblionumber) = @_;
    my @result;
    my $dbh   = C4::Context->dbh;
    
    my $sth= $dbh->prepare("Select id,apellido,nombre,tipo from autores inner join colaboradores on colaboradores.idColaborador=autores.id where biblionumber = ?");
    $sth->execute($biblionumber);
     my @results2;
    while (my $data = $sth->fetchrow_hashref) {
       push(@results2,$data);
    }
    $sth->finish();
    return(@results2);
    
} # sub getbiblio



#Disponibilidad
sub getavails {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from unavailable");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'code'}}= $data->{'description'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getavails

#Disponibilidad
sub getavailsplus {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from unavailable");
  my %resultslabels;
	$resultslabels{0}= 'Disponible';	
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'code'}}= $data->{'description'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getavails

sub getAvail{
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from unavailable where code = '$cod' ";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}

#Temas, toma un id de tema y devuelve la descripcion del tema.
sub getTema{
	my ($idTema)=@_;
	my $dbh = C4::Context->dbh;
        my $query = "SELECT * from temas where id = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($idTema);
        my $tema=$sth->fetchrow_hashref;
        $sth->finish();
	return($tema);
}

#Disponibilidad
sub availArray {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from unavailable");
  my @results;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    push(@results,$data->{'description'});
  } # while
  $sth->finish;
  return(scalar(@results),\@results);
} # sub availArray



sub availDetail
{
        my ($item) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "select * from availability where item = ? ORDER BY date DESC";
        my $sth = $dbh->prepare($query);
        $sth->execute($item);
	 my @results;
	my $i=0;
	 while (my $data=$sth->fetchrow_hashref){$results[$i]=$data; $i++; }
  	$sth->finish;
  	return(scalar(@results),\@results);
}




sub SearchSig
{
my ($signature) = @_;
my $dbh = C4::Context->dbh;
my $query = "SELECT distinct biblio.* from biblio inner join items on biblio.biblionumber=items.biblionumber  where items.bulk like ? or items.bulk like ? ; ";
my $sth = $dbh->prepare($query);
$sth->execute("$signature%","% $signature%");
 my @results;
 my $i=0;
 while (my $data=$sth->fetchrow_hashref){$results[$i]=$data; $i++; }
 $sth->finish;
 return(scalar(@results),@results);					   
}




END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut


