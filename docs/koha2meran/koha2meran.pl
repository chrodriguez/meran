#!/usr/bin/perl

use CGI::Session;
use C4::Context;
use MARC::Record;
use Digest::SHA  qw(sha1 sha1_hex sha1_base64 sha256_base64 );

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
my $tt1 = time();
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

print "Renombrando tablas \n";
  renombrarTablas();
print "Quitando tablas de mas \n";
 quitarTablasDeMas();
print "Hasheando passwords \n";
   hashearPasswords();
print "Limpiamos las tablas de circulacion \n";
limpiarCirculacion();
print "Referencias de usuarios en circulacion \n";
my $st2 = time();
  repararReferenciasDeUsuarios();
my $end2 = time();
my $tardo2=($end2 - $st2);
print "AL FIN TERMINARON LOS USUARIOS!!! Tardo $tardo2 segundos !!!\n";

print "Relacion usuario-persona \n";
  crearRelacionUsuarioPersona();
print "Creando nuevas claves foraneas \n";
  crearClaves();
print "Creando la estructura MARC \n";
 crearEstructuraMarc();
print "Traducción Estructura MARC \n";
  traduccionEstructuraMarc();
print "Agregando preferencias del sistema \n";
  agregarPreferenciasDelSistema();
print "FIN!!! \n";
my $tt2 = time();
print "\n GRACIAS DICO!!! \n";

my $tardo2=($tt2 - $tt1);
my $min= $tardo2/60;
my $hour= $min/60;
print "AL FIN TERMINO TODO!!! Tardo $tardo2 segundos !!! que son $min minutos !!! o mejor $hour horas !!!\n";

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
		if($_->{'campoTabla'} eq 'author'){ 
		      $dn1->{'valor'}='cat_autor@'.$biblio->{$_->{'campoTabla'}}; 
		  }
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
	
	my $additionalauthors=$dbh->prepare("SELECT * FROM additionalauthors where id1= ?;");
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
	&guardaNivel1MARC($biblio->{'biblionumber'},\@ids1);

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
# LA Localidad pasa como texto
#         elsif($_->{'campoTabla'} eq 'place'){ #Esto no se puede pasar sin buscar la referencia
#                      my $idLocalidad= buscarLocalidadParecida($biblioitem->{$_->{'campoTabla'}});
#                       $dn2->{'valor'}='ref_localidad@'.$idLocalidad; 
#               } 
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

    &guardaNivel2MARC($biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},\@ids2);

