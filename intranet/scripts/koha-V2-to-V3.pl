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


crearRelacionKohaMarc();
crearTablasNecesarias();
=cut
#################
procesarV2_V3();
#################
#Referencias
crearNuevasReferencias();
repararReferencias();
quitarReferenciasViejas();
##
quitarTablasDeMas();
pasarTodoAInnodb();
crearClaves();
=cut

#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------FUNCIONES---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------#-----------------------------------------------------------------------------------------------------------------------------------
	
	sub procesarV2_V3 {

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
 }
$biblios->finish();
#---------------------------------------FIN NIVEL1---------------------------------------#

	}

	sub repararReferencias {
	#########################################################################
	#			REPARAR REFERENCIAS!!!!!			#
	#########################################################################

	#############1111111111111111111111111111111111111111111111##############
	my $niveles1=$dbh->prepare("SELECT * FROM nivel1 ;");
	$niveles1->execute();

	while (my $nivel1=$niveles1->fetchrow_hashref ) {

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

	sub crearRelacionKohaMarc {
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
(4, 'nivel2', 'anio_publicacion', 'año publicacion', '260', 'c'),
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
(25, 'biblio', 'seriestitle', 'Número de Clasificación Decimal Universal', '080', 'a'),
(26, 'biblio', 'title', 'Título', '245', 'a'),
(27, 'biblio', 'unititle', 'Resto del título', '245', 'b'),
(30, 'biblioitems', 'dewey', 'Call number prefix (NR)', '852', 'k'),
(31, 'biblioitems', 'idCountry', 'Código ISO (R)', '043', 'c'),
(33, 'biblioitems', 'illus', 'Otros detalles físicos', '300', 'b'),
(34, 'biblioitems', 'issn', 'ISSN', '022', 'a'),
(35, 'biblioitems', 'itemtype', 'Tipo de documento', '910', 'a'),
(36, 'biblioitems', 'lccn', 'LC control number', '010', 'a'),
(37, 'biblioitems', 'notes', 'Nota General', '500', 'a'),
(38, 'biblioitems', 'number', 'Mención de edición', '250', 'a'),
(39, 'biblioitems', 'pages', 'Extensión', '300', 'a'),
(40, 'biblioitems', 'place', 'Lugar de publicación, distribución, etc.', '260', 'a'),
(41, 'biblioitems', 'publicationyear', 'Fecha de publicación, distribución, etc.', '260', 'c'),
(42, 'biblioitems', 'seriestitle', 'Título', '440', 'a'),
(43, 'biblioitems', 'size', 'Dimensiones', '300', 'c'),
(44, 'biblioitems', 'subclass', 'Call number suffix (NR)', '852', 'm'),
(45, 'biblioitems', 'url', 'Identificador Uniforme de Recurso (URI)', '856', 'u'),
(46, 'biblioitems', 'volume', 'Number of part/section of a work', '740', 'n'),
(47, 'biblioitems', 'volumeddesc', 'Título', '740', 'a'),
(48, 'bibliosubject', 'subject', 'Tópico o nombre geográfico', '650', 'a'),
(49, 'bibliosubtitle', 'subtitle', 'Título propiamente dicho/Título corto', '246', 'a'),
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

	sub crearTablasNecesarias {
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
	
	sub quitarTablasDeMas {
	#########################################################################
	#			QUITAR TABLAS DE MAS!!!				#
	#########################################################################
	my @drops = ('additionalauthors', 'aqbookfund', 'aqbooksellers', 'aqbudget', 'aqorderbreakdown', 'aqorderdelivery', 'aqorders', 'biblio', 'biblioitems', 'bibliosubject', 'bibliosubtitle', 'bibliothesaurus', 'borexp', 'branchtransfers', 'catalogueentry', 'categoryitem', 'currency', 'defaultbiblioitem', 'deletedbiblio', 'deletedbiblioitems', 'deleteditems', 'ethnicity', 'isbns', 'isomarc', 'items', 'itemsprices', 'printers', 'publisher', 'reserveconstraints', 'statistics', 'virtual_itemtypes','virtual_request', 'marc_subfield_table');

	my $drop=$dbh->prepare("DROP TABLE ? ;");
	foreach $tabla (@drops){$drop->execute($tabla);}
	}

	sub pasarTodoAInnodb {
	#########################################################################
	#			PASAR TODO A INNODB				#
	#########################################################################
	my @innodbs = ('analyticalauthors','analyticalkeyword','analyticalsubject','authorised_values','autores','availability','biblioanalysis','bibliolevel','bookshelf','borrowers','branchcategories','branches','branchrelations','busquedas','categories','colaboradores','countries','deletedborrowers','dptos_partidos','feriados','generic_report_joins','generic_report_tables','historialBusqueda','historicCirculation','historicIssues','historicSanctions','informacion_referencias','iso2709','issues','issuetypes','itemtypes','keyword','languages','localidades','marc_blob_subfield','marc_breeding','marc_subfield_structure','marc_tag_structure','marc_word','marcrecorddone','modificaciones','persons','provincias','referenciaColaboradores','reserves','sanctionissuetypes','sanctionrules','sanctions','sanctiontypes','sanctiontypesrules','sessionqueries','sessions','shelfcontents','stopwords','supports','systempreferences','tablasDeReferencias','tablasDeReferenciasInfo','temas','unavailable','uploadedmarc','userflags','users','z3950queue','z3950results','z3950servers');
	my $innodb=$dbh->prepare("ALTER TABLE ? ENGINE = innodb;");
	foreach $tabla (@innodbs){$innodb->execute($tabla);}
	}

	sub crearClaves {
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


	#########################################################################
	#			GRACIAS!!!!!!!!!!				#
	#########################################################################

