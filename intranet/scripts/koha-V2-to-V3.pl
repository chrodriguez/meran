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

######Primero agrego las tablas nuevas######
my $tablas=$dbh->prepare("
CREATE TABLE `nivel1` (
  `id1` int(11) NOT NULL auto_increment,
  `titulo` varchar(100) NOT NULL,
  `autor` int(11) NOT NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id1`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1  ;

CREATE TABLE `nivel1_repetibles` (
  `rep_n1_id` int(11) NOT NULL auto_increment,
  `id1` int(11) NOT NULL,
  `campo` varchar(3) default NULL,
  `subcampo` varchar(3) NOT NULL,
  `dato` varchar(250) NOT NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`rep_n1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

CREATE TABLE `nivel2` (
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1  ;

CREATE TABLE `nivel2_repetibles` (
  `rep_n2_id` int(11) NOT NULL auto_increment,
  `id2` int(11) NOT NULL,
  `campo` varchar(3) default NULL,
  `subcampo` varchar(3) NOT NULL,
  `dato` varchar(250) default NULL,
  `timestamp` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`rep_n2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

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

$tablas->execute();

	#########################################################################
	#			NUEVAS REFERENCIAS!!!!!				#
	#########################################################################
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
	my $av1=$dbh->prepare("ALTER TABLE `availability` ADD `id1` INT( 11 ) NOT NULL FIRST ;");
	$av1->execute();

	my $hi1=$dbh->prepare("ALTER TABLE `historicIssues` ADD `id3` INT( 11 ) NOT NULL FIRST ;");
	$hi1->execute();

	my $hc1=$dbh->prepare("ALTER TABLE `historicCirculation` ADD `id1` INT( 11 ) NOT NULL AFTER `id` ,
		ADD `id2` INT( 11 ) NOT NULL AFTER `id1` ,
		ADD `id3` INT( 11 ) NOT NULL AFTER `id2` ;");

	my $is1=$dbh->prepare("ALTER TABLE `issues` ADD `id3` INT( 11 ) NOT NULL FIRST ;");
	#Los 3 Niveles#
	my $mod=$dbh->prepare("ALTER TABLE `modificaciones` ADD `id` INT( 11 ) NOT NULL AFTER `numero` ;");
	$mod->execute();
	#########################################################################
	#			FIN NUEVAS REFERENCIAS!!!!!			#
	#########################################################################

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
	push (@N2,$n2);	my $estantes2=$dbh->prepare(" UPDATE shelfcontents SET id2 = ? where biblioitemnumber= ?;");

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
		push(@ids1,$_->{'campo'}.",".$_->{'subcampo'});
		push(@valores1,$biblio->{$_->{'campoTabla'}});
	}
	
	###########################OTRAS TABLA biblio##########################
	# subject
	my $temas=$dbh->prepare("SELECT * FROM bibliosubject where biblionumber= ?;");
	$temas->execute($biblio->{'biblionumber'});
	
	while (my $biblosubject=$temas->fetchrow_hashref ) {
		push(@ids1,$subject->{'campo'}.",".$subject->{'subcampo'});
		push(@valores1,$biblosubject->{$subject->{'campoTabla'}});
		}
	$temas->finish();

	# subtitle
	my $subtitulos=$dbh->prepare("SELECT * FROM bibliosubtitle where biblionumber= ?;");
	$subtitulos->execute($biblio->{'biblionumber'});
	
	while (my $biblosubtitle=$subtitulos->fetchrow_hashref ) {
		push(@ids1,$subtitle->{'campo'}.",".$subtitle->{'subcampo'});
		push(@valores1,$biblosubtitle->{$subtitle->{'campoTabla'}});
		}
	$subtitulos->finish();

	# additionalauthor
	
	my $additionalauthors=$dbh->prepare("SELECT * FROM additionalauthors where biblionumber= ?;");
	$additionalauthors->execute($biblio->{'biblionumber'});
	
	while (my $aauthors=$additionalauthors->fetchrow_hashref ) {
		push(@ids1,$additionalauthor->{'campo'}.",".$additionalauthor->{'subcampo'});
		push(@valores1,$aauthors->{$additionalauthor->{'campoTabla'}});
		}
	$additionalauthors->finish();	

	#########################################################################
	my($error,$codMsg);
	($id1,$error,$codMsg)=&guardarNivel1($autor,\@ids1,\@valores1);

	#########################################################################
	#			REFERENCIAS A NIVEL 1 (biblio)			#
	#				colaboradores				#
	#########################################################################
	my $col2=$dbh->prepare("UPDATE colaboradores SET id1 = ? where biblionumber= ?;");
	$col2->execute($id1,$biblio->{'biblionumber'});
	$col2->finish();

	my $mod1=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Libro' and numero = ?;");
	$mod1->execute($id1,$biblio->{'biblionumber'});
	$mod1->finish();
	#########################################################################
	#		FIN REFERENCIAS A NIVEL 1 (biblio)			#
	#########################################################################
#---------------------------------------FIN NIVEL1---------------------------------------#	

#---------------------------------------NIVEL2---------------------------------------#
	my $biblioitems=$dbh->prepare("SELECT * FROM biblioitems where biblionumber= ?;");
	$biblioitems->execute($biblio->{'biblionumber'});
	while (my $biblioitem=$biblioitems->fetchrow_hashref ) {
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



	($id2,$tipoDocN2,$error,$codMsg)=&guardarNivel2($id1,\@ids2,\@valores2);

	#########################################################################
	#		REFERENCIAS A NIVEL 2 (biblioitemnumber)		#
	#			biblioanalysis					#
	#			reserves					#
	#			shelfcontents					#
	#########################################################################
	my $banalysis2=$dbh->prepare("UPDATE biblioanalysis SET id1 = ? and id2 = ? where biblionumber= ? and biblioitemnumber= ?;");
	$banalysis2->execute($id1,$id2,$biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'});
	$banalysis2->finish();

	my $reserves2=$dbh->prepare("UPDATE reserves SET id2 = ? where biblioitemnumber= ? and itemnumber is NULL;");
	$reserves2->execute($id2,$biblioitem->{'biblioitemnumber'});
	$reserves2->finish();

	my $estantes2=$dbh->prepare(" UPDATE shelfcontents SET id2 = ? where biblioitemnumber= ?;");
	$estantes2->execute($id2,$biblioitem->{'biblioitemnumber'}); 
	$estantes2->finish();

	my $mod2=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Grupo' and numero = ?;");
	$mod2->execute($id2,$biblioitem->{'biblioitemnumber'});
	$mod2->finish();

	#########################################################################
	#		FIN REFERENCIAS A NIVEL 2 (biblioitemnumber)		#
	#########################################################################

#---------------------------------------NIVEL3---------------------------------------#	

	my $items=$dbh->prepare("SELECT * FROM items where biblioitemnumber= ?;");
	$items->execute($biblioitem->{'biblioitemnumber'});
	while (my $item=$items->fetchrow_hashref ) {
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
	
	($id3,$error,$codMsg)=&guardarNivel3($id1,$id2,$item->{'barcode'},1,$tipoDocN2,\@ids3,\@valores3);


	#########################################################################
	#		REFERENCIAS A NIVEL 3 (itemnumber)			#
	#			availability					#
	#			historicIssues					#
	#			historicCirculation				#
	#			issues						#
	#			reserves						#
	#########################################################################
	my $av2=$dbh->prepare(" UPDATE availability SET id3 = ? where item = ?;");
	$av2->execute($id3,$item->{'itemnumber'}); 
	$av2->finish();

	my $hi2=$dbh->prepare(" UPDATE historicIssues SET id3 = ? where itemnumber = ?;");
	$hi2->execute($id3,$item->{'itemnumber'}); 
	$hi2->finish();

	my $hc2=$dbh->prepare(" UPDATE historicCirculation SET id1 = ? , id2 = ? , id3 = ? where biblionumber= ? and biblioitemnumber= ? and itemnumber = ?;");
	$hc2->execute($id1,$id2,$id3,$biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},$item->{'itemnumber'}); 
	$hc2->finish();

	my $is2=$dbh->prepare(" UPDATE issues SET id3 = ? where itemnumber = ?;");
	$is2->execute($id3,$item->{'itemnumber'}); 
	$is2->finish();

	my $reserves3=$dbh->prepare("UPDATE reserves SET id2 = ? , id3 = ?  where biblioitemnumber = ? and itemnumber = ?;");
	$reserves3->execute($id2,$id3,$biblioitem->{'biblioitemnumber'},$item->{'itemnumber'});
	$reserves3->finish();

	my $mod3=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Ejemplar' and numero = ?;");
	$mod3->execute($id3,$item->{'itemnumber'});
	$mod3->finish();

	#########################################################################
	#		FIN REFERENCIAS A NIVEL 3 (itemnumber)			#
	#########################################################################




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
	
	#########################################################################
	#			CONTROL DE AUTORIDADES				#
	#########################################################################

my $control_autoridades=$dbh->prepare("
CREATE TABLE `control_autores_seudonimos` (
  `id` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`,`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `control_autores_sinonimos` (
  `id` int(11) NOT NULL,
  `autor` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`autor`),
  KEY `autor` (`autor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `control_editoriales_seudonimos` (
  `id` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`,`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `control_temas_seudonimos` (
  `id` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`,`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `control_temas_sinonimos` (
  `id` int(11) NOT NULL auto_increment,
  `tema` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`tema`),
  KEY `tema` (`tema`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
");
$control_autoridades->execute();


	#########################################################################
	#			QUITAR TABLAS DE MAS!!!				#
	#########################################################################



	#########################################################################
	#			GRACIAS!!!!!!!!!!				#
	#########################################################################

