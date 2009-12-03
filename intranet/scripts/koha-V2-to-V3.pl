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

##Otras Tablas que se fusionan##
my $subject;
my $subtitle;
my $isbn;
my $publisher;
my $additionalauthor;
###############################

my $dbh = C4::Context->dbh;

print "INICIO \n";

print "Creando relacion Koha-Marc \n";
crearRelacionKohaMarc();

print "Creando tablas necesarias \n";
crearTablasNecesarias();

print "Creando nuevas referencias \n";
crearNuevasReferencias();

#################
print "Procesando los 3 niveles (va a tardar!!! ...MUCHO!!!) \n";
my $st1 = time();
procesarV2_V3();
my $end1 = time();
my $tardo1=($end1 - $st1);
print "AL FIN TERMINO!!! Tardo $tardo1 segundos !!!\n";
#################

#Referencias
print "Reparando referencias. OTRO QUE VA A TARDAR!!! \n";
my $st2 = time();
repararReferencias();
my $end2 = time();
my $tardo2=($end2 - $st2);
print "FFFAAAAAAAAA  NO TERMINABA MAS!! Fuiste a comer???  Tardo $tardo2 segundos !!!\n";
print "Quitando referencias  viejas \n";
quitarReferenciasViejas();
##

print "Quitando tablas de mas \n";
quitarTablasDeMas();
print "Pasamos TODO a INNODB \n";
pasarTodoAInnodb();
print "Creando nuevas claves foraneas \n";
crearClaves();
print "Creando la estructura MARC \n";
crearEstructuraMarc();

print "Agregando preferencias del sistema \n";
agregarPreferenciasDelSistema();
print "FIN!!! \n";
print "\n GRACIAS DICO!!! \n";

