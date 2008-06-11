#!/usr/bin/perl

use C4::Context;
use C4::AR::Catalogacion;

my @N1;
my @N2;
my @N3;
my $autor;
my @ids1=();
my @valores1=();
my @ids2=();
my @valores2=();
my @ids3=();
my @valores3=();
my $id1;
my $id2;
my $tipoDocN2;
my $id3;

##Otras Tablas##
my $subject;
my $subtitle;
my $isbn;
my $publisher;
my $additionalauthor;
################

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("SELECT * FROM biblio ;");
$sth->execute();
	
	#Obtengo los campos del nivel 1
	my $sth1=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='biblio';");
	$sth1->execute();
	while (my $n1=$sth1->fetchrow_hashref) {
	push (@N1,$n1);
	}
	$sth1->finish();

	#Obtengo los campos del nivel 2
	my $sth3=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='biblioitems';");
	$sth3->execute();
	while (my $n2=$sth3->fetchrow_hashref) {
	push (@N2,$n2);
	}
	$sth3->finish();

	#Obtengo los campos del nivel 3
	my $sth5=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='items';");
	$sth5->execute();
	while (my $n3=$sth5->fetchrow_hashref) {
	push (@N3,$n3);
	}
	$sth5->finish();

####################################Otras Tablas#######################################
	my $sth10=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='bibliosubject';");
	$sth10->execute();
	$subject=$sth10->fetchrow_hashref;
	$sth10->finish();

	my $sth11=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='bibliosubtitle';");
	$sth11->execute();
	$subtitle=$sth11->fetchrow_hashref;
	$sth11->finish();

	my $sth12=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='additionalauthors';");
	$sth12->execute();
	$additionalauthor=$sth12->fetchrow_hashref;
	$sth12->finish();

	my $sth13=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='publisher';");
	$sth13->execute();
	$publisher=$sth13->fetchrow_hashref;
	$sth13->finish();

	my $sth14=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='isbns';");
	$sth14->execute();
	$isbn=$sth14->fetchrow_hashref;
	$sth14->finish();
###############################################################################

