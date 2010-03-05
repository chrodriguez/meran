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

print "Creando tablas necesarias \n";
   crearTablasNecesarias();

print "Creando nuevas referencias \n";
   crearNuevasReferencias();

#################
print "Procesando los 3 niveles (va a tardar!!! ...MUCHO!!! mas de lo que te imaginas) \n";
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
# ##


print "Renombrando tablas \n";
 renombrarTablas();
print "Quitando tablas de mas \n";
quitarTablasDeMas();
print "Hasheando passwords \n";
  hashearPasswords();
print "Relacion usuario-persona \n";
 crearRelacionUsuarioPersona();
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
    sub buscarLocalidadParecida 
    { my ($localidad) = @_;
      my $loc=$dbh->prepare("SELECT id  FROM localidades where nombre sounds like ? ;");
         $loc->execute($localidad);
      my $id=$loc->fetchrow;
        $loc->finish();
      return $id;
    }

    sub buscarLocalidadDesdeId
    { my ($idlocalidad) = @_;
      if($idlocalidad){
      my $loc=$dbh->prepare("SELECT id  FROM ref_localidad where localidad = ? ;");
         $loc->execute($idlocalidad);
      my $id=$loc->fetchrow;
        $loc->finish();
      return $id;}
      else {
        return '';
      }
    }

	sub procesarV2_V3 
	{
	

    my $id1_nuevo;
    my $id2_nuevo;
    my $id3_nuevo;

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
 	print "Procesando registro: $registro de $cantidad ($porcentaje%) \r";



#---------------------------------------NIVEL1---------------------------------------#


	foreach (@N1) {
		my $dn1;
		$dn1->{'campo'}=$_->{'campo'};
		$dn1->{'subcampo'}=$_->{'subcampo'};
        
        if($_->{'campoTabla'} eq 'author'){ $dn1->{'valor'}='cat_autor@'.$biblio->{$_->{'campoTabla'}}; }
          else { $dn1->{'valor'}=$biblio->{$_->{'campoTabla'}};}

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
		push (@ar1,$biblosubject->{'cat_tema@'.$subject->{'campoTabla'}});
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
	push(@ar1,'cat_autor@'.$aauthors->{$additionalauthor->{'campoTabla'}});
	}
	$dn1->{'simple'}=0;
	$dn1->{'valor'}=\@ar1;
	push(@ids1,$dn1);
	$additionalauthors->finish();

	#########################################################################
	my($error,$codMsg);
	$id1_nuevo=&guardaNivel1MARC($biblio->{'biblionumber'},\@ids1);

#---------------------------------------FIN NIVEL1---------------------------------------#	

#---------------------------------------NIVEL2---------------------------------------#
	my $biblioitems=$dbh->prepare("SELECT * FROM biblioitems where biblionumber= ?;");
	$biblioitems->execute($biblio->{'biblionumber'});
	while (my $biblioitem=$biblioitems->fetchrow_hashref ) {
	foreach (@N2) {
		my $dn2;
		$dn2->{'campo'}=$_->{'campo'};
		$dn2->{'subcampo'}=$_->{'subcampo'};

        if($_->{'campoTabla'} eq 'itemtype'){ $dn2->{'valor'}='cat_ref_tipo_nivel3@'.$biblioitem->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'idLanguage'){ $dn2->{'valor'}='ref_idioma@'.$biblioitem->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'idCountry'){ $dn2->{'valor'}='ref_pais@'.$biblioitem->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'place'){ #Esto no se puede pasar sin buscar la referencia
#                     my $idLocalidad= buscarLocalidadParecida($biblioitem->{$_->{'campoTabla'}});
#                     $dn2->{'valor'}='ref_localidad@'.$idLocalidad; 
                      $dn2->{'valor'}='ref_localidad@'.$biblioitem->{$_->{'campoTabla'}};
              } 
        elsif($_->{'campoTabla'} eq 'idSupport'){ $dn2->{'valor'}='ref_soporte@'.$biblioitem->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'classification'){ $dn2->{'valor'}='ref_nivel_bibliografico@'.$biblioitem->{$_->{'campoTabla'}}; }
          else { $dn2->{'valor'}=$biblioitem->{$_->{'campoTabla'}}; }

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

	$id2_nuevo=&guardaNivel2MARC($biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},$id1_nuevo,\@ids2);

#---------------------------------------NIVEL3---------------------------------------#	

	my $items=$dbh->prepare("SELECT * FROM items where biblioitemnumber= ?;");
	$items->execute($biblioitem->{'biblioitemnumber'});
	while (my $item=$items->fetchrow_hashref ) {
	foreach (@N3) {
		my $dn3;
		$dn3->{'campo'}=$_->{'campo'};
		$dn3->{'subcampo'}=$_->{'subcampo'};

		my $val='';

        if($_->{'campoTabla'} eq 'notforloan'){   $val='ref_disponibilidad@'.$item->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'homebranch'){$val='pref_unidad_informacion@'.$item->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'wthdrawn'){ if ($item->{$_->{'campoTabla'}}){$val='ref_estado@'.$item->{$_->{'campoTabla'}};}
                                                    else {$val='ref_estado@0';} #Esta disponible
                                                 }
        elsif($_->{'campoTabla'} eq 'holdingbranch'){ $val='pref_unidad_informacion@'.$item->{$_->{'campoTabla'}}; }
          else { $val=$item->{$_->{'campoTabla'}}; }


		$dn3->{'valor'}=$val;
		$dn3->{'simple'}=1;
		if (($dn3->{'valor'} ne '') && ($dn3->{'valor'} ne null)){push(@ids3,$dn3);}
	}
	
	$id3_nuevo=&guardaNivel3MARC($biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},$item->{'itemnumber'},$id1_nuevo,$id2_nuevo,\@ids3);


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

	my $cant_nivel1=$dbh->prepare("SELECT count(*) as cantidad FROM cat_registro_marc_n1 ;");
	$cant_nivel1->execute();
	my $cantidad=$cant_nivel1->fetchrow;
	my $registro=1;
	print "Se van a procesar $cantidad registros \n";


	#############1111111111111111111111111111111111111111111111##############
	my $niveles1=$dbh->prepare("SELECT * FROM cat_registro_marc_n1 ;");
	$niveles1->execute();

	while (my $nivel1=$niveles1->fetchrow_hashref ) {
	my $porcentaje= int (($registro * 100) / $cantidad );
# 	print "Procesando registro: $registro de $cantidad ($porcentaje%) \n";

	#########################################################################
	#			REFERENCIAS A NIVEL 1 (biblio)			#
	#				colaboradores				#
	#########################################################################
	my $col2=$dbh->prepare("UPDATE colaboradores SET id1 = ? where biblionumber= ?;");
	$col2->execute($nivel1->{'id'},$nivel1->{'biblionumber'});
	$col2->finish();

	my $mod1=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Libro' and numero = ?;");
	$mod1->execute($nivel1->{'id'},$nivel1->{'biblionumber'});
	$mod1->finish();
	
	#########################################################################
	#		FIN REFERENCIAS A NIVEL 1 (biblio)			#
	#########################################################################

	#############2222222222222222222222222222222222222222222222##############
	my $niveles2=$dbh->prepare("SELECT * FROM cat_registro_marc_n2 where id1 = ? ;");
	$niveles2->execute($nivel1->{'id'});

	while (my $nivel2=$niveles2->fetchrow_hashref ) {

	#########################################################################
	#		REFERENCIAS A NIVEL 2 (biblioitemnumber)		#
	#			biblioanalysis					#
	#			reserves					#
	#			shelfcontents					#
	#########################################################################
	my $banalysis2=$dbh->prepare("UPDATE biblioanalysis SET id1 = ? , id2 = ? where biblionumber= ? and biblioitemnumber= ?;");
	$banalysis2->execute($nivel1->{'id'},$nivel2->{'id'},$nivel1->{'biblionumber'},$nivel2->{'biblioitemnumber'});
	$banalysis2->finish();

	my $reserves2=$dbh->prepare("UPDATE reserves SET id2 = ? where biblioitemnumber= ? and itemnumber is NULL;");
	$reserves2->execute($nivel2->{'id'},$nivel2->{'biblioitemnumber'});
	$reserves2->finish();

	my $estantes2=$dbh->prepare(" UPDATE shelfcontents SET id2 = ? where biblioitemnumber= ?;");
	$estantes2->execute($nivel2->{'id'},$nivel2->{'biblioitemnumber'}); 
	$estantes2->finish();

	my $mod2=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Grupo' and numero = ?;");
	$mod2->execute($nivel2->{'id'},$nivel2->{'biblioitemnumber'});
	$mod2->finish();

	#########################################################################
	#		FIN REFERENCIAS A NIVEL 2 (biblioitemnumber)		#
	#########################################################################

	#############3333333333333333333333333333333333333333333333##############
	my $niveles3=$dbh->prepare("SELECT * FROM cat_registro_marc_n3 where id1 = ? and id2 = ? ;");
	$niveles3->execute($nivel1->{'id'},$nivel2->{'id'});

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
	$av2->execute($nivel3->{'id'},$nivel3->{'itemnumber'}); 
	$av2->finish();

	my $hi2=$dbh->prepare(" UPDATE historicIssues SET id3 = ? where itemnumber = ?;");
	$hi2->execute($nivel3->{'id'},$nivel3->{'itemnumber'}); 
	$hi2->finish();

	my $hc2=$dbh->prepare(" UPDATE historicCirculation SET id1 = ? , id2 = ? , id3 = ? where biblionumber= ? and biblioitemnumber= ? and itemnumber = ?;");
	$hc2->execute($nivel3->{'id1'},$nivel3->{'id2'},$nivel3->{'id'},$nivel3->{'biblionumber'},$nivel3->{'biblioitemnumber'},$nivel3->{'itemnumber'}); 
	$hc2->finish();

	my $is2=$dbh->prepare(" UPDATE issues SET id3 = ? where itemnumber = ?;");
	$is2->execute($nivel3->{'id'},$nivel3->{'itemnumber'}); 
	$is2->finish();

	my $reserves3=$dbh->prepare("UPDATE reserves SET id2 = ? , id3 = ?  where biblioitemnumber = ? and itemnumber = ?;");
	$reserves3->execute($nivel3->{'id2'},$nivel3->{'id'},$nivel3->{'biblioitemnumber'},$nivel3->{'itemnumber'});
	$reserves3->finish();

	my $mod3=$dbh->prepare("UPDATE modificaciones SET id = ? where tipo = 'Ejemplar' and numero = ?;");
	$mod3->execute($nivel3->{'id'},$nivel3->{'itemnumber'});
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
	my $rn1=$dbh->prepare("ALTER TABLE cat_registro_marc_n1 ADD biblionumber INT( 11 ) NOT NULL FIRST ;");
	$rn1->execute();

	my $rn2=$dbh->prepare("ALTER TABLE cat_registro_marc_n2 ADD biblionumber INT( 11 ) NOT NULL FIRST,
				ADD biblioitemnumber INT( 11 ) NOT NULL AFTER biblionumber;");
	$rn2->execute();

	my $rn3=$dbh->prepare("ALTER TABLE cat_registro_marc_n3 ADD biblionumber INT( 11 ) NOT NULL FIRST ,
		ADD biblioitemnumber INT( 11 ) NOT NULL AFTER biblionumber ,
		ADD itemnumber INT( 11 ) NOT NULL AFTER biblioitemnumber ;");
	$rn3->execute();
	#
	
	#Nivel 1#
	my $col=$dbh->prepare("ALTER TABLE `colaboradores` ADD `id1` INT( 11 ) NOT NULL FIRST ;");
   	$col->execute();

    my $adaut=$dbh->prepare("ALTER TABLE additionalauthors ADD `id1` INT( 11 ) NOT NULL FIRST ;");
    $adaut->execute();

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

    my $loc1=  $dbh->prepare("ALTER TABLE localidades DROP PRIMARY KEY;");
    $loc1->execute();
    my $loc2=  $dbh->prepare("ALTER TABLE localidades ADD `id` INT NOT NULL AUTO_INCREMENT FIRST ,ADD PRIMARY KEY ( id );");
    $loc2->execute();
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
	my $rmn1=$dbh->prepare("ALTER TABLE cat_registro_marc_n1 DROP biblionumber ;");
	$rmn1->execute();
	my $rmn2=$dbh->prepare("ALTER TABLE cat_registro_marc_n2 DROP biblionumber, DROP biblioitemnumber;");
	$rmn2->execute();
	my $rmn3=$dbh->prepare("ALTER TABLE cat_registro_marc_n3 DROP biblionumber, DROP biblioitemnumber, DROP itemnumber;");
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

	my $res2=$dbh->prepare("ALTER TABLE `reserves` DROP `priority` , DROP `found` , DROP `itemnumber` ;");
	$res2->execute();

	#########################################################################
	#			FIN QUITAR REFERENCIAS VIEJAS!!!!!		#
	#########################################################################

	}

	sub crearTablasNecesarias 
	{
	#########################################################################
	#			CREAR TABLAS NECESARIAS!!!			#
	#########################################################################

    my $dropear=$dbh->prepare("DROP TABLE IF EXISTS `cat_registro_marc_n3` ,`cat_registro_marc_n2`, `cat_registro_marc_n1`;");
    $dropear->execute();

    my @sqls=("DROP TABLE IF EXISTS `cat_control_seudonimo_autor`;",
"CREATE TABLE IF NOT EXISTS `cat_control_seudonimo_autor` (
  `id_autor` int(11) NOT NULL,
  `id_autor_seudonimo` int(11) NOT NULL,
  PRIMARY KEY  (`id_autor`,`id_autor_seudonimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_control_seudonimo_editorial`;",
"CREATE TABLE IF NOT EXISTS `cat_control_seudonimo_editorial` (
  `id_editorial` int(11) NOT NULL,
  `id_editorial_seudonimo` int(11) NOT NULL,
  PRIMARY KEY  (`id_editorial`,`id_editorial_seudonimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_control_seudonimo_tema`;",
"CREATE TABLE IF NOT EXISTS `cat_control_seudonimo_tema` (
  `id_tema` int(11) NOT NULL,
  `id_tema_seudonimo` int(11) NOT NULL,
  PRIMARY KEY  (`id_tema`,`id_tema_seudonimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_control_sinonimo_autor`;",
"CREATE TABLE IF NOT EXISTS `cat_control_sinonimo_autor` (
  `id` int(11) NOT NULL,
  `autor` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`autor`),
  KEY `autor` (`autor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_control_sinonimo_editorial`;",
"CREATE TABLE IF NOT EXISTS `cat_control_sinonimo_editorial` (
  `id` int(11) NOT NULL,
  `editorial` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`editorial`),
  KEY `editorial` (`editorial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_control_sinonimo_tema`;",
"CREATE TABLE IF NOT EXISTS `cat_control_sinonimo_tema` (
  `id` int(11) NOT NULL auto_increment,
  `tema` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`,`tema`),
  KEY `tema` (`tema`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_encabezado_campo_opac`;",
"CREATE TABLE IF NOT EXISTS `cat_encabezado_campo_opac` (
  `idencabezado` int(11) NOT NULL auto_increment,
  `nombre` varchar(255) NOT NULL,
  `orden` int(11) NOT NULL,
  `linea` tinyint(1) NOT NULL default '0',
  `nivel` tinyint(1) NOT NULL,
  `visible` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`idencabezado`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
"INSERT  INTO `cat_encabezado_campo_opac` (`idencabezado`, `nombre`, `orden`, `linea`, `nivel`, `visible`) VALUES
(1, 'Encabezado 1', -1, 0, 2, 1),
(2, 'Encabezado 3', 0, 0, 3, 1),
(3, 'Encabezado 2', 0, 0, 2, 1),
(4, 'Encabezado Nivel 1', 0, 0, 1, 1);",
"DROP TABLE IF EXISTS `cat_encabezado_item_opac`;",
"CREATE TABLE IF NOT EXISTS `cat_encabezado_item_opac` (
  `idencabezado` int(11) NOT NULL default '0',
  `itemtype` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`idencabezado`,`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"INSERT  INTO `cat_encabezado_item_opac` (`idencabezado`, `itemtype`) VALUES
(1, 'ACT'),
(1, 'LIB'),
(2, 'ACT'),
(2, 'LIB'),
(3, 'LIB'),
(4, 'LIB');",
"DROP TABLE IF EXISTS `cat_estructura_catalogacion`;",
"CREATE TABLE IF NOT EXISTS `cat_estructura_catalogacion` (
  `id` int(11) NOT NULL auto_increment,
  `campo` char(3) NOT NULL,
  `subcampo` char(1) NOT NULL,
  `itemtype` varchar(4) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL,
  `tipo` varchar(255) NOT NULL,
  `referencia` tinyint(1) NOT NULL default '0',
  `nivel` tinyint(1) NOT NULL,
  `obligatorio` tinyint(1) NOT NULL default '0',
  `intranet_habilitado` int(11) default '0',
  `visible` tinyint(1) NOT NULL default '1',
  `idinforef` int(11) default NULL,
  `idCompCliente` varchar(255) NOT NULL,
  `fijo` tinyint(1) NOT NULL default '0' COMMENT 'modificable = 0, No \r\nmodificable = 1',
  `repetible` tinyint(1) NOT NULL default '1' COMMENT 'repetible = 1 \r\n(es petible)',
  `rules` varchar(255) default NULL,
  `grupo` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `campo` (`campo`),
  KEY `subcampo` (`subcampo`),
  KEY `itemtype` (`itemtype`),
  KEY `indiceTodos` (`campo`,`subcampo`,`itemtype`),
  KEY `idinforef` (`idinforef`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;",
"INSERT INTO `cat_estructura_catalogacion` (`id`, `campo`, `subcampo`, `itemtype`, `liblibrarian`, `tipo`, `referencia`, `nivel`, `obligatorio`, `intranet_habilitado`, `visible`, `idinforef`, `idCompCliente`, `fijo`, `repetible`, `rules`, `grupo`) VALUES
(51, '245', 'a', 'ALL', 'Título', 'text', 0, 1, 1, 3, 1, NULL, '1', 1, 0, 'alphanumeric_total:true', 0),
(52, '995', 'd', 'ALL', 'Unidad de Información de Origen', 'combo', 1, 3, 1, 4, 1, 7, '2', 1, 0, 'alphanumeric_total:true', 0),
(53, '995', 'c', 'ALL', 'Unidad de Información', 'combo', 1, 3, 1, 2, 1, 7, '3', 1, 0, 'alphanumeric_total:true', 0),
(54, '995', 'o', 'ALL', 'Disponibilidad', 'combo', 1, 3, 1, 3, 1, 20, '4', 1, 0, 'alphanumeric_total:true', 0),
(55, '995', 'e', 'ALL', 'Estado', 'combo', 1, 3, 1, 5, 1, 9, '5', 1, 0, 'alphanumeric_total:true', 0),
(56, '910', 'a', 'ALL', 'Tipo de Documento', 'combo', 1, 2, 1, 1, 1, 8, '6', 1, 0, 'alphanumeric_total:true', 0),
(59, '260', 'c', 'ALL', 'Fecha de publicación, distribución, etc.', 'calendar', 0, 2, 0, 2, 1, NULL, '3c650621a845f2ed6226269a137a8dd9', 1, 0, 'alphanumeric_total:true', 0),
(60, '043', 'c', 'ALL', 'Código ISO (R)', 'combo', 1, 2, 0, 3, 1, 17, 'cefaa8a5a8a3407c70df0e307dbd04bc', 1, 0, 'alphanumeric_total:true', 0),
(61, '041', 'h', 'ALL', 'Código de idioma de la versión original y/o \r\ntraducciones intermedias del texto', 'combo', 1, 2, 0, 5, 1, 18, 'd02d2fa5669407a74cc3937e20589794', 1, 0, 'alphanumeric_total:true', 0),
(62, '900', 'b', 'ALL', 'Nivel Bibliográfico', 'combo', 1, 2, 0, 6, 1, 19, 'd45294e8506d009a430a08fe9674ffcd', 1, 0, 'alphanumeric_total:true', 0),
(63, '995', 't', 'ALL', 'Signatura Topográfica', 'text', 0, 3, 0, 6, 1, NULL, '6bab6f3097531cc673b716beecb02291', 1, 0, 'alphanumeric_total:true', 0),
(65, '995', 'f', 'ALL', 'Código de Barras', 'text', 0, 3, 0, 1, 1, NULL, '62fe2d3dcb85e12ed75812bbac9f9e5a', 1, 0, 'alphanumeric_total:true', 0),
(66, '110', 'a', 'ALL', 'Autor', 'auto', 1, 1, 0, 1, 1, 21, 'bf8e17616267c51064becf693e64501e', 1, 0, 'alphanumeric_total:true', 0),
(67, '260', 'a', 'ALL', 'Ciudad de publicación', 'text', 0, 2, 0, 7, 1, NULL, 'cbbd9c107865b4586ceed391f8b5223b', 1, 0, 'alphanumeric_total:true', 0),
(68, '245', 'h', 'ALL', 'Medio', 'combo', 1, 2, 0, 4, 1, 4, 'dbd4ba15b96cf63914351cdb163467b2', 1, 0, 'alphanumeric_total:true', 0),
(107, '080', 'a', 'ALL', 'CDU', 'text', 0, 1, 0, 3, 1, NULL, 'ea0c6caa38d898989866335e1af0844e', 0, 1, ' alphanumeric_total:true ', 1),
(108, '084', 'a', 'ALL', 'Otro Número de Clasificación R', 'text', 0, 1, 0, 4, 1, NULL, 'a17d02aa9b8000545cbda6ecc9795cca', 0, 1, ' alphanumeric_total:true ', 2),
(109, '100', 'a', 'ALL', 'Nombre Personal', 'auto', 1, 1, 1, 5, 1, 21, 'ac650c162cb9a25439b3cf0121c04d4b', 0, 1, ' alphanumeric_total:true ', 3),
(110, '100', 'b', 'ALL', 'Número asociado al nombre', 'text', 0, 1, 0, 6, 1, NULL, 'b62a61396e3b2253834943f36b1c5c87', 0, 1, ' alphanumeric_total:true ', 4),
(111, '100', 'c', 'ALL', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 7, 1, NULL, 'db40bfc73a6b47a223d05354aad6fa01', 0, 1, ' alphanumeric_total:true ', 5),
(112, '100', 'd', 'ALL', 'Fechas de nacimiento y muerte del autor', 'calendar', 0, 1, 0, 8, 1, NULL, '3b14403d2b3bfa1b272ec8f1e40b0168', 0, 1, ' alphanumeric_total:true ', 6),
(113, '111', 'a', 'ALL', 'Congresos Conferencias etc.', 'text', 0, 1, 0, 9, 1, NULL, '2d5a88362087f3249641aa935cd8dc45', 0, 1, ' alphanumeric_total:true ', 7),
(114, '111', 'c', 'ALL', 'Lugar de la reunión', 'auto', 1, 1, 0, 10, 1, 16, '060b526698bf141dd9ed0a1af4bb7c2d', 0, 1, ' alphanumeric_total:true ', 8),
(115, '111', 'd', 'ALL', 'Fecha de la reunión', 'text', 0, 1, 0, 11, 1, NULL, '7567ea2a7165b64e35e07f9239bf0c71', 0, 1, ' alphanumeric_total:true ', 9),
(116, '700', 'a', 'ALL', 'Nombre Personal', 'auto', 1, 1, 0, 12, 1, 21, '496705e6cd65f25e4e41ef8f26d0027e', 0, 1, ' alphanumeric_total:true ', 10),
(117, '700', 'b', 'ALL', 'Número asociado al nombre', 'text', 0, 1, 0, 13, 1, NULL, '4fcabc8e2d75c645552d462df7109c85', 0, 1, ' alphanumeric_total:true ', 11),
(118, '700', 'c', 'ALL', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 14, 1, NULL, 'c1b59097f399bb24a7dedd6e3339badb', 0, 1, ' alphanumeric_total:true ', 12),
(119, '700', 'd', 'ALL', 'Fechas asociadas con el nombre', 'calendar', 0, 1, 0, 15, 1, NULL, 'a866a7222462053c4e750ddd3d663dea', 0, 1, ' alphanumeric_total:true ', 13),
(120, '710', 'a', 'ALL', 'Nombre de la entidad o jurisdicción', 'auto', 1, 1, 0, 16, 1, 31, '538f99c8e5537a6307385edc614e65cf', 0, 1, ' alphanumeric_total:true ', 14),
(121, '720', 'a', 'ALL', 'Entrada secundaria no controlada', 'text', 0, 1, 0, 17, 1, NULL, '33c7296b105f76296cdbacad6584cae9', 0, 1, ' alphanumeric_total:true ', 15),
(122, '210', 'a', 'ALL', 'Título abreviado para publicación seriada', 'text', 0, 1, 0, 18, 1, NULL, '7b2a5ab0c335b6bd5dd38b849badd8bc', 0, 1, ' alphanumeric_total:true ', 16),
(123, '222', 'a', 'ALL', 'Título clave', 'text', 0, 1, 0, 19, 1, NULL, '88ea02b00dbedb9dda51615c3c3c8707', 0, 1, ' alphanumeric_total:true ', 17),
(124, '245', 'b', 'ALL', 'Título informativo', 'text', 0, 1, 0, 20, 1, NULL, '21f6e655816f1ac4b941bc13908197e3', 0, 1, ' alphanumeric_total:true ', 18),
(125, '246', 'a', 'ALL', 'Variante del título', 'text', 0, 1, 0, 21, 1, NULL, 'c682c271dabbfb6a0f8878df928a3b1c', 0, 1, ' alphanumeric_total:true ', 19),
(126, '246', 'b', 'ALL', 'Variante del título informativo', 'text', 0, 1, 0, 22, 1, NULL, '7ef2d014b5db89d8d4980dbdc4822b5c', 0, 1, ' alphanumeric_total:true ', 20),
(127, '534', 'a', 'ALL', 'Título original', 'text', 0, 1, 0, 23, 1, NULL, 'c2d53e2fa84556af755bd8395a4a62cd', 0, 1, ' alphanumeric_total:true ', 21),
(128, '600', 'a', 'ALL', 'Nombre Personal', 'auto', 1, 1, 0, 24, 1, 28, 'f558fc057d212e144b86196d2a2c55c4', 0, 1, ' alphanumeric_total:true ', 22),
(129, '600', 'b', 'ALL', 'Número asociado al nombre', 'text', 0, 1, 0, 25, 1, NULL, 'ec8d0b007a5d9be29c4ab7fea291d6d1', 0, 1, ' alphanumeric_total:true ', 23),
(130, '600', 'c', 'ALL', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 26, 1, NULL, '8d72a2e4fcb2fea44f316ebbf26c23fa', 0, 1, ' alphanumeric_total:true ', 24),
(131, '600', 'd', 'ALL', 'Fechas asociadas con el nombre', 'calendar', 0, 1, 0, 27, 1, NULL, '00b61ffb2f9d4d4fee7fe7eb7af5ca2a', 0, 1, ' alphanumeric_total:true ', 25),
(132, '650', 'a', 'ALL', 'Término controlado', 'text', 0, 1, 0, 28, 1, NULL, '357a2f17fd0088cb1f0e8370b62d7452', 0, 1, ' alphanumeric_total:true ', 26),
(133, '650', '2', 'ALL', 'Fuente del encabezamiento o término', 'text', 0, 1, 0, 29, 1, NULL, '05828ac7a6143d90273a1f80be98095a', 0, 1, ' alphanumeric_total:true ', 27),
(134, '651', 'a', 'ALL', 'Nombre geográfico', 'auto', 1, 1, 0, 30, 1, 17, 'b62f6fea9e64c8db720eb447052d0bd6', 0, 1, ' alphanumeric_total:true ', 28),
(135, '653', 'a', 'ALL', 'Término no controlado', 'text', 0, 1, 0, 31, 1, NULL, 'eea199e92303ba203519cd460a662188', 0, 1, ' alphanumeric_total:true ', 29),
(136, '655', 'a', 'ALL', 'Genero/Forma del material', 'text', 0, 1, 0, 32, 1, NULL, 'e4a8ffaf0bad3ad286cf3057466a0e89', 0, 1, ' alphanumeric_total:true ', 30),
(137, '020', 'a', 'LIB', 'ISBN', 'text', 0, 2, 0, 8, 1, NULL, '18c969e664f25625d83183540b563ad0', 0, 1, ' alphanumeric_total:true ', 31),
(138, '041', 'a', 'LIB', 'Idioma', 'auto', 1, 2, 0, 9, 1, 24, 'c304616fe1434ba4235a146010b98aa3', 0, 1, ' alphanumeric_total:true ', 32),
(140, '250', 'a', 'LIB', 'Mención de edición', 'text', 0, 2, 0, 11, 1, NULL, '665d8ec1b8a444dcf4d8732f09022742', 0, 1, ' alphanumeric_total:true ', 34),
(141, '260', 'b', 'LIB', 'Editor', 'text', 0, 2, 0, 12, 1, NULL, 'c9cf3e8f4cdf5e96f913c4fc5d949591', 0, 1, ' alphanumeric_total:true ', 35),
(142, '300', 'a', 'LIB', 'Descripción física', 'text', 0, 2, 0, 13, 1, NULL, '6982e2c38b57af9484301752acba4d44', 0, 1, ' alphanumeric_total:true ', 36),
(143, '440', 'a', 'LIB', 'Título de la serie', 'text', 0, 2, 0, 14, 1, NULL, '484e5d9090c3ba6b66ebad0c0e1150d2', 0, 1, ' alphanumeric_total:true ', 37),
(144, '440', 'p', 'LIB', 'Nombre de la subserie', 'text', 0, 2, 0, 15, 1, NULL, '5c9badf652343301382222dee9d8cd81', 0, 1, ' alphanumeric_total:true ', 38),
(145, '440', 'v', 'LIB', 'Número de la serie', 'text', 0, 2, 0, 16, 1, NULL, '2c1cdfad0546433f47440881acc9dc1a', 0, 1, ' alphanumeric_total:true ', 39),
(146, '500', 'a', 'LIB', 'Notas', 'text', 0, 2, 0, 17, 1, NULL, 'd92774dab9a0b65d987d0d10fcc5ee96', 0, 1, ' alphanumeric_total:true ', 40),
(147, '773', 'd', 'LIB', 'Lugar editorial y fecha de publicación', 'text', 0, 2, 0, 18, 1, NULL, 'a418ddf28c319073c56d72d92182c086', 0, 1, ' alphanumeric_total:true ', 41),
(148, '773', 'g', 'LIB', 'Páginas', 'text', 0, 2, 0, 19, 1, NULL, 'c7cce151b4ab09c91a7a51d92b9300eb', 0, 1, ' alphanumeric_total:true ', 42),
(149, '773', 't', 'LIB', 'Título', 'text', 0, 2, 0, 20, 1, NULL, 'c448fa15d5d384ffe9058f12a48c4546', 0, 1, ' alphanumeric_total:true ', 43);",
"DROP TABLE IF EXISTS `cat_estructura_catalogacion_opac`;",
"CREATE TABLE IF NOT EXISTS `cat_estructura_catalogacion_opac` (
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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;",
"INSERT  INTO `cat_estructura_catalogacion_opac` (`idestcatopac`, `campo`, `subcampo`, `textpred`, `textsucc`, `separador`, `idencabezado`, `visible`) VALUES
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
(15, '020', 'a', 'asd', '', '', 3, 1);",
"DROP TABLE IF EXISTS `cat_historico_disponibilidad`;",
"CREATE TABLE IF NOT EXISTS `cat_historico_disponibilidad` (
  `id_detalle` int(11) NOT NULL auto_increment,
  `id3` varchar(10) NOT NULL,
  `detalle` varchar(30) NOT NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `fecha` date NOT NULL default '0000-00-00',
  `tipo_prestamo` varchar(15) NOT NULL,
  `id_ui` varchar(5) NOT NULL,
  PRIMARY KEY  (`id_detalle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `cat_portada_registro`;",
"CREATE TABLE IF NOT EXISTS `cat_portada_registro` (
  `id` tinyint(4) NOT NULL auto_increment,
  `isbn` varchar(50) NOT NULL,
  `small` varchar(500) default NULL,
  `medium` varchar(500) default NULL,
  `large` varchar(500) default NULL,
  UNIQUE KEY `isbn` (`isbn`),
  UNIQUE KEY `id_2` (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `cat_pref_mapeo_koha_marc`;",
"CREATE TABLE IF NOT EXISTS `cat_pref_mapeo_koha_marc` (
  `idmap` int(11) NOT NULL auto_increment,
  `tabla` varchar(100) NOT NULL,
  `campoTabla` varchar(100) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `campo` varchar(3) NOT NULL,
  `subcampo` varchar(1) NOT NULL,
  PRIMARY KEY  (`idmap`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
"INSERT  INTO `cat_pref_mapeo_koha_marc` (`tabla`, `campoTabla`, `nombre`, `campo`, `subcampo`) VALUES
( 'additionalauthors', 'author', 'Nombre Personal', '700', 'a'),
( 'biblio', 'abstract', 'Nota de resumen, etc.', '520', 'a'),
( 'biblio', 'author', 'Nombre Personal', '100', 'a'),
( 'biblio', 'notes', 'Entrada principal del original', '534', 'a'),
( 'biblio', 'seriestitle', 'Numero de Clasificacion Decimal Universal', '080', 'a'),
( 'biblio', 'title', 'Titulo', '245', 'a'),
( 'biblio', 'unititle', 'Resto del ti­tulo', '245', 'b'),
( 'biblioitems', 'dewey', 'Call number prefix (NR)', '852', 'k'),
( 'biblioitems', 'idCountry', 'Codigo ISO (R)', '043', 'c'),
( 'biblioitems', 'illus', 'Otros detalles fi­sicos', '300', 'b'),
( 'biblioitems', 'issn', 'ISSN', '022', 'a'),
( 'biblioitems', 'itemtype', 'Tipo de documento', '910', 'a'),
( 'biblioitems', 'lccn', 'LC control number', '010', 'a'),
( 'biblioitems', 'notes', 'Nota General', '500', 'a'),
( 'biblioitems', 'number', 'Mencion de edicion', '250', 'a'),
( 'biblioitems', 'pages', 'Extension', '300', 'a'),
( 'biblioitems', 'place', 'Lugar de publicacion, distribucion, etc.', '260', 'a'),
( 'biblioitems', 'publicationyear', 'Fecha de publicacion, distribucion, etc.', '260', 'c'),
( 'biblioitems', 'seriestitle', 'Ti­tulo', '440', 'a'),
( 'biblioitems', 'size', 'Dimensiones', '300', 'c'),
( 'biblioitems', 'subclass', 'Call number suffix (NR)', '852', 'm'),
( 'biblioitems', 'url', 'Identificador Uniforme de Recurso (URI)', '856', 'u'),
( 'biblioitems', 'volume', 'Number of part/section of a work', '440', 'v'),
( 'biblioitems', 'volumeddesc', 'Ti­tulo', '440', 'p'),
( 'bibliosubject', 'subject', 'Topico o nombre geografico', '650', 'a'),
( 'bibliosubtitle', 'subtitle', 'Ti­tulo propiamente dicho/Ti­tulo corto', '246', 'a'),
( 'isbns', 'isbn', 'ISBN', '020', 'a'),
( 'items', 'barcode', 'Codigo de Barras', '995', 'f'),
( 'items', 'booksellerid', 'Nombre del vendedor', '995', 'a'),
( 'items', 'bulk', 'Signatura Topografica', '995', 't'),
( 'items', 'dateaccessioned', 'Fecha de acceso', '995', 'm'),
( 'items', 'holdingbranch', 'Unidad de Informacion', '995', 'c'),
( 'items', 'homebranch', 'Unidad de Informacion de Origen', '995', 'd'),
( 'items', 'itemnotes', 'Notas del item', '995', 'u'),
( 'items', 'notforloan', 'Disponibilidad', '995', 'o'),
( 'items', 'price', 'Precio de compra', '995', 'p'),
( 'items', 'replacementprice', 'Precio de reemplazo', '995', 'r'),
( 'items', 'wthdrawn', 'Estado', '995', 'e'),
( 'publisher', 'publisher', 'Nombre de la editorial, distribuidor, etc.', '260', 'b'),
( 'biblioitems', 'classification', '', '900', 'b'),
( 'biblioitems', 'idLanguage', '', '041', 'h'),
( 'biblioitems', 'idSupport', '', '245', 'h');",
"DROP TABLE IF EXISTS `cat_registro_marc_n1`;",
"CREATE TABLE IF NOT EXISTS `cat_registro_marc_n1` (
  `id` int(11) NOT NULL auto_increment,
  `marc_record` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `cat_registro_marc_n2`;",
"CREATE TABLE IF NOT EXISTS `cat_registro_marc_n2` (
  `id` int(11) NOT NULL auto_increment,
  `marc_record` text NOT NULL,
  `id1` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `cat_registro_marc_n3`;",
"CREATE TABLE IF NOT EXISTS `cat_registro_marc_n3` (
  `id` int(11) NOT NULL auto_increment,
  `marc_record` text NOT NULL,
  `id1` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `cat_registro_marc_n3_n1` (`id1`),
  KEY `cat_registro_marc_n3_n2` (`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `cat_z3950_cola`;",
"CREATE TABLE IF NOT EXISTS `cat_z3950_cola` (
  `id` int(11) NOT NULL auto_increment,
  `busqueda` text,
  `cola` datetime NOT NULL,
  `comienzo` datetime default NULL,
  `fin` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `cat_z3950_resultado`;",
"CREATE TABLE IF NOT EXISTS `cat_z3950_resultado` (
  `id` int(11) NOT NULL auto_increment,
  `servidor_id` tinyint(4) NOT NULL,
  `registro` longtext character set utf8,
  `cola_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;",
"DROP TABLE IF EXISTS `contacto`;",
"CREATE TABLE IF NOT EXISTS `contacto` (
  `id` int(11) NOT NULL auto_increment,
  `trato` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `apellido` varchar(255) NOT NULL,
  `direccion` varchar(255) default NULL,
  `codigo_postal` varchar(255) default NULL,
  `ciudad` varchar(255) default NULL,
  `pais` varchar(255) default NULL,
  `telefono` varchar(255) default NULL,
  `email` varchar(255) NOT NULL,
  `asunto` varchar(255) NOT NULL,
  `mensaje` text NOT NULL,
  `leido` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;",
"DROP TABLE IF EXISTS `indice_busqueda`;",
"CREATE TABLE IF NOT EXISTS `indice_busqueda` (
  `id` int(11) NOT NULL auto_increment,
  `titulo` text,
  `autor` text,
  `string` text NOT NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  FULLTEXT KEY `string` (`string`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `perm_catalogo`;",
"CREATE TABLE IF NOT EXISTS `perm_catalogo` (
  `ui` varchar(4) NOT NULL,
  `tipo_documento` varchar(4) NOT NULL,
  `datos_nivel1` varbinary(8) NOT NULL default '00000',
  `datos_nivel2` varbinary(8) NOT NULL default '00000',
  `datos_nivel3` varbinary(8) NOT NULL default '00000',
  `estantes_virtuales` varbinary(8) NOT NULL default '00000',
  `estructura_catalogacion_n1` varbinary(8) NOT NULL default '00000',
  `estructura_catalogacion_n2` varbinary(8) NOT NULL default '00000',
  `estructura_catalogacion_n3` varbinary(8) NOT NULL default '00000',
  `tablas_de_refencia` varbinary(8) NOT NULL default '00000',
  `control_de_autoridades` varbinary(8) NOT NULL default '00000',
  `usuarios` varchar(8) NOT NULL default '00000000',
  `sistema` varchar(8) NOT NULL default '00000001',
  `undefined` varchar(8) NOT NULL default '00000001',
  `id` int(11) NOT NULL auto_increment,
  `id_persona` int(11) unsigned NOT NULL,
  `nro_socio` varchar(16) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `id_persona` (`ui`,`tipo_documento`,`nro_socio`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;",
"INSERT  INTO `perm_catalogo` (`ui`, `tipo_documento`, `datos_nivel1`, `datos_nivel2`, `datos_nivel3`, `estantes_virtuales`, `estructura_catalogacion_n1`, `estructura_catalogacion_n2`, `estructura_catalogacion_n3`, `tablas_de_refencia`, `control_de_autoridades`, `usuarios`, `sistema`, `undefined`, `id`, `id_persona`, `nro_socio`) VALUES
('DEO', 'LIB', '00000001', '00000001', '00010000', '00001111', '00000001', '00000001', '00000001', '00000001', '00000001', '00001111', '00000001', '00001111', 1, 21, 'kohaadmin');",
"DROP TABLE IF EXISTS `perm_circulacion`;",
"CREATE TABLE IF NOT EXISTS `perm_circulacion` (
  `nro_socio` varchar(16) NOT NULL,
  `ui` varchar(4) NOT NULL,
  `tipo_documento` varchar(4) NOT NULL,
  `catalogo` varbinary(8) NOT NULL,
  `prestamos` varbinary(8) NOT NULL,
  PRIMARY KEY  (`nro_socio`,`ui`,`tipo_documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `perm_general`;",
"CREATE TABLE IF NOT EXISTS `perm_general` (
  `nro_socio` varchar(16) NOT NULL,
  `ui` varchar(4) NOT NULL,
  `tipo_documento` varchar(4) NOT NULL,
  `preferencias` varbinary(8) NOT NULL,
  `reportes` varchar(8) NOT NULL default '00000000',
  `permisos` varchar(8) NOT NULL default '00000000',
  PRIMARY KEY  (`nro_socio`,`ui`,`tipo_documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"INSERT  INTO `perm_general` (`nro_socio`, `ui`, `tipo_documento`, `preferencias`, `reportes`, `permisos`) VALUES
('kohaadmin', 'DEO', 'ANY', '', '00001111', '00001111');",
"DROP TABLE IF EXISTS `pref_informacion_referencia`;",

"CREATE TABLE IF NOT EXISTS `pref_informacion_referencia` (
  `idinforef` int(11) NOT NULL auto_increment,
  `idestcat` int(11) NOT NULL,
  `referencia` varchar(255) NOT NULL,
  `orden` varchar(255) default NULL,
  `campos` varchar(255) default NULL,
  `separador` varchar(3) default NULL,
  PRIMARY KEY  (`idinforef`),
  KEY `idestcat` (`idestcat`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;",

"INSERT INTO `pref_informacion_referencia` (`idinforef`, `idestcat`, `referencia`, `orden`, `campos`, `separador`) VALUES
(1, 45, 'autores', 'nacionalidad', 'completo', '?'),
(2, 46, 'temas', 'nombre', 'nombre', ','),
(3, 47, 'bibliolevel', 'description', 'description', ','),
(4, 47, 'soporte', 'description', 'description', ','),
(5, 45, 'countries', 'printable_name', 'printable_name', '/'),
(6, 45, 'languages', 'description', 'description', '/'),
(7, 44, 'ui', 'nombre', 'nombre', ','),
(8, 45, 'tipo_ejemplar', 'nombre', 'nombre', ','),
(9, 45, 'estado', 'nombre', 'nombre', ','),
(16, 0, 'ciudad', 'nombre', 'nombre', ','),
(17, 60, 'pais', 'nombre_largo', 'nombre', ','),
(18, 61, 'idioma', 'description', 'description', ','),
(19, 62, 'nivel_bibliografico', 'description', 'description', ','),
(20, 0, 'disponibilidad', 'nombre', 'nombre', ','),
(21, 66, 'autor', 'completo', 'completo', ','),
(22, 67, 'ciudad', 'NOMBRE', 'NOMBRE', ','),
(23, 68, 'soporte', 'description', 'description', ','),
(24, 103, 'tipo_colaborador', 'codigo', 'descripcion', NULL);",
"DROP TABLE IF EXISTS `pref_palabra_frecuente`;",
"CREATE TABLE IF NOT EXISTS `pref_palabra_frecuente` (
  `word` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"INSERT INTO `pref_palabra_frecuente` (`word`) VALUES
('an'),
('A'),
('THE'),
('EL'),
('LOS'),
('LA');",
"DROP TABLE IF EXISTS `pref_tabla_referencia_info`;",
"CREATE TABLE IF NOT EXISTS `pref_tabla_referencia_info` (
  `orden` varchar(20) NOT NULL,
  `referencia` varchar(30) NOT NULL,
  `similares` varchar(20) NOT NULL,
  PRIMARY KEY  (`referencia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"INSERT INTO `pref_tabla_referencia_info` (`orden`, `referencia`, `similares`) VALUES
('apellido', 'autores', 'apellido'),
('nombre', 'temas', 'nombre');",
"DROP TABLE IF EXISTS `pref_tabla_referencia_rel_catalogo`;",
"CREATE TABLE IF NOT EXISTS `pref_tabla_referencia_rel_catalogo` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `alias_tabla` varchar(32) NOT NULL,
  `tabla_referente` varchar(32) NOT NULL,
  `campo_referente` varchar(32) NOT NULL,
  `sub_campo_referente` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;",
"INSERT INTO `pref_tabla_referencia_rel_catalogo` (`id`, `alias_tabla`, `tabla_referente`, `campo_referente`, `sub_campo_referente`) VALUES
(2, 'ui', 'usr_socio', 'id_ui', NULL),
(10, 'tipo_prestamo', 'circ_prestamo', 'tipo_prestamo', NULL),
(13, 'tipo_socio', 'usr_socio', 'cod_categoria', NULL),
(14, 'tipo_documento_usr', 'usr_persona', 'tipo_documento', NULL),
(16, 'ciudad', 'usr_persona', 'ciudad', NULL),
(17, 'perfiles_opac', 'cat_visualizacion_opac', 'id_perfil', NULL);",
"DROP TABLE IF EXISTS `ref_tipo_operacion`;",
"CREATE TABLE IF NOT EXISTS `ref_tipo_operacion` (
  `id` int(11) NOT NULL auto_increment,
  `descripcion` varchar(20) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `pref_servidor_z3950`;",
"CREATE TABLE IF NOT EXISTS `pref_servidor_z3950` (
  `servidor` varchar(255) default NULL,
  `puerto` int(11) default NULL,
  `base` varchar(255) default NULL,
  `usuario` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `nombre` text,
  `id` int(11) NOT NULL auto_increment,
  `habilitado` tinyint(1) NOT NULL default '1',
  `sintaxis` varchar(80) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
"INSERT INTO `pref_servidor_z3950` (`servidor`, `puerto`, `base`, `usuario`, `password`, `nombre`, `id`, `habilitado`, `sintaxis`) VALUES ('z3950.loc.gov', 7090, 'voyager', NULL, NULL, 'Library of Congress', 1, 1, 'UNIMARC');",
"DROP TABLE IF EXISTS `ref_disponibilidad`;",
"CREATE TABLE IF NOT EXISTS `ref_disponibilidad` (
  `id` int(11) NOT NULL auto_increment,
  `nombre` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
"INSERT INTO `ref_disponibilidad` (`id`, `nombre`) VALUES
(0, 'Domiciliario'),
(1, 'Sala de Lectura');",
"DROP TABLE IF EXISTS `ref_estado`;",
"CREATE TABLE IF NOT EXISTS `ref_estado` (
  `id` int(11) NOT NULL ,
  `nombre` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
"CREATE TABLE IF NOT EXISTS `ref_estado` (
  `id` tinyint(5) NOT NULL auto_increment,
  `nombre` varchar(30) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;",
"INSERT INTO `ref_estado` (`id`, `nombre`) VALUES
(0, 'Disponible'),
(1, 'Perdido'),
(2, 'Compartido'),
(4, 'Baja'),
(5, 'Ejemplar deteriorado'),
(6, 'En Encuadernación'),
(7, 'En Etiquetado'),
(8, 'En Impresiones'),
(9, 'En procesos técnicos');",

"CREATE TABLE IF NOT EXISTS `usr_ref_tipo_documento` (
  `id` int(11) NOT NULL auto_increment,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;",
"INSERT INTO `usr_ref_tipo_documento` (`id`, `nombre`, `descripcion`) VALUES
(1, 'DNI', 'DNI'),
(2, 'LC', 'LC'),
(3, 'LE', 'LE'),
(4, 'PAS', 'PAS');",
"CREATE TABLE IF NOT EXISTS `usr_estado` (
  `id_estado` int(11) NOT NULL auto_increment,
  `regular` tinyint(1) NOT NULL default '0',
  `categoria` char(2) NOT NULL,
  `fuente` varchar(255) NOT NULL default 'koha',
  PRIMARY KEY  (`id_estado`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
"INSERT INTO `usr_estado` (`id_estado`, `regular`, `categoria`, `fuente`) VALUES
(20, 1, 'NN', 'ES UNA FUENTE DEFAULT, PREGUNTARLE A EINAR....'),
(46, 1, 'NN', 'MONO TU FUCKING KOHAADMIN SUPERLIBRARIAN'),
(47, 1, 'NN', 'ES UNA FUENTE DEFAULT, PREGUNTARLE A EINAR....');",
"DROP TABLE IF EXISTS `pref_tabla_referencia`;",
"CREATE TABLE IF NOT EXISTS `pref_tabla_referencia` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `nombre_tabla` varchar(40) NOT NULL,
  `alias_tabla` varchar(20) NOT NULL default '0',
  `campo_busqueda` varchar(255) NOT NULL default 'jmmj',
  PRIMARY KEY  (`id`),
  KEY `campo_busqueda` (`campo_busqueda`)
) ENGINE=MyISAM ;",
"INSERT INTO `pref_tabla_referencia` (`id`, `nombre_tabla`, `alias_tabla`, `campo_busqueda`) VALUES
(3, 'cat_autor', 'autor', 'completo'),
(4, 'cat_ref_tipo_nivel3', 'tipo_ejemplar', 'nombre'),
(5, 'pref_unidad_informacion', 'ui', 'nombre'),
(6, 'ref_idioma', 'idioma', 'description'),
(7, 'ref_pais', 'pais', 'nombre_largo'),
(8, 'ref_disponibilidad', 'disponibilidad', 'nombre'),
(9, 'circ_ref_tipo_prestamo', 'tipo_prestamo', 'descripcion'),
(10, 'ref_soporte', 'soporte', 'description'),
(11, 'ref_nivel_bibliografico', 'nivel_bibliografico', 'description'),
(12, 'cat_tema', 'tema', 'nombre'),
(13, 'usr_ref_categoria_socio', 'tipo_socio', 'description'),
(14, 'usr_ref_tipo_documento', 'tipo_documento_usr', 'nombre'),
(15, 'ref_estado', 'estado', 'nombre'),
(16, 'ref_localidad', 'ciudad', 'NOMBRE'),
(17, 'cat_perfil_opac', 'perfiles_opac', 'nombre');",
"DROP TABLE IF EXISTS cat_rating;",
"CREATE TABLE IF NOT EXISTS cat_rating (
  nro_socio varchar(11) NOT NULL,
  id2 int(11) NOT NULL,
  rate float NOT NULL,
  review text,
  PRIMARY KEY  (nro_socio,id2)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;",
"DROP TABLE IF EXISTS `cat_favoritos_opac`;",
"CREATE TABLE IF NOT EXISTS `cat_favoritos_opac` (
  `nro_socio` varchar(16) character set utf8 NOT NULL,
  `id1` int(11) NOT NULL,
  PRIMARY KEY  (`nro_socio`,`id1`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;",
"CREATE TABLE  `sys_novedad` (
`id` INT( 16 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`usuario` VARCHAR( 16 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`fecha` TIMESTAMP NOT NULL ,
`titulo` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`categoria` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`contenido` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL
) ENGINE = MYISAM;"
);

foreach my $sql (@sqls){
    my $qsql=$dbh->prepare($sql);
    $qsql->execute();
}

}


    sub renombrarTablas
    {
    #########################################################################
    #           Renombramos tablas!!!             #
    #########################################################################
    my @antes=( 'biblioanalysis','autores','analyticalauthors','colaboradores','shelfcontents',
                'publisher','bookshelf','availability','referenciaColaboradores','itemtypes',
                'temas','analyticalsubject','issues','issuetypes','sanctionrules',
                'sanctiontypesrules','reserves','sanctions','sanctionissuetypes','sanctiontypes',
                'branchcategories','feriados','iso2709','stopwords','systempreferences',
                'branchrelations','branches','authorised_values','dptos_partidos',
                'languages','localidades','bibliolevel','countries','provincias',
                'supports','historicCirculation','historicIssues','historicSanctions','modificaciones',
                'persons','categories','borrowers','deletedborrowers','historialBusqueda','busquedas','sessions','userflags');

    my @despues=( 'cat_analitica','cat_autor','cat_autor_analitica','cat_colaborador','cat_contenido_estante',
                'cat_editorial','cat_estante','cat_historico_disponibilidad','cat_ref_colaborador','cat_ref_tipo_nivel3',
                'cat_tema','cat_tema_analitica','circ_prestamo','circ_ref_tipo_prestamo','circ_regla_sancion',
                'circ_regla_tipo_sancion','circ_reserva','circ_sancion','circ_tipo_prestamo_sancion','circ_tipo_sancion',
                'pref_categoria_unidad_informacion','pref_feriado','pref_iso2709','pref_palabra_frecuente','pref_preferencia_sistema',
                'pref_relacion_unidad_informacion','pref_unidad_informacion','pref_valor_autorizado','ref_dpto_partido',
                'ref_idioma','ref_localidad','ref_nivel_bibliografico','ref_pais','ref_provincia',
                'ref_soporte','rep_historial_circulacion','rep_historial_prestamo','rep_historial_sancion',
                'rep_registro_modificacion','usr_persona','usr_ref_categoria_socio','usr_socio','usr_socio_borrado',
                'rep_historial_busqueda','rep_busqueda','sist_sesion','usr_permiso');

  for(my $i=0; $i< scalar(@antes); $i++){
    my $rename=$dbh->prepare("RENAME TABLE ".$antes[$i]." TO ".$despues[$i]."; ");
    $rename->execute();
  }
### Despues de renombrar hay que alterarlas 

    my @alternos=(
    "ALTER TABLE rep_historial_busqueda CHANGE `HTTP_USER_AGENT` `agent` VARCHAR( 255 ) NOT NULL;",
    "ALTER TABLE rep_busqueda CHANGE `borrower` `nro_socio` INT( 11 ) NULL DEFAULT NULL;",
    " ALTER TABLE `rep_busqueda` CHANGE `nro_socio` `nro_socio` VARCHAR( 16 ) NULL DEFAULT NULL;",
    "ALTER TABLE circ_reserva CHANGE `reservenumber` `id_reserva` INT(11) NOT NULL AUTO_INCREMENT,
      CHANGE `borrowernumber` `nro_socio` VARCHAR(16) NOT NULL DEFAULT '0', 
      CHANGE `reservedate` `fecha_reserva` VARCHAR(20) NOT NULL,
      CHANGE `constrainttype` `estado` CHAR(1) NULL DEFAULT NULL, 
      CHANGE `branchcode` `id_ui` VARCHAR(4) NULL DEFAULT NULL, 
      CHANGE `notificationdate` `fecha_notificacion` VARCHAR(20) NULL DEFAULT NULL, 
      CHANGE `reminderdate` `fecha_recordatorio` VARCHAR(20) NULL DEFAULT NULL;",
    " ALTER TABLE circ_reserva  DROP `cancellationdate`,  DROP `reservenotes`,  DROP `priority`,  DROP `found`;",
    " ALTER TABLE circ_prestamo CHANGE `borrowernumber` `nro_socio` VARCHAR( 16 ) NOT NULL DEFAULT '0',
      CHANGE `issuecode` `tipo_prestamo` CHAR( 2 ) NOT NULL DEFAULT 'DO',
      CHANGE `date_due` `fecha_prestamo` VARCHAR( 20 ) NULL DEFAULT NULL ,
      CHANGE `branchcode` `id_ui_origen` CHAR( 4 ) NULL DEFAULT NULL ,
      CHANGE `issuingbranch` `id_ui_prestamo` CHAR( 18 ) NULL DEFAULT NULL ,
      CHANGE `returndate` `fecha_devolucion` VARCHAR( 20 ) NULL DEFAULT NULL ,
      CHANGE `lastreneweddate` `fecha_ultima_renovacion` VARCHAR( 20 ) NULL DEFAULT NULL ,
      CHANGE `renewals` `renovaciones` TINYINT( 4 ) NULL DEFAULT NULL;",
      "ALTER TABLE circ_prestamo DROP `return`;",
      "ALTER TABLE `usr_persona` CHANGE `personnumber` `id_persona` INT(11) NOT NULL AUTO_INCREMENT, 
       CHANGE `borrowernumber` id_socio INT(11) NULL DEFAULT NULL, 
       CHANGE `cardnumber` nro_socio VARCHAR(16) NOT NULL, 
       CHANGE `documentnumber` `nro_documento` VARCHAR(16) NOT NULL, 
       CHANGE `documenttype` `tipo_documento` CHAR(3) NOT NULL, 
       CHANGE `surname` `apellido` TEXT NOT NULL, 
       CHANGE `firstname` `nombre` TEXT  NOT NULL, 
       CHANGE `title` `titulo` TEXT NULL DEFAULT NULL, 
       CHANGE `othernames` `otros_nombres` TEXT NULL DEFAULT NULL, 
       CHANGE `initials` `iniciales` TEXT NULL DEFAULT NULL,
       CHANGE `streetaddress` `calle` TEXT NULL DEFAULT NULL,
       CHANGE `suburb` `barrio` TEXT NULL DEFAULT NULL,
       CHANGE `city` `ciudad` TEXT NULL DEFAULT NULL,
       CHANGE `phone` `telefono` TEXT NULL DEFAULT NULL,
       CHANGE `emailaddress` `email` TEXT NULL DEFAULT NULL,
       CHANGE `faxnumber` `fax` TEXT NULL DEFAULT NULL,
       CHANGE `textmessaging` `msg_texto` TEXT NULL DEFAULT NULL,
       CHANGE `altstreetaddress` `alt_calle` TEXT NULL DEFAULT NULL,
       CHANGE `altsuburb` `alt_barrio` TEXT NULL DEFAULT NULL,
       CHANGE `altcity` `alt_ciudad` TEXT NULL DEFAULT NULL,
       CHANGE `altphone` `alt_telefono` TEXT NULL DEFAULT NULL,
       CHANGE `dateofbirth` `nacimiento` DATE NULL DEFAULT NULL,
       CHANGE `dateenrolled` `fecha_alta` DATE NULL DEFAULT NULL,
       CHANGE `studentnumber` legajo VARCHAR( 8 ) NOT NULL, 
       CHANGE `sex` `sexo` CHAR(1) NULL DEFAULT NULL, 
       CHANGE `phoneday` `telefono_laboral` VARCHAR(50)  NULL DEFAULT NULL,
       CHANGE `regular` `cumple_condicion` TINYINT(1) NOT NULL DEFAULT '0';",
       "ALTER TABLE `usr_persona` DROP `gonenoaddress`,  DROP `lost`,  DROP `debarred`,  DROP `school`,  DROP `contactname`,  DROP `borrowernotes`,  DROP `guarantor`,  DROP `area`,  DROP `ethnicity`,  DROP `ethnotes`,  DROP `expiry`,  DROP `altnotes`,  DROP `altrelationship`,  DROP `streetcity`,  DROP `preferredcont`,  DROP `physstreet`,  DROP `homezipcode`,  DROP `zipcode`,  DROP `userid`,  DROP `flags`;",
       "ALTER TABLE `usr_socio` CHANGE `cardnumber` `nro_socio` VARCHAR( 16 ) NOT NULL ,
        CHANGE `borrowernumber` `id_socio` INT( 11 ) NOT NULL AUTO_INCREMENT ,
        CHANGE `branchcode` `id_ui` VARCHAR( 4 ) NOT NULL ,
        CHANGE `categorycode` `cod_categoria` CHAR( 2 ) NOT NULL ,
        CHANGE `dateenrolled` `fecha_alta` DATE NULL DEFAULT NULL ,
        CHANGE `expiry` `expira` DATE NULL DEFAULT NULL ,
        CHANGE `lastlogin` `last_login` DATETIME NULL DEFAULT NULL ,
        CHANGE `lastchangepassword` `last_change_password` DATE NULL DEFAULT NULL ,
        CHANGE `changepassword` `change_password` TINYINT( 1 ) NULL DEFAULT '0',
        CHANGE `usercourse` `cumple_requisito` DATE NULL DEFAULT NULL;",
      "ALTER TABLE `usr_socio` ADD `nombre_apellido_autorizado` VARCHAR( 255 )  NULL ;",
      "ALTER TABLE `usr_socio` ADD dni_autorizado VARCHAR( 16 )  NULL ;",
      "ALTER TABLE `usr_socio` ADD telefono_autorizado VARCHAR( 255 )  NULL ;",
      "ALTER TABLE `usr_socio` ADD is_super_user INT( 11 )NOT NULL ;",
      "ALTER TABLE `usr_socio` ADD credential_type VARCHAR( 255 ) NOT NULL ;",
      "ALTER TABLE `usr_socio` CHANGE `credential_type` `credential_type` VARCHAR( 255 ) NOT NULL DEFAULT 'estudiante'",
      "ALTER TABLE `usr_socio` ADD id_estado INT( 11 )NOT NULL ;",
      "ALTER TABLE `usr_socio` ADD activo VARCHAR( 255 ) NOT NULL ;",
      "ALTER TABLE `usr_socio` ADD agregacion_temp VARCHAR( 255 ) NULL ;",
      "ALTER TABLE `pref_unidad_informacion` CHANGE `branchcode` `id_ui` VARCHAR( 4 )  NOT NULL ,
      CHANGE `branchname` `nombre` TEXT  NOT NULL ,
      CHANGE `branchaddress1` `direccion` TEXT  NULL DEFAULT NULL ,
      CHANGE `branchaddress2` `alt_direccion` TEXT  NULL DEFAULT NULL ,
      CHANGE `branchphone` `telefono` TEXT  NULL DEFAULT NULL ,
      CHANGE `branchfax` `fax` TEXT  NULL DEFAULT NULL ,
      CHANGE `branchemail` `email` TEXT  NULL DEFAULT NULL ;",
      "ALTER TABLE `pref_unidad_informacion`
      DROP `branchaddress3`,
      DROP `issuing`;",
      "ALTER TABLE `pref_unidad_informacion` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;" ,
      "ALTER TABLE `pref_unidad_informacion` DROP INDEX `branchcode`",
      "ALTER TABLE `sist_sesion` ADD `token` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `nroRandom` ;",
      "ALTER TABLE `usr_persona` ADD `version_documento` CHAR( 1 ) NOT NULL DEFAULT 'P' AFTER `id_persona` ;",
      "ALTER TABLE `usr_persona`    DROP `id_socio`, DROP `nro_socio`;",
      "ALTER TABLE `usr_persona` DROP `branchcode` , DROP `categorycode` ;",
      "ALTER TABLE `usr_persona` ADD `es_socio` INT( 1 ) UNSIGNED NOT NULL DEFAULT '0' COMMENT '1= si; 0=no';",
      "ALTER TABLE `usr_socio` CHANGE `password` `password` VARCHAR( 255 ) NULL DEFAULT NULL;",
      "ALTER TABLE `usr_socio` ADD `id_persona` INT( 11 ) NOT NULL FIRST ;",
      "ALTER TABLE `ref_pais` DROP PRIMARY KEY;",
      "ALTER TABLE `ref_pais` ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;",
      " ALTER TABLE `ref_pais` CHANGE `name` `nombre` VARCHAR( 80 )  NOT NULL ,
      CHANGE `printable_name` `nombre_largo` VARCHAR( 80 ) NOT NULL ,
      CHANGE `code` `codigo` VARCHAR( 11 ) NOT NULL;",
      "ALTER TABLE `cat_ref_tipo_nivel3` DROP INDEX `itemtype`;",
      "ALTER TABLE `cat_ref_tipo_nivel3` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;",
      "ALTER TABLE `cat_ref_tipo_nivel3`
      DROP `loanlength`,
      DROP `renewalsallowed`,
      DROP `rentalcharge`,
      DROP `search`,
      DROP `detail`;",
      " ALTER TABLE `cat_ref_tipo_nivel3` CHANGE `itemtype` `id_tipo_doc` VARCHAR( 4 ) NOT NULL ,
      CHANGE `description` `nombre` TEXT NULL DEFAULT NULL;",
      "ALTER TABLE ref_idioma ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;",
      " ALTER TABLE `ref_estado` CHANGE `code` `id` TINYINT( 5 ) NOT NULL AUTO_INCREMENT ,
      CHANGE `description` `nombre` VARCHAR( 30 ) CHARACTER SET utf8 COLLATE utf8_swedish_ci NOT NULL;",
      " ALTER TABLE `ref_estado` ADD UNIQUE ( `nombre` );",
      "ALTER TABLE `circ_prestamo` ADD `id_prestamo` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;",
      "ALTER TABLE `circ_reserva`
        DROP `biblioitemnumber`,
        DROP `cancellationdate`,
        DROP `reservenotes`;",
      " ALTER TABLE `circ_sancion` CHANGE `sanctionnumber` `id_sancion` INT( 11 ) NOT NULL AUTO_INCREMENT ,
        CHANGE `sanctiontypecode` `tipo_sancion` INT( 11 ) NULL DEFAULT '0',
        CHANGE `reservenumber` `id_reserva` INT( 11 ) NULL DEFAULT NULL ,
        CHANGE `borrowernumber` `nro_socio` VARCHAR( 16 ) NOT NULL DEFAULT '0',
        CHANGE `startdate` `fecha_comienzo` DATE NOT NULL DEFAULT '0000-00-00',
        CHANGE `enddate` `fecha_final` DATE NOT NULL DEFAULT '0000-00-00',
        CHANGE `delaydays` `dias_sancion` INT( 11 ) NULL DEFAULT '0',
        CHANGE `itemnumber` `id3` INT( 11 ) NULL DEFAULT NULL ",
        "ALTER TABLE `circ_tipo_prestamo_sancion` CHANGE `sanctiontypecode` `tipo_sancion` INT( 11 ) NOT NULL DEFAULT '0',
         CHANGE `issuecode` `tipo_prestamo` CHAR( 2 ) CHARACTER SET utf8 COLLATE utf8_swedish_ci NOT NULL ;",
        " ALTER TABLE `circ_tipo_sancion` CHANGE `sanctiontypecode` `tipo_sancion` INT( 11 ) NOT NULL AUTO_INCREMENT ,
        CHANGE `categorycode` `categoria_socio` CHAR( 2 ) CHARACTER SET utf8 COLLATE utf8_swedish_ci NOT NULL ,
        CHANGE `issuecode` `tipo_prestamo` CHAR( 2 ) CHARACTER SET utf8 COLLATE utf8_swedish_ci NOT NULL ;",
        " ALTER TABLE `circ_ref_tipo_prestamo` CHANGE `issuecode` `id_tipo_prestamo` CHAR( 2 ) CHARACTER SET utf8 COLLATE utf8_swedish_ci NOT NULL ,
          CHANGE `description` `descripcion` TEXT CHARACTER SET utf8 COLLATE utf8_swedish_ci NULL DEFAULT NULL ,
          CHANGE `notforloan` `id_disponibilidad` TINYINT( 1 ) NOT NULL DEFAULT '0',
          CHANGE `maxissues` `prestamos` INT( 11 ) NOT NULL DEFAULT '0',
          CHANGE `daysissues` `dias_prestamo` INT( 11 ) NOT NULL DEFAULT '0',
          CHANGE `renew` `renovaciones` INT( 11 ) NOT NULL DEFAULT '0',
          CHANGE `renewdays` `dias_renovacion` TINYINT( 3 ) NOT NULL DEFAULT '0',
          CHANGE `dayscanrenew` `dias_antes_renovacion` TINYINT( 10 ) NOT NULL DEFAULT '0',
          CHANGE `enabled` `habilitado` TINYINT( 4 ) NULL DEFAULT '1' ;",
         " ALTER TABLE `circ_ref_tipo_prestamo` DROP PRIMARY KEY ;",
         "ALTER TABLE `circ_ref_tipo_prestamo` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;",
         "ALTER TABLE `circ_regla_sancion` CHANGE `sanctionrulecode` `regla_sancion` INT( 11 ) NOT NULL AUTO_INCREMENT ,
          CHANGE `sanctiondays` `dias_sancion` INT( 11 ) NOT NULL DEFAULT '0',
          CHANGE `delaydays` `dias_demora` INT( 11 ) NOT NULL DEFAULT '0';",
         " ALTER TABLE `circ_regla_tipo_sancion` CHANGE `sanctiontypecode` `tipo_sancion` INT( 11 ) NOT NULL DEFAULT '0',
          CHANGE `sanctionrulecode` `regla_sancion` INT( 11 ) NOT NULL DEFAULT '0',
          CHANGE `orden` `orden` INT( 11 ) NOT NULL DEFAULT '1',
          CHANGE `amount` `cantidad` INT( 11 ) NOT NULL DEFAULT '1';",
          "ALTER TABLE `circ_prestamo` ADD `agregacion_temp` VARCHAR( 255 ) NULL ;",
           "CREATE TABLE IF NOT EXISTS `cat_visualizacion_intra` (
            `id` int(11) NOT NULL auto_increment,
            `campo` char(3) NOT NULL,
            `subcampo` char(1) NOT NULL,
            `vista_intra` varchar(255) default NULL,
            `tipo_ejemplar` char(3) NOT NULL,
            PRIMARY KEY  (`id`),
            KEY `campo` (`campo`,`subcampo`)
            ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;",
            "INSERT INTO `cat_visualizacion_intra` (`id`, `campo`, `subcampo`, `vista_intra`, `tipo_ejemplar`) VALUES
            (1, '245', 'a', 'Título', 'ALL'),
            (2, '995', 'd', 'Unidad de Información de Origen', 'ALL'),
            (3, '995', 'c', 'Unidad de Información', 'ALL'),
            (4, '995', 'o', 'Disponibilidad', 'ALL'),
            (5, '995', 'e', 'Estado', 'ALL'),
            (6, '910', 'a', 'Tipo de Documento', 'ALL'),
            (7, '260', 'c', 'Fecha de publicación', 'ALL'),
            (8, '043', 'c', 'Código ISO (R)', 'LIB'),
            (9, '041', 'h', 'Código de idioma de la versión original y/o traducciones intermedias del texto', 'LIB'),
            (10, '900', 'b', 'Nivel Bibliográfico', 'ALL'),
            (11, '995', 't', 'Signatura Topográfica', 'ALL'),
            (12, '995', 'f', 'Código de Barras', 'ALL'),
            (13, '100', 'a', 'Autor', 'ALL'),
            (14, '260', 'a', 'Ciudad de publicación', 'ALL'),
            (15, '245', 'h', 'Medio', 'ALL'),
            (16, '041', 'a', 'Código de Idioma para texto o pista de sonido o título separado', 'MAP'),
            (17, '995', 'a', 'Nombre del vendedor', 'LIB'),
            (18, '084', 'a', 'Otro Número de Clasificación R', 'ALL'),
            (19, '995', 'u', 'Notas del item', 'LIB'),
            (20, '022', 'a', 'Año', 'LIB'),
            (21, '082', '2', 'No. de la edición', 'ALL'),
            (22, '440', 'a', 'Serie - título de la serie', 'LIB'),
            (23, '020', 'a', 'ISBN', 'LIB'),
            (24, '245', 'b', 'Resto del título', 'ALL'),
            (25, '072', '2', 'Fuente del código', 'LIB');",
            "CREATE TABLE IF NOT EXISTS `cat_visualizacion_opac` (
            `id` int(11) NOT NULL auto_increment,
            `campo` char(3) NOT NULL,
            `subcampo` char(1) NOT NULL,
            `vista_opac` varchar(255) default NULL,
            `id_perfil` int(11) NOT NULL,
            PRIMARY KEY  (`id`),
            KEY `campo` (`campo`,`subcampo`)
            ) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;",
            "INSERT INTO `cat_visualizacion_opac` (`id`, `campo`, `subcampo`, `vista_opac`, `id_perfil`) VALUES
            (2, '013', 'b', 'rock', 1),
            (3, '110', 'f', 'No se, ni idea', 1),
            (4, '653', 'a', 'Lenguaje natural ananaan', 1);",
            "CREATE TABLE IF NOT EXISTS `ref_colaborador` (
            `id` int(11) NOT NULL auto_increment,
            `codigo` varchar(10) NOT NULL,
            `descripcion` text NOT NULL,
            PRIMARY KEY  (`id`)
            ) ENGINE=MyISAM  DEFAULT CHARSET=utf8",
            "INSERT INTO `ref_colaborador` (`id`, `codigo`, `descripcion`) VALUES
                (1, 'acp', 'Art copyist'),
                (2, 'act', 'Actor'),
                (3, 'adp', 'Adapter'),
                (4, 'aft', 'Author of afterword, colophon, etc.'),
                (5, 'anl', 'Analyst'),
                (6, 'anm', 'Animator'),
                (7, 'ann', 'Annotator'),
                (8, 'ant', 'Bibliographic antecedent'),
                (9, 'app', 'Applicant'),
                (10, 'aqt', 'Author in quotations or text abstracts'),
                (11, 'arc', 'Architect'),
                (12, 'ard', 'Artistic director'),
                (13, 'arr', 'Arranger'),
                (14, 'art', 'Artist'),
                (15, 'asg', 'Assignee'),
                (16, 'asn', 'Associated name'),
                (17, 'att', 'Attributed name'),
                (18, 'auc', 'Auctioneer'),
                (19, 'aud', 'Author of dialog'),
                (20, 'aui', 'Author of introduction'),
                (21, 'aus', 'Author of screenplay'),
                (22, 'aut', 'Author'),
                (23, 'bdd', 'Binding designer'),
                (24, 'bjd', 'Bookjacket designer'),
                (25, 'bkd', 'Book designer'),
                (26, 'bkp', 'Book producer'),
                (27, 'bnd', 'Binder'),
                (28, 'bpd', 'Bookplate designer'),
                (29, 'bsl', 'Bookseller'),
                (30, 'ccp', 'Conceptor'),
                (31, 'chr', 'Choreographer'),
                (32, 'clb', 'Collaborator'),
                (33, 'cli', 'Client'),
                (34, 'cll', 'Calligrapher'),
                (35, 'clt', 'Collotyper'),
                (36, 'cmm', 'Commentator'),
                (37, 'cmp', 'Composer'),
                (38, 'cmt', 'Compositor'),
                (39, 'cng', 'Cinematographer'),
                (40, 'cnd', 'Conductor'),
                (41, 'cns', 'Censor'),
                (42, 'coe', 'Contestant -appellee'),
                (43, 'col', 'Collector'),
                (44, 'com', 'Compiler'),
                (45, 'cos', 'Contestant'),
                (46, 'cot', 'Contestant -appellant'),
                (47, 'cov', 'Cover designer'),
                (48, 'cpc', 'Copyright claimant'),
                (49, 'cpe', 'Complainant-appellee'),
                (50, 'cph', 'Copyright holder'),
                (51, 'cpl', 'Complainant'),
                (52, 'cpt', 'Complainant-appellant'),
                (53, 'cre', 'Creator'),
                (54, 'crp', 'Correspondent'),
                (55, 'crr', 'Corrector'),
                (56, 'csl', 'Consultant'),
                (57, 'csp', 'Consultant to a project'),
                (58, 'cst', 'Costume designer'),
                (59, 'ctb', 'Contributor'),
                (60, 'cte', 'Contestee-appellee'),
                (61, 'ctg', 'Cartographer'),
                (62, 'ctr', 'Contractor'),
                (63, 'cts', 'Contestee'),
                (64, 'ctt', 'Contestee-appellant'),
                (65, 'cur', 'Curator'),
                (66, 'cwt', 'Commentator for written text'),
                (67, 'dfd', 'Defendant'),
                (68, 'dfe', 'Defendant-appellee'),
                (69, 'dft', 'Defendant-appellant'),
                (70, 'dgg', 'Degree grantor'),
                (71, 'dis', 'Dissertant'),
                (72, 'dln', 'Delineator'),
                (73, 'dnc', 'Dancer'),
                (74, 'dnr', 'Donor'),
                (75, 'dpc', 'Depicted'),
                (76, 'dpt', 'Depositor'),
                (77, 'drm', 'Draftsman'),
                (78, 'drt', 'Director'),
                (79, 'dsr', 'Designer'),
                (80, 'dst', 'Distributor'),
                (81, 'dtc', 'Data contributor'),
                (82, 'dte', 'Dedicatee'),
                (83, 'dtm', 'Data manager'),
                (84, 'dto', 'Dedicator'),
                (85, 'dub', 'Dubious author'),
                (86, 'edt', 'Editor'),
                (87, 'egr', 'Engraver'),
                (88, 'elg', 'Electrician'),
                (89, 'elt', 'Electrotyper'),
                (90, 'eng', 'Engineer'),
                (91, 'etr', 'Etcher'),
                (92, 'exp', 'Expert'),
                (93, 'fac', 'Facsimilist'),
                (94, 'fld', 'Field director'),
                (95, 'flm', 'Film editor'),
                (96, 'fmo', 'Former owner'),
                (97, 'fpy', 'First party'),
                (98, 'fnd', 'Funder'),
                (99, 'frg', 'Forger'),
                (100, 'gis', 'Geographic information specialist'),
                (101, '-grt', 'Graphic technician'),
                (102, 'hnr', 'Honoree'),
                (103, 'hst', 'Host'),
                (104, 'ill', 'Illustrator'),
                (105, 'ilu', 'Illuminator'),
                (106, 'ins', 'Inscriber'),
                (107, 'inv', 'Inventor'),
                (108, 'itr', 'Instrumentalist'),
                (109, 'ive', 'Interviewee'),
                (110, 'ivr', 'Interviewer'),
                (111, 'lbr', 'Laboratory '),
                (112, 'lbt', 'Librettist'),
                (113, 'ldr', 'Laboratory director'),
                (114, 'led', 'Lead '),
                (115, 'lee', 'Libelee-appellee'),
                (116, 'lel', 'Libelee'),
                (117, 'len', 'Lender'),
                (118, 'let', 'Libelee-appellant'),
                (119, 'lgd', 'Lighting designer'),
                (120, 'lie', 'Libelant-appellee'),
                (121, 'lil', 'Libelant'),
                (122, 'lit', 'Libelant-appellant'),
                (123, 'lsa', 'Landscape architect'),
                (124, 'lse', 'Licensee'),
                (125, 'lso', 'Licensor'),
                (126, 'ltg', 'Lithographer'),
                (127, 'lyr', 'Lyricist'),
                (128, 'mcp', 'Music copyist'),
                (129, 'mfr', 'Manufacturer'),
                (130, 'mdc', 'Metadata contact'),
                (131, 'mod', 'Moderator'),
                (132, 'mon', 'Monitor'),
                (133, 'mrk', 'Markup editor'),
                (134, 'msd', 'Musical director'),
                (135, 'mte', 'Metal-engraver'),
                (136, 'mus', 'Musician'),
                (137, 'nrt', 'Narrator'),
                (138, 'opn', 'Opponent'),
                (139, 'org', 'Originator'),
                (140, 'orm', 'Organizer of meeting'),
                (141, 'oth', 'Other'),
                (142, 'own', 'Owner'),
                (143, 'pat', 'Patron'),
                (144, 'pbd', 'Publishing director'),
                (145, 'pbl', 'Publisher'),
                (146, 'pdr', 'Project director '),
                (147, 'pfr', 'Proofreader'),
                (148, 'pht', 'Photographer'),
                (149, 'plt', 'Platemaker'),
                (150, 'pma', 'Permitting agency'),
                (151, 'pmn', 'Production manager'),
                (152, 'pop', 'Printer of plates'),
                (153, 'ppm', 'Papermaker'),
                (154, 'ppt', 'Puppeteer'),
                (155, 'prc', 'Process contact'),
                (156, 'prd', 'Production personnel'),
                (157, 'prf', 'Performer'),
                (158, 'prg', 'Programmer'),
                (159, 'prm', 'Pr