#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------FUNCIONES---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------
	sub procesarV2_V3 
	{
	

    my $id1_nuevo;
    my $id2_nuevo;

	my $cant_biblios=$dbh->prepare("SELECT count(*) as cantidad FROM biblio ;");
	$cant_biblios->execute();
	my $cantidad=$cant_biblios->fetchrow;
	my $registro=1;
	print "Se van a procesar $cantidad registros \n";


	
	my $biblios=$dbh->prepare("SELECT * FROM biblio ;");
	$biblios->execute();

	#Obtengo los campos del nivel 1
	my $campos_n1=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='biblio';");
	$campos_n1->execute();
	while (my $n1=$campos_n1->fetchrow_hashref) {
	push (@N1,$n1);
	}
	$campos_n1->finish();

	#Obtengo los campos del nivel 2
	my $campos_n2=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='biblioitems';");
	$campos_n2->execute();
	while (my $n2=$campos_n2->fetchrow_hashref) {
	push (@N2,$n2);	
	}
	$campos_n2->finish();

	#Obtengo los campos del nivel 3
	my $campos_n3=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='items';");
	$campos_n3->execute();
	while (my $n3=$campos_n3->fetchrow_hashref) {
	push (@N3,$n3);
	}
	$campos_n3->finish();

	####################################Otras Tablas#######################################
	my $kohaToMARC1=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='bibliosubject';");
	$kohaToMARC1->execute();
	$subject=$kohaToMARC1->fetchrow_hashref;
	$kohaToMARC1->finish();

	my $kohaToMARC2=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='bibliosubtitle';");
	$kohaToMARC2->execute();
	$subtitle=$kohaToMARC2->fetchrow_hashref;
	$kohaToMARC2->finish();

	my $kohaToMARC3=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='additionalauthors';");
	$kohaToMARC3->execute();
	$additionalauthor=$kohaToMARC3->fetchrow_hashref;
	$kohaToMARC3->finish();

	my $kohaToMARC4=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='publisher';");
	$kohaToMARC4->execute();
	$publisher=$kohaToMARC4->fetchrow_hashref;
	$kohaToMARC4->finish();

	my $kohaToMARC5=$dbh->prepare("SELECT * FROM cat_pref_mapeo_koha_marc where tabla='isbns';");
	$kohaToMARC5->execute();
	$isbn=$kohaToMARC5->fetchrow_hashref;
	$kohaToMARC5->finish();
	###############################################################################

	while (my $biblio=$biblios->fetchrow_hashref ) {
	
	my $porcentaje= int (($registro * 100) / $cantidad );
	print "Procesando registro: $registro de $cantidad ($porcentaje%) \n";



#---------------------------------------NIVEL1---------------------------------------#


	foreach (@N1) {
		my $dn1;
		$dn1->{'campo'}=$_->{'campo'};
		$dn1->{'subcampo'}=$_->{'subcampo'};
		$dn1->{'valor'}=$biblio->{$_->{'campoTabla'}};
		$dn1->{'simple'}=1;
		if (($dn1->{'valor'} ne '') && ($dn1->{'valor'} ne null)){push(@ids1,$dn1);}
	}

	###########################OTRAS TABLA biblio##########################
	# subject
	my $temas=$dbh->prepare("SELECT * FROM bibliosubject where biblionumber= ?;");
	$temas->execute($biblio->{'biblionumber'});
	my $dn1;
	my @ar1;
	$dn1->{'campo'}=$subject->{'campo'};
	$dn1->{'subcampo'}=$subject->{'subcampo'};

	while (my $biblosubject=$temas->fetchrow_hashref ) {
		push (@ar1,$biblosubject->{$subject->{'campoTabla'}});
		}
	$dn1->{'simple'}=0;
	$dn1->{'valor'}=\@ar1;
	push(@ids1,$dn1);
	$temas->finish();

	# subtitle
	my $subtitulos=$dbh->prepare("SELECT * FROM bibliosubtitle where biblionumber= ?;");
	$subtitulos->execute($biblio->{'biblionumber'});

	my $dn1;
	my @ar1;
	$dn1->{'campo'}=$subtitle->{'campo'};
	$dn1->{'subcampo'}=$subtitle->{'subcampo'};
	while (my $biblosubtitle=$subtitulos->fetchrow_hashref ) {
	push(@ar1,$biblosubtitle->{$subtitle->{'campoTabla'}});
	}
	$dn1->{'simple'}=0;
	$dn1->{'valor'}=\@ar1;
	push(@ids1,$dn1);
	$subtitulos->finish();

	# additionalauthor
	
	my $additionalauthors=$dbh->prepare("SELECT * FROM additionalauthors where biblionumber= ?;");
	$additionalauthors->execute($biblio->{'biblionumber'});
	my $dn1;
	my @ar1;
	$dn1->{'campo'}=$additionalauthor->{'campo'};
	$dn1->{'subcampo'}=$additionalauthor->{'subcampo'};
	while (my $aauthors=$additionalauthors->fetchrow_hashref ) {
	push(@ar1,$aauthors->{$additionalauthor->{'campoTabla'}});
	}
	$dn1->{'simple'}=0;
	$dn1->{'valor'}=\@ar1;
	push(@ids1,$dn1);
	$additionalauthors->finish();

	#########################################################################
	my($error,$codMsg);
	($id1,$error,$codMsg)=&guardaNivel1MARC(\@ids1);
	
	#Guardo la referencia
	my $ref1=$dbh->prepare("UPDATE nivel1 SET biblionumber= ? where id1 = ?  ;");
	$ref1->execute($biblio->{'biblionumber'},$id1);
	#
#---------------------------------------FIN NIVEL1---------------------------------------#	

#---------------------------------------NIVEL2---------------------------------------#
	my $biblioitems=$dbh->prepare("SELECT * FROM biblioitems where biblionumber= ?;");
	$biblioitems->execute($biblio->{'biblionumber'});
	while (my $biblioitem=$biblioitems->fetchrow_hashref ) {
	foreach (@N2) {
		my $dn2;
		$dn2->{'campo'}=$_->{'campo'};
		$dn2->{'subcampo'}=$_->{'subcampo'};
		$dn2->{'valor'}=$biblioitem->{$_->{'campoTabla'}};
		$dn2->{'simple'}=1;
		if (($dn2->{'valor'} ne '') && ($dn2->{'valor'} ne null)){push(@ids2,$dn2);}
	}
	
	###########################OTRAS TABLAS biblioitem##########################
	# publisher
	
	my $sth15=$dbh->prepare("SELECT * FROM publisher where biblioitemnumber= ?;");
	$sth15->execute($biblioitem->{'biblioitemnumber'});
		my $dn2;
		my @ar2;
		$dn2->{'campo'}=$publisher->{'campo'};
		$dn2->{'subcampo'}=$publisher->{'subcampo'};	
	while (my $pub=$sth15->fetchrow_hashref ) {
		push(@ar2,$pub->{$publisher->{'campoTabla'}});
		}
	$dn2->{'simple'}=0;
	$dn2->{'valor'}=\@ar2;
	push(@ids2,$dn2);
	$sth15->finish();
	
	# isbn

	my $sth16=$dbh->prepare("SELECT * FROM isbns where biblioitemnumber= ?;");
	$sth16->execute($biblioitem->{'biblioitemnumber'});
		my $dn2;
		my @ar2;
		$dn2->{'campo'}=$isbn->{'campo'};
		$dn2->{'subcampo'}=$isbn->{'subcampo'};

	while (my $is =$sth16->fetchrow_hashref ) {

		push(@ar2,$is->{$isbn->{'campoTabla'}});	
	}

	$dn2->{'simple'}=0;
	$dn2->{'valor'}=\@ar2;
	push(@ids2,$dn2);
	$sth16->finish();
	########################################################################

	($id2,$tipoDocN2,$error,$codMsg)=&guardaNivel2MARC($id1,\@ids2);
	
	#Guardo la referencia
	my $ref2=$dbh->prepare("UPDATE nivel2 SET biblionumber= ?, biblioitemnumber= ?  where id2 = ?  ;");
	$ref2->execute($biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},$id2);
	#

#---------------------------------------NIVEL3---------------------------------------#	

	my $items=$dbh->prepare("SELECT * FROM items where biblioitemnumber= ?;");
	$items->execute($biblioitem->{'biblioitemnumber'});
	while (my $item=$items->fetchrow_hashref ) {
	foreach (@N3) {
		my $dn3;
		$dn3->{'campo'}=$_->{'campo'};
		$dn3->{'subcampo'}=$_->{'subcampo'};

		my $val='';
		if ($_->{'campoTabla'} eq 'notforloan'){
			if ($item->{$_->{'campoTabla'}}  == 1){$val='SA';}
			elsif ($item->{$_->{'campoTabla'}}  == 0){$val='DO';}
			}
		else {$val=$item->{$_->{'campoTabla'}};}
		$dn3->{'valor'}=$val;
		$dn3->{'simple'}=1;
		if (($dn3->{'valor'} ne '') && ($dn3->{'valor'} ne null)){push(@ids3,$dn3);}
	}
	
	($error,$codMsg)=&guardaNivel3MARC($id1,$id2,$item->{'barcode'},1,$tipoDocN2,\@ids3);
	#Obtengo el ID3   gracias dico!!
	my $query3="select max(id3) from nivel3;";
	my $sth_query3=$dbh->prepare($query3);
           $sth_query3->execute();
	my $id3=$sth_query3->fetchrow;

	#Guardo la referencia
	my $ref3=$dbh->prepare("UPDATE nivel3 SET biblionumber = ?, biblioitemnumber = ?,itemnumber = ?  where id3 = ? ;");
	$ref3->execute($biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},$item->{'itemnumber'},$id3);
	#


	@ids3=();
	@valores3=();	
	}
	$items->finish();
#---------------------------------------FIN NIVEL3---------------------------------------#	
	@ids2=();
	@valores2=();
	}
	$biblioitems->finish();
#---------------------------------------FIN NIVEL2---------------------------------------#
	@ids1=();
	@valores1=();
	$registro++;
 }
$biblios->finish();
#---------------------------------------FIN NIVEL1---------------------------------------#

	}
	sub repararReferencias 
	{
	#########################################################################
	#			REPARAR REFERENCIAS!!!!!			#
	#########################################################################

	my $cant_nivel1=$dbh->prepare("SELECT count(*) as cantidad FROM nivel1 ;");
	$cant_nivel1->execute();
	my $cantidad=$cant_nivel1->fetchrow;
	my $registro=1;
	print "Se van a procesar $cantidad registros \n";


	#############1111111111111111111111111111111111111111111111##############
	my $niveles1=$dbh->prepare("SELECT * FROM nivel1 ;");
	$niveles1->execute();

	while (my $nivel1=$niveles1->fetchrow_hashref ) {
	my $porcentaje= int (($registro * 100) / $cantidad );
	print "Procesando registro: $registro de $cantidad ($porcentaje%) \n";

	#########################################################################
	#			REFERENCIAS A NIVEL 1 (biblio)			#
	#				colaboradores				#
	#########################################################################
	my $col2=$dbh->prepare("UPDATE colaboradores SET id1 = ? where biblionumber= ?;");
	$col2->execute($nivel1->{'id1'},$nivel1->{'biblionumber'});
	$col2->finish();

	my $mod1=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Libro' and numero = ?;");
	$mod1->execute($nivel1->{'id1'},$nivel1->{'biblionumber'});
	$mod1->finish();
	
	#########################################################################
	#		FIN REFERENCIAS A NIVEL 1 (biblio)			#
	#########################################################################

	#############2222222222222222222222222222222222222222222222##############
	my $niveles2=$dbh->prepare("SELECT * FROM nivel2 where id1 = ? ;");
	$niveles2->execute($nivel1->{'id1'});

	while (my $nivel2=$niveles2->fetchrow_hashref ) {

	#########################################################################
	#		REFERENCIAS A NIVEL 2 (biblioitemnumber)		#
	#			biblioanalysis					#
	#			reserves					#
	#			shelfcontents					#
	#########################################################################
	my $banalysis2=$dbh->prepare("UPDATE biblioanalysis SET id1 = ? , id2 = ? where biblionumber= ? and biblioitemnumber= ?;");
	$banalysis2->execute($nivel1->{'id1'},$nivel2->{'id2'},$nivel1->{'biblionumber'},$nivel2->{'biblioitemnumber'});
	$banalysis2->finish();

	my $reserves2=$dbh->prepare("UPDATE reserves SET id2 = ? where biblioitemnumber= ? and itemnumber is NULL;");
	$reserves2->execute($nivel2->{'id2'},$nivel2->{'biblioitemnumber'});
	$reserves2->finish();

	my $estantes2=$dbh->prepare(" UPDATE shelfcontents SET id2 = ? where biblioitemnumber= ?;");
	$estantes2->execute($nivel2->{'id2'},$nivel2->{'biblioitemnumber'}); 
	$estantes2->finish();

	my $mod2=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Grupo' and numero = ?;");
	$mod2->execute($nivel2->{'id2'},$nivel2->{'biblioitemnumber'});
	$mod2->finish();

	#########################################################################
	#		FIN REFERENCIAS A NIVEL 2 (biblioitemnumber)		#
	#########################################################################

	#############3333333333333333333333333333333333333333333333##############
	my $niveles3=$dbh->prepare("SELECT * FROM nivel3 where id1 = ? and id2 = ? ;");
	$niveles3->execute($nivel1->{'id1'},$nivel2->{'id2'});

	while (my $nivel3=$niveles3->fetchrow_hashref ) {


	#########################################################################
	#		REFERENCIAS A NIVEL 3 (itemnumber)			#
	#			availability					#
	#			historicIssues					#
	#			historicCirculation				#
	#			issues						#
	#			reserves						#
	#########################################################################
	my $av2=$dbh->prepare(" UPDATE availability SET id3 = ? where item = ?;");
	$av2->execute($nivel3->{'id3'},$nivel3->{'itemnumber'}); 
	$av2->finish();

	my $hi2=$dbh->prepare(" UPDATE historicIssues SET id3 = ? where itemnumber = ?;");
	$hi2->execute($nivel3->{'id3'},$nivel3->{'itemnumber'}); 
	$hi2->finish();

	my $hc2=$dbh->prepare(" UPDATE historicCirculation SET id1 = ? , id2 = ? , id3 = ? where biblionumber= ? and biblioitemnumber= ? and itemnumber = ?;");
	$hc2->execute($nivel3->{'id1'},$nivel3->{'id2'},$nivel3->{'id3'},$nivel3->{'biblionumber'},$nivel3->{'biblioitemnumber'},$nivel3->{'itemnumber'}); 
	$hc2->finish();

	my $is2=$dbh->prepare(" UPDATE issues SET id3 = ? where itemnumber = ?;");
	$is2->execute($nivel3->{'id3'},$nivel3->{'itemnumber'}); 
	$is2->finish();

	my $reserves3=$dbh->prepare("UPDATE reserves SET id2 = ? , id3 = ?  where biblioitemnumber = ? and itemnumber = ?;");
	$reserves3->execute($nivel3->{'id2'},$nivel3->{'id3'},$nivel3->{'biblioitemnumber'},$nivel3->{'itemnumber'});
	$reserves3->finish();

	my $mod3=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Ejemplar' and numero = ?;");
	$mod3->execute($nivel3->{'id3'},$nivel3->{'itemnumber'});
	$mod3->finish();

	#########################################################################
	#		FIN REFERENCIAS A NIVEL 3 (itemnumber)			#
	#########################################################################
	
	}#Fin niveles3
	}#Fin niveles2

	$registro++;
	}#Fin niveles1
	
}
	sub crearNuevasReferencias
	{
	#########################################################################
	#			NUEVAS REFERENCIAS!!!!!				#
	#########################################################################
	# En los Niveles
	my $rn1=$dbh->prepare("ALTER TABLE nivel1 ADD biblionumber INT( 11 ) NOT NULL FIRST ;");
	$rn1->execute();

	my $rn2=$dbh->prepare("ALTER TABLE nivel2 ADD biblionumber INT( 11 ) NOT NULL FIRST,
				ADD biblioitemnumber INT( 11 ) NOT NULL AFTER biblionumber;");
	$rn2->execute();

	my $rn3=$dbh->prepare("ALTER TABLE nivel3 ADD biblionumber INT( 11 ) NOT NULL FIRST ,
		ADD biblioitemnumber INT( 11 ) NOT NULL AFTER biblionumber ,
		ADD itemnumber INT( 11 ) NOT NULL AFTER biblioitemnumber ;");
	$rn3->execute();
	#
	
	#Nivel 1#
	my $col=$dbh->prepare("ALTER TABLE `colaboradores` ADD `id1` INT( 11 ) NOT NULL FIRST ;");
   	$col->execute();
	#Nivel 2#
	my $banalysis=$dbh->prepare("ALTER TABLE `biblioanalysis` ADD `id1` INT( 11 ) NOT NULL FIRST , 
					ADD `id2` INT( 11 ) NOT NULL AFTER `id1` ;");
	$banalysis->execute();
	my $reserves=$dbh->prepare("ALTER TABLE `reserves` ADD `id2` INT( 11 ) NOT NULL FIRST , 
					ADD `id3` INT( 11 ) NULL AFTER `id2` ;");
	$reserves->execute();
	my $estantes=$dbh->prepare("ALTER TABLE `shelfcontents` ADD `id2` INT( 11 ) NOT NULL FIRST ;");
	$estantes->execute();
	#Nivel 3#
	my $av1=$dbh->prepare("ALTER TABLE `availability` ADD `id3` INT( 11 ) NOT NULL FIRST ;");
	$av1->execute();

	my $hi1=$dbh->prepare("ALTER TABLE `historicIssues` ADD `id3` INT( 11 ) NOT NULL FIRST ;");
	$hi1->execute();

	my $hc1=$dbh->prepare("ALTER TABLE `historicCirculation` ADD `id1` INT( 11 ) NOT NULL AFTER `id` ,
		ADD `id2` INT( 11 ) NOT NULL AFTER `id1` ,
		ADD `id3` INT( 11 ) NOT NULL AFTER `id2` ;");
	$hc1->execute();

	my $is1=$dbh->prepare("ALTER TABLE `issues` ADD `id3` INT( 11 ) NOT NULL FIRST ;");
	$is1->execute();
	#Los 3 Niveles#
	my $mod=$dbh->prepare("ALTER TABLE `modificaciones` ADD `id` INT( 11 ) NOT NULL AFTER `numero` ;");
	$mod->execute();
	#########################################################################
	#			FIN NUEVAS REFERENCIAS!!!!!			#
	#########################################################################
	}
	sub quitarReferenciasViejas
	{

	#########################################################################
	#			QUITAR REFERENCIAS VIEJAS!!!!!			#
	#########################################################################
	#En los niveles
	my $rmn1=$dbh->prepare("ALTER TABLE nivel1 DROP biblionumber ;");
	$rmn1->execute();
	my $rmn2=$dbh->prepare("ALTER TABLE nivel2 DROP biblionumber, DROP biblioitemnumber;");
	$rmn2->execute();
	my $rmn3=$dbh->prepare("ALTER TABLE nivel3 DROP biblionumber, DROP biblioitemnumber, DROP itemnumber;");
	$rmn3->execute();

	#Nivel 1
	my $col3=$dbh->prepare("ALTER TABLE `colaboradores` DROP `biblionumber`;");
   	$col3->execute();
	#Nivel 2
	my $banalysis3=$dbh->prepare("ALTER TABLE biblioanalysis DROP `biblionumber`, DROP `biblioitemnumber`;");
	$banalysis3->execute();

	my $estantes3=$dbh->prepare("ALTER TABLE `shelfcontents` DROP `biblioitemnumber`;");
   	$estantes3->execute();
	#Nivel 3
	my $av3=$dbh->prepare("ALTER TABLE availability DROP item;");
   	$av3->execute();

	my $hi3=$dbh->prepare("ALTER TABLE historicIssues DROP itemnumber;");
   	$hi3->execute();

	my $hc3=$dbh->prepare("ALTER TABLE `historicCirculation` DROP `biblionumber`,   DROP `biblioitemnumber`,   DROP `itemnumber`;");
   	$hc3->execute();

	my $is3=$dbh->prepare("ALTER TABLE issues DROP itemnumber;");
   	$is3->execute();
	
	my $reserves4=$dbh->prepare("ALTER TABLE `reserves`   DROP `biblioitemnumber`,   DROP `itemnumber`;");

	#TODOS
	my $mod4=$dbh->prepare("ALTER TABLE modificaciones DROP numero;");
   	$mod4->execute();


	my $res1=$dbh->prepare("ALTER TABLE `reserves` CHANGE `constrainttype` `estado` CHAR( 1 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL;");
	$res1->execute();
	my $res2=$dbh->prepare("ALTER TABLE `reserves` DROP `priority` , DROP `found` , DROP `itemnumber` ;");
	$res2->execute();

	#########################################################################
	#			FIN QUITAR REFERENCIAS VIEJAS!!!!!		#
	#########################################################################

	}
	sub crearRelacionKohaMarc 
	{
	#########################################################################
	#			RELACION KOHA-MARC				#
	#########################################################################

my $kohamarc=$dbh->prepare("DROP TABLE IF EXISTS cat_pref_mapeo_koha_marc;");
$kohamarc->execute();

my $kohamarc1=$dbh->prepare("CREATE TABLE cat_pref_mapeo_koha_marc (
  `idmap` int(11) NOT NULL auto_increment,
  `tabla` varchar(100) NOT NULL,
  `campoTabla` varchar(100) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `campo` varchar(3) NOT NULL,
  `subcampo` varchar(1) NOT NULL,
  PRIMARY KEY  (`idmap`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;");
$kohamarc1->execute();

my $kohamarc2=$dbh->prepare("INSERT INTO cat_pref_mapeo_koha_marc ( `tabla`, `campoTabla`, `nombre`, `campo`, `subcampo`) VALUES 
( 'additionalauthors', 'author', 'Nombre Personal', '700', 'a'),
( 'biblio', 'abstract', 'Nota de resumen, etc.', '520', 'a'),
( 'biblio', 'author', 'Nombre Personal', '100', 'a'),
( 'biblio', 'notes', 'Entrada principal del original', '534', 'a'),
( 'biblio', 'seriestitle', 'Numero de Clasificacion Decimal Universal', '080', 'a'),
( 'biblio', 'title', 'Titulo', '245', 'a'),
( 'biblio', 'unititle', 'Resto del titulo', '245', 'b'),
( 'biblioitems', 'dewey', 'Call number prefix (NR)', '852', 'k'),
( 'biblioitems', 'idCountry', 'Codigo ISO (R)', '043', 'c'),
( 'biblioitems', 'illus', 'Otros detalles fisicos', '300', 'b'),
( 'biblioitems', 'issn', 'ISSN', '022', 'a'),
( 'biblioitems', 'itemtype', 'Tipo de documento', '910', 'a'),
( 'biblioitems', 'lccn', 'LC control number', '010', 'a'),
( 'biblioitems', 'notes', 'Nota General', '500', 'a'),
( 'biblioitems', 'number', 'Menciin de edicion', '250', 'a'),
( 'biblioitems', 'pages', 'Extension', '300', 'a'),
( 'biblioitems', 'place', 'Lugar de publicacion, distribucion, etc.', '260', 'a'),
( 'biblioitems', 'publicationyear', 'Fecha de publicacion, distribucion, etc.', '260', 'c'),
( 'biblioitems', 'seriestitle', 'Titulo', '440', 'a'),
( 'biblioitems', 'size', 'Dimensiones', '300', 'c'),
( 'biblioitems', 'subclass', 'Call number suffix (NR)', '852', 'm'),
( 'biblioitems', 'url', 'Identificador Uniforme de Recurso (URI)', '856', 'u'),
( 'biblioitems', 'volume', 'Number of part/section of a work', '740', 'n'),
( 'biblioitems', 'volumeddesc', 'Titulo', '740', 'a'),
( 'bibliosubject', 'subject', 'Topico o nombre geografico', '650', 'a'),
( 'bibliosubtitle', 'subtitle', 'Titulo propiamente dicho/Titulo corto', '246', 'a'),
( 'isbns', 'isbn', 'ISBN', '020', 'a'),
( 'items', 'barcode', 'C&oacute;digo de Barras', '995', 'f'),
( 'items', 'booksellerid', 'Nombre del vendedor', '995', 'a'),
( 'items', 'bulk', 'Signatura Topogr&aacute;fica', '995', 't'),
( 'items', 'dateaccessioned', 'Fecha de acceso', '995', 'm'),
( 'items', 'holdingbranch', 'Unidad de Informaci&oacute;n', '995', 'c'),
( 'items', 'homebranch', 'Unidad de Informaci&oacute;n de Origen', '995', 'd'),
( 'items', 'itemnotes', 'Notas del item', '995', 'u'),
( 'items', 'notforloan', 'Disponibilidad', '995', 'o'),
( 'items', 'price', 'Precio de compra', '995', 'p'),
( 'items', 'replacementprice', 'Precio de reemplazo', '995', 'r'),
( 'items', 'wthdrawn', 'Estado', '995', 'e'),
( 'publisher', 'publisher', 'Nombre de la editorial, distribuidor, etc.', '260', 'b'),
( 'biblioitems', 'classification', '', '900', 'b'),
( 'biblioitems', 'idLanguage', '', '041', 'h'),
( 'biblioitems', 'idSupport', '', '245', 'h');");
$kohamarc2->execute();
#################################################################################
	}
	sub crearTablasNecesarias 
	{
	#########################################################################
	#			CREAR TABLAS NECESARIAS!!!			#
	#########################################################################

my $dropear=$dbh->prepare("DROP TABLE IF EXISTS `nivel1`, `nivel1_repetibles`, `nivel2`, `nivel2_repetibles`, `nivel3`, `nivel3_repetibles`, `amazon_covers`;");
$dropear->execute();



######Primero agrego las tablas nuevas######
my $tabla1=$dbh->prepare("
CREATE TABLE IF NOT EXISTS `cat_registro_marc_n1` (
  `id` int(11) NOT NULL auto_increment,
  `marc_record` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1; ");
$tabla1->execute();

my $tabla2=$dbh->prepare(
"CREATE TABLE IF NOT EXISTS `cat_registro_marc_n2` (
  `id` int(11) NOT NULL auto_increment,
  `marc_record` text NOT NULL,
  `id1` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;");
$tabla3->execute();

my $tabla3=$dbh->prepare("
CREATE TABLE IF NOT EXISTS `cat_registro_marc_n3` (
  `id` int(11) NOT NULL auto_increment,
  `marc_record` text NOT NULL,
  `id1` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `cat_registro_marc_n3_n1` (`id1`),
  KEY `cat_registro_marc_n3_n2` (`id2`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;");
$tabla3->execute();


my $tabla4=$dbh->prepare("
CREATE TABLE `amazon_covers` (
  `isbn` varchar(50) NOT NULL,
  `small` varchar(500) default NULL,
  `medium` varchar(500) default NULL,
  `large` varchar(50) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

");
$tabla4->execute();

	#########################################################################
	#			CONTROL DE AUTORIDADES				#
	#########################################################################

my $dropear=$dbh->prepare("DROP TABLE IF EXISTS `control_autores_seudonimos`,`control_autores_sinonimos`,`control_editoriales_seudonimos`,`control_temas_seudonimos`,`control_temas_sinonimos`,`busquedas`,`historialBusqueda` ;");
$dropear->execute();


my $control_autoridades1=$dbh->prepare("
CREATE TABLE `control_autores_seudonimos` (
  `id` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`,`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
$control_autoridades1->execute();

my $control_autoridades2=$dbh->prepare("
CREATE TABLE `control_autores_sinonimos` (
  `id` int(11) NOT NULL,
  `autor` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`autor`),
  KEY `autor` (`autor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
$control_autoridades2->execute();

my $control_autoridades3=$dbh->prepare("
CREATE TABLE `control_editoriales_seudonimos` (
  `id` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`,`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
$control_autoridades3->execute();

my $control_autoridades4=$dbh->prepare("
CREATE TABLE `control_temas_seudonimos` (
  `id` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`,`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
$control_autoridades4->execute();

my $control_autoridades5=$dbh->prepare("
CREATE TABLE `control_temas_sinonimos` (
  `id` int(11) NOT NULL auto_increment,
  `tema` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`tema`),
  KEY `tema` (`tema`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
");
$control_autoridades5->execute();

######### Otros ###################


# my $b1= $dbh->prepare( "CREATE TABLE `busquedas` (
#   `idBusqueda` int(11) NOT NULL auto_increment,
#   `borrower` int(11) default NULL,
#   `fecha` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
#   PRIMARY KEY  (`idBusqueda`)
# ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;");
# $b1->execute();
# my $b2= $dbh->prepare( "CREATE TABLE `historialBusqueda` (
#   `idHistorial` int(11) NOT NULL auto_increment,
#   `idBusqueda` int(11) NOT NULL,
#   `campo` varchar(100) NOT NULL,
#   `valor` varchar(100) NOT NULL,
#   `tipo` varchar(10) default NULL,
#   PRIMARY KEY  (`idHistorial`),
#   KEY `FK_idBusqueda` (`idBusqueda`)
# ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;");
# $b2->execute();
	}
	sub quitarTablasDeMas 
	{
	#########################################################################
	#			QUITAR TABLAS DE MAS!!!				#
	#########################################################################
	my @drops = ('accountlines','accountoffsets','additionalauthors', 'aqbookfund', 'aqbooksellers', 'aqbudget', 'aqorderbreakdown', 'aqorderdelivery', 'aqorders', 'biblio', 'biblioitems', 'bibliosubject', 'bibliosubtitle', 'bibliothesaurus', 'borexp', 'branchtransfers', 'catalogueentry', 'categoryitem', 'currency', 'defaultbiblioitem', 'deletedbiblio', 'deletedbiblioitems', 'deleteditems', 'ethnicity', 'isbns', 'isomarc', 'items', 'itemsprices', 'printers', 'publisher', 'reserveconstraints', 'statistics', 'virtual_itemtypes','virtual_request','websites', 'marc_subfield_table', 'marc_word', 'marc_biblio','marc_blob_subfield', 'marcrecorddone','marc_breeding','relationISO');

	foreach $tabla (@drops){
	my $drop=$dbh->prepare("DROP TABLE $tabla ;");
	$drop->execute();}
	
	}
	sub pasarTodoAInnodb 
	{
	#########################################################################
	#			PASAR TODO A INNODB				#
	#########################################################################
	#hay que quitar algunos fulltext que no soporta Innodb
	#my $fulltext=$dbh->prepare("ALTER TABLE `biblioanalysis` DROP INDEX `resumen`");
	#$fulltext->execute();

	my @innodbs = ('analyticalauthors','analyticalsubject','authorised_values','autores','availability','biblioanalysis','bibliolevel','bookshelf','borrowers','branchcategories','branches','branchrelations','busquedas','categories','colaboradores','countries','deletedborrowers','dptos_partidos','feriados','generic_report_joins','generic_report_tables','historialBusqueda','historicCirculation','historicIssues','historicSanctions','iso2709','issues','issuetypes','itemtypes','languages','localidades','marc_subfield_structure','marc_tag_structure','modificaciones','persons','provincias','referenciaColaboradores','reserves','sanctionissuetypes','sanctionrules','sanctions','sanctiontypes','sanctiontypesrules','sessionqueries','sessions','shelfcontents','stopwords','supports','systempreferences','tablasDeReferencias','tablasDeReferenciasInfo','temas','unavailable','uploadedmarc','userflags','users','z3950queue','z3950results','z3950servers');
	
	foreach $tabla (@innodbs)
	{
	my $innodb=$dbh->prepare("ALTER TABLE $tabla ENGINE = innodb;");
	$innodb->execute();
	}
	}
	sub crearClaves 
	{
	#########################################################################
	#			CREAR CLAVES FORANEAS				#
	#########################################################################

	my @claves = (
'ALTER TABLE `nivel1_repetibles` ADD CONSTRAINT `FK_nivel1_repetibles` FOREIGN KEY (`id1`) REFERENCES `nivel1` (`id1`);',
'ALTER TABLE `nivel2_repetibles` ADD CONSTRAINT `FK_nivel2_repetibles` FOREIGN KEY (`id2`) REFERENCES `nivel2` (`id2`);',
'ALTER TABLE `nivel3_repetibles` ADD CONSTRAINT `FK_nivel3_repetibles` FOREIGN KEY (`id3`) REFERENCES `nivel3` (`id3`);',
'ALTER TABLE `nivel1` ADD CONSTRAINT `FK_nivel1_autores` FOREIGN KEY (`autor`) REFERENCES `autores` (`id`);',
'ALTER TABLE `reserves` ADD CONSTRAINT `FK_reserves_id2` FOREIGN KEY (`id2`) REFERENCES `nivel2` (`id2`);',
'ALTER TABLE `reserves` ADD CONSTRAINT `FK_reserves_id3` FOREIGN KEY (`id3`) REFERENCES `nivel3` (`id3`);',
'ALTER TABLE `issues` ADD CONSTRAINT `FK_issues_id3` FOREIGN KEY (`id3`) REFERENCES `nivel3` (`id3`);',
'ALTER TABLE `historicCirculation` ADD CONSTRAINT `FK_historicCirculation_id1` FOREIGN KEY (`id1`) REFERENCES `nivel1` (`id1`);',
'ALTER TABLE `historicCirculation` ADD CONSTRAINT `FK_historicCirculation_id2` FOREIGN KEY (`id2`) REFERENCES `nivel2` (`id2`);',
'ALTER TABLE `historicCirculation` ADD CONSTRAINT `FK_historicCirculation_id3` FOREIGN KEY (`id3`) REFERENCES `nivel3` (`id3`);'
	);
	
	foreach $clave (@claves){my $cv=$dbh->prepare($clave);	$cv->execute();}

	}

	sub agregarPreferenciasDelSistema 
	{
	#########################################################################
	#			PREFERENCIAS DEL SISTEMA			#
	#########################################################################
	my $pref1=$dbh->prepare("INSERT INTO systempreferences (variable,value,explanation,type,options) VALUES ('paginas','10','Cantidad de paginas que va a  mostrar el paginador.','text','');");
	   $pref1->execute();

	my $pref2=$dbh->prepare("INSERT INTO `unavailable` ( `code` , `description` ) VALUES ( '0', 'Disponible');");
	   $pref2->execute();


	}

	sub crearEstructuraMarc 
	{
	#########################################################################
	#			ESTRUCTURA MARC					#
	#########################################################################

my $marc=$dbh->prepare("DROP TABLE IF EXISTS `estructura_catalogacion`, `informacion_referencias`, `marc_subfield_structure`,`encabezado_campo_opac`,`encabezado_item_opac`,`estructura_catalogacion_opac`;");
   $marc->execute();


my $marc10=$dbh->prepare("
CREATE TABLE `encabezado_campo_opac` (
  `idencabezado` int(11) NOT NULL auto_increment,
  `nombre` varchar(255) NOT NULL,
  `orden` int(11) NOT NULL,
  `linea` tinyint(1) NOT NULL default '0',
  `nivel` tinyint(1) NOT NULL,
  PRIMARY KEY  (`idencabezado`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;");
$marc10->execute();

my $marc11 = $dbh->prepare("INSERT INTO `encabezado_campo_opac` (`idencabezado`, `nombre`, `orden`, `linea`, `nivel`) VALUES
(1, 'Encabezado 1', -1, 0, 2),
(2, 'Encabezado 3', 0, 0, 3),
(3, 'Encabezado 2', 0, 0, 2),
(4, 'Encabezado Nivel 1', 0, 0, 1);");
$marc11->execute();


my $marc12=$dbh->prepare("CREATE TABLE `encabezado_item_opac` (
  `idencabezado` int(11) NOT NULL default '0',
  `itemtype` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`idencabezado`,`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
$marc12->execute();

my $marc13 = $dbh->prepare("
INSERT INTO `encabezado_item_opac` (`idencabezado`, `itemtype`) VALUES
(1, 'ACT'),
(1, 'LIB'),
(2, 'ACT'),
(2, 'LIB'),
(3, 'LIB'),
(4, 'LIB');");
$marc13->execute();


my $marc14=$dbh->prepare("CREATE TABLE `estructura_catalogacion_opac` (
  `idestcatopac` int(11) NOT NULL auto_increment,
  `campo` char(3) NOT NULL,
  `subcampo` char(1) NOT NULL,
  `textpred` varchar(255) default NULL,
  `textsucc` varchar(255) default NULL,
  `separador` varchar(3) default NULL,
  `idencabezado` int(11) NOT NULL,
  `visible` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`idestcatopac`),
  KEY `campo` (`campo`,`subcampo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1  ;
");
$marc14->execute();

my $marc15 = $dbh->prepare("INSERT INTO `estructura_catalogacion_opac` (`idestcatopac`, `campo`, `subcampo`, `textpred`, `textsucc`, `separador`, `idencabezado`, `visible`) VALUES
(1, '245', 'a', 'Titulo', '*', ' ', 1, 1),
(2, '245', 'h', 'Medio nuevo', '---', '/', 1, 1),
(3, '995', 'c', 'Unid. Info.', '', '', 2, 1),
(4, '995', 'd', 'Unid. Info. Orig.', '', '', 2, 1),
(5, '995', 'e', 'Estado', '', '', 2, 1),
(6, '995', 'o', 'Disponibilidad', '', '', 2, 1),
(7, '995', 't', 'Sig. Top.', '', '', 2, 1),
(8, '020', 'a', 'ISBN:', '', '', 1, 1),
(9, '022', 'a', 'ISSN', '', '', 3, 1),
(10, '041', 'h', 'Cod. Idioma de la Version Orig.', '', '', 3, 1),
(11, '043', 'a', 'Codigo de Area Geografica', '', '', 3, 1),
(15, '020', 'a', 'asd', '', '', 3, 1); ");
$marc15->execute();

my $marc1=$dbh->prepare("CREATE TABLE `estructura_catalogacion` (
  `id` int(11) NOT NULL auto_increment,
  `campo` char(3) NOT NULL,
  `subcampo` char(1) NOT NULL,
  `itemtype` varchar(4) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL,
  `tipo` char(5) NOT NULL,
  `referencia` tinyint(1) NOT NULL default '0',
  `nivel` tinyint(1) NOT NULL,
  `obligatorio` tinyint(1) NOT NULL default '0',
  `intranet_habilitado` int(11) default '0',
  `visible` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  KEY `campo` (`campo`),
  KEY `subcampo` (`subcampo`),
  KEY `itemtype` (`itemtype`),
  KEY `indiceTodos` (`campo`,`subcampo`,`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ");
$marc1->execute();

my $marc2 = $dbh->prepare("INSERT INTO `estructura_catalogacion` (`id`, `campo`, `subcampo`, `itemtype`, `liblibrarian`, `tipo`, `referencia`, `nivel`, `obligatorio`, `intranet_habilitado`, `visible`) VALUES 
(1, '700', 'a', 'ALL', 'Autores Adicionales', 'texa2', 1, 1, 0, 1, 1),
(2, '245', 'b', 'ALL', 'T�tulo informativo', 'text', 0, 1, 0, 2, 1),
(3, '246', 'a', 'ALL', 'Otros titulos', 'texa2', 0, 1, 0, 3, 1),
(4, '650', 'a', 'ALL', 'Temas', 'texa2', 1, 1, 0, 4, 1),
(5, '080', 'a', 'ALL', 'CDU', 'texa2', 0, 1, 0, 5, 1),
(6, '534', 'a', 'ALL', 'Notas', 'texta', 0, 1, 0, 6, 1),
(7, '520', 'a', 'ALL', 'Resumen', 'texta', 0, 1, 0, 7, 1),
(8, '900', 'b', 'ALL', 'Nivel Bibliogr�fico', 'combo', 1, 2, 0, 1, 1),
(9, '245', 'h', 'ALL', 'Soporte', 'combo', 1, 2, 0, 2, 1),
(10, '250', 'a', 'ALL', 'N�mero de Edici�n', 'text', 0, 2, 0, 3, 1),
(11, '260', 'a', 'ALL', 'Lugar de publicaci�n', 'text', 0, 2, 0, 4, 1),
(12, '260', 'b', 'ALL', 'Editor', 'texa2', 0, 2, 0, 5, 1),
(13, '260', 'c', 'ALL', 'A�o de Edici�n', 'text', 0, 2, 0, 6, 1),
(14, '300', 'a', 'ALL', 'Descripci�n F�sica', 'text', 0, 2, 0, 7, 1),
(15, '300', 'c', 'ALL', 'Tama�o', 'text', 0, 2, 0, 8, 1),
(16, '440', 'a', 'ALL', 'Serie', 'text', 0, 2, 0, 9, 1),
(17, '020', 'a', 'ALL', 'ISBN', 'texa2', 0, 2, 0, 10, 1),
(18, '022', 'a', 'ALL', 'ISSN', 'texa2', 0, 2, 0, 11, 1),
(19, '740', 'n', 'ALL', 'Volumen', 'text', 0, 2, 0, 13, 1),
(20, '740', 'a', 'ALL', 'Descripci�n del volumen', 'text', 0, 2, 0, 14, 1),
(21, '043', 'c', 'ALL', 'Pa�s', 'combo', 1, 2, 0, 15, 1),
(22, '041', 'h', 'ALL', 'Idioma', 'combo', 1, 2, 0, 16, 1),
(23, '500', 'a', 'ALL', 'Notas', 'texta', 0, 2, 0, 18, 1),
(24, '995', 'c', 'ALL', 'Unidad de Informaci�n', 'combo', 1, 3, 1, 1, 1),
(25, '995', 'd', 'ALL', 'Unidad de Informaci�n de Origen', 'combo', 1, 3, 1, 2, 1),
(26, '995', 't', 'ALL', 'Signatura Topogr�fica', 'text', 0, 3, 0, 3, 1),
(27, '995', 'u', 'ALL', 'Notas', 'texta', 0, 3, 0, 4, 1),
(28, '995', 'o', 'ALL', 'Disponibilidad', 'combo', 1, 3, 1, 5, 1),
(29, '995', 'e', 'ALL', 'Estado', 'combo', 1, 3, 1, 6, 1),
(30, '010', 'a', 'ALL', 'LCCN', 'text', 0, 2, 0, 12, 1),
(31, '856', 'u', 'ALL', 'URL de Sitio Web (Sin http://)', 'texa2', 0, 2, 0, 17, 1),
(32, '555', 'a', 'ALL', 'Indice', 'texta', 0, 2, 0, 19, 1);");
$marc2->execute();

my $marc3=$dbh->prepare("CREATE TABLE `informacion_referencias` (
  `idinforef` int(11) NOT NULL auto_increment,
  `idestcat` int(11) NOT NULL,
  `referencia` varchar(255) NOT NULL,
  `orden` varchar(255) NOT NULL,
  `campos` varchar(255) NOT NULL,
  `separador` varchar(3) default NULL,
  PRIMARY KEY  (`idinforef`),
  KEY `idestcat` (`idestcat`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;");
$marc3->execute();

my $marc4 = $dbh->prepare("INSERT INTO `informacion_referencias` (`idinforef`, `idestcat`, `referencia`, `orden`, `campos`, `separador`) VALUES 
(1, 1, 'autores', 'apellido', 'completo', '-'),
(2, 4, 'temas', 'nombre', 'nombre', ','),
(3, 8, 'bibliolevel', 'description', 'description', ','),
(4, 9, 'supports', 'description', 'description', ','),
(5, 21, 'countries', 'printable_name', 'printable_name', '/'),
(6, 22, 'languages', 'description', 'description', '/'),
(7, 24, 'branches', 'branchname', 'branchname', '-'),
(8, 25, 'branches', 'branchname', 'branchname', '-'),
(9, 28, 'issuetypes', 'description', 'description', ','),
(10, 29, 'unavailable', 'code', 'description', ',');");
$marc4->execute();


my $marc5=$dbh->prepare(" CREATE TABLE `marc_subfield_structure` (
  `nivel` tinyint(1) NOT NULL default '0',
  `obligatorio` tinyint(1) NOT NULL default '0',
  `campo` char(3) NOT NULL default '',
  `subcampo` char(1) NOT NULL default '',
  `liblibrarian` char(255) NOT NULL default '',
  `libopac` char(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `kohafield` char(40) default NULL,
  `tab` tinyint(1) default NULL,
  `authorised_value` char(13) default NULL,
  `thesaurus_category` char(10) default NULL,
  `value_builder` char(80) default NULL,
  PRIMARY KEY  (`campo`,`subcampo`),
  KEY `kohafield` (`kohafield`),
  KEY `tab` (`tab`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; ");
$marc5->execute();

my $marc6 = $dbh->prepare("
INSERT INTO `marc_subfield_structure` (`nivel`, `obligatorio`, `campo`, `subcampo`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `thesaurus_category`, `value_builder`) VALUES 
(0, 0, '010', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 1, NULL, -1, '', '', '')


;");
$marc6->execute();
#################################################################################



my $tipoDocumentos1=$dbh->prepare("
CREATE TABLE `tipo_documento` (
`idTipoDoc` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`nombre` VARCHAR( 50 ) NOT NULL ,
`descripcion` VARCHAR( 250 ) NOT NULL
) ENGINE = innodb CHARACTER SET latin1 COLLATE latin1_spanish_ci;
");
$tipoDocumentos1->execute();


my $tipoDocumentos2 = $dbh->prepare("
INSERT INTO `tipo_documento` ( `nombre` , `descripcion` )
VALUES 
('DNI', 'DNI'),
('LC', 'LC'),
('LE', 'LE'),
('CI', 'CI'),
('PAS', 'PAS')
;
 ");
$tipoDocumentos2->execute();



}




########## MAS METODOS DE MIERDA ############

=item
guardaNivel1MARC
Guarda los campos del nivel 1 en un MARC RECORD.
=cut

sub guardaNivel1MARC {
    my ($nivel1)=@_;

    my $marc = MARC::Record->new();

    foreach my $obj(@$nivel1){
        my $campo=$obj->{'campo'};
        my $subcampo=$obj->{'subcampo'};
        my $valor=$obj->{'valor'};

        if ($valor ne ''){
                my $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                $marc->add_fields($field);
        }
    }

    my $reg_marc_1 =$dbh->prepare("INSERT INTO cat_registro_marc_n1 (marc_record) VALUES (?) ");
       $reg_marc_1->execute($marc);


        my $query_MAX = "SELECT MAX(id) FROM cat_registro_marc_n1";
        my $sth_MAX = $dbh->prepare($query_MAX);
        $sth_MAX->execute();
        my $id1_nuevo = $sth_MAX->fetchrow;

    return($id1_nuevo);
}

=item
guardaNivel2MARC
Guarda los campos del nivel 2 en un MARC RECORD.
=cut

sub guardaNivel2MARC {
    my ($id1, $nivel2)=@_;

    my $marc = MARC::Record->new();

    foreach my $obj(@$nivel2){
        my $campo=$obj->{'campo'};
        my $subcampo=$obj->{'subcampo'};
        my $valor=$obj->{'valor'};

        if ($valor ne ''){
                my $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                $marc->add_fields($field);
        }
    }

    my $reg_marc_2 =$dbh->prepare("INSERT INTO cat_registro_marc_n2 (marc_record,id1) VALUES (?,?) ");
       $reg_marc_2->execute($marc,$id1);


        my $query_MAX = "SELECT MAX(id) FROM cat_registro_marc_n2";
        my $sth_MAX = $dbh->prepare($query_MAX);
        $sth_MAX->execute();
        my $id2_nuevo = $sth_MAX->fetchrow;

    return($id2_nuevo);
}


=item
guardaNivel2MARC
Guarda los campos del nivel 2 en un MARC RECORD.
=cut

sub guardaNivel2MARC {
    my ($id1,$id2,$nivel3)=@_;

    my $marc = MARC::Record->new();

    foreach my $obj(@$nivel3){
        my $campo=$obj->{'campo'};
        my $subcampo=$obj->{'subcampo'};
        my $valor=$obj->{'valor'};

        if ($valor ne ''){
                my $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                $marc->add_fields($field);
        }
    }

    my $reg_marc_2 =$dbh->prepare("INSERT INTO cat_registro_marc_n3 (marc_record,id1,id2) VALUES (?,?,?) ");
       $reg_marc_2->execute($marc,$id1,$id2);


        my $query_MAX = "SELECT MAX(id) FROM cat_registro_marc_n3";
        my $sth_MAX = $dbh->prepare($query_MAX);
        $sth_MAX->execute();
        my $id3_nuevo = $sth_MAX->fetchrow;

    return($id3_nuevo);
}

	#########################################################################
	#			GRACIAS!!!!!!!!!!				#
	#########################################################################