while (my $biblio=$sth->fetchrow_hashref ) {
	$autor=$biblio->{'author'};
#---------------------------------------NIVEL1---------------------------------------#
	foreach (@N1) {
		push(@ids1,$_->{'campo'}.",".$_->{'subcampo'});
		push(@valores1,$biblio->{$_->{'campoTabla'}});
	}
	
	###########################OTRAS TABLA biblio##########################
	# subject
	my $sth6=$dbh->prepare("SELECT * FROM bibliosubject where biblionumber= ?;");
	$sth6->execute($biblio->{'biblionumber'});
	
	while (my $biblosubject=$sth6->fetchrow_hashref ) {
		push(@ids1,$subject->{'campo'}.",".$subject->{'subcampo'});
		push(@valores1,$biblosubject->{$subject->{'campoTabla'}});
		}
	$sth6->finish();

	# subtitle
	my $sth7=$dbh->prepare("SELECT * FROM bibliosubtitle where biblionumber= ?;");
	$sth7->execute($biblio->{'biblionumber'});
	
	while (my $biblosubtitle=$sth7->fetchrow_hashref ) {
		push(@ids1,$subtitle->{'campo'}.",".$subtitle->{'subcampo'});
		push(@valores1,$biblosubtitle->{$subtitle->{'campoTabla'}});
		}
	$sth7->finish();

	# additionalauthor
	
	my $sth8=$dbh->prepare("SELECT * FROM additionalauthors where biblionumber= ?;");
	$sth8->execute($biblio->{'biblionumber'});
	
	while (my $aauthors=$sth8->fetchrow_hashref ) {
		push(@ids1,$additionalauthor->{'campo'}.",".$additionalauthor->{'subcampo'});
		push(@valores1,$aauthors->{$additionalauthor->{'campoTabla'}});
		}
	$sth8->finish();	

	#########################################################################

	$id1=&guardarNivel1($autor,\@ids1,\@valores1);
#---------------------------------------NIVEL1---------------------------------------#	

#---------------------------------------NIVEL2---------------------------------------#
	my $sth2=$dbh->prepare("SELECT * FROM biblioitems where biblionumber= ?;");
	$sth2->execute($biblio->{'biblionumber'});
	while (my $biblioitem=$sth2->fetchrow_hashref ) {
	foreach (@N2) {
		push(@ids2,$_->{'campo'}.",".$_->{'subcampo'});
		push(@valores2,$biblioitem->{$_->{'campoTabla'}});
	}
	
	###########################OTRAS TABLAS biblioitem##########################
	# publisher
	
	my $sth15=$dbh->prepare("SELECT * FROM publisher where biblioitemnumber= ?;");
	$sth15->execute($biblioitem->{'biblioitemnumber'});
	
	while (my $pub=$sth15->fetchrow_hashref ) {
		push(@ids2,$publisher->{'campo'}.",".$publisher->{'subcampo'});
		push(@valores2,$pub->{$publisher->{'campoTabla'}});
		}
	$sth15->finish();
	
	# isbn

	my $sth16=$dbh->prepare("SELECT * FROM isbns where biblioitemnumber= ?;");
	$sth16->execute($biblioitem->{'biblioitemnumber'});
	
	while (my $is =$sth16->fetchrow_hashref ) {
		push(@ids2,$isbn->{'campo'}.",".$isbn->{'subcampo'});
		push(@valores2,$is->{$isbn->{'campoTabla'}});
		}
	$sth16->finish();
	########################################################################



	($id2,$tipoDocN2)=&guardarNivel2($id1,\@ids2,\@valores2);

	###########################ESTANTES VIRTUALES##########################
	my $sth20=$dbh->prepare(" UPDATE shelfcontents SET id = ? where id = ?;");
	$sth20->execute("33333".$id2,$biblioitem->{'biblioitemnumber'}); 
	# Le agrego 33333 para no volver a procesar los estantes al final son removidos
	$sth20->finish();
	########################################################################

#---------------------------------------NIVEL3---------------------------------------#	

	my $sth4=$dbh->prepare("SELECT * FROM items where biblioitemnumber= ?;");
	$sth4->execute($biblioitem->{'biblioitemnumber'});
	while (my $item=$sth4->fetchrow_hashref ) {
	foreach (@N3) {
		push(@ids3,$_->{'campo'}.",".$_->{'subcampo'});
		my $val='';
		if ($_->{'campoTabla'} eq 'notforloan'){
			if ($item->{$_->{'campoTabla'}}  == 1){$val='SA';}
			elsif ($item->{$_->{'campoTabla'}}  == 0){$val='DO';}
			}
		else {$val=$item->{$_->{'campoTabla'}};}
		push(@valores3,$val);
	}
	
	$id3=&guardarNivel3($id1,$id2,$item->{'barcode'},1,$tipoDocN2,\@ids3,\@valores3);

	@ids3=();
	@valores3=();	
	}
	$sth4->finish();
#---------------------------------------NIVEL3---------------------------------------#	
	@ids2=();
	@valores2=();
	}
	$sth2->finish();
#---------------------------------------NIVEL2---------------------------------------#
	@ids1=();
	@valores1=();
 }
$sth->finish();



###########################ESTANTES VIRTUALES##########################
#Los que no comiencen con 33333 quedaron colgados se eliminan
my $sth21=$dbh->prepare("DELETE  FROM shelfcontents WHERE SUBSTRING(id,1,5) <> '33333' ;");
$sth21->execute();
$sth21->finish();

#Se deben quitar los 33333
my $sth22=$dbh->prepare(" UPDATE shelfcontents SET id = SUBSTRING(id,6) ;");
$sth22->execute(); 
$sth22->finish();
########################################################################