#ACA HAY QUE PROCESAR LAS ANALITICAS DE ESTE NIVEL 2!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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

        if($_->{'campoTabla'} eq 'notforloan'){   
	    my $disponibilidad = getDisponibilidad($item->{$_->{'campoTabla'}}) || 'CIRC0001'; # Para sala por defecto.
	    $val='ref_disponibilidad@'.$disponibilidad;
	}
        elsif($_->{'campoTabla'} eq 'homebranch'){$val='pref_unidad_informacion@'.$item->{$_->{'campoTabla'}}; }
        elsif($_->{'campoTabla'} eq 'wthdrawn'){ 
                                            if ($item->{$_->{'campoTabla'}}){
                                                     # Si no es 0 va con el valor original
							  my $estado = getEstado($item->{$_->{'campoTabla'}}) || 'STATE000'; #Si no se encuentra la disponibilidad, de baja.
                                                          $val='ref_estado@'.$item->{$_->{'campoTabla'}};
                                                    }
                                                    else {
                                                     # Si es 0, está disponible, va con el nuevo estado que es STATE002
                                                          $val='ref_estado@STATE002';
                                                    } #Esta disponible ==> STATE002
                                                 }
        elsif($_->{'campoTabla'} eq 'holdingbranch'){ $val='pref_unidad_informacion@'.$item->{$_->{'campoTabla'}}; }
          else { $val=$item->{$_->{'campoTabla'}}; }


		$dn3->{'valor'}=$val;
		$dn3->{'simple'}=1;
		if (($dn3->{'valor'} ne '') && ($dn3->{'valor'} ne null)){push(@ids3,$dn3);}
	}
	
	&guardaNivel3MARC($biblio->{'biblionumber'},$biblioitem->{'biblioitemnumber'},$item->{'itemnumber'},\@ids3);


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

	sub crearNuevasReferencias
	{
	#########################################################################
	#			NUEVAS REFERENCIAS!!!!!				#
	#########################################################################
	
	#Nivel 1#

	my $col=$dbh->prepare("ALTER TABLE `colaboradores` CHANGE biblionumber `id1` INT( 11 ) NOT NULL FIRST ;");
   	$col->execute();

    my $adaut=$dbh->prepare("ALTER TABLE additionalauthors CHANGE biblionumber `id1` INT( 11 ) NOT NULL FIRST ;");
    $adaut->execute();

	#Nivel 2#
	my $banalysis=$dbh->prepare("ALTER TABLE `biblioanalysis` CHANGE biblionumber `id1` INT( 11 ) NOT NULL FIRST , 
					CHANGE biblioitemnumber `id2` INT( 11 ) NOT NULL AFTER `id1` ;");
	$banalysis->execute();
	my $reserves=$dbh->prepare("ALTER TABLE `reserves` CHANGE biblioitemnumber `id2` INT( 11 ) NOT NULL FIRST , 
					CHANGE itemnumber `id3` INT( 11 ) NULL AFTER `id2` ;");
	$reserves->execute();
	my $estantes=$dbh->prepare("ALTER TABLE `shelfcontents` CHANGE biblioitemnumber `id2` INT( 11 ) NOT NULL FIRST ;");
	$estantes->execute();
	#Nivel 3#
	my $av1=$dbh->prepare("ALTER TABLE `availability` CHANGE item `id3` INT( 11 ) NOT NULL FIRST ;");
	$av1->execute();

	my $hi1=$dbh->prepare("ALTER TABLE `historicIssues` CHANGE itemnumber `id3` INT( 11 ) NOT NULL FIRST ;");
	$hi1->execute();

	my $hc1=$dbh->prepare("ALTER TABLE `historicCirculation` CHANGE biblionumber `id1` INT( 11 ) NOT NULL AFTER `id` ,
		CHANGE biblioitemnumber `id2` INT( 11 ) NOT NULL AFTER `id1` ,
		CHANGE itemnumber `id3` INT( 11 ) NOT NULL AFTER `id2` ;");
	$hc1->execute();

	my $is1=$dbh->prepare("ALTER TABLE `issues` CHANGE itemnumber `id3` INT( 11 ) NOT NULL FIRST ;");
	$is1->execute();
	#Los 3 Niveles#
	my $mod=$dbh->prepare("ALTER TABLE `modificaciones` CHANGE numero `id` INT( 11 ) NOT NULL AFTER idModificacion ;");
	$mod->execute();

    my $loc1=  $dbh->prepare("ALTER TABLE localidades DROP PRIMARY KEY;");
    $loc1->execute();
    my $loc2=  $dbh->prepare("ALTER TABLE localidades ADD `id` INT NOT NULL AUTO_INCREMENT FIRST ,ADD PRIMARY KEY ( id );");
    $loc2->execute();
	#########################################################################
	#			FIN NUEVAS REFERENCIAS!!!!!			#
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
    my @drops = ('accountlines', 'accountoffsets', 'aqbookfund', 'aqbooksellers', 'aqbudget', 'aqorderbreakdown', 'aqorderdelivery', 'aqorders', 
                  'biblio', 'biblioitems', 'bibliothesaurus', 'borexp', 'branchtransfers', 'catalogueentry', 'categoryitem', 'currency', 'defaultbiblioitem', 
                  'deletedbiblio', 'deletedbiblioitems', 'deleteditems', 'ethnicity', 'isbns', 'isomarc', 'items', 'itemsprices', 'marcrecorddone', 
                  'marc_biblio', 'marc_blob_subfield', 'marc_breeding', 'marc_subfield_structure', 'marc_subfield_table', 'marc_tag_structure', 'marc_word', 
                  'printers', 'relationISO', 'reserveconstraints', 'statistics', 'virtual_itemtypes', 'virtual_request', 'websites', 'z3950queue', 
                  'z3950results', 'z3950servers', 'uploadedmarc','generic_report_joins','generic_report_tables','tablasDeReferencias','tablasDeReferenciasInfo',
                  'additionalauthors','bibliosubtitle','bibliosubject','sessionqueries','analyticalkeyword','keyword','unavailable','users','categories','stopwords');

      foreach $tabla (@drops) {
        my $drop=$dbh->prepare(" DROP TABLE ".$tabla." ;");
        $drop->execute();
      }

  }

  sub crearRelacionUsuarioPersona    
  {

#Default ui
    my $q_ui=$dbh->prepare("SELECT value FROM pref_preferencia_sistema where variable ='defaultbranch';");
    $q_ui->execute();
    my $ui=$q_ui->fetchrow || 'DEO';


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
     
            #seteamos que es socio
            my $persocio=$dbh->prepare(" UPDATE usr_persona SET es_socio='1' WHERE id_persona= ? ;");
            $persocio->execute($id_persona);
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
(?, 'kohaadmin', ? , 'ES', NULL, NULL, 1, 'a1q8oyiSjO02w1vpPlwscK+kQdDDbolevtC2ZsZX1Uc', '2010-01-13 00:00:00', '2009-12-13', 0, '0000-00-00', '', '', '', 1, '', 46, '1', 'id_persona');";
 my $ks=$dbh->prepare($kohaadmin_socio);
    $ks->execute($id_persona_kohaadmin,$ui);


#habilitamos los socios

 my $act=$dbh->prepare("UPDATE `usr_socio` SET id_estado =20, activo =1 WHERE id_estado =0;");
    $act->execute();

#Agregamos los socios de las personas no habilitadas!!! 

    my $persona=$dbh->prepare("SELECT * FROM usr_persona;");
    $persona->execute();

    while (my $p=$persona->fetchrow_hashref) {
      if(!$p->{'es_socio'}){
           my $usu_0=$dbh->prepare("INSERT INTO usr_socio (id_persona,nro_socio,id_ui,cod_categoria,flags,change_password,is_super_user,id_estado,activo) VALUES
                ( ? , ? ,?,'ES', 0, 1, 0, 20, 0);");
             $usu_0->execute($p->{'id_persona'},$p->{'nro_documento'},$ui);
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
          my $upus=$dbh->prepare(" UPDATE usr_socio SET password='".sha256_base64($usuario->{'password'})."' WHERE nro_socio='". $usuario->{'nro_socio'} ."' ;");
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

    my $reg_marc_1 =$dbh->prepare("INSERT INTO cat_registro_marc_n1 (marc_record,id) VALUES (?,?) ");
       $reg_marc_1->execute($marc->as_usmarc,$biblionumber);
}




=item
guardaNivel2MARC
Guarda los campos del nivel 2 en un MARC RECORD.
=cut

sub guardaNivel2MARC {
    my ($biblionumber,$biblioitemnumber, $nivel2)=@_;

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

    my $reg_marc_2 =$dbh->prepare("INSERT INTO cat_registro_marc_n2 (marc_record,id1,id) VALUES (?,?,?) ");
       $reg_marc_2->execute($marc->as_usmarc,$biblionumber,$biblioitemnumber);

}


=item
guardaNivel3MARC
Guarda los campos del nivel 2 en un MARC RECORD.
=cut

sub guardaNivel3MARC {
    my ($biblionumber,$biblioitemnumber,$itemnumber,$nivel3)=@_;

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

    my $reg_marc_3 =$dbh->prepare("INSERT INTO cat_registro_marc_n3 (marc_record,id1,id2,id,codigo_barra,signatura) VALUES (?,?,?,?,?,?	)");
	my $codigo=trim($marc->subfield("995","f"));
	my $signatura=trim($marc->subfield("995","t")) || "Signatura ".$itemnumber;# LA SIGNATURA ES OBLIGATORIA!!!

       $reg_marc_3->execute($marc->as_usmarc,$biblionumber,$biblioitemnumber,$itemnumber,$codigo,$signatura);

}


    #########################################################################
    #           ESTRUCTURA CATALOGACION                                     #
    #########################################################################
  sub crearEstructuraMarc {

        aplicarSQL("estructuraMARC.sql");

    }

sub traduccionEstructuraMarc {

        aplicarSQL("traduccionBibliaMARC.sql");

    }

    ###########################################################################################################
    #                                    REPARARAR REFERENCIAS SOCIO                                          #
    #           En todos lados se utiliza nro_socio pero en koha hay tablas que tienen id_socio               #
    #                                           circ_reserva                                                  #
    #                                           circ_prestamo                                                 #
    #                                           circ_sancion                                                  #
    #                                         rep_historial_circulacion                                       #
    #                                          rep_historial_sancion                                          #
    #                                          rep_historial_prestamo                                         #
    ###########################################################################################################

  sub repararReferenciasDeUsuarios {


    my $cant_usr=$dbh->prepare("SELECT count(*) as cantidad FROM usr_socio ;");
    $cant_usr->execute();
    my $cantidad=$cant_usr->fetchrow;
    my $num_usuario=1;
    print "Se van a procesar $cantidad usuarios \n";


    my @refusrs = ('circ_reserva','circ_prestamo','circ_sancion','rep_historial_circulacion','rep_historial_sancion','rep_historial_prestamo');
    

    my $usuarios=$dbh->prepare("SELECT * FROM usr_socio;");
    $usuarios->execute();

    while (my $usuario=$usuarios->fetchrow_hashref) {

    my $porcentaje= int (($num_usuario * 100) / $cantidad );
    print "Procesando usuario: $num_usuario de $cantidad ($porcentaje%) \r";

        foreach $tabla (@refusrs)
      {
            my $refusuario=$dbh->prepare("UPDATE $tabla  SET nro_socio='".$usuario->{'nro_socio'}."' WHERE borrowernumber='". $usuario->{'id_socio'} ."' ;");
            $refusuario->execute();
      }

    $num_usuario++;
    }


    foreach $tabla (@refusrs)
    {
      my $refusr=$dbh->prepare("ALTER TABLE $tabla DROP borrowernumber;");
      $refusr->execute();
    }

    }


#### Se limpian las tablas de circulacion ####

  sub limpiarCirculacion {

        aplicarSQL("limpiarCirculacion.sql");

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

  sub getEstado {
    my ($id)=@_;

    my $q_estado=$dbh->prepare("SELECT codigo FROM ref_estado where id = ? ;");
    $q_estado->execute($id);
    my $estado=$q_estado->fetchrow;
    return $estado;
    }

  sub getDisponibilidad {
    my ($id)=@_;

    my $q_disp=$dbh->prepare("SELECT codigo FROM ref_disponibilidad where id = ? ;");
    $q_disp->execute($id);
    my $disp=$q_disp->fetchrow;
    return $disp;
    }

sub trim{
    my ($string) = @_;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}