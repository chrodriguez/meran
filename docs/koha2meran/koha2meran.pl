#!/usr/bin/perl

use CGI::Session;
use C4::Context;
use MARC::Record;

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
    
    aplicarSQL("tablasNuevas.sql");

}


    sub renombrarTablas
    {
    #########################################################################
    #           Renombramos tablas!!!             #
    #########################################################################
        my %hash = ();
        $hash{ 'biblioanalysis' } = 'cat_analitica';
        $hash{ 'autores' } = 'cat_autor';
        $hash{ 'analyticalauthors' } = 'cat_autor_analitica';
        $hash{ 'colaboradores' } = 'cat_colaborador';
        $hash{ 'shelfcontents' } = 'cat_contenido_estante';
        $hash{ 'publisher' } = 'cat_editorial';
        $hash{ 'bookshelf' } = 'cat_estante';
        $hash{ 'availability' } = 'cat_historico_disponibilidad';
        $hash{ 'referenciaColaboradores' } = 'cat_ref_colaborador';
        $hash{ 'itemtypes' } = 'cat_ref_tipo_nivel3';
        $hash{ 'temas' } = 'cat_tema';
        $hash{ 'analyticalsubject' } = 'cat_tema_analitica';
        $hash{ 'issues' } = 'circ_prestamo';
        $hash{ 'issuetypes' } = 'circ_ref_tipo_prestamo';
        $hash{ 'sanctionrules' } = 'circ_regla_sancion';
        $hash{ 'sanctiontypesrules' } = 'circ_regla_tipo_sancion';
        $hash{ 'reserves' } = 'circ_reserva';
        $hash{ 'sanctions' } = 'circ_sancion';
        $hash{ 'sanctionissuetypes' } = 'circ_tipo_prestamo_sancion';
        $hash{ 'sanctiontypes' } = 'circ_tipo_sancion';
        $hash{ 'branchcategories' } = 'pref_categoria_unidad_informacion';
        $hash{ 'feriados' } = 'pref_feriado';
        $hash{ 'iso2709' } = 'pref_iso2709';
        $hash{ 'stopwords' } = 'pref_palabra_frecuente';
        $hash{ 'systempreferences' } = 'pref_preferencia_sistema';
        $hash{ 'branchrelations' } = 'pref_relacion_unidad_informacion';
        $hash{ 'branches' } = 'pref_unidad_informacion';
        $hash{ 'authorised_values' } = 'pref_valor_autorizado';
        $hash{ 'dptos_partidos' } = 'ref_dpto_partido';
        $hash{ 'languages' } = 'ref_idioma';
        $hash{ 'localidades' } = 'ref_localidad';
        $hash{ 'bibliolevel' } = 'ref_nivel_bibliografico';
        $hash{ 'countries' } = 'ref_pais';
        $hash{ 'provincias' } = 'ref_provincia';
        $hash{ 'supports' } = 'ref_soporte';
        $hash{ 'historicCirculation' } = 'rep_historial_circulacion';
        $hash{ 'historicIssues' } = 'rep_historial_prestamo';
        $hash{ 'historicSanctions' } = 'rep_historial_sancion';
        $hash{ 'modificaciones' } = 'rep_registro_modificacion';
        $hash{ 'persons' } = 'usr_persona';
        $hash{ 'categories' } = 'usr_ref_categoria_socio';
        $hash{ 'borrowers' } = 'usr_socio';
        $hash{ 'deletedborrowers' } = 'usr_socio_borrado';
        $hash{ 'historialBusqueda' } = 'rep_historial_busqueda';
        $hash{ 'busquedas' } = 'rep_busqueda';
        $hash{ 'sessions' } = 'sist_sesion';
        $hash{ 'userflags' } = 'usr_permiso';

        foreach my $llave (keys %hash){
            my $rename=$dbh->prepare("RENAME TABLE ".$llave." TO ".$hash{$llave}."; ");
            $rename->execute();
        } 

### Despues de renombrar hay que alterarlas 

   aplicarSQL("ultimosUpdates.sql");

    }

    sub quitarTablasDeMas 
    {
    #########################################################################
    #           QUITAR TABLAS DE MAS!!!             #
    #########################################################################
    my @drops = ('accountlines', 'accountoffsets', 'amazon_covers', 'aqbookfund', 'aqbooksellers', 'aqbudget', 'aqorderbreakdown', 'aqorderdelivery', 'aqorders', 
                  'biblio', 'biblioitems', 'bibliothesaurus', 'borexp', 'branchtransfers', 'catalogueentry', 'categoryitem', 'currency', 'defaultbiblioitem', 
                  'deletedbiblio', 'deletedbiblioitems', 'deleteditems', 'ethnicity', 'isbns', 'isomarc', 'items', 'itemsprices', 'languages', 'marcrecorddone', 
                  'marc_biblio', 'marc_blob_subfield', 'marc_breeding', 'marc_subfield_structure', 'marc_subfield_table', 'marc_tag_structure', 'marc_word', 
                  'printers', 'publisher', 'relationISO', 'reserveconstraints', 'statistics', 'virtual_itemtypes', 'virtual_request', 'websites', 'z3950queue', 
                  'z3950results', 'z3950servers', 'uploadedmarc','generic_report_joins','generic_report_tables','tablasDeReferencias','tablasDeReferenciasInfo',
                  'additionalauthors','bibliosubtitle','bibliosubject','sessionqueries','analyticalkeyword','keyword');

      foreach $tabla (@drops) {
        my $drop=$dbh->prepare(" DROP TABLE ".$tabla." ;");
        $drop->execute();
      }

  }

  sub crearRelacionUsuarioPersona    
  {
# Le agrega el id_persona a usr_socio 
    my $usuarios=$dbh->prepare("SELECT * FROM usr_socio;");
    $usuarios->execute();

    while (my $usuario=$usuarios->fetchrow_hashref) {
        my $persona=$dbh->prepare("SELECT id_persona FROM usr_persona WHERE  nro_documento= ? ;");
        $persona->execute($usuario->{'documentnumber'});
        my $id_persona=$persona->fetchrow;
        

        if (!$id_persona) {
             #No existe la persona HAY QUE CREARLA!!!
        my $nueva_persona=$dbh->prepare("INSERT into usr_persona (nro_documento,tipo_documento,apellido,nombre,titulo,
                                        otros_nombres,iniciales,calle,barrio,ciudad,telefono,email,fax,msg_texto,
                                        alt_calle,alt_barrio,alt_ciudad,alt_telefono,nacimiento,sexo,
                                        telefono_laboral,es_socio,cumple_condicion,legajo) 
                                        values (?,?,?,?,?,
                                                ?,?,?,?,?,?,?,?,?,
                                                ?,?,?,?,?,?,
                                                ?,'1','1','');");
        $nueva_persona->execute($usuario->{'documentnumber'},$usuario->{'documenttype'},$usuario->{'surname'},$usuario->{'firstname'},$usuario->{'title'},
                                $usuario->{'othernames'},$usuario->{'initials'},$usuario->{'streetaddress'},$usuario->{'suburb'},buscarLocalidadDesdeId($usuario->{'city'}),$usuario->{'phone'},$usuario->{'emailaddress'},$usuario->{'faxnumber'},$usuario->{'textmessaging'},
                                $usuario->{'altstreetaddress'},$usuario->{'altsuburb'},buscarLocalidadDesdeId($usuario->{'altcity'}),$usuario->{'altphone'},$usuario->{'dateofbirth'},$usuario->{'sex'}, 
                                $usuario->{'phoneday'});
        
        $persona->execute($usuario->{'documentnumber'});
        $id_persona=$persona->fetchrow;

          }
            my $upuspr=$dbh->prepare(" UPDATE usr_socio SET id_persona = ? WHERE nro_socio= ? ;");
            $upuspr->execute($id_persona,$usuario->{'nro_socio'});
     

    }

#Limpiamos usr_socio
       my $limpiando_usr= "ALTER TABLE `usr_socio`  DROP documentnumber  , DROP `documenttype`,  DROP `surname`,  DROP `firstname`,  DROP `title`,  DROP `othernames`,
        DROP `initials`,  DROP `streetaddress`,  DROP `suburb`,  DROP `city`,  DROP `phone`,  DROP `emailaddress`,  DROP `faxnumber`,
        DROP `textmessaging`,  DROP `altstreetaddress`,  DROP `altsuburb`,  DROP `altcity`,  DROP `altphone`,  DROP `dateofbirth`,  
        DROP `gonenoaddress`,  DROP `lost`,  DROP `debarred`,  DROP `studentnumber`,  DROP `school`,  DROP `contactname`,
        DROP `borrowernotes`,  DROP `guarantor`,  DROP `area`,  DROP `ethnicity`,  DROP `ethnotes`,  DROP `sex`,  DROP `altnotes`,
        DROP `altrelationship`,  DROP `streetcity`,  DROP `phoneday`,  DROP `preferredcont`,  DROP `physstreet`,  DROP `homezipcode`,
        DROP `zipcode`,  DROP `userid`;";

        my $droppr=$dbh->prepare($limpiando_usr);
         $droppr->execute();


#Agregamos KOHAADMIN!!!

 my $kohaadmin_persona="INSERT INTO `usr_persona` (`version_documento`, `nro_documento`, `tipo_documento`, `apellido`, `nombre`, `titulo`, `otros_nombres`, `iniciales`, `calle`, `barrio`, `ciudad`, `telefono`, `email`, `fax`, `msg_texto`, `alt_calle`, `alt_barrio`, `alt_ciudad`, `alt_telefono`, `nacimiento`, `fecha_alta`, `legajo`, `sexo`, `telefono_laboral`, `cumple_condicion`, `es_socio`) VALUES
('P', '1000000', 'DNI', 'kohaadmin', 'kohaadmin', NULL, NULL, 'DGR', '007', NULL, '16648', '', '', NULL, NULL, NULL, NULL, '', NULL, '2009-12-23', NULL, '007', NULL, NULL, 0, 1);";
 my $kp=$dbh->prepare($kohaadmin_persona);
    $kp->execute();
 my $personaka=$dbh->prepare("SELECT id_persona FROM usr_persona WHERE  nro_documento= ? ;");
    $personaka->execute('1000000');
 my $id_persona_kohaadmin=$personaka->fetchrow;

my $kohaadmin_socio="INSERT INTO `usr_socio` (`id_persona`, `nro_socio`, `id_ui`, `cod_categoria`, `fecha_alta`, `expira`, `flags`, `password`, `last_login`, `last_change_password`, `change_password`, `cumple_requisito`, `nombre_apellido_autorizado`, `dni_autorizado`, `telefono_autorizado`, `is_super_user`, `credential_type`, `id_estado`, `activo`, `agregacion_temp`) VALUES
(?, 'kohaadmin', 'DEO', 'DO', NULL, NULL, 1, 'a1q8oyiSjO02w1vpPlwscK+kQdDDbolevtC2ZsZX1Uc', '2010-01-13 00:00:00', '2009-12-13', 0, '0000-00-00', '', '', '', 1, '', 46, '1', 'id_persona');";
 my $ks=$dbh->prepare($kohaadmin_socio);
    $ks->execute($id_persona_kohaadmin);


#habilitamos los socios

 my $act=$dbh->prepare("UPDATE `usr_socio` SET id_estado =20, activo =1 WHERE id_estado =0;");
    $act->execute();

#Agregamos los socios de las personas no habilitadas!!! 

    my $persona=$dbh->prepare("SELECT * FROM usr_persona;");
    $persona->execute();

    while (my $p=$persona->fetchrow_hashref) {
      if(!$p->{'es_socio'}){
           my $usu_0=$dbh->prepare("INSERT INTO usr_socio (id_persona,nro_socio,id_ui,cod_categoria,flags,change_password,is_super_user,id_estado,activo) VALUES
                ( ? , ? ,'DEO','ES', 0, 1, 0, 20, 0);");
             $usu_0->execute($p->{'id_persona'},$p->{'nro_documento'});
      }

    }

  }

  sub hashearPasswords    
  {
  #Re Hasear Pass con sha256
    my $usuarios=$dbh->prepare("SELECT * FROM usr_socio;");
    $usuarios->execute();
    while (my $usuario=$usuarios->fetchrow_hashref) {
      if($usuario->{'password'}){
          my $upus=$dbh->prepare(" UPDATE usr_socio SET password='".C4::AR::Auth::hashear_password($usuario->{'password'},'SHA_256_B64')."' WHERE nro_socio='". $usuario->{'nro_socio'} ."' ;");
          $upus->execute();
      }
    }
  }

    sub pasarTodoAInnodb 
    {
    #########################################################################
    #           PASAR TODO A INNODB             #
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
    #           CREAR CLAVES FORANEAS               #
    #########################################################################
    aplicarSQL("clavesForaneas.sql");
    }

    sub agregarPreferenciasDelSistema 
    {
    #########################################################################
    #           PREFERENCIAS DEL SISTEMA            #
    #########################################################################
    aplicarSQL("preferenciasSistema.sql");
    }


=item
guardaNivel1MARC
Guarda los campos del nivel 1 en un MARC RECORD.
=cut

sub guardaNivel1MARC {
    my ($biblionumber, $nivel1)=@_;

    my $marc = MARC::Record->new();

    foreach my $obj(@$nivel1){
        my $campo=$obj->{'campo'};
        my $subcampo=$obj->{'subcampo'};

        if ($obj->{'simple'}){
            my $valor=$obj->{'valor'};
            if ($valor ne ''){

                    my $field;
                     if ($field=$marc->field($campo)){ #Ya existe el campo, se agrega el subcampo
                         $field->add_subfields( $subcampo => $valor );
                     } else { #NO existe el campo, se agrega uno nuevo
                         $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                         $marc->append_fields($field);
                     }

                }
       }
       else {
            my $arr=$obj->{'valor'};
             foreach my $valor (@$arr){
                if ($valor ne ''){
                    my $field;
                     if ($field=$marc->field($campo)){ #Ya existe el campo, se agrega el subcampo
                         $field->add_subfields( $subcampo => $valor );
                     } else { #NO existe el campo, se agrega uno nuevo
                         $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                         $marc->append_fields($field);
                     }
                }
            }
        }
    }

    my $reg_marc_1 =$dbh->prepare("INSERT INTO cat_registro_marc_n1 (marc_record,biblionumber) VALUES (?,?) ");
       $reg_marc_1->execute($marc->as_usmarc,$biblionumber);


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
    my ($biblionumber,$biblioitemnumber,$id1, $nivel2)=@_;

    my $marc = MARC::Record->new();

    foreach my $obj(@$nivel2){
        my $campo=$obj->{'campo'};
        my $subcampo=$obj->{'subcampo'};

        if ($obj->{'simple'}){
            my $valor=$obj->{'valor'};
            if ($valor ne ''){
                    my $field;
                     if ($field=$marc->field($campo)){ #Ya existe el campo, se agrega el subcampo
                         $field->add_subfields( $subcampo => $valor );
                     } else { #NO existe el campo, se agrega uno nuevo
                         $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                         $marc->append_fields($field);
                     }
                }
       }
       else {
            my $arr=$obj->{'valor'};
             foreach my $valor (@$arr){
                if ($valor ne ''){
                    my $field;
                     if ($field=$marc->field($campo)){ #Ya existe el campo, se agrega el subcampo
                         $field->add_subfields( $subcampo => $valor );
                     } else { #NO existe el campo, se agrega uno nuevo
                         $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                         $marc->append_fields($field);
                     }
                }
            }
        }
    }

    my $reg_marc_2 =$dbh->prepare("INSERT INTO cat_registro_marc_n2 (marc_record,id1,biblionumber,biblioitemnumber) VALUES (?,?,?,?) ");
       $reg_marc_2->execute($marc->as_usmarc,$id1,$biblionumber,$biblioitemnumber);


        my $query_MAX = "SELECT MAX(id) FROM cat_registro_marc_n2";
        my $sth_MAX = $dbh->prepare($query_MAX);
        $sth_MAX->execute();
        my $id2_nuevo = $sth_MAX->fetchrow;

    return($id2_nuevo);
}


=item
guardaNivel3MARC
Guarda los campos del nivel 2 en un MARC RECORD.
=cut

sub guardaNivel3MARC {
    my ($biblionumber,$biblioitemnumber,$itemnumber,$id1,$id2,$nivel3)=@_;

    my $marc = MARC::Record->new();

    foreach my $obj(@$nivel3){
        my $campo=$obj->{'campo'};
        my $subcampo=$obj->{'subcampo'};

        if ($obj->{'simple'}){
            my $valor=$obj->{'valor'};
            if ($valor ne ''){
                    my $field;
                     if ($field=$marc->field($campo)){ #Ya existe el campo, se agrega el subcampo
                         $field->add_subfields( $subcampo => $valor );
                     } else { #NO existe el campo, se agrega uno nuevo
                         $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                         $marc->append_fields($field);
                     }
                }
       }
       else {
            my $arr=$obj->{'valor'};
             foreach my $valor (@$arr){
                if ($valor ne ''){
                    my $field;
                     if ($field=$marc->field($campo)){ #Ya existe el campo, se agrega el subcampo
                         $field->add_subfields( $subcampo => $valor );
                     } else { #NO existe el campo, se agrega uno nuevo
                         $field = MARC::Field->new($campo,'','',$subcampo => $valor);
                         $marc->append_fields($field);
                     }
                }
            }
        }
    }

    my $reg_marc_2 =$dbh->prepare("INSERT INTO cat_registro_marc_n3 (marc_record,id1,id2,biblionumber,biblioitemnumber,itemnumber) VALUES (?,?,?,?,?,?) ");
       $reg_marc_2->execute($marc->as_usmarc,$id1,$id2,$biblionumber,$biblioitemnumber,$itemnumber);


        my $query_MAX = "SELECT MAX(id) FROM cat_registro_marc_n3";
        my $sth_MAX = $dbh->prepare($query_MAX);
        $sth_MAX->execute();
        my $id3_nuevo = $sth_MAX->fetchrow;

    return($id3_nuevo);
}


    #########################################################################
    #           ESTRUCTURA CATALOGACION               #
    #########################################################################
  sub crearEstructuraMarc {

        aplicarSQL("estructuraMARC.sql");

    }
    #########################################################################
    #           GRACIAS!!!!!!!!!!               #
    #########################################################################

  sub aplicarSQL {
    my ($sql)=@_;

    my $PASSWD = C4::Context->config("pass");
    my $USER = C4::Context->config("user");
    my $BASE = C4::Context->config("database");

    system("mysql -f --default-character-set=utf8 $BASE -u$USER -p$PASSWD < $sql ") == 0 or print "Fallo el sql ".$sql." \n";

    }

