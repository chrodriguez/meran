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
print "FIN!!! \n";
print "\n GRACIAS DICO!!! \n";

#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------FUNCIONES---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------
	sub procesarV2_V3 
	{
	
	my $cant_biblios=$dbh->prepare("SELECT count(*) as cantidad FROM biblio ;");
	$cant_biblios->execute();
	my $cantidad=$cant_biblios->fetchrow;
	my $registro=1;
	print "Se van a procesar $cantidad registros \n";


	
	my $biblios=$dbh->prepare("SELECT * FROM biblio ;");
	$biblios->execute();

	#Obtengo los campos del nivel 1
	my $campos_n1=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='biblio';");
	$campos_n1->execute();
	while (my $n1=$campos_n1->fetchrow_hashref) {
	push (@N1,$n1);
	}
	$campos_n1->finish();

	#Obtengo los campos del nivel 2
	my $campos_n2=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='biblioitems';");
	$campos_n2->execute();
	while (my $n2=$campos_n2->fetchrow_hashref) {
	push (@N2,$n2);	
	}
	$campos_n2->finish();

	#Obtengo los campos del nivel 3
	my $campos_n3=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='items';");
	$campos_n3->execute();
	while (my $n3=$campos_n3->fetchrow_hashref) {
	push (@N3,$n3);
	}
	$campos_n3->finish();

	####################################Otras Tablas#######################################
	my $kohaToMARC1=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='bibliosubject';");
	$kohaToMARC1->execute();
	$subject=$kohaToMARC1->fetchrow_hashref;
	$kohaToMARC1->finish();

	my $kohaToMARC2=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='bibliosubtitle';");
	$kohaToMARC2->execute();
	$subtitle=$kohaToMARC2->fetchrow_hashref;
	$kohaToMARC2->finish();

	my $kohaToMARC3=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='additionalauthors';");
	$kohaToMARC3->execute();
	$additionalauthor=$kohaToMARC3->fetchrow_hashref;
	$kohaToMARC3->finish();

	my $kohaToMARC4=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='publisher';");
	$kohaToMARC4->execute();
	$publisher=$kohaToMARC4->fetchrow_hashref;
	$kohaToMARC4->finish();

	my $kohaToMARC5=$dbh->prepare("SELECT * FROM kohaToMARC where tabla='isbns';");
	$kohaToMARC5->execute();
	$isbn=$kohaToMARC5->fetchrow_hashref;
	$kohaToMARC5->finish();
	###############################################################################

	while (my $biblio=$biblios->fetchrow_hashref ) {
	
	my $porcentaje= int (($registro * 100) / $cantidad );
	print "Procesando registro: $registro de $cantidad ($porcentaje%) \n";



	$autor=$biblio->{'author'};
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
	($id1,$error,$codMsg)=&guardarNivel1($autor,\@ids1);
	
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

	($id2,$tipoDocN2,$error,$codMsg)=&guardarNivel2($id1,\@ids2);
	
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
	
	($error,$codMsg)=&guardarNivel3($id1,$id2,$item->{'barcode'},1,$tipoDocN2,\@ids3);
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
	#########################################################################
	#			FIN QUITAR REFERENCIAS VIEJAS!!!!!		#
	#########################################################################

	}
	sub crearRelacionKohaMarc 
	{
	#########################################################################
	#			RELACION KOHA-MARC				#
	#########################################################################

my $kohamarc=$dbh->prepare("DROP TABLE IF EXISTS `kohaToMARC`;");
$kohamarc->execute();

my $kohamarc1=$dbh->prepare("CREATE TABLE `kohaToMARC` (
  `idmap` int(11) NOT NULL auto_increment,
  `tabla` varchar(100) NOT NULL,
  `campoTabla` varchar(100) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `campo` varchar(3) NOT NULL,
  `subcampo` varchar(1) NOT NULL,
  PRIMARY KEY  (`idmap`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;");
$kohamarc1->execute();

my $kohamarc2=$dbh->prepare("INSERT INTO `kohaToMARC` (`idmap`, `tabla`, `campoTabla`, `nombre`, `campo`, `subcampo`) VALUES 
(1, 'nivel1', 'titulo', 'titulo', '245', 'a'),
(2, 'nivel2', 'tipo_documento', 'tipo documento', '910', 'a'),
(3, 'nivel2', 'pais_publicacion', 'pais publicacion', '043', 'c'),
(4, 'nivel2', 'anio_publicacion', 'a帽o publicacion', '260', 'c'),
(5, 'nivel2', 'ciudad_publicacion', 'ciudad publicacion', '260', 'a'),
(6, 'nivel2', 'lenguaje', 'idioma', '041', 'h'),
(7, 'nivel2', 'soporte', 'soporte', '245', 'h'),
(8, 'nivel2', 'nivel_bibliografico', 'nivel bibliografico', '900', 'b'),
(9, 'nivel3', 'holdingbranch', 'Unidad de informacion de origen', '995', 'd'),
(10, 'nivel3', 'homebranch', 'Unidad de informacion', '995', 'c'),
(11, 'nivel3', 'signatura_topografica', 'signatura topografica', '995', 't'),
(12, 'nivel3', 'wthdrawn', 'Estado de ejemplar', '995', 'e'),
(13, 'nivel3', 'notforloan', 'Disponibilidad', '995', 'o'),
(20, 'additionalauthors', 'author', 'Nombre Personal', '700', 'a'),
(21, 'biblio', 'abstract', 'Nota de resumen, etc.', '520', 'a'),
(22, 'biblio', 'author', 'Nombre Personal', '100', 'a'),
(24, 'biblio', 'notes', 'Entrada principal del original', '534', 'a'),
(25, 'biblio', 'seriestitle', 'N煤mero de Clasificaci贸n Decimal Universal', '080', 'a'),
(26, 'biblio', 'title', 'T铆tulo', '245', 'a'),
(27, 'biblio', 'unititle', 'Resto del t铆tulo', '245', 'b'),
(30, 'biblioitems', 'dewey', 'Call number prefix (NR)', '852', 'k'),
(31, 'biblioitems', 'idCountry', 'C贸digo ISO (R)', '043', 'c'),
(33, 'biblioitems', 'illus', 'Otros detalles f铆sicos', '300', 'b'),
(34, 'biblioitems', 'issn', 'ISSN', '022', 'a'),
(35, 'biblioitems', 'itemtype', 'Tipo de documento', '910', 'a'),
(36, 'biblioitems', 'lccn', 'LC control number', '010', 'a'),
(37, 'biblioitems', 'notes', 'Nota General', '500', 'a'),
(38, 'biblioitems', 'number', 'Menci贸n de edici贸n', '250', 'a'),
(39, 'biblioitems', 'pages', 'Extensi贸n', '300', 'a'),
(40, 'biblioitems', 'place', 'Lugar de publicaci贸n, distribuci贸n, etc.', '260', 'a'),
(41, 'biblioitems', 'publicationyear', 'Fecha de publicaci贸n, distribuci贸n, etc.', '260', 'c'),
(42, 'biblioitems', 'seriestitle', 'T铆tulo', '440', 'a'),
(43, 'biblioitems', 'size', 'Dimensiones', '300', 'c'),
(44, 'biblioitems', 'subclass', 'Call number suffix (NR)', '852', 'm'),
(45, 'biblioitems', 'url', 'Identificador Uniforme de Recurso (URI)', '856', 'u'),
(46, 'biblioitems', 'volume', 'Number of part/section of a work', '740', 'n'),
(47, 'biblioitems', 'volumeddesc', 'T铆tulo', '740', 'a'),
(48, 'bibliosubject', 'subject', 'T贸pico o nombre geogr谩fico', '650', 'a'),
(49, 'bibliosubtitle', 'subtitle', 'T铆tulo propiamente dicho/T铆tulo corto', '246', 'a'),
(50, 'isbns', 'isbn', 'ISBN', '020', 'a'),
(51, 'items', 'barcode', 'C&oacute;digo de Barras', '995', 'f'),
(52, 'items', 'booksellerid', 'Nombre del vendedor', '995', 'a'),
(53, 'items', 'bulk', 'Signatura Topogr&aacute;fica', '995', 't'),
(54, 'items', 'dateaccessioned', 'Fecha de acceso', '995', 'm'),
(55, 'items', 'holdingbranch', 'Unidad de Informaci&oacute;n', '995', 'c'),
(56, 'items', 'homebranch', 'Unidad de Informaci&oacute;n de Origen', '995', 'd'),
(57, 'items', 'itemnotes', 'Notas del item', '995', 'u'),
(59, 'items', 'notforloan', 'Disponibilidad', '995', 'o'),
(60, 'items', 'price', 'Precio de compra', '995', 'p'),
(61, 'items', 'replacementprice', 'Precio de reemplazo', '995', 'r'),
(62, 'items', 'wthdrawn', 'Estado', '995', 'e'),
(63, 'publisher', 'publisher', 'Nombre de la editorial, distribuidor, etc.', '260', 'b'),
(64, 'biblioitems', 'classification', '', '900', 'b'),
(65, 'biblioitems', 'idLanguage', '', '041', 'h'),
(66, 'biblioitems', 'idSupport', '', '245', 'h');");
$kohamarc2->execute();
#################################################################################
	}
	sub crearTablasNecesarias 
	{
	#########################################################################
	#			CREAR TABLAS NECESARIAS!!!			#
	#########################################################################

my $dropear=$dbh->prepare("DROP TABLE IF EXISTS `nivel1`, `nivel1_repetibles`, `nivel2`, `nivel2_repetibles`, `nivel3`, `nivel3_repetibles`;");
$dropear->execute();



######Primero agrego las tablas nuevas######
my $tabla1=$dbh->prepare("
CREATE TABLE `nivel1` (
  `id1` int(11) NOT NULL auto_increment,
  `titulo` varchar(100) NOT NULL,
  `autor` int(11) NOT NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id1`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1  ;");
$tabla1->execute();

my $tabla2=$dbh->prepare(
"CREATE TABLE `nivel1_repetibles` (
  `rep_n1_id` int(11) NOT NULL auto_increment,
  `id1` int(11) NOT NULL,
  `campo` varchar(3) default NULL,
  `subcampo` varchar(3) NOT NULL,
  `dato` varchar(250) NOT NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`rep_n1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;");
$tabla2->execute();

my $tabla3=$dbh->prepare(
"CREATE TABLE `nivel2` (
  `id2` int(11) NOT NULL auto_increment,
  `id1` int(11) NOT NULL,
  `tipo_documento` varchar(4) NOT NULL,
  `nivel_bibliografico` varchar(2) NOT NULL,
  `soporte` varchar(3) NOT NULL,
  `pais_publicacion` char(2) NOT NULL,
  `lenguaje` char(2) NOT NULL,
  `ciudad_publicacion` varchar(20) NOT NULL,
  `anio_publicacion` varchar(15) default NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1  ;");
$tabla3->execute();

my $tabla4=$dbh->prepare("
CREATE TABLE `nivel2_repetibles` (
  `rep_n2_id` int(11) NOT NULL auto_increment,
  `id2` int(11) NOT NULL,
  `campo` varchar(3) default NULL,
  `subcampo` varchar(3) NOT NULL,
  `dato` varchar(250) default NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`rep_n2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;");
$tabla4->execute();

my $tabla5=$dbh->prepare("
CREATE TABLE `nivel3` (
  `id3` int(11) NOT NULL auto_increment,
  `id1` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  `barcode` varchar(20) default NULL,
  `signatura_topografica` varchar(30) default NULL,
  `holdingbranch` varchar(15) default NULL,
  `homebranch` varchar(15) default NULL,
  `wthdrawn` smallint(1) NOT NULL default '0',
  `notforloan` char(2) default '0',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, 
 PRIMARY KEY  (`id3`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;");
$tabla5->execute();

my $tabla6=$dbh->prepare("
CREATE TABLE `nivel3_repetibles` (
  `rep_n3_id` int(11) NOT NULL auto_increment,
  `id3` int(11) NOT NULL,
  `campo` varchar(3) default NULL,
  `subcampo` varchar(3) NOT NULL,
  `dato` varchar(250) NOT NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`rep_n3_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
");
$tabla6->execute();


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


my $b1= $dbh->prepare( "CREATE TABLE `busquedas` (
  `idBusqueda` int(11) NOT NULL auto_increment,
  `borrower` int(11) default NULL,
  `fecha` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`idBusqueda`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;");
$b1->execute();
my $b2= $dbh->prepare( "CREATE TABLE `historialBusqueda` (
  `idHistorial` int(11) NOT NULL auto_increment,
  `idBusqueda` int(11) NOT NULL,
  `campo` varchar(100) NOT NULL,
  `valor` varchar(100) NOT NULL,
  `tipo` varchar(10) default NULL,
  PRIMARY KEY  (`idHistorial`),
  KEY `FK_idBusqueda` (`idBusqueda`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;");
$b2->execute();
	}
	sub quitarTablasDeMas 
	{
	#########################################################################
	#			QUITAR TABLAS DE MAS!!!				#
	#########################################################################
	my @drops = ('additionalauthors', 'aqbookfund', 'aqbooksellers', 'aqbudget', 'aqorderbreakdown', 'aqorderdelivery', 'aqorders', 'biblio', 'biblioitems', 'bibliosubject', 'bibliosubtitle', 'bibliothesaurus', 'borexp', 'branchtransfers', 'catalogueentry', 'categoryitem', 'currency', 'defaultbiblioitem', 'deletedbiblio', 'deletedbiblioitems', 'deleteditems', 'ethnicity', 'isbns', 'isomarc', 'items', 'itemsprices', 'printers', 'publisher', 'reserveconstraints', 'statistics', 'virtual_itemtypes','virtual_request', 'marc_subfield_table');

	my $drop=$dbh->prepare("DROP TABLE ? ;");
	foreach $tabla (@drops){$drop->execute($tabla);}
	}
	sub pasarTodoAInnodb 
	{
	#########################################################################
	#			PASAR TODO A INNODB				#
	#########################################################################
	my @innodbs = ('analyticalauthors','analyticalkeyword','analyticalsubject','authorised_values','autores','availability','biblioanalysis','bibliolevel','bookshelf','borrowers','branchcategories','branches','branchrelations','busquedas','categories','colaboradores','countries','deletedborrowers','dptos_partidos','feriados','generic_report_joins','generic_report_tables','historialBusqueda','historicCirculation','historicIssues','historicSanctions','informacion_referencias','iso2709','issues','issuetypes','itemtypes','keyword','languages','localidades','marc_blob_subfield','marc_breeding','marc_subfield_structure','marc_tag_structure','marc_word','marcrecorddone','modificaciones','persons','provincias','referenciaColaboradores','reserves','sanctionissuetypes','sanctionrules','sanctions','sanctiontypes','sanctiontypesrules','sessionqueries','sessions','shelfcontents','stopwords','supports','systempreferences','tablasDeReferencias','tablasDeReferenciasInfo','temas','unavailable','uploadedmarc','userflags','users','z3950queue','z3950results','z3950servers');
	my $innodb=$dbh->prepare("ALTER TABLE ? ENGINE = innodb;");
	foreach $tabla (@innodbs){$innodb->execute($tabla);}
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
	sub crearEstructuraMarc 
	{
	#########################################################################
	#			ESTRUCTURA MARC					#
	#########################################################################

my $marc=$dbh->prepare("DROP TABLE IF EXISTS `estructura_catalogacion`, `informacion_referencias`, `marc_subfield_structure`;");
   $marc->execute();

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;");
$marc1->execute();

my $marc2 = $dbh->prepare("INSERT INTO `estructura_catalogacion` (`id`, `campo`, `subcampo`, `itemtype`, `liblibrarian`, `tipo`, `referencia`, `nivel`, `obligatorio`, `intranet_habilitado`, `visible`) VALUES 
(1, '700', 'a', 'ALL', 'Autores Adicionales', 'texa2', 1, 1, 0, 1, 1),
(2, '245', 'b', 'ALL', 'T韙ulo informativo', 'text', 0, 1, 0, 2, 1),
(3, '246', 'a', 'ALL', 'Otros titulos', 'texa2', 0, 1, 0, 3, 1),
(4, '650', 'a', 'ALL', 'Temas', 'texa2', 1, 1, 0, 4, 1),
(5, '080', 'a', 'ALL', 'CDU', 'texa2', 0, 1, 0, 5, 1),
(6, '534', 'a', 'ALL', 'Notas', 'texta', 0, 1, 0, 6, 1),
(7, '520', 'a', 'ALL', 'Resumen', 'texta', 0, 1, 0, 7, 1),
(8, '900', 'b', 'ALL', 'Nivel Bibliogr醘ico', 'combo', 1, 2, 0, 1, 1),
(9, '245', 'h', 'ALL', 'Soporte', 'combo', 1, 2, 0, 2, 1),
(10, '250', 'a', 'ALL', 'N鷐ero de Edici髇', 'text', 0, 2, 0, 3, 1),
(11, '260', 'a', 'ALL', 'Lugar de publicaci髇', 'text', 0, 2, 0, 4, 1),
(12, '260', 'b', 'ALL', 'Editor', 'texa2', 0, 2, 0, 5, 1),
(13, '260', 'c', 'ALL', 'A駉 de Edici髇', 'text', 0, 2, 0, 6, 1),
(14, '300', 'a', 'ALL', 'Descripci髇 F韘ica', 'text', 0, 2, 0, 7, 1),
(15, '300', 'c', 'ALL', 'Tama駉', 'text', 0, 2, 0, 8, 1),
(16, '440', 'a', 'ALL', 'Serie', 'text', 0, 2, 0, 9, 1),
(17, '020', 'a', 'ALL', 'ISBN', 'texa2', 0, 2, 0, 10, 1),
(18, '022', 'a', 'ALL', 'ISSN', 'texa2', 0, 2, 0, 11, 1),
(19, '740', 'n', 'ALL', 'Volumen', 'text', 0, 2, 0, 13, 1),
(20, '740', 'a', 'ALL', 'Descripci髇 del volumen', 'text', 0, 2, 0, 14, 1),
(21, '043', 'c', 'ALL', 'Pa韘', 'combo', 1, 2, 0, 15, 1),
(22, '041', 'h', 'ALL', 'Idioma', 'combo', 1, 2, 0, 16, 1),
(23, '500', 'a', 'ALL', 'Notas', 'texta', 0, 2, 0, 18, 1),
(24, '995', 'c', 'ALL', 'Unidad de Informaci髇', 'combo', 1, 3, 1, 1, 1),
(25, '995', 'd', 'ALL', 'Unidad de Informaci髇 de Origen', 'combo', 1, 3, 1, 2, 1),
(26, '995', 't', 'ALL', 'Signatura Topogr醘ica', 'text', 0, 3, 0, 3, 1),
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
  `tagfield` char(3) NOT NULL default '',
  `tagsubfield` char(1) NOT NULL default '',
  `liblibrarian` char(255) NOT NULL default '',
  `libopac` char(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `kohafield` char(40) default NULL,
  `tab` tinyint(1) default NULL,
  `authorised_value` char(13) default NULL,
  `thesaurus_category` char(10) default NULL,
  `value_builder` char(80) default NULL,
  PRIMARY KEY  (`tagfield`,`tagsubfield`),
  KEY `kohafield` (`kohafield`),
  KEY `tab` (`tab`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; ");
$marc5->execute();

my $marc6 = $dbh->prepare("
INSERT INTO `marc_subfield_structure` (`nivel`, `obligatorio`, `tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `thesaurus_category`, `value_builder`) VALUES 
(0, 0, '010', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 1, NULL, -1, '', '', ''),
(2, 0, '010', 'a', 'LC control number', 'LC control number', 0, 1, 'biblioitems.lccn', 0, NULL, '', ''),
(0, 0, '010', 'b', 'NUCMC control number', 'NUCMC control number', 1, 1, NULL, -1, '', '', ''),
(0, 0, '010', 'z', 'Canceled or invalid LC control number', 'Canceled or invalid LC control number', 1, 0, NULL, -1, '', '', ''),
(0, 0, '011', 'a', 'Linking LC control number (R)', 'Linking LC control number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', 'a', 'Number', 'Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', 'b', 'Country', 'Country', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', 'c', 'Type of number', 'Type of number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', 'd', 'Date', 'Date', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', 'e', 'Status', 'Status', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '013', 'f', 'Party to document', 'Party to document', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '015', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '015', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '015', 'a', 'National bibliography number', 'National bibliography number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '016', '2', 'Source', 'Source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '016', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '016', 'a', 'Record control number', 'Record control number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '016', 'z', 'Canceled or invalid record control number', 'Canceled or invalid record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '017', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '017', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '017', 'a', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '017', 'b', 'Source (agency assigning number) (NR)', 'Source (agency assigning number) (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '017', 'c', 'Terms of availability', 'Terms of availability', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '017', 'z', 'Canceled/invalid ISBN', 'Canceled/invalid ISBN', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '018', 'a', 'Copyright article-fee code (NR)', 'Copyright article-fee code (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '020', '6', 'Linkage See', 'Linkage See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '020', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '020', 'a', 'ISBN', 'ISBN', 0, 1, 'isbns.isbn', 0, NULL, NULL, ''),
(0, 0, '020', 'b', 'Binding information (NR) [OBSOLETE]', 'Binding information (NR) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '020', 'c', 'T閞minos de disponibilidad', 'T閞minos de disponibilidad', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '020', 'z', 'ISBN Inv醠ido/cancelado', 'ISBN Inv醠ido/cancelado', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '022', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '022', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '022', 'a', 'ISSN', 'ISSN', 0, 0, 'biblioitems.issn', 0, NULL, NULL, ''),
(0, 0, '022', 'y', 'ISSN incorrecto', 'ISSN incorrecto', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '022', 'z', 'ISSN cancelado', 'ISSN cancelado', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', '2', 'Source of number or code', 'Source of number or code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', 'a', 'Standard number or code', 'Standard number or code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', 'c', 'Terms of availability', 'Terms of availability', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', 'd', 'Additional codes following the standard number or code', 'Additional codes following the standard number or code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '024', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '025', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '025', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '025', 'a', 'Standard technical report number', 'Standard technical report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '025', 'z', 'Canceled/invalid number', 'Canceled/invalid number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '027', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '027', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '027', 'a', 'Standard Technical Report Number (NR)', 'Standard Technical Report Number (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '027', 'z', 'Cancelled/invalid STRN (R)', 'Cancelled/invalid STRN (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '028', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '028', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '028', 'a', 'Publisher number', 'Publisher number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '028', 'b', 'Source', 'Source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '030', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '030', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '030', 'a', 'CODEN', 'CODEN', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '030', 'z', 'Canceled/invalid CODEN', 'Canceled/invalid CODEN', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '032', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '032', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '032', 'a', 'Postal registration number', 'Postal registration number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '032', 'b', 'Source (agency assigning number)', 'Source (agency assigning number)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '033', '3', 'Materials specified', 'Materials specified', 0, 0, '', -1, '', '', ''),
(0, 0, '033', '6', 'Linkage See', 'Linkage See', 0, 0, '', -1, '', '', ''),
(0, 0, '033', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, '', -1, '', '', ''),
(0, 0, '033', 'a', 'Formatted date/time', 'Formatted date/time', 1, 0, '', -1, '', '', ''),
(0, 0, '033', 'b', 'Geographic classification area code', 'Geographic classification area code', 1, 0, '', -1, '', '', ''),
(0, 0, '033', 'c', 'Geographic classification subarea code', 'Geographic classification subarea code', 1, 0, '', -1, '', '', ''),
(0, 0, '034', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'a', 'Category of scale', 'Category of scale', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'b', 'Constant ratio linear horizontal scale', 'Constant ratio linear horizontal scale', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'c', 'Constant ratio linear vertical scale', 'Constant ratio linear vertical scale', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'd', 'Coordinates--westernmost longitude', 'Coordinates--westernmost longitude', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'e', 'Coordinates--easternmost longitude', 'Coordinates--easternmost longitude', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'f', 'Coordinates--northernmost longitude', 'Coordinates--northernmost longitude', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'g', 'Coordinates--southernmost longitude', 'Coordinates--southernmost longitude', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'h', 'Angular scale', 'Angular scale', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'j', 'Declination--northern limit', 'Declination--northern limit', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'k', 'Declination--southern limit', 'Declination--southern limit', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'm', 'Right ascension--eastern limit', 'Right ascension--eastern limit', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'n', 'Right ascension--western limit', 'Right ascension--western limit', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 'p', 'Equinox', 'Equinox', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 's', 'G-ring latitude', 'G-ring latitude', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '034', 't', 'G-ring latitude', 'G-ring latitude', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '035', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '035', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '035', 'a', 'System control number', 'System control number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '035', 'z', 'Canceled/invalid control number', 'Canceled/invalid control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '036', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '036', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '036', 'a', 'Original study number', 'Original study number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '036', 'b', 'Source (agency assigning number)', 'Source (agency assigning number)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '037', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '037', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '037', 'a', 'Stock number', 'Stock number', 0, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '037', 'b', 'Source of stock number/acquisition', 'Source of stock number/acquisition', 0, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '037', 'c', 'Terms of availability', 'Terms of availability', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '037', 'f', 'Form of issue', 'Form of issue', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '037', 'g', 'Additional format characteristics', 'Additional format characteristics', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '037', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '039', 'a', 'Level of rules in bibliographic description (NR)    0 - No level defined by rules    1 - Minimal    2 - Less than full    3 - Full', 'Level of rules in bibliographic description (NR)    0 - No level defined by rules    1 - Minimal    2 - Less than full    3 - Full', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '039', 'b', 'Level of effort used to assign nonsubject heading access points (NR)    2 - Less than full    3 - Full', 'Level of effort used to assign nonsubject heading access points (NR)    2 - Less than full    3 - Full', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '039', 'c', 'Level of effort used to assign subject headings  (NR)    0 - None    2 - Less than full    3 - Full', 'Level of effort used to assign subject headings  (NR)    0 - None    2 - Less than full    3 - Full', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '039', 'd', 'Level of effort used to assign classification  (NR)    0 - None    2 - Less than full    3 - Full', 'Level of effort used to assign classification  (NR)    0 - None    2 - Less than full    3 - Full', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '039', 'e', 'Number of fixed field character positions coded  (NR)    0 - None    1 - Minimal    2 - Most necessary    3 - Full', 'Number of fixed field character positions coded  (NR)    0 - None    1 - Minimal    2 - Most necessary    3 - Full', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', 'a', 'Original cataloging agency', 'Original cataloging agency', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', 'b', 'Language of cataloging', 'Language of cataloging', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', 'c', 'Transcribing agency', 'Transcribing agency', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', 'd', 'Modifying agency', 'Modifying agency', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '040', 'e', 'Description conventions', 'Description conventions', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '041', 'a', 'C骴igo de Idioma para texto o pista de sonido o t韙ulo separado', 'C骴igo de Idioma para texto o pista de sonido o t韙ulo separado', 0, 0, 'biblioitems.idLanguage', 0, 'languages', NULL, ''),
(0, 0, '041', 'b', 'Language code of summary or abstract/overprinted title or subtitle', 'Language code of summary or abstract/overprinted title or subtitle', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', 'c', 'Languages of available translation  (SE) [OBSOLETE]', 'Languages of available translation  (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', 'd', 'Language code of sung or spoken text', 'Language code of sung or spoken text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', 'e', 'Language code of librettos', 'Language code of librettos', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', 'f', 'Language code of table of contents', 'Language code of table of contents', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '041', 'g', 'Language code of accompanying material other than librettos (NR)', 'Language code of accompanying material other than librettos (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '041', 'h', 'C骴igo de idioma de la versi髇 original y/o traducciones intermedias del texto', 'C骴igo de idioma de la versi髇 original y/o traducciones intermedias del texto', 1, 0, NULL, 0, NULL, NULL, ''),
(0, 0, '042', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '042', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '042', 'a', 'Time period code', 'Time period code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '042', 'b', 'Formatted 9999 B', 'Formatted 9999 B', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '042', 'c', 'Formatted pre-9999 B', 'Formatted pre-9999 B', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '043', '2', 'Source of local code (R)', 'Source of local code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '043', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '043', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '043', 'a', 'C骴igo de 醨ea geogr醘ica (R)', 'C骴igo de 醨ea geogr醘ica (R)', 1, 0, NULL, 0, NULL, NULL, ''),
(2, 0, '043', 'c', 'C骴igo ISO (R)', 'C骴igo ISO (R)', 1, 0, 'biblioitems.idCountry', 0, 'countries', NULL, ''),
(0, 0, '044', '2', 'Source of local subentity code (R)', 'Source of local subentity code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '044', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '044', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '044', 'a', 'Country of publishing/producing entity code (R)', 'Country of publishing/producing entity code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '044', 'b', 'Local subentity code (R)', 'Local subentity code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '044', 'c', 'ISO subentity code (R)', 'ISO subentity code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '045', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '045', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '045', 'a', 'Time period code (R)', 'Time period code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '045', 'b', 'Formatted 9999 B', 'Formatted 9999 B', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '045', 'c', 'Formatted pre-9999 B', 'Formatted pre-9999 B', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', 'a', 'Type of date code', 'Type of date code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', 'b', 'Date 1 (B', 'Date 1 (B', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', 'c', 'Date 1 (C', 'Date 1 (C', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', 'd', 'Date 2 (B', 'Date 2 (B', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '046', 'e', 'Date 2 (C', 'Date 2 (C', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '047', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '047', 'a', 'Performer or ensemble', 'Performer or ensemble', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '047', 'b', 'Soloist', 'Soloist', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '048', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '048', 'a', 'Performer or ensemble (R)', 'Performer or ensemble (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '048', 'b', 'Soloist (R)', 'Soloist (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '050', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '050', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '050', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '050', 'a', 'Classification number', 'Classification number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '050', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '050', 'd', 'Supplementary class number (MU) [OBSOLETE]', 'Supplementary class number (MU) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '051', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '051', 'a', 'Classification number', 'Classification number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '051', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '051', 'c', 'Copy information', 'Copy information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', '2', 'Code source', 'Code source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', 'a', 'Geographic classification area code', 'Geographic classification area code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', 'b', 'Geographic classification subarea code', 'Geographic classification subarea code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', 'c', 'Subject (MP) [OBSOLETE]', 'Subject (MP) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '052', 'd', 'Populated place name', 'Populated place name', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '055', '2', 'Source of call/class number', 'Source of call/class number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '055', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '055', 'a', 'Classification number', 'Classification number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '055', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '060', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '060', 'a', 'Classification number', 'Classification number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '060', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '061', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '061', 'a', 'Classification number', 'Classification number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '061', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '061', 'c', 'Copy information', 'Copy information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '066', 'a', 'Conjunto de caracteres primario G0', 'Conjunto de caracteres primario G0', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '066', 'b', 'Conjunto de caracteres G1', 'Conjunto de caracteres G1', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '066', 'c', 'Conjunto de caracteres alternos G0 o G1', 'Conjunto de caracteres alternos G0 o G1', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '070', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '070', 'a', 'Classification number', 'Classification number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '070', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '071', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '071', 'a', 'Classification number', 'Classification number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '071', 'b', 'Item number', 'Item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '071', 'c', 'Copy information', 'Copy information', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '072', '2', 'Fuente del c骴igo', 'Fuente del c骴igo', 0, 0, NULL, 0, NULL, NULL, ''),
(0, 0, '072', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '072', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '072', 'a', 'C骴igo de categor韆 tem醫ica', 'C骴igo de categor韆 tem醫ica', 0, 0, NULL, 0, NULL, NULL, ''),
(1, 0, '072', 'x', 'C骴igo de subdivisi髇 de categor韆 tem醫ica', 'C骴igo de subdivisi髇 de categor韆 tem醫ica', 1, 0, NULL, 0, NULL, NULL, ''),
(0, 0, '074', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '074', 'a', 'GPO item number', 'GPO item number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '074', 'z', 'Canceled/invalid GPO item number', 'Canceled/invalid GPO item number', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '080', '2', 'Identificador de la edici髇', 'Identificador de la edici髇', 0, 0, NULL, 0, NULL, NULL, ''),
(0, 0, '080', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '080', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '080', 'a', 'N鷐ero de Clasificaci髇 Decimal Universal', 'N鷐ero de Clasificaci髇 Decimal Universal', 0, 0, 'biblio.seriestitle', 0, NULL, NULL, ''),
(1, 0, '080', 'b', 'N鷐ero del Item', 'N鷐ero del Item', 0, 0, NULL, 0, NULL, NULL, ''),
(1, 0, '080', 'x', 'Subdivisi髇 auxiliar com鷑 (R)', 'Subdivisi髇 auxiliar com鷑 (R)', 1, 0, NULL, 0, NULL, NULL, ''),
(1, 0, '082', '2', 'No. de la edici髇', 'No. de la edici髇', 0, 0, NULL, 0, NULL, NULL, ''),
(0, 0, '082', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '082', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '082', 'a', 'N鷐ero de Clasificaci髇 Decimal Dewey (R)', 'N鷐ero de Clasificaci髇 Decimal Dewey (R)', 1, 0, NULL, 0, NULL, NULL, ''),
(1, 0, '082', 'b', 'No. del Item', 'No. del Item', 1, 0, NULL, 0, NULL, NULL, ''),
(1, 0, '084', '2', 'Fuente del n鷐ero', 'Fuente del n鷐ero', 0, 0, NULL, 0, NULL, NULL, ''),
(0, 0, '084', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '084', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '084', 'a', 'Otro N鷐ero de Clasificaci髇 (R)', 'Otro N鷐ero de Clasificaci髇 (R)', 1, 0, NULL, 0, NULL, NULL, ''),
(1, 0, '084', 'b', 'N鷐ero del Item', 'N鷐ero del Item', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '086', '2', 'Fuente del n鷐ero', 'Fuente del n鷐ero', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '086', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '086', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '086', 'a', 'N鷐ero de Clasificaci髇 para Documentos Gubernamentales', 'N鷐ero de Clasificaci髇 para Documentos Gubernamentales', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '086', 'z', 'N鷐ero de clasificaci髇 cancelado/inv醠ido (R)', 'N鷐ero de clasificaci髇 cancelado/inv醠ido (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '088', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '088', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '088', 'a', 'Report number', 'Report number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '088', 'z', 'Canceled/invalid report number', 'Canceled/invalid report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '090', 'a', 'Koha Itemtype (NR)', 'Koha Itemtype (NR)', 0, 0, NULL, NULL, NULL, NULL, ''),
(0, 0, '090', 'b', 'Koha Dewey Subclass (NR)', 'Koha Dewey Subclass (NR)', 0, 0, NULL, NULL, NULL, NULL, ''),
(0, 0, '090', 'c', 'Koha biblionumber (NR)', 'Koha biblionumber (NR)', 0, 0, 'biblio.biblionumber', NULL, NULL, NULL, ''),
(0, 0, '090', 'd', 'Koha biblioitemnumber (NR)', 'Koha biblioitemnumber (NR)', 0, 0, 'biblioitems.biblioitemnumber', NULL, NULL, NULL, ''),
(0, 0, '091', 'a', 'Microfilm shelf location (NR)', 'Microfilm shelf location (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '100', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '100', 'a', 'Nombre Personal', 'Nombre Personal', 0, 0, 'biblio.author', 1, NULL, NULL, ''),
(1, 0, '100', 'b', 'Numeraci髇', 'Numeraci髇', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '100', 'c', 'T韙ulos y otras palabras asociadas con el nombre', 'T韙ulos y otras palabras asociadas con el nombre', 1, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '100', 'd', 'Fechas asociadas con el nombre', 'Fechas asociadas con el nombre', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '100', 'e', 'T閞mino de relaci髇', 'T閞mino de relaci髇', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '100', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', 'j', 'Attribution qualifier', 'Attribution qualifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '100', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '100', 'q', 'Forma completa del nombre', 'Forma completa del nombre', 0, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '100', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '100', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '110', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '110', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '110', 'a', 'Nombre de la instituci髇, jurisdicci髇 como entrada principal', 'Nombre de la instituci髇, jurisdicci髇 como entrada principal', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '110', 'b', 'Unidad subordinada', 'Unidad subordinada', 1, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '110', 'c', 'Location of meeting', 'Location of meeting', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '110', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '110', 'e', 'T閞mino de relaci髇', 'T閞mino de relaci髇', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '110', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '110', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '110', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '111', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '111', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '111', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '111', 'a', 'Nombre de la reuni髇 como entrada principal', 'Nombre de la reuni髇 como entrada principal', 0, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '111', 'b', 'Number  (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '111', 'c', 'Localizaci髇 de la reuni髇', 'Localizaci髇 de la reuni髇', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '111', 'd', 'Fecha de la reuni髇', 'Fecha de la reuni髇', 0, 0, NULL, 1, NULL, NULL, ''),
(1, 0, '111', 'e', 'Unidad subordinada', 'Unidad subordinada', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '111', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '111', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '111', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '111', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '111', 'n', 'N鷐ero de la parte/secci髇/reuni髇', 'N鷐ero de la parte/secci髇/reuni髇', 1, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '111', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '111', 'q', 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '111', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '111', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 1, NULL, NULL, ''),
(0, 0, '130', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'a', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'd', 'Date of treaty signing', 'Date of treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '130', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '210', '2', 'Fuente', 'Fuente', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '210', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '210', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '210', 'a', 'T韙ulo abreviado', 'T韙ulo abreviado', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '210', 'b', 'Informaci髇 calificadora', 'Informaci髇 calificadora', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '211', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '211', 'a', 'Acronym or shortened title (NR)', 'Acronym or shortened title (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '212', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '212', 'a', 'Variant access title (NR)', 'Variant access title (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '214', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '214', 'a', 'Augmented title (NR)', 'Augmented title (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '222', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '222', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '222', 'a', 'T韙ulo clave', 'T韙ulo clave', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '222', 'b', 'Informacion calificadora', 'Informacion calificadora', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '240', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '240', 'a', 'T韙ulo Uniforme', 'T韙ulo Uniforme', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'd', 'Fecha de la firma del tratado', 'Fecha de la firma del tratado', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'f', 'Fecha del Trabajo', 'Fecha del Trabajo', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'g', 'Informaci髇 miscel醤ea', 'Informaci髇 miscel醤ea', 0, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '240', 'h', 'Medio', 'Medio', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'k', 'Formas de Subencabezamientos', 'Formas de Subencabezamientos', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'l', 'Idioma del trabajo', 'Idioma del trabajo', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '240', 'n', 'N鷐ero de la parte/secci髇/reuni髇', 'N鷐ero de la parte/secci髇/reuni髇', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '240', 'p', 'Nombre de la parte/secci髇', 'Nombre de la parte/secci髇', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '240', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '240', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '241', 'a', 'Romanized title (NR)', 'Romanized title (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '241', 'h', 'Medium (NR)', 'Medium (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '242', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '242', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '242', 'a', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '242', 'b', 'Resto del t韙ulo', 'Resto del t韙ulo', 0, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '242', 'c', 'Menci髇 de responsabilidad', 'Menci髇 de responsabilidad', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '242', 'd', 'Designation of section (BK AM MP MU VM SE) [OBSOLETE]', 'Designation of section (BK AM MP MU VM SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '242', 'e', 'Name of part/section  (BK AM MP MU VM SE) [OBSOLETE]', 'Name of part/section  (BK AM MP MU VM SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '242', 'h', 'Medio', 'Medio', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '242', 'n', 'N鷐ero de la parte/secci髇 del trabajo', 'N鷐ero de la parte/secci髇 del trabajo', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '242', 'p', 'Nombre de la parte/secci髇 del trabajo', 'Nombre de la parte/secci髇 del trabajo', 1, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '242', 'y', 'C骴igo de idioma del t韙ulo traducido', 'C骴igo de idioma del t韙ulo traducido', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '243', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'a', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'd', 'Date of treaty signing', 'Date of treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'm', 'Medium of performance for music', 'Medium of performance for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '243', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '245', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '245', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 1, '245', 'a', 'T韙ulo', 'T韙ulo', 0, 0, 'biblio.title', 2, NULL, NULL, ''),
(1, 0, '245', 'b', 'Resto del t韙ulo', 'Resto del t韙ulo', 0, 0, 'biblio.unititle', 2, NULL, NULL, ''),
(1, 0, '245', 'c', 'Menci髇 de responsabilidad', 'Menci髇 de responsabilidad', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '245', 'd', 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '245', 'e', 'Name of part/section  (SE) [OBSOLETE]', 'Name of part/section  (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '245', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '245', 'g', 'Bulk dates', 'Bulk dates', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '245', 'h', 'Medio', 'Medio', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '245', 'k', 'Form', 'Form', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '245', 'n', 'N鷐ero de la parte/secci髇 de la obra', 'N鷐ero de la parte/secci髇 de la obra', 1, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '245', 'p', 'Nombre de la parte/secci髇 de la obra', 'Nombre de la parte/secci髇 de la obra', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '245', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '246', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '246', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '246', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '246', 'a', 'T韙ulo propiamente dicho/T韙ulo corto', 'T韙ulo propiamente dicho/T韙ulo corto', 0, 0, 'bibliosubtitle.subtitle', 2, NULL, NULL, ''),
(1, 0, '246', 'b', 'Resto del t韙ulo', 'Resto del t韙ulo', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '246', 'd', 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '246', 'e', 'Name of part/section  (SE) [OBSOLETE]', 'Name of part/section  (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '246', 'f', 'Designaci髇 de volumen y n鷐ero y/o fecha del trabajo', 'Designaci髇 de volumen y n鷐ero y/o fecha del trabajo', 0, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '246', 'g', 'Informaci髇 miscel醤ea', 'Informaci髇 miscel醤ea', 0, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '246', 'h', 'Medio', 'Medio', 0, 0, NULL, 2, NULL, NULL, ''),
(1, 0, '246', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '246', 'n', 'N鷐ero de parte/secci髇 de la obra', 'N鷐ero de parte/secci髇 de la obra', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '246', 'p', 'Nombre de parte/secci髇 de la obra', 'Nombre de parte/secci髇 de la obra', 1, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '247', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'a', 'Title proper/short title', 'Title proper/short title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'b', 'Remainder of title', 'Remainder of title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'd', 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'e', 'Name of part/section  (SE) [OBSOLETE]', 'Name of part/section  (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'f', 'Date or sequential designation', 'Date or sequential designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '247', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '250', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '250', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '250', 'a', 'Menci髇 de edici髇', 'Menci髇 de edici髇', 0, 0, 'biblioitems.number', 2, NULL, NULL, ''),
(2, 0, '250', 'b', 'Resto de la menci髇 de edici髇', 'Resto de la menci髇 de edici髇', 0, 0, NULL, 2, NULL, NULL, ''),
(0, 0, '254', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '254', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '254', 'a', 'Musical presentation statement', 'Musical presentation statement', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'a', 'Statement of scale', 'Statement of scale', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'b', 'Statement of projection', 'Statement of projection', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'c', 'Statement of coordinates', 'Statement of coordinates', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'd', 'Statement of zone', 'Statement of zone', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'e', 'Statement of equinox', 'Statement of equinox', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'f', 'Outer G-ring coordinate pairs', 'Outer G-ring coordinate pairs', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '255', 'g', 'Exclusion G-ring coordinate pairs', 'Exclusion G-ring coordinate pairs', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '256', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '256', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '256', 'a', 'Computer file characteristics', 'Computer file characteristics', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '257', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '257', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '257', 'a', 'Country of producing entity', 'Country of producing entity', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '260', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '260', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '260', 'a', 'Lugar de publicaci髇, distribuci髇, etc.', 'Lugar de publicaci髇, distribuci髇, etc.', 1, 0, 'biblioitems.place', 2, NULL, NULL, ''),
(2, 0, '260', 'b', 'Nombre de la editorial, distribuidor, etc.', 'Nombre de la editorial, distribuidor, etc.', 1, 0, 'publisher.publisher', 2, NULL, NULL, ''),
(2, 0, '260', 'c', 'Fecha de publicaci髇, distribuci髇, etc.', 'Fecha de publicaci髇, distribuci髇, etc.', 1, 0, 'biblioitems.publicationyear', 2, NULL, NULL, ''),
(0, 0, '260', 'd', 'Plates of publisher''s number for music (Pre-AACR 2) (R) [US-LOCAL]', 'Plates of publisher''s number for music (Pre-AACR 2) (R) [US-LOCAL]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '260', 'e', 'Place of manufacture', 'Place of manufacture', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '260', 'f', 'Manufacturer', 'Manufacturer', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '260', 'g', 'Date of manufacture', 'Date of manufacture', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', 'a', 'Producing company (R)', 'Producing company (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', 'b', 'Releasing company (primary distributor)  (R)', 'Releasing company (primary distributor)  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', 'd', 'Date of production, release, etc', 'Date of production, release, etc', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', 'e', 'Contractual producer (R)', 'Contractual producer (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '261', 'f', 'Place of production, release, etc', 'Place of production, release, etc', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', 'a', 'Place of production, release, etc', 'Place of production, release, etc', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', 'b', 'Publisher or trade name (NR)', 'Publisher or trade name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', 'c', 'Date of production, release, etc', 'Date of production, release, etc', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', 'k', 'Serial identification (NR)', 'Serial identification (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '262', 'l', 'Matrix and/or take number (NR)', 'Matrix and/or take number (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', '4', 'Relator code', 'Relator code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'a', 'Address', 'Address', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'b', 'City', 'City', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'c', 'State or province', 'State or province', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'd', 'Country', 'Country', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'e', 'Postal code', 'Postal code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'f', 'Terms preceding attention name', 'Terms preceding attention name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'g', 'Attention name', 'Attention name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'h', 'Attention position', 'Attention position', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'i', 'Type of address', 'Type of address', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'j', 'Specialized telephone number', 'Specialized telephone number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'k', 'Telephone number', 'Telephone number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'l', 'Fax number', 'Fax number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'm', 'Electronic mail address', 'Electronic mail address', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'n', 'TDD or TTY number', 'TDD or TTY number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'p', 'Contact person', 'Contact person', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'q', 'Title of contact person', 'Title of contact person', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'r', 'Hours', 'Hours', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '263', 'z', 'Public note', 'Public note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '265', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '265', 'a', 'Source for acquisition/subscription address (R)', 'Source for acquisition/subscription address (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', '4', 'Relator code (R)', 'Relator code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'a', 'Address (R)', 'Address (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'b', 'City (NR)', 'City (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'c', 'State or province (NR)', 'State or province (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'd', 'Country (NR)', 'Country (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'e', 'Postal code  (NR)', 'Postal code  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'f', 'Terms preceding attention name (NR)', 'Terms preceding attention name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'g', 'Attention name (NR)', 'Attention name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'h', 'Attention position (NR)', 'Attention position (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'i', 'Type of address (NR)', 'Type of address (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'j', 'Specialized telephone number (R)', 'Specialized telephone number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'k', 'Telephone number (R)', 'Telephone number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'l', 'Fax number (R)', 'Fax number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'm', 'Electronic mail address  (R)', 'Electronic mail address  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'n', 'TDD or TTY number (R)', 'TDD or TTY number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'p', 'Contact person (R)', 'Contact person (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'q', 'Title of contact person (R)', 'Title of contact person (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'r', 'Hours (R)', 'Hours (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '270', 'z', 'Public note (R)', 'Public note (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '300', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, '', '', ''),
(0, 0, '300', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, '', '', ''),
(0, 0, '300', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, '', '', ''),
(2, 0, '300', 'a', 'Extensi髇', 'Extensi髇', 1, 0, 'biblioitems.pages', 3, '', '', ''),
(2, 0, '300', 'b', 'Otros detalles f韘icos', 'Otros detalles f韘icos', 0, 0, 'biblioitems.illus', 3, '', '', ''),
(2, 0, '300', 'c', 'Dimensiones', 'Dimensiones', 1, 0, 'biblioitems.size', 3, '', '', ''),
(2, 0, '300', 'e', 'Material acompa馻nte', 'Material acompa馻nte', 0, 0, NULL, 3, '', '', ''),
(0, 0, '300', 'f', 'Type of unit', 'Type of unit', 1, 0, NULL, -1, 'itemtypes', '', ''),
(0, 0, '300', 'g', 'Size of unit', 'Size of unit', 1, 0, NULL, -1, '', '', ''),
(0, 0, '301', 'a', 'Extent of item (NR)', 'Extent of item (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '301', 'b', 'Sound characteristics (NR)', 'Sound characteristics (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '301', 'c', 'Color characteristics (NR)', 'Color characteristics (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '301', 'd', 'Dimensions (NR)', 'Dimensions (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '301', 'e', 'Accompanying material (NR)', 'Accompanying material (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '301', 'f', 'Speed (NR)', 'Speed (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '302', 'a', 'Page count (NR)', 'Page count (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '303', 'a', 'Unit count (NR)', 'Unit count (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '304', 'a', 'Linear footage (NR)', 'Linear footage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'a', 'Extent (NR)', 'Extent (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'b', 'Other physical details (NR)', 'Other physical details (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'c', 'Dimensions (NR)', 'Dimensions (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'd', 'Microgroove or standard (NR)', 'Microgroove or standard (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'e', 'Stereophonic, monaural (NR)', 'Stereophonic, monaural (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'f', 'Number of tracks (NR)', 'Number of tracks (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'm', 'Serial identification (NR)', 'Serial identification (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '305', 'n', 'Matrix and/or take number (NR)', 'Matrix and/or take number (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '306', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '306', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '306', 'a', 'Hours', 'Hours', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '306', 'b', 'Additional information', 'Additional information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '307', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '307', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '307', 'a', 'Hours (NR)', 'Hours (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '307', 'b', 'Additional information (NR)', 'Additional information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', 'a', 'Number of reels (NR)', 'Number of reels (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', 'b', 'Footage (NR)', 'Footage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', 'c', 'Sound characteristics (NR)', 'Sound characteristics (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', 'd', 'Color characteristics (NR)', 'Color characteristics (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', 'e', 'Width (NR)', 'Width (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '308', 'f', 'Presentation format (NR)', 'Presentation format (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '310', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '310', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '310', 'a', 'Frecuencia actual de la publicaci髇', 'Frecuencia actual de la publicaci髇', 0, 0, NULL, 3, NULL, NULL, ''),
(2, 0, '310', 'b', 'Fecha de la frecuencia actual de la publicaci髇', 'Fecha de la frecuencia actual de la publicaci髇', 0, 0, NULL, 3, NULL, NULL, ''),
(0, 0, '315', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '315', 'a', 'Frequency (R)', 'Frequency (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '315', 'b', 'Dates of frequency (R)', 'Dates of frequency (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '321', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '321', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '321', 'a', 'Former publication frequency', 'Former publication frequency', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '321', 'b', 'Dates of former publication frequency', 'Dates of former publication frequency', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'a', 'Material base and configuration', 'Material base and configuration', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'b', 'Dimensions', 'Dimensions', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'c', 'Materials applied to surface', 'Materials applied to surface', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'd', 'Information recording technique', 'Information recording technique', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'e', 'Support', 'Support', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'f', 'Production rate/ratio', 'Production rate/ratio', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'h', 'Location within medium', 'Location within medium', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '340', 'i', 'Technical specifications of medium', 'Technical specifications of medium', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', '2', 'Reference method used', 'Reference method used', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'a', 'Name', 'Name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'b', 'Coordinate or distance units', 'Coordinate or distance units', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'c', 'Latitude resolution', 'Latitude resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'd', 'Longitude resolution', 'Longitude resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'e', 'Standard parallel or oblique line latitude', 'Standard parallel or oblique line latitude', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'f', 'Oblique line longitude', 'Oblique line longitude', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'g', 'Longitude of central meridian or projection center', 'Longitude of central meridian or projection center', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'h', 'Latitude of projection origin or projection center', 'Latitude of projection origin or projection center', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'i', 'False easting', 'False easting', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'j', 'False northing', 'False northing', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'k', 'Scale factor', 'Scale factor', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'l', 'Height of perspective point above surface', 'Height of perspective point above surface', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'm', 'Azimuthal angle', 'Azimuthal angle', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'n', 'Azimuth measure point longitude or straight vertical longitude from pole', 'Azimuth measure point longitude or straight vertical longitude from pole', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'o', 'Landsat number and path number', 'Landsat number and path number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'p', 'Zone identifier', 'Zone identifier', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'q', 'Ellipsoid name', 'Ellipsoid name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'r', 'Semi-major axis', 'Semi-major axis', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 's', 'Denominator of flattening ratio', 'Denominator of flattening ratio', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 't', 'Vertical resolution', 'Vertical resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'u', 'Vertical encoding method', 'Vertical encoding method', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'v', 'Local planar, local, or other projection or grid description', 'Local planar, local, or other projection or grid description', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '342', 'w', 'Local planar or local georeference information', 'Local planar or local georeference information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'a', 'Planar coordinate encoding method', 'Planar coordinate encoding method', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'b', 'Planar distance units', 'Planar distance units', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'c', 'Abscissa resolution', 'Abscissa resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'd', 'Ordinate resolution', 'Ordinate resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'e', 'Distance resolution', 'Distance resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'f', 'Bearing resolution', 'Bearing resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'g', 'Bearing units', 'Bearing units', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'h', 'Bearing reference direction', 'Bearing reference direction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '343', 'i', 'Bearing reference meridian', 'Bearing reference meridian', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '350', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '350', 'a', 'Price (R)', 'Price (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '350', 'b', 'Form of issue (R)', 'Form of issue (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '351', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '351', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '351', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '351', 'a', 'Organization', 'Organization', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '351', 'b', 'Arrangement', 'Arrangement', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '351', 'c', 'Hierarchical level', 'Hierarchical level', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'a', 'Direct reference method', 'Direct reference method', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'b', 'Object type', 'Object type', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'c', 'Object count', 'Object count', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'd', 'Row count', 'Row count', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'e', 'Column count', 'Column count', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'f', 'Vertical count', 'Vertical count', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'g', 'VPF topology level', 'VPF topology level', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '352', 'i', 'Indirect reference description', 'Indirect reference description', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'a', 'Security classification', 'Security classification', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'b', 'Handling instructions', 'Handling instructions', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'c', 'External dissemination information', 'External dissemination information', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'd', 'Downgrading or declassification event', 'Downgrading or declassification event', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'e', 'Classification system', 'Classification system', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'f', 'Country of origin code', 'Country of origin code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'g', 'Downgrading date', 'Downgrading date', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'h', 'Declassification date', 'Declassification date', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '355', 'j', 'Authorization', 'Authorization', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', 'a', 'Dates of publication and/or sequential designation', 'Dates of publication and/or sequential designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', 'b', 'Originating agency (R)', 'Originating agency (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', 'c', 'Authorized recipients of material (R)', 'Authorized recipients of material (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', 'g', 'Other restrictions (R)', 'Other restrictions (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '357', 'z', 'Source of information', 'Source of information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '359', 'a', 'Rental price (NR)', 'Rental price (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '362', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '362', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '362', 'a', 'Fecha de publicaci髇 y/o designaci髇 secuencial', 'Fecha de publicaci髇 y/o designaci髇 secuencial', 0, 0, NULL, 3, NULL, NULL, ''),
(2, 0, '362', 'z', 'Fuente de la informaci髇', 'Fuente de la informaci髇', 0, 0, NULL, 3, NULL, NULL, ''),
(0, 0, '400', '4', 'Relator code (R)', 'Relator code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'a', 'Personal name (NR)', 'Personal name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'b', 'Numeration (NR)', 'Numeration (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'c', 'Titles and other words associated with a name  (R)', 'Titles and other words associated with a name  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'd', 'Dates associated with a name (NR)', 'Dates associated with a name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'e', 'Relator term (R)', 'Relator term (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'f', 'Date of a work (NR)', 'Date of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'g', 'Miscellaneous information (NR)', 'Miscellaneous information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'k', 'Form subheading (R)', 'Form subheading (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'l', 'Language of a work (NR)', 'Language of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'n', 'Number of part/section of a work (R)', 'Number of part/section of a work (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'p', 'Name of part/section of a work (R)', 'Name of part/section of a work (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'q', 'Fuller form of name (NR) [OBSOLETE]', 'Fuller form of name (NR) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 't', 'Title of a work (NR)', 'Title of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'u', 'Affiliation (NR)', 'Affiliation (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'v', 'Volume number/sequential designation  (NR)', 'Volume number/sequential designation  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '400', 'x', 'International Standard Serial Number  (NR)', 'International Standard Serial Number  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', '4', 'Relator code (R)', 'Relator code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'a', 'Corporate name or jurisdiction name as entry element (NR)', 'Corporate name or jurisdiction name as entry element (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'b', 'Subordinate unit (R)', 'Subordinate unit (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'c', 'Location of meeting (NR)', 'Location of meeting (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'd', 'Date of meeting or treaty signing (R)', 'Date of meeting or treaty signing (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'e', 'Relator term (R)', 'Relator term (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'f', 'Date of a work (NR)', 'Date of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'g', 'Miscellaneous information (NR)', 'Miscellaneous information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'k', 'Form subheading (R)', 'Form subheading (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'l', 'Language of a work (NR)', 'Language of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'n', 'Number of part/section/meeting (R)', 'Number of part/section/meeting (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'p', 'Name of part/section of a work (R)', 'Name of part/section of a work (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 't', 'Title of a work (NR)', 'Title of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'u', 'Affiliation (NR)', 'Affiliation (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'v', 'Volume number/sequential designation  (NR)', 'Volume number/sequential designation  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '410', 'x', 'International Standard Serial Number  (NR)', 'International Standard Serial Number  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', '4', 'Relator code (R)', 'Relator code (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'a', 'Meeting name or jurisdiction name as entry element (NR)', 'Meeting name or jurisdiction name as entry element (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'b', 'Number  [OBSOLETE]', 'Number  [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'c', 'Location of meeting (NR)', 'Location of meeting (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'd', 'Date of meeting (NR)', 'Date of meeting (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'e', 'Subordinate unit (R)', 'Subordinate unit (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'f', 'Date of a work (NR)', 'Date of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'g', 'Miscellaneous information (NR)', 'Miscellaneous information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'k', 'Form subheading (R)', 'Form subheading (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'l', 'Language of a work (NR)', 'Language of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'n', 'Number of part/section/meeting (R)', 'Number of part/section/meeting (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'p', 'Name of part/section of a work (R)', 'Name of part/section of a work (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'q', 'Name of meeting following jurisdiction name entry element (NR)', 'Name of meeting following jurisdiction name entry element (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 't', 'Title of a work (NR)', 'Title of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'u', 'Affiliation (NR)', 'Affiliation (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'v', 'Volume number/sequential designation  (NR)', 'Volume number/sequential designation  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '411', 'x', 'International Standard Serial Number  (NR)', 'International Standard Serial Number  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '440', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '440', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '440', 'a', 'T韙ulo', 'T韙ulo', 0, 0, 'biblioitems.seriestitle', 4, NULL, NULL, ''),
(2, 0, '440', 'n', 'N鷐ero de la parte/secci髇 de una obra', 'N鷐ero de la parte/secci髇 de una obra', 1, 0, NULL, 4, NULL, NULL, ''),
(2, 0, '440', 'p', 'Nombre de la parte/secci髇', 'Nombre de la parte/secci髇', 1, 0, NULL, 4, NULL, NULL, ''),
(2, 0, '440', 'v', 'N鷐ero de volumen/designaci髇 secuencial', 'N鷐ero de volumen/designaci髇 secuencial', 0, 0, NULL, 4, NULL, NULL, ''),
(2, 0, '440', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 4, NULL, NULL, ''),
(0, 0, '490', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '490', '8', 'Field link and sequence number  See', 'Field link and sequence number  See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '490', 'a', 'Series statement', 'Series statement', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '490', 'l', 'Library of Congress call number', 'Library of Congress call number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '490', 'v', 'Volume number/sequential designation', 'Volume number/sequential designation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '490', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '500', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '500', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '500', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '500', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '500', 'a', 'Nota General', 'Nota General', 0, 0, 'biblioitems.notes', 5, NULL, NULL, ''),
(0, 0, '500', 'l', 'Library of Congress call number (SE) [OBSOLETE]', 'Library of Congress call number (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '500', 'x', 'International Standard Serial Number  (SE) [OBSOLETE]', 'International Standard Serial Number  (SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '500', 'z', 'Source of note information (AM SE) [OBSOLETE]', 'Source of note information (AM SE) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '501', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '501', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '501', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '501', 'a', 'With note', 'With note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '502', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '502', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '502', 'a', 'Dissertation note', 'Dissertation note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '503', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '503', 'a', 'bibliographic history note (NR)', 'bibliographic history note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '504', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '504', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '504', 'a', 'Nota de Bibliograf韆, etc.', 'Nota de Bibliograf韆, etc.', 0, 0, NULL, 5, NULL, NULL, ''),
(2, 0, '504', 'b', 'N鷐ero de referencias', 'N鷐ero de referencias', 0, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '505', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '505', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '505', 'a', 'Nota de contenido formateada', 'Nota de contenido formateada', 0, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '505', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '505', 'r', 'Statement of responsibility', 'Statement of responsibility', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '505', 't', 'Title', 'Title', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '505', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', 'a', 'Terms governing access', 'Terms governing access', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', 'b', 'Jurisdiction', 'Jurisdiction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', 'c', 'Physical access provisions', 'Physical access provisions', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', 'd', 'Authorized users', 'Authorized users', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '506', 'e', 'Authorization', 'Authorization', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '507', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '507', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '507', 'a', 'Representative fraction of scale note', 'Representative fraction of scale note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '507', 'b', 'Remainder of scale note', 'Remainder of scale note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '508', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '508', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '508', 'a', 'Creation/production credits note', 'Creation/production credits note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', 'a', 'Name of source', 'Name of source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', 'b', 'Coverage of source', 'Coverage of source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', 'c', 'Location within source', 'Location within source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '510', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '511', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '511', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '511', 'a', 'Participant or performer note', 'Participant or performer note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '512', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '512', 'a', 'Earlier or later volumes separately cataloged note (NR)', 'Earlier or later volumes separately cataloged note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '513', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '513', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '513', 'a', 'Type of report', 'Type of report', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '513', 'b', 'Period covered', 'Period covered', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'a', 'Attribute accuracy report', 'Attribute accuracy report', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'b', 'Attribute accuracy value', 'Attribute accuracy value', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'c', 'Attribute accuracy explanation', 'Attribute accuracy explanation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'd', 'Logical consistency report', 'Logical consistency report', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'e', 'Completeness report', 'Completeness report', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'f', 'Horizontal position accuracy report', 'Horizontal position accuracy report', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'g', 'Horizontal position accuracy value', 'Horizontal position accuracy value', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'h', 'Horizontal position accuracy explanation', 'Horizontal position accuracy explanation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'i', 'Vertical positional accuracy report', 'Vertical positional accuracy report', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'j', 'Vertical positional accuracy value', 'Vertical positional accuracy value', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'k', 'Vertical positional accuracy explanation', 'Vertical positional accuracy explanation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'm', 'Cloud cover', 'Cloud cover', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '514', 'z', 'Display note', 'Display note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '515', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '515', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '515', 'a', 'Numbering peculiarities note', 'Numbering peculiarities note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '515', 'z', 'Source of note information (NR)  (SE) [OBSOLETE]', 'Source of note information (NR)  (SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '516', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '516', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '516', 'a', 'Type of computer file or data note', 'Type of computer file or data note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '517', 'a', 'Different formats (NR)', 'Different formats (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '517', 'b', 'Content descriptors (R)', 'Content descriptors (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '517', 'c', 'Additional animation techniques (R)', 'Additional animation techniques (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '518', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '518', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '518', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '518', 'a', 'Date/time and place of an event note', 'Date/time and place of an event note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '520', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '520', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '520', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '520', 'a', 'Nota de resumen, etc.', 'Nota de resumen, etc.', 0, 0, 'biblio.abstract', 5, NULL, NULL, ''),
(0, 0, '520', 'b', 'Expansion of summary note', 'Expansion of summary note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '520', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '520', 'z', 'Source of note information (NR)  [OBSOLETE]', 'Source of note information (NR)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '521', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '521', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '521', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '521', 'a', 'Target audience note', 'Target audience note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '521', 'b', 'Source', 'Source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '522', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '522', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '522', 'a', 'Geographic coverage note', 'Geographic coverage note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '523', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '523', 'a', 'Time period of content note (NR)', 'Time period of content note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '523', 'b', 'Dates of data collection note (NR)', 'Dates of data collection note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '524', '2', 'Source of schema used', 'Source of schema used', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '524', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '524', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '524', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '524', 'a', 'Preferred citation of described materials note', 'Preferred citation of described materials note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '525', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '525', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '525', 'a', 'Supplement note', 'Supplement note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '525', 'z', 'Source of note information (NR)  (SE) [OBSOLETE]', 'Source of note information (NR)  (SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'a', 'Program name', 'Program name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'b', 'Interest level', 'Interest level', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'c', 'Reading level', 'Reading level', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'd', 'Title point value', 'Title point value', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'x', 'Nonpublic note', 'Nonpublic note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '526', 'z', 'Public note', 'Public note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '527', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '527', 'a', 'Censorship note (NR)', 'Censorship note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', 'a', 'Additional physical form available note', 'Additional physical form available note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', 'b', 'Availability source', 'Availability source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', 'c', 'Availability conditions', 'Availability conditions', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', 'd', 'Order number', 'Order number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '530', 'z', 'Source of note information (NR)  (AM CF VM SE) [OBSOLETE]', 'Source of note information (NR)  (AM CF VM SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', '7', 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'a', 'Type of reproduction', 'Type of reproduction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'b', 'Place of reproduction', 'Place of reproduction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'c', 'Agency responsible for reproduction', 'Agency responsible for reproduction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'd', 'Date of reproduction', 'Date of reproduction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'e', 'Physical description of reproduction', 'Physical description of reproduction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'f', 'Series statement of reproduction', 'Series statement of reproduction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'm', 'Dates and/or sequential designation of issues reproduced', 'Dates and/or sequential designation of issues reproduced', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '533', 'n', 'Note about reproduction', 'Note about reproduction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '534', 'a', 'Entrada principal del original', 'Entrada principal del original', 0, 0, 'biblio.notes', 5, NULL, NULL, ''),
(1, 0, '534', 'b', 'Menci髇 de edici髇 del original', 'Menci髇 de edici髇 del original', 0, 0, NULL, 5, NULL, NULL, ''),
(1, 0, '534', 'c', 'Publicaci髇, distribuci髇, etc. del original', 'Publicaci髇, distribuci髇, etc. del original', 0, 0, NULL, 5, NULL, NULL, ''),
(1, 0, '534', 'e', 'Descripci髇 f韘ica, etc. del original', 'Descripci髇 f韘ica, etc. del original', 0, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '534', 'f', 'Series statement of original', 'Series statement of original', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', 'k', 'Key title of original', 'Key title of original', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', 'l', 'Location of original', 'Location of original', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', 'm', 'Material specific details', 'Material specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', 'n', 'Note about original', 'Note about original', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', 'p', 'Frase introductora', 'Frase introductora', 0, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '534', 't', 'Menci髇 de t韙ulo del original', 'Menci髇 de t韙ulo del original', 0, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '534', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '534', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', 'a', 'Custodian', 'Custodian', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', 'b', 'Postal address', 'Postal address', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', 'c', 'Country', 'Country', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', 'd', 'Telecommunications address', 'Telecommunications address', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '535', 'g', 'Repository location code', 'Repository location code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'a', 'Text of note', 'Text of note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'b', 'Contract number', 'Contract number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'c', 'Grant number', 'Grant number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'd', 'Undifferentiated number', 'Undifferentiated number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'e', 'Program element number', 'Program element number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'f', 'Project number', 'Project number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'g', 'Task number', 'Task number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '536', 'h', 'Work unit number', 'Work unit number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '537', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '537', 'a', 'Source of data note (NR)', 'Source of data note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '538', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '538', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '538', 'a', 'Nota sobre detalles del sistema', 'Nota sobre detalles del sistema', 0, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '540', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', 'a', 'Terms governing use and reproduction', 'Terms governing use and reproduction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', 'b', 'Jurisdiction', 'Jurisdiction', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', 'c', 'Authorization', 'Authorization', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '540', 'd', 'Authorized users', 'Authorized users', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'a', 'Source of acquisition', 'Source of acquisition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'b', 'Address', 'Address', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'c', 'Method of acquisition', 'Method of acquisition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'd', 'Date of acquisition', 'Date of acquisition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'e', 'Accession number', 'Accession number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'f', 'Owner', 'Owner', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'h', 'Purchase price', 'Purchase price', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'n', 'Extent', 'Extent', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '541', 'o', 'Type of unit', 'Type of unit', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '543', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '543', 'a', 'Solicitation information note (NR)', 'Solicitation information note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', 'a', 'Custodian', 'Custodian', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', 'b', 'Address', 'Address', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', 'c', 'Country', 'Country', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', 'd', 'Title', 'Title', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', 'e', 'Provenance', 'Provenance', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '544', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '545', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '545', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''), 
(0, 0, '545', 'a', 'Biographical or historical note', 'Biographical or historical note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '545', 'b', 'Expansion', 'Expansion', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '545', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '546', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '546', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '546', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '546', 'a', 'Nota de idioma', 'Nota de idioma', 0, 0, NULL, 5, NULL, NULL, ''),
(2, 0, '546', 'b', 'Informaci髇 sobre c骴igos o alfabetos', 'Informaci髇 sobre c骴igos o alfabetos', 1, 0, NULL, 5, NULL, NULL, ''),
(0, 0, '546', 'z', 'Source of note information (NR)  (SE) [OBSOLETE]', 'Source of note information (NR)  (SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '547', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '547', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '547', 'a', 'Former title complexity note', 'Former title complexity note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '547', 'z', 'Source of note information (NR)  (SE) [OBSOLETE]', 'Source of note information (NR)  (SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '550', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '550', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '550', 'a', 'Issuing body note', 'Issuing body note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '550', 'z', 'Source of note information (NR)  (SE) [OBSOLETE]', 'Source of note information (NR)  (SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'a', 'Entity type label', 'Entity type label', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'b', 'Entity type definition and source', 'Entity type definition and source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'c', 'Attribute label', 'Attribute label', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'd', 'Attribute definition and source', 'Attribute definition and source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'e', 'Enumerated domain value', 'Enumerated domain value', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'f', 'Enumerated domain value definition and source', 'Enumerated domain value definition and source', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'g', 'Range domain minimum and maximum', 'Range domain minimum and maximum', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'h', 'Codeset name and source', 'Codeset name and source', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'i', 'Unrepresentable domain', 'Unrepresentable domain', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'j', 'Attribute units of measurement and resolution', 'Attribute units of measurement and resolution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'k', 'Beginning date and ending date of attribute values', 'Beginning date and ending date of attribute values', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'l', 'Attribute value accuracy', 'Attribute value accuracy', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'm', 'Attribute value accuracy explanation', 'Attribute value accuracy explanation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'n', 'Attribute measurement frequency', 'Attribute measurement frequency', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'o', 'Entity and attribute overview', 'Entity and attribute overview', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'p', 'Entity and attribute detail citation', 'Entity and attribute detail citation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '552', 'z', 'Display note', 'Display note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '555', 'a', 'Cumulative index/finding aids note', 'Cumulative index/finding aids note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', 'b', 'Availability source', 'Availability source', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', 'c', 'Degree of control', 'Degree of control', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', 'd', 'bibliographic reference', 'bibliographic reference', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '555', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '556', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '556', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '556', 'a', 'Information about documentation note', 'Information about documentation note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '556', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '561', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '561', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '561', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '561', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '561', 'a', 'History', 'History', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '561', 'b', 'Time of collation (NR) [OBSOLETE]', 'Time of collation (NR) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', 'a', 'Identifying markings', 'Identifying markings', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', 'b', 'Copy identification', 'Copy identification', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', 'c', 'Version identification', 'Version identification', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', 'd', 'Presentation format', 'Presentation format', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '562', 'e', 'Number of copies', 'Number of copies', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', 'a', 'Number of cases/variables', 'Number of cases/variables', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', 'b', 'Name of variable', 'Name of variable', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', 'c', 'Unit of analysis', 'Unit of analysis', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', 'd', 'Universe of data', 'Universe of data', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '565', 'e', 'Filing scheme or code', 'Filing scheme or code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '567', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '567', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '567', 'a', 'Methodology note', 'Methodology note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '570', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '570', 'a', 'Editor note (NR)', 'Editor note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '570', 'z', 'Source of note information (NR)', 'Source of note information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '580', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '580', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '580', 'a', 'Linking entry complexity note', 'Linking entry complexity note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '580', 'z', 'Source of note information (NR)  [OBSOLETE]', 'Source of note information (NR)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '581', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '581', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '581', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '581', 'a', 'Publications about described materials note', 'Publications about described materials note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '581', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '582', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '582', 'a', 'Related computer files note (NR)', 'Related computer files note (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', '2', 'Source of term', 'Source of term', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'a', 'Action', 'Action', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'b', 'Action identification', 'Action identification', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'c', 'Time/date of action', 'Time/date of action', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'd', 'Action interval', 'Action interval', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'e', 'Contingency for action', 'Contingency for action', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'f', 'Authorization', 'Authorization', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'h', 'Jurisdiction', 'Jurisdiction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'i', 'Method of action', 'Method of action', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'j', 'Site of action', 'Site of action', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'k', 'Action agent', 'Action agent', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'l', 'Status', 'Status', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'n', 'Extent', 'Extent', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'o', 'Type of unit', 'Type of unit', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '583', 'z', 'Public note', 'Public note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '584', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '584', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '584', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '584', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '584', 'a', 'Accumulation', 'Accumulation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '584', 'b', 'Frequency of use', 'Frequency of use', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '585', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '585', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '585', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '585', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '585', 'a', 'Exhibitions note', 'Exhibitions note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '586', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '586', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '586', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '586', 'a', 'Awards note', 'Awards note', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '590', 'a', 'Receipt date (NR)', 'Receipt date (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '590', 'b', 'Provenance (NR)', 'Provenance (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '590', 'd', 'Origin of safety copy (NR)', 'Origin of safety copy (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '600', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '600', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '600', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '600', 'a', 'Nombre Personal', 'Nombre Personal', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'b', 'Numeraci髇', 'Numeraci髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'c', 'T韙ulos y otras palabras asociadas con el nombre', 'T韙ulos y otras palabras asociadas con el nombre', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'd', 'Fechas asociadas con el nombre', 'Fechas asociadas con el nombre', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'e', 'T閞mino de relaci髇', 'T閞mino de relaci髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '600', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'j', 'Attribution qualifier', 'Attribution qualifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '600', 'q', 'Forma completa del nombre', 'Forma completa del nombre', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '600', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '600', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '600', 't', 'T韙ulo del trabajo', 'T韙ulo del trabajo', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '600', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'y', 'Subdivisi髇 cronol骻ica', 'Subdivisi髇 cronol骻ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '600', 'z', 'Subdivisi髇 geogr醘ica', 'Subdivisi髇 geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '610', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '610', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '610', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '610', 'a', 'Nombre corporativo o de jurisdicci髇 como entrada', 'Nombre corporativo o de jurisdicci髇 como entrada', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', 'b', 'Unidad subordinada', 'Unidad subordinada', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '610', 'c', 'Location of meeting', 'Location of meeting', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '610', 'e', 'Relaci髇', 'Relaci髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '610', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '610', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '610', 't', 'T韙ulo del trabajo', 'T韙ulo del trabajo', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', 'y', 'Subdivisi髇 cronol骻ica', 'Subdivisi髇 cronol骻ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '610', 'z', 'Subdivisi髇 geogr醘ica', 'Subdivisi髇 geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '611', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', '4', 'C骴igo de relator', 'C骴igo de relator', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '611', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '611', 'a', 'Nombre de la reuni髇 o jurisdicci髇 como entrada', 'Nombre de la reuni髇 o jurisdicci髇 como entrada', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '611', 'b', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '611', 'c', 'Lugar de la reuni髇', 'Lugar de la reuni髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', 'd', 'Fecha de la reuni髇', 'Fecha de la reuni髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', 'e', 'Unidad subordinada', 'Unidad subordinada', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '611', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '611', 'n', 'N鷐ero de parte/secci髇/reuni髇', 'N鷐ero de parte/secci髇/reuni髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '611', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 'q', 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '611', 't', 'T韙ulo del trabajo', 'T韙ulo del trabajo', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '611', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', 'y', 'Subdivisi髇 cronol骻ica', 'Subdivisi髇 cronol骻ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '611', 'z', 'Subdivisi髇 geogr醘ica', 'Subdivisi髇 geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '630', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '630', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '630', 'a', 'T韙ulo Uniforme', 'T韙ulo Uniforme', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '630', 'd', 'Date of treaty signing', 'Date of treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'n', 'N鷐ero de la parte/secci髇/reuni髇', 'N鷐ero de la parte/secci髇/reuni髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '630', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 'p', 'Nombre de la parte/secci髇', 'Nombre de la parte/secci髇', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '630', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '630', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '630', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '630', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '630', 'y', 'Subdivisi髇 cronol骻ica', 'Subdivisi髇 cronol骻ica', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '630', 'z', 'Subdivisi髇 geogr醘ica', 'Subdivisi髇 geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '650', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '650', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '650', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '650', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '650', 'a', 'T髉ico o nombre geogr醘ico', 'T髉ico o nombre geogr醘ico', 0, 0, 'bibliosubject.subject', 6, NULL, NULL, ''),
(0, 0, '650', 'b', 'Topical term following geographic name as entry element', 'Topical term following geographic name as entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '650', 'c', 'Location of event', 'Location of event', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '650', 'd', 'Active dates', 'Active dates', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '650', 'e', 'Relaci髇', 'Relaci髇', 0, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '650', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '650', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '650', 'y', 'Subdivisi髇 cronol骻ica', 'Subdivisi髇 cronol骻ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '650', 'z', 'Subdivisi髇 Geogr醘ica', 'Subdivisi髇 Geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '651', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '651', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '651', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '651', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '651', 'a', 'Nombre geogr醘ico', 'Nombre geogr醘ico', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '651', 'b', 'Geographic name following place entry element  (R) [OBSOLETE]', 'Geographic name following place entry element  (R) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '651', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '651', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '651', 'y', 'Subdivisi髇 cronol骻ica', 'Subdivisi髇 cronol骻ica', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '651', 'z', 'Subdivisi髇 geogr醘ica', 'Subdivisi髇 geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '652', 'a', 'Geographic name of place element  (NR)', 'Geographic name of place element  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '652', 'x', 'General subdivision (R)', 'General subdivision (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '652', 'y', 'Chronological subdivision (R)', 'Chronological subdivision (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '652', 'z', 'Geographic subdivision (R)', 'Geographic subdivision (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '653', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '653', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '653', 'a', 'T閞mino no controlado', 'T閞mino no controlado', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '654', '2', 'Source of heading or term', 'Source of heading or term', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', 'a', 'Focus term', 'Focus term', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', 'b', 'Non-focus term', 'Non-focus term', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', 'c', 'Facet/hierarchy designation', 'Facet/hierarchy designation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', 'v', 'Form subdivision', 'Form subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', 'y', 'Chronological subdivision', 'Chronological subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '654', 'z', 'Geographic subdivision', 'Geographic subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '655', '2', 'Fuente del encabezamiento o t閞mino', 'Fuente del encabezamiento o t閞mino', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '655', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '655', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '655', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '655', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '655', 'a', 'Genero/Forma', 'Genero/Forma', 0, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '655', 'b', 'Non-focus term', 'Non-focus term', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '655', 'c', 'Facet/hierarchy designation', 'Facet/hierarchy designation', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '655', 'v', 'Subdivisi髇 de forma', 'Subdivisi髇 de forma', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '655', 'x', 'Subdivisi髇 general', 'Subdivisi髇 general', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '655', 'y', 'Subdivisi髇 cronol骻ic', 'Subdivisi髇 cronol骻ic', 1, 0, NULL, 6, NULL, NULL, ''),
(1, 0, '655', 'z', 'Subdivisi髇 geogr醘ica', 'Subdivisi髇 geogr醘ica', 1, 0, NULL, 6, NULL, NULL, ''),
(0, 0, '656', '2', 'Source of term', 'Source of term', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', 'a', 'Occupation', 'Occupation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', 'k', 'Form', 'Form', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', 'v', 'Form subdivision', 'Form subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', 'x', 'General subdivision', 'General subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', 'y', 'Chronological subdivision', 'Chronological subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '656', 'z', 'Geographic subdivision', 'Geographic subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', '2', 'Source of term', 'Source of term', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', 'a', 'Function', 'Function', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', 'v', 'Form subdivision', 'Form subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', 'x', 'General subdivision', 'General subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', 'y', 'Chronological subdivision', 'Chronological subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '657', 'z', 'Geographic subdivision', 'Geographic subdivision', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', '2', 'Source of term or code', 'Source of term or code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', 'a', 'Main curriculum objective', 'Main curriculum objective', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', 'b', 'Subordinate curriculum objective', 'Subordinate curriculum objective', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', 'c', 'Curriculum code', 'Curriculum code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '658', 'd', 'Correlation factor', 'Correlation factor', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '700', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '700', 'a', 'Nombre Personal', 'Nombre Personal', 0, 0, 'additionalauthors.author', 7, NULL, NULL, ''),
(1, 0, '700', 'b', 'Numeraci髇', 'Numeraci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '700', 'c', 'T韙ulos y otras palabras asociadas con el nombre', 'T韙ulos y otras palabras asociadas con el nombre', 1, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '700', 'd', 'Fechas asociadas con el nombre', 'Fechas asociadas con el nombre', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '700', 'e', 'T閞mino de relaci髇', 'T閞mino de relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '700', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'j', 'Attribution qualifier', 'Attribution qualifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '700', 'q', 'Forma completa del nombre', 'Forma completa del nombre', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '700', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '700', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '700', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '700', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'a', 'Personal name (NR)', 'Personal name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'b', 'Numeration (NR)', 'Numeration (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'c', 'Titles and other words  associated with a name  (R)', 'Titles and other words  associated with a name  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'd', 'Dates associated with a name (NR)', 'Dates associated with a name (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'e', 'Relator term (R)', 'Relator term (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'f', 'Date of a work (NR)', 'Date of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'g', 'Miscellaneous information (NR)', 'Miscellaneous information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'h', 'Medium (NR)', 'Medium (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'k', 'Form subheading (R)', 'Form subheading (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'l', 'Language of a work (NR)', 'Language of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'm', 'Medium of performance for music (R)', 'Medium of performance for music (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'n', 'Number of part/section of a work  (R)', 'Number of part/section of a work  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'o', 'Arranged statement for music (NR)', 'Arranged statement for music (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'p', 'Name of part/section of a work (R)', 'Name of part/section of a work (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 'r', 'Key for music (NR)', 'Key for music (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 's', 'Version (NR)', 'Version (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '705', 't', 'Title of a work (NR)', 'Title of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '710', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '710', 'a', 'Nombre corporativo o de jurisdicci髇 como entrada', 'Nombre corporativo o de jurisdicci髇 como entrada', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '710', 'b', 'Unidad subordinada', 'Unidad subordinada', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '710', 'c', 'Location of meeting', 'Location of meeting', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '710', 'e', 'Relaci髇', 'Relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '710', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '710', 't', 'T韙ulo del trabajo', 'T韙ulo del trabajo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '710', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '710', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', '4', 'C骴igo de relaci髇', 'C骴igo de relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '711', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '711', 'a', 'Nombre de la reuni髇 o de jurisdicci髇 como entrada', 'Nombre de la reuni髇 o de jurisdicci髇 como entrada', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '711', 'b', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '711', 'c', 'Localizaci髇 de la reuni髇', 'Localizaci髇 de la reuni髇', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '711', 'd', 'Fecha de la reuni髇 o firma del tratado', 'Fecha de la reuni髇 o firma del tratado', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '711', 'e', 'Unidad Subordinada', 'Unidad Subordinada', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '711', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 'n', 'N鷐ero de la parte/secci髇 del trabajo', 'N鷐ero de la parte/secci髇 del trabajo', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '711', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 'q', 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '711', 't', 'T韙ulo del trabajo', 'T韙ulo del trabajo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '711', 'u', 'Afiliaci髇', 'Afiliaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '711', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'a', 'Corporate name or jurisdiction name  (NR)', 'Corporate name or jurisdiction name  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'b', 'Subordinate unit (R)', 'Subordinate unit (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'e', 'Relator term (R)', 'Relator term (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'f', 'Date of a work (NR)', 'Date of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'g', 'Miscellaneous information (NR)', 'Miscellaneous information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'h', 'Medium (NR)', 'Medium (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'k', 'Form subheading (R)', 'Form subheading (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'l', 'Language of a work (NR)', 'Language of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'm', 'Medium of performance for music (R)', 'Medium of performance for music (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'n', 'Number of part/section/meeting (R)', 'Number of part/section/meeting (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'o', 'Arranged statement for music (NR)', 'Arranged statement for music (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'p', 'Name of part/section of a work (R)', 'Name of part/section of a work (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'r', 'Key for music (NR)', 'Key for music (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 's', 'Version (NR)', 'Version (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 't', 'Title of a work (NR)', 'Title of a work (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '715', 'u', 'Nonprinting information (NR)', 'Nonprinting information (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '720', '4', 'C骴igo de la relaci髇', 'C骴igo de la relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '720', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '720', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '720', 'a', 'Nombre', 'Nombre', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '720', 'e', 'Relaci髇', 'Relaci髇', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '730', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '730', 'a', 'T韙ulo uniforme', 'T韙ulo uniforme', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '730', 'd', 'Date of treaty signing', 'Date of treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'n', 'N鷐ero de la parte/secci髇 del trabajo', 'N鷐ero de la parte/secci髇 del trabajo', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '730', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'p', 'Nombre de una parte/secci髇 del trabajo', 'Nombre de una parte/secci髇 del trabajo', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '730', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '730', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '740', '5', 'Institution to which field applies See', 'Institution to which field applies See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '740', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '740', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '740', 'a', 'T韙ulo', 'T韙ulo', 0, 0, 'biblioitems.volumeddesc', 7, NULL, NULL, ''),
(0, 0, '740', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '740', 'n', 'N鷐ero de parte', 'N鷐ero de parte', 1, 0, 'biblioitems.volume', 7, NULL, NULL, ''),
(0, 0, '740', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '752', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '752', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(1, 0, '752', 'a', 'Pa韘', 'Pa韘', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '752', 'b', 'Estado, provincia, territorio', 'Estado, provincia, territorio', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '752', 'c', 'Pa韘, regi髇, 醨ea de islas', 'Pa韘, regi髇, 醨ea de islas', 0, 0, NULL, 7, NULL, NULL, ''),
(1, 0, '752', 'd', 'Ciudad', 'Ciudad', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '753', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '753', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '753', 'a', 'Make and model of machine', 'Make and model of machine', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '753', 'b', 'Programming language', 'Programming language', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '753', 'c', 'Operating system', 'Operating system', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '754', '2', 'Source of taxonomic identification', 'Source of taxonomic identification', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '754', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '754', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '754', 'a', 'Taxonomic name/taxonomic hierarchical category', 'Taxonomic name/taxonomic hierarchical category', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', '2', 'Source of term (NR)', 'Source of term (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', '3', 'Materials specified (NR)', 'Materials specified (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', 'a', 'Access term (NR)', 'Access term (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', 'x', 'General subdivision (R)', 'General subdivision (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', 'y', 'Chronological subdivision (R)', 'Chronological subdivision (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '755', 'z', 'Geographic subdivision (R)', 'Geographic subdivision (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '760', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '760', '7', 'Control subfield (NR)    0 - Type of main entry heading    1 - Form of name    2 - Type of record    3 - bibliographic level', 'Control subfield (NR)    0 - Type of main entry heading    1 - Form of name    2 - Type of record    3 - bibliographic level', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '760', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '760', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''), 
(0, 0, '760', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '760', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '760', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '760', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '760', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '760', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '760', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '760', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '762', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '762', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '762', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '762', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '762', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '762', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '762', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '762', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '762', 'h', 'Descripci髇 f韘ica', 'Descripci髇 f韘ica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '762', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '762', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '762', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '762', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '762', 'q', 'Parallel title (NR) (BK SE)  [OBSOLETE]', 'Parallel title (NR) (BK SE)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '762', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '762', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '762', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '762', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '762', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '765', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '765', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '765', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '765', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '765', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '765', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '765', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '765', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '765', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '765', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '765', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '765', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '765', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '765', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '765', 'q', 'Parallel title (NR) (BK SE)  [OBSOLETE]', 'Parallel title (NR) (BK SE)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '765', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '765', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '765', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '765', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '765', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '765', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '765', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '765', 'z', 'ISBN', 'ISBN', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '767', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '767', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '767', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '770', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '770', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '770', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '770', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '770', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '770', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '770', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '770', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '770', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '770', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '770', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '770', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '770', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '770', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '770', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '770', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '770', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '770', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '770', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '770', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '770', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '770', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '770', 'z', 'ISBN', 'ISBN', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '772', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '772', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '772', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '772', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '772', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '772', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '772', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '772', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '772', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '772', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '772', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '772', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '772', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '772', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '772', 'q', 'Parallel title (NR) (BK SE)  [OBSOLETE]', 'Parallel title (NR) (BK SE)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '772', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '772', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '772', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '772', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '772', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '772', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '772', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '772', 'z', 'ISBN', 'ISBN', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '773', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '773', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '773', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '773', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '773', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '773', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '773', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '773', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '773', 'p', 'Abbreviated title', 'Abbreviated title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '773', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '773', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '773', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '773', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '773', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '773', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '773', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '773', 'z', 'ISBN', 'ISBN', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '774', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '774', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '774', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '774', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '774', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '774', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '774', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '774', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '774', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '774', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '774', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '774', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '774', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '774', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '774', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '774', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '774', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '774', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '774', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '774', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '774', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '774', 'z', 'ISBN', 'ISBN', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '775', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'e', 'Language code', 'Language code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'f', 'Country code', 'Country code', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '775', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '776', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '777', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '777', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '777', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '777', 'a', 'Entrada principal de Serie', 'Entrada principal de Serie', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'b', 'Edici髇', 'Edici髇', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '777', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '777', 'd', 'Lugar, editorial y fecha de publicaci髇', 'Lugar, editorial y fecha de publicaci髇', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'g', 'Informaci髇 sobre relaciones', 'Informaci髇 sobre relaciones', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'h', 'Descripci髇 fisica', 'Descripci髇 fisica', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'i', 'Texto a desplegar', 'Texto a desplegar', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '777', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '777', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '777', 'n', 'Nota', 'Nota', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'o', 'Otro 韙em identificador', 'Otro 韙em identificador', 1, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '777', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '777', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '777', 't', 'T韙ulo', 'T韙ulo', 0, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'w', 'N鷐ero de Control del Registro', 'N鷐ero de Control del Registro', 1, 0, NULL, 7, NULL, NULL, ''),
(2, 0, '777', 'x', 'ISSN', 'ISSN', 0, 0, NULL, 7, NULL, NULL, ''),
(0, 0, '777', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '780', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '780', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'q', 'Parallel title (NR) (BK SE) [OBSOLETE]', 'Parallel title (NR) (BK SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '785', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '785', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'j', 'Period of content', 'Period of content', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'p', 'Abbreviated title', 'Abbreviated title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'v', 'Source Contribution', 'Source Contribution', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '786', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', '7', 'Control subfield', 'Control subfield', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'a', 'Main entry heading', 'Main entry heading', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'b', 'Edition', 'Edition', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'c', 'Qualifying information', 'Qualifying information', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'd', 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'g', 'Relationship information', 'Relationship information', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'h', 'Physical description', 'Physical description', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'i', 'Display text', 'Display text', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'k', 'Series data for related item', 'Series data for related item', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'm', 'Material-specific details', 'Material-specific details', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'n', 'Note', 'Note', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'o', 'Other item identifier', 'Other item identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'r', 'Report number', 'Report number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 's', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 't', 'Title', 'Title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'u', 'Standard Technical Report Number', 'Standard Technical Report Number', 0, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '787', 'x', 'International Standard Serial Number', 'International Standard Serial Number', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'y', 'CODEN designation', 'CODEN designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '787', 'z', 'International Standard Book Number', 'International Standard Book Number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', '4', 'Relator code', 'Relator code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', '8', 'Field link and sequence number  See', 'Field link and sequence number  See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'a', 'Personal name', 'Personal name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'b', 'Numeration', 'Numeration', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'c', 'Titles and other words associated with a name', 'Titles and other words associated with a name', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'd', 'Dates associated with a name', 'Dates associated with a name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'e', 'Relator term', 'Relator term', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'j', 'Attribution qualifier', 'Attribution qualifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'q', 'Fuller form of name', 'Fuller form of name', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'u', 'Affiliation', 'Affiliation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '800', 'v', 'Volume number/sequential designation', 'Volume number/sequential designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', '4', 'Relator code', 'Relator code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', '8', 'Field link and sequence number  See', 'Field link and sequence number  See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'c', 'Location of meeting', 'Location of meeting', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'e', 'Relator term', 'Relator term', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'u', 'Affiliation', 'Affiliation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '810', 'v', 'Volume number/sequential designation', 'Volume number/sequential designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', '4', 'Relator code', 'Relator code', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', '8', 'Field link and sequence number  See', 'Field link and sequence number  See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'a', 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'b', 'Number (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number (BK CF MP MU SE VM MX)  [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'c', 'Location of meeting', 'Location of meeting', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'd', 'Date of meeting', 'Date of meeting', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'e', 'Subordinate unit', 'Subordinate unit', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'q', 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'u', 'Affiliation', 'Affiliation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '811', 'v', 'Volume number/sequential designation', 'Volume number/sequential designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', '8', 'Field link and sequence number  See', 'Field link and sequence number  See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'a', 'Uniform title', 'Uniform title', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'd', 'Date of treaty signing', 'Date of treaty signing', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'f', 'Date of a work', 'Date of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'h', 'Medium', 'Medium', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'k', 'Form subheading', 'Form subheading', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'l', 'Language of a work', 'Language of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'm', 'Medium of performance for music', 'Medium of performance for music', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'o', 'Arranged statement for music', 'Arranged statement for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'r', 'Key for music', 'Key for music', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 's', 'Version', 'Version', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 't', 'Title of a work', 'Title of a work', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '830', 'v', 'Volume number/sequential designation', 'Volume number/sequential designation', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '840', 'a', 'Title (NR)', 'Title (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '840', 'h', 'Medium (NR)', 'Medium (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '840', 'v', 'Volume or number (NR)', 'Volume or number (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '841', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '841', 'a', 'Holding institution', 'Holding institution', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '850', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '850', 'a', 'Instituci髇 que tiene las existencias', 'Instituci髇 que tiene las existencias', 1, 0, NULL, 8, NULL, NULL, ''),
(0, 0, '850', 'b', 'Holdings (NR) (MU VM SE) [OBSOLETE]', 'Holdings (NR) (MU VM SE) [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '850', 'd', 'Inclusive dates (NR) (MU VM SE)  [OBSOLETE]', 'Inclusive dates (NR) (MU VM SE)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '850', 'e', 'Retention statement (NR) (CF MU VM SE)  [OBSOLETE]', 'Retention statement (NR) (CF MU VM SE)  [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', '3', 'Materials specified (NR)', 'Materials specified (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'a', 'Name (custodian or owner) (NR)', 'Name (custodian or owner) (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'b', 'Institutional division (NR)', 'Institutional division (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'c', 'Street address (NR)', 'Street address (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'd', 'Country (NR)', 'Country (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'e', 'Location of units (NR)', 'Location of units (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'f', 'Item number (NR)', 'Item number (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '851', 'g', 'Repository location code (NR)', 'Repository location code (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '852', '2', 'Fuente de clasificaci髇 o Esquema de almacenamiento en la estanteria', 'Fuente de clasificaci髇 o Esquema de almacenamiento en la estanteria', 0, 0, '', 8, '', '', ''),
(0, 0, '852', '3', 'Materials specified (NR)', 'Materials specified (NR)', 0, 0, '', -1, '', '', ''),
(0, 0, '852', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, '', -1, '', '', ''),
(0, 0, '852', '8', '', '', 1, 0, NULL, -1, '', '', ''),
(3, 0, '852', 'a', 'Localizaci髇', 'Localizaci髇', 0, 0, '', 8, '', '', ''),
(3, 0, '852', 'b', 'Sublocalizaci髇 o sub醨ea', 'Sublocalizaci髇 o sub醨ea', 1, 0, '', 8, '', '', ''),
(3, 0, '995', 't', 'Signatura Topogr&aacute;fica', 'Signatura Topogr&aacute;fica', 1, 0, 'items.bulk', 10, '', '', ''),
(0, 0, '852', 'e', 'Address', 'Address', 1, 0, '', -1, '', '', ''),
(0, 0, '852', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, '', -1, '', '', ''),
(0, 0, '852', 'g', 'Non-coded location qualifier (R)', 'Non-coded location qualifier (R)', 1, 0, '', -1, '', '', ''),
(3, 0, '852', 'h', 'Parte de la Clasificaci髇', 'Parte de la Clasificaci髇', 0, 0, 'biblioitems.classification', 8, '', '', ''),
(3, 0, '852', 'i', 'Parte del Item', 'Parte del Item', 1, 0, '', 8, '', '', ''),
(3, 0, '852', 'j', 'N鷐ero de control de almacenamiento/estanter韆', 'N鷐ero de control de almacenamiento/estanter韆', 0, 0, '', 8, '', '', ''),
(0, 0, '852', 'k', 'Call number prefix (NR)', 'Call number prefix (NR)', 0, 0, 'biblioitems.dewey', 8, '', '', ''),
(0, 0, '852', 'l', 'Shelving form of title (NR)', 'Shelving form of title (NR)', 0, 0, '', -1, '', '', ''),
(0, 0, '852', 'm', 'Call number suffix (NR)', 'Call number suffix (NR)', 0, 0, 'biblioitems.subclass', 8, '', '', ''),
(0, 0, '852', 'n', 'Country code (NR)', 'Country code (NR)', 0, 0, '', -1, '', '', ''),
(0, 0, '852', 'p', 'Piece designation (NR)', 'Piece designation (NR)', 0, 0, '', -1, '', '', ''),
(0, 0, '852', 'q', 'Piece physical condition (NR)', 'Piece physical condition (NR)', 0, 0, '', -1, '', '', ''),
(0, 0, '852', 's', 'Copyright article-fee code (R)', 'Copyright article-fee code (R)', 1, 0, '', -1, '', '', ''),
(3, 0, '852', 't', 'N鷐ero de copia', 'N鷐ero de copia', 0, 0, '', 8, '', '', ''),
(3, 0, '852', 'x', 'Nota no p鷅lica', 'Nota no p鷅lica', 1, 0, '', 8, '', '', ''),
(3, 0, '852', 'z', 'Nota p鷅lica', 'Nota p鷅lica', 1, 0, '', 8, '', '', ''),
(0, 0, '853', '2', 'Access method', 'Access method', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', '3', 'Materials specified', 'Materials specified', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', '6', 'Linkage See', 'Linkage See', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', '8', 'Field link and sequence number See', 'Field link and sequence number See', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'a', 'Host name', 'Host name', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'b', 'Access number', 'Access number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'c', 'Compression information', 'Compression information', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'd', 'Path', 'Path', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'f', 'Electronic name', 'Electronic name', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'h', 'Processor of request', 'Processor of request', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'i', 'Instruction', 'Instruction', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'j', 'Bits per second', 'Bits per second', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'k', 'Password', 'Password', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'l', 'Logon', 'Logon', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'm', 'Contact for access assistance', 'Contact for access assistance', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'n', 'Name of location of host', 'Name of location of host', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'o', 'Operating system', 'Operating system', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'p', 'Port', 'Port', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'q', 'Electronic format type', 'Electronic format type', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'r', 'Settings', 'Settings', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 's', 'File size', 'File size', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 't', 'Terminal emulation', 'Terminal emulation', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'v', 'Hours access method available', 'Hours access method available', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'w', 'Record control number', 'Record control number', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'y', 'Link text', 'Link text', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '853', 'z', 'Public note', 'Public note', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', '2', 'Access method (NR)', 'Access method (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', '3', 'Materials specified (NR)', 'Materials specified (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', '6', 'Linkage (NR)', 'Linkage (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'a', 'Host name (R)', 'Host name (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'b', 'Access number (R)', 'Access number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'c', 'Compression information (R)', 'Compression information (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'd', 'Path (R)', 'Path (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'f', 'Electronic name (R)', 'Electronic name (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'g', 'Uniform Resource Name (R) [OBSOLETE]', 'Uniform Resource Name (R) [OBSOLETE]', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'h', 'Processor of request (NR)', 'Processor of request (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'i', 'Instruction (R)', 'Instruction (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'j', 'Bits per second (NR)', 'Bits per second (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'k', 'Password (NR)', 'Password (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'l', 'Logon (NR)', 'Logon (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'm', 'Contact for access assistance (R)', 'Contact for access assistance (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'n', 'Name of location of host in subfield  (NR)', 'Name of location of host in subfield  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'o', 'Operating system (NR)', 'Operating system (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'p', 'Port (NR)', 'Port (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'q', 'Electronic format type (NR)', 'Electronic format type (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'r', 'Settings (NR)', 'Settings (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 's', 'File size (R)', 'File size (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 't', 'Terminal emulation (R)', 'Terminal emulation (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(2, 0, '856', 'u', 'Identificador Uniforme de Recurso (URI)', 'Identificador Uniforme de Recurso (URI)', 1, 0, 'biblioitems.url', 8, NULL, NULL, ''),
(0, 0, '856', 'v', 'Hours access method available (R)', 'Hours access method available (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '856', 'w', 'Record control number (R)', 'Record control number (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '856', 'x', 'Nota no p鷅lica', 'Nota no p鷅lica', 1, 0, NULL, 8, NULL, NULL, ''),
(0, 0, '856', 'y', 'Link text (R)', 'Link text (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '856', 'z', 'Nota p鷅lica', 'Nota p鷅lica', 1, 0, NULL, 8, NULL, NULL, ''),
(0, 0, '863', '8', '  (R)', '  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', '8', 'Field link and sequence number  (R)', 'Field link and sequence number  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'b', 'Home branch (NR)', 'Home branch (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'c', 'Cost (R)', 'Cost (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'd', 'Date acquired (R)', 'Date acquired (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'e', 'Source of acquisition (R)', 'Source of acquisition (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'j', 'Item status (R)', 'Item status (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'l', 'Temporary location (R)', 'Temporary location (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'p', 'Piece designation (R)', 'Piece designation (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '876', 'z', 'Note  (R)', 'Note  (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '880', '6', 'Linkage (NR) -z Same as associated field', 'Linkage (NR) -z Same as associated field', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '886', '2', 'Source of data (NR) -z - Foreign MARC subfield (R)', 'Source of data (NR) -z - Foreign MARC subfield (R)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '886', 'a', 'Tag of the foreign MARC field (NR)', 'Tag of the foreign MARC field (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(0, 0, '886', 'b', 'Content of the foreign MARC field  (NR)', 'Content of the foreign MARC field  (NR)', 0, 0, NULL, -1, NULL, NULL, ''),
(3, 1, '995', 'd', 'Unidad de Informaci&oacute;n de Origen', 'Unidad de Informaci&oacute;n de Origen', 1, 0, 'items.homebranch', 10, 'branches', '', ''),
(3, 0, '995', 'f', 'C&oacute;digo de Barras', 'C&oacute;digo de Barras', 1, 0, 'items.barcode', 10, '', '', ''),
(3, 0, '995', 'm', 'Fecha de acceso', 'Fecha de acceso', 1, 0, 'items.dateaccessioned', 10, '', '', ''),
(3, 1, '995', 'o', 'Disponibilidad', 'Disponibilidad', 1, 0, 'items.notforloan', 10, 'loan', '', ''),
(3, 0, '995', 's', 'Koha item number', 'Koha item number', 1, 0, 'items.itemnumber', -1, '', '', ''),
(3, 0, '995', 'u', 'Notas del item', 'Notas del item', 1, 0, 'items.itemnotes', 10, '', '', ''),
(3, 1, '995', 'c', 'Unidad de Informaci&oacute;n', 'Unidad de Informaci&oacute;n', 0, 0, 'items.holdingbranch', 10, 'branches', '', ''),
(0, 0, '043', 'b', 'C骴igo Local GAC (R)', 'C骴igo Local GAC (R)', 1, 0, NULL, -1, NULL, NULL, ''),
(3, 0, '995', 'a', 'Nombre del vendedor', 'Nombre del vendedor', 0, 0, 'items.booksellerid', 10, '', '', ''),
(3, 0, '995', 'p', 'Precio de compra', 'Precio de compra', 0, 0, 'items.price', 10, '', '', ''),
(0, 0, '995', 'r', 'Precio de reemplazo', 'Precio de reemplazo', 0, 0, 'items.replacementprice', 10, '', '', ''),
(2, 1, '910', 'a', 'Tipo de documento', 'Tipo de documento', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', NULL, NULL),
(3, 1, '995', 'e', 'Estado', 'Estado', 0, 0, 'items.wthdrawn', 10, 'wthdrawn', '', ''),
(0, 0, '000', '@', 'LEADER', 'LEADER', 0, 0, '', 0, '', '', 'marc21_leader.pl'),
(2, 0, '900', 'b', 'nivel bibliografico', 'nivel bibliografico', 0, 0, NULL, NULL, NULL, NULL, NULL);");
$marc6->execute();
#################################################################################
}

	#########################################################################
	#			GRACIAS!!!!!!!!!!				#
	#########################################################################

