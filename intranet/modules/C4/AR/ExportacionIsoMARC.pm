package C4::AR::ExportacionIsoMARC;

#
#para la exportacion de registros a marc
#

use strict;
require Exporter;

use C4::Context;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(

	getMarcSubfieldFromKohaField
	getMapeoKohaMarc
	getMarcSubfieldsFromBiblio
	getMarcRecordFromBiblio
	getMarcRecordFromBiblioitem
	getMarcRecordFromItem
	getExportFromBiblio
	getBibliosFromRange

);

my $mapeo_koha_marc=undef;

=head2 getMapeoKohaMarc

=over 4
($MARCfield,$MARCsubfield)=GetMarcFromKohaField($kohafield,$frameworkcode);
Returns the MARC fields & subfields mapped to the koha field 

=back

=cut

sub getMapeoKohaMarc {

    if (defined($mapeo_koha_marc)) {
        return $mapeo_koha_marc;
    } else {
        $mapeo_koha_marc->{'biblio'}        = getMarcSubfieldsFromBiblio();
        $mapeo_koha_marc->{'biblioitem'}    = getMarcSubfieldsFromBiblioitem();
        $mapeo_koha_marc->{'item'}          = getMarcSubfieldsFromItem();

        return $mapeo_koha_marc;
    }
    1;
}


=head2 getMarcSubfieldFromKohaField

=over 4
($MARCfield,$MARCsubfield)=GetMarcFromKohaField($kohafield,$frameworkcode);
Returns the MARC fields & subfields mapped to the koha field 

=back

=cut

sub getMarcSubfieldFromKohaField {
    my ( $kohafield ) = @_;

    my $dbh = C4::Context->dbh;
    my %results;
    my $query ="SELECT * FROM marc_subfield_structure WHERE kohafield='?';";
        my $sth=$dbh->prepare($query);
    $sth->execute($kohafield);
    my $marc=$sth->fetchrow_hashref;
    return $marc;
}


=head2 getMarcSubfieldsFromBiblio

=over 4
getMarcSubfieldsFromBiblio = campos marc del biblio

=back

=cut

sub getMarcSubfieldsFromBiblio {

    my $dbh = C4::Context->dbh;
    my %loop_data;

    my $query   = "SELECT tagfield,tagsubfield,kohafield,kohadefault FROM marc_subfield_structure WHERE kohafield like 'biblio.%' or kohafield like 'bibliosubject.%' or kohafield like 'bibliosubtitle.%' or kohafield like 'additionalauthors.%' or kohafield like 'colaboradores.%' ORDER BY kohadefault DESC;";
    my $sth     = $dbh->prepare($query);
    $sth->execute();
    while ( my $row = $sth->fetchrow_hashref ) {
        my %row_data;
		$row_data{campo}                = $row->{tagfield};
		$row_data{subcampo}             = $row->{tagsubfield};
		$row_data{kohadefault}          = $row->{kohadefault};
		my @aux                         = split(/\./,$row->{kohafield});
		$row_data{campokoha}            = $aux[1];
		$row_data{tablakoha}            = $aux[0];
		push(@{$loop_data{$row->{kohafield}}} , \%row_data);
    }

    $sth->finish;

    return \%loop_data;
}


sub getSubfields {
    my $dbh = C4::Context->dbh;
    my %loop_data;

    my $query   = " SELECT tagfield,tagsubfield,kohafield FROM marc_subfield_structure WHERE kohafield IS NOT NULL AND kohafield <> '' ;";
    my $sth     = $dbh->prepare($query);
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        my @aux = split(/\./, $row->{kohafield});
        $loop_data{$row->{tagfield}.','.$row->{tagsubfield}}->{'tabla'}    = $aux[0];
        $loop_data{$row->{tagfield}.','.$row->{tagsubfield}}->{'field'}    = $aux[1];
#             C4::AR::Debug::debug("ExportacionIsoMARC => getSubfields => key ".$row->{tagfield}.','.$row->{tagsubfield}." tabla ".$aux[1]);
    }

    $sth->finish;

    return \%loop_data;
}

=item getTablaFromSubfield
  Obtiene el nombre de la tabla KOHA segun el campo y subcampo
=cut
sub getTablaFromSubfieldByCampoSubcampo {
    my ($campo, $subcampo) = @_;

    my $key = $campo.','.$subcampo;

    my ($subfields_hash_ref) = getSubfields();
    my $tabla = $subfields_hash_ref->{$key}->{'tabla'};
    my $field = $subfields_hash_ref->{$key}->{'field'};

    C4::AR::Debug::debug("ExportacionIsoMARC => getTablaFromSubfieldByCampoSubcampo => campo, subcampo => ".$key);
    C4::AR::Debug::debug("ExportacionIsoMARC => getTablaFromSubfieldByCampoSubcampo => Tabla => ".$tabla);
    C4::AR::Debug::debug("ExportacionIsoMARC => getTablaFromSubfieldByCampoSubcampo => Field => ".$field);
    return ($tabla, $field);
}

sub verificarExistenciaDeDato {
    my ($campo, $subcampo, $dato) = @_;

    my ($tabla, $field) = getTablaFromSubfieldByCampoSubcampo($campo, $subcampo);
    
    my $dbh     = C4::Context->dbh;


# TODO agregue esto para q funcione por ahora, luego SACARLO!!!!!!!!!
    my $query   = "SET NAMES utf8;";
    my $sth     = $dbh->prepare($query);
       $sth->execute();

    my $query   = "SELECT count(*) AS cant FROM $tabla WHERE $field = ?;";
    my $sth     = $dbh->prepare($query);
       $sth->execute($dato);
    
    my $data = $sth->fetchrow_hashref;
    
    C4::AR::Debug::debug("ExportacionIsoMARC => verificarExistenciaDeDato => cant =>  ".$data->{'cant'});
    my $query   = "SELECT count(*) AS cant FROM $tabla WHERE $field = ?;";
    my $sth     = $dbh->prepare($query);
       $sth->execute($dato);
    C4::AR::Debug::debug("ExportacionIsoMARC => verificarExistenciaDeDato => cant =>  ".$data->{'cant'});

    return $data->{'cant'};
}


=head2 getMarcSubfieldsFromBiblioitem

=over 4
getMarcSubfieldsFromBiblioitem = campos marc del biblioitem

=back

=cut

sub getMarcSubfieldsFromBiblioitem {

    my $dbh = C4::Context->dbh;
    my %loop_data;

    my $query ="SELECT tagfield,tagsubfield,kohafield,kohadefault FROM marc_subfield_structure WHERE kohafield like 'biblioitems.%' or kohafield like 'isbns.%' or kohafield like 'publisher.%' ORDER BY kohadefault DESC;";
    my $sth=$dbh->prepare($query);
    $sth->execute();
    while ( my $row = $sth->fetchrow_hashref ) {
        my %row_data;

		$row_data{campo}                = $row->{tagfield};
		$row_data{subcampo}             = $row->{tagsubfield};
		$row_data{kohadefault}          = $row->{kohadefault};
		my @aux                         = split(/\./,$row->{kohafield});
		$row_data{campokoha}            = $aux[1];
		$row_data{tablakoha}            = $aux[0];
		push(@{$loop_data{$row->{kohafield}}},\%row_data);
    }

    $sth->finish;
    return \%loop_data;
}

=head2 getMarcSubfieldsFromItem

=over 4
getMarcSubfieldsFromItem = campos marc del item

=back

=cut

sub getMarcSubfieldsFromItem {

    my $dbh = C4::Context->dbh;
    my %loop_data;

    my $query = " SELECT tagfield,tagsubfield,kohafield,kohadefault FROM marc_subfield_structure WHERE kohafield like 'items.%' ORDER BY kohadefault DESC; ";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    while ( my $row = $sth->fetchrow_hashref ) {
        my %row_data;

		$row_data{campo}                = $row->{tagfield};
		$row_data{subcampo}             = $row->{tagsubfield};
		$row_data{kohadefault}          = $row->{kohadefault};
		my @aux                         = split(/\./,$row->{kohafield});
		$row_data{campokoha}            = $aux[1];
		$row_data{tablakoha}            = $aux[0];
		push(@{$loop_data{$row->{kohafield}}},\%row_data);
    }

    $sth->finish;
    return \%loop_data;
}


=head2 getMarcRecordFromBiblio

=over 4
Obtenemos el Marc::Record de un biblio
=back

=cut

sub getKohaToMarcByTablaCampo {
    my ($tablahash,$tabla,$campo,$id ) = @_;

    my %registroMarc;
    my $dato;
    my $camposKohaMarc = getMapeoKohaMarc;
    
    my $dbh     = C4::Context->dbh;
    my $query   = "SELECT * FROM $tabla WHERE $campo = ?;";
    my $sth     = $dbh->prepare($query);
       $sth->execute($id);
    my @datosKoha;
    
    while (my $datos = $sth->fetchrow_hashref) {
        push(@datosKoha,$datos);
    }
    
    my $sth2=$dbh->prepare("SHOW COLUMNS from $tabla");
    $sth2->execute;
#     C4::AR::Debug::debug("getKohaToMarcByTablaCampo => PROCESANDO la tabla ============ ".$tabla." ============");

    while ((my $campotabla) = $sth2->fetchrow_array) {
#         C4::AR::Debug::debug("getKohaToMarcByTablaCampo => tabla: ".$tabla." campo de la tabla: ".$campotabla);
    
        if ($camposKohaMarc->{$tablahash}->{$tabla.".".$campotabla}){
            my $campo;
            my $subcampo;
            foreach my $hash_record (@{$camposKohaMarc->{$tablahash}->{$tabla.".".$campotabla}}){
                if((!$campo)||($hash_record->{default})){
                        $campo    = $hash_record->{campo};
                        $subcampo = $hash_record->{subcampo};
                        }
                }
#             C4::AR::Debug::debug("getKohaToMarcByTablaCampo => se van a procesar ".scalar(@datosKoha)." campos");
            foreach my $datos (@datosKoha) {
#                 C4::AR::Debug::debug("getKohaToMarcByTablaCampo => PROCESANDO ===> campo: ".$campo." subcampo: ".$subcampo."  valor:".$datos->{$campotabla});
                if ($datos->{$campotabla}){
                    #obtengo la referencia si es necesario, sino devuelve el mismo dato
# C4::AR::Debug::debug("ExportacionIsoMARC => getKohaToMarcByTablaCampo => campo, subcampo, dato => ".$campo.", ".$subcampo.", ".$datos->{$campotabla});
                    $dato = getDatoFromReferencia($campo, $subcampo, $datos->{$campotabla});
                    push @{$registroMarc{$campo}} , ($subcampo => $dato);
                }
            }
        } else {
#             C4::AR::Debug::debug("getKohaToMarcByTablaCampo => NO EXISTE MAPEO para tabla: ".$tabla." campo de la tabla: ".$campotabla);
        }
    }

    return \%registroMarc;
}

=item sub marc_record_to_ISO

  pasa un marc_record_array_to_ISO a un arhivo ISO
=cut
sub marc_record_array_to_ISO {
    my ($marc_record_array_ref) = @_;

    foreach my $marc_record (@$marc_record_array_ref){
#             $marc_record->encoding( 'UTF-8' );
          print $marc_record->as_usmarc();
    }
}

sub limpiar_enter_para_roble {
    my ($marc_record_unido) = @_;
    #Para ROBLE limpio de \n y \r de los campos de notas (520a,534a,500a)
        #Un solo campo
        if (( $marc_record_unido->field('520') )&&( $marc_record_unido->field('520')->subfield('a') )) {
            my $nota=$marc_record_unido->field('520')->subfield('a');
            $nota =~ s/\n//ig;
            $nota =~ s/\r/ /ig;
            $marc_record_unido->field('520')->update( 'a' => $nota );
        }
        #Un solo campo
        if (( $marc_record_unido->field('534') )&&( $marc_record_unido->field('534')->subfield('a') )) {
            my $nota=$marc_record_unido->field('534')->subfield('a');
            $nota =~ s/\n//ig;
            $nota =~ s/\r/ /ig;
            $marc_record_unido->field('534')->update( 'a' => $nota );
        }
        #Varios campos
        if (( $marc_record_unido->field('500') )&&( $marc_record_unido->field('500')->subfield('a') )) {
            my @campos = $marc_record_unido->field('500');
            $marc_record_unido->delete_fields(@campos);
            foreach my $field (@campos){
                my @notas=$field->subfield('a');
                $field->delete_subfield(code => 'a');
                foreach my $nota (@notas){
                    $nota =~ s/\n//ig;
                    $nota =~ s/\r/ /ig;
                    $field->add_subfields( 'a' => $nota );
                }
             $marc_record_unido->append_fields($field);
            }
        }
    return $marc_record_unido;
}

=item sub marc_record_to_ISO_from_range
  exporta un rago de biblios pasados por parametro a un archivo ISO
=cut
sub marc_record_to_ISO_from_range {
    my ( $query ) = @_;

    use Time::HiRes;
    my $start = [ Time::HiRes::gettimeofday( ) ];

    my ($cant, @biblios_array) = C4::AR::ExportacionIsoMARC::getRecordsFromRange( $query );
    my @records_array;
    my $marc_record_array_ref;
    my $field_ident_biblioteca  = MARC::Field->new('910','','','a' => C4::Context->preference("defaultbranch"));
    my $field_ident_universidad = MARC::Field->new('040','','','a' => C4::Context->preference("origen_catalogacion"));

    if($query->param('export_format') eq "xml"){print MARC::File::XML::header();}

    foreach my $b (@biblios_array){
        $marc_record_array_ref = C4::AR::ExportacionIsoMARC::getExportFromBiblio($b->{'biblionumber'}, $query->param('exportar_ejemplares'));

        if($query->param('export_type') eq "isis_marc"){
            #Se exporta todo en un registro para  Roble
            my $marc_record_unido = MARC::Record->new();

            foreach my $marc_record (@$marc_record_array_ref){
                 #elimino el campo 090 que es para KOHA
                $marc_record->delete_field($marc_record->field('090'));
                $marc_record_unido->append_fields( $marc_record->fields());
            }
            $marc_record_unido->append_fields($field_ident_biblioteca);
            $marc_record_unido->append_fields($field_ident_universidad);

            if($query->param('export_format') eq "iso"){

                #Para ROBLE limpio de \n y \r de los campos de notas (520a,534a,500a,995u)
                $marc_record_unido = C4::AR::ExportacionIsoMARC::limpiar_enter_para_roble($marc_record_unido);

                # Para ROBLE reemplazo el separador de subcampo \x1F por ^ 
                my $registro_marc= $marc_record_unido->as_usmarc();
                $registro_marc =~ s/\x1F/\^/ig;
                print $registro_marc;

            } else {
                print MARC::File::XML::record( $marc_record_unido );
            }

        } else {
                #Se exporta todos los registros separados para poder volver a utilizar en Koha
            foreach my $marc_record (@$marc_record_array_ref){
                if($query->param('export_format') eq "iso"){
                    print $marc_record->as_usmarc();
                } else {
                    print MARC::File::XML::record( $marc_record );
                }

            }
        }
    }
    if($query->param('export_format') eq "xml"){print MARC::File::XML::footer();}
    
    my $elapsed             = Time::HiRes::tv_interval( $start );
    exit;
}


=item sub getDatoFromReferencia

Obtiene el dato de la referencia si es necesario
=cut
sub getDatoFromReferencia {
    my ($campo, $subcampo, $referencia) = @_;  

    use Switch;
 #   use C4::Search;
#     C4::AR::Debug::debug("getDatoFromReferencia => campo: ".$campo." subcampo: ".$subcampo." dato: ".$referencia);

    my $dato = $referencia;

#    switch($campo.$subcampo) {
      # Referencias a Autores
#      case "100a" { $dato = C4::Search::getautor($referencia)->{'completo'}; }  # - biblio.author (100 a) --> autores.id --> autores.completo     
#      case "110a" { $dato = C4::Search::getautor($referencia)->{'completo'}; }  # - biblio.author (110 a) --> autores.id --> autores.completo     
#      case "111a" { $dato = C4::Search::getautor($referencia)->{'completo'}; }  # - biblio.author (111 a) --> autores.id --> autores.completo     
#      case "700a" { $dato = C4::Search::getautor($referencia)->{'completo'}; }  # - additionalauthors.author (700 a) --> autores.id --> autores.completo
#      case "710a" { $dato = C4::Search::getautor($referencia)->{'completo'}; }  # - colaboradores.idColaborador (710 a) --> autores.id --> autores.completo
      # Referencias a Temas
#      case "650a" { $dato = C4::Search::getTema($referencia)->{'nombre'}; }     # - bibliosubjet.subject (650 a) --> temas.id --> temas.nombre
#      case "651a" { $dato = C4::Search::getTema($referencia)->{'nombre'}; }     # - bibliosubjet.subject (651 a) --> temas.id --> temas.nombre
#      case "653a" { $dato = C4::Search::getTema($referencia)->{'nombre'}; }     # - bibliosubjet.subject (653 a) --> temas.id --> temas.nombre
#    }

#     C4::AR::Debug::debug("getDatoFromReferencia => salida: ".$dato);
    return $dato;
}

sub unirHashes {
   my ($hash1,$hash2) = @_;
   
#    C4::AR::Debug::debug("UNIENDO HASHES");
    my %new_hash = %$hash1;
    
    foreach my $key2 ( keys %$hash2 )
    {
# 		C4::AR::Debug::debug("UNIENDO HASHES KEY : ".$key2);
        if( exists $hash1->{$key2} ) {
            #CAMPOS DUPLICADOS: UNIMOS LOS ARREGLOS DE SUBCAMPOS!!!
            # FIXME  FIXME FIXME FIXME FIXME FIXME FIXME
            my @aux=();
            
            my $clave=1;
            my $k;
            my $v;
            foreach my $val (@{$hash1->{$key2}}) {
                if($clave){ $k=$val; $clave=0;}
                else { $v=$val;$clave=1; push (@aux,($k=>$v))}
            }
            
            $clave=1;
            foreach my $val (@{$hash2->{$key2}}) {
                if($clave){ $k=$val; $clave=0;}
                else { $v=$val;$clave=1; push (@aux,($k=>$v))}
            }
            @{$new_hash{$key2}}=@aux;
            # FIXME  FIXME FIXME FIXME FIXME FIXME FIXME
        } else {
            $new_hash{$key2} = $hash2->{$key2};
# 			C4::AR::Debug::debug("UNIENDO HASHES : NUEVO!! ");
        }
    }

   return \%new_hash;
}

=head2 getKohaToMarcBiblio

=over 4

=back

=cut

sub getKohaToMarcBiblio {
    my ( $biblionumber ) = @_;

    my $registroMarc= getKohaToMarcByTablaCampo('biblio','biblio','biblionumber',$biblionumber);
       $registroMarc= unirHashes( $registroMarc ,getKohaToMarcByTablaCampo('biblio','additionalauthors','biblionumber',$biblionumber));
       $registroMarc= unirHashes( $registroMarc ,getKohaToMarcByTablaCampo('biblio','bibliosubject','biblionumber',$biblionumber));
       $registroMarc= unirHashes( $registroMarc ,getKohaToMarcByTablaCampo('biblio','bibliosubtitle','biblionumber',$biblionumber));
       $registroMarc= unirHashes( $registroMarc ,getKohaToMarcByTablaCampo('biblio','colaboradores','biblionumber',$biblionumber));
    return  $registroMarc;
}

=head2 getKohaToMarcBiblioitem

=over 4

=back

=cut

sub getKohaToMarcBiblioitem {
    my ( $biblioitemnumber ) = @_;

      my $registroMarc= getKohaToMarcByTablaCampo('biblioitem','biblioitems','biblioitemnumber',$biblioitemnumber);
	 $registroMarc= unirHashes( $registroMarc ,getKohaToMarcByTablaCampo('biblioitem','publisher','biblioitemnumber',$biblioitemnumber));
	 $registroMarc= unirHashes( $registroMarc ,getKohaToMarcByTablaCampo('biblioitem','isbns','biblioitemnumber',$biblioitemnumber));

     return  $registroMarc;
}

=head2 getKohaToMarcItem

=over 4

=back

=cut

sub getKohaToMarcItem {
    my ( $itemnumber ) = @_;

      my $registroMarc  = getKohaToMarcByTablaCampo('item','items','itemnumber',$itemnumber);

    return  $registroMarc;
}


=head2 getMarcRecordFromBiblio

=over 4
Obtenemos el Marc::Record de un biblio
=back

=cut

sub getMarcRecordFromBiblio {
    my ( $biblionumber ) = @_;

    my $indentificador_1    = '#';
    my $indentificador_2    = '#';
    my $marc_record         = MARC::Record->new();
    my $registroMarc        = getKohaToMarcBiblio($biblionumber);

    foreach my $campo (keys %$registroMarc){
#       C4::AR::Debug::debug("getMarcRecordFromBiblio => Agregando al registro ===> campo ".$campo." con ".scalar(@{$registroMarc->{$campo}})." subcampos");
      my $field = MARC::Field->new($campo, $indentificador_1, $indentificador_2, @{$registroMarc->{$campo}});
      $marc_record->append_fields($field);
    }

    #Identificamos que es un Biblio
    if ($marc_record->field('090')){
	$marc_record->field('090')->add_subfields( 'a' => 'Biblio' );
    }
    else{
	my $field = MARC::Field->new('090', $indentificador_1, $indentificador_2, 'a' => 'Biblio');
	$marc_record->append_fields($field);
    }

#     C4::AR::Debug::debug("getMarcRecordFromBiblio => REGISTRO MARC: ".$marc_record->as_formatted());
    return $marc_record;
}

=head2 getMarcRecordFromBiblioitem

=over 4
Obtenemos el Marc::Record de un biblioitem
=back

=cut

sub getMarcRecordFromBiblioitem {
    my ( $biblioitemnumber ) = @_;

    my $indentificador_1    = '#';
    my $indentificador_2    = '#';
    my $marc_record         = MARC::Record->new();
    my $registroMarc        = getKohaToMarcBiblioitem($biblioitemnumber);

    foreach my $campo (keys %$registroMarc){
#         C4::AR::Debug::debug("getMarcRecordFromBiblioitem => Agregando al registro ===> campo ".$campo." con ".scalar(@{$registroMarc->{$campo}})." subcampos");
	    my $field = MARC::Field->new($campo, $indentificador_1, $indentificador_2, @{$registroMarc->{$campo}});
	    $marc_record->append_fields($field);
    }
    
        #Identificamos que es un Biblioitem
    if ($marc_record->field('090')){
        $marc_record->field('090')->add_subfields( 'a' => 'Biblioitem' );
    }
    else{
        my $field = MARC::Field->new('090', $indentificador_1, $indentificador_2, 'a' => 'Biblioitem');
        $marc_record->append_fields($field);
    }
    
#     C4::AR::Debug::debug("getMarcRecordFromBiblioitem => REGISTRO MARC: ".$marc_record->as_formatted());
    return $marc_record;
}


=head2 getMarcRecordFromBiblioitem

=over 4
Obtenemos el Marc::Record de un biblio
=back

=cut

sub getMarcRecordFromItem {
    my ( $itemnumber ) = @_;

    my $indentificador_1    = '#';
    my $indentificador_2    = '#';
    my $marc_record         = MARC::Record->new();
    my $registroMarc        = getKohaToMarcItem($itemnumber);
    
    foreach my $campo (keys %$registroMarc){
#       C4::AR::Debug::debug("getMarcRecordFromBiblioitem => Agregando al registro ===> campo ".$campo." con ".scalar(@{$registroMarc->{$campo}})." subcampos");
      my $field = MARC::Field->new($campo, $indentificador_1, $indentificador_2, @{$registroMarc->{$campo}});
      $marc_record->append_fields($field);
    }

        #Identificamos que es un Item
    if ($marc_record->field('090')){
	$marc_record->field('090')->add_subfields( 'a' => 'Item' );
    }
    else{
	my $field = MARC::Field->new('090', $indentificador_1, $indentificador_2, 'a' => 'Item');
	$marc_record->append_fields($field);
    }

#     C4::AR::Debug::debug("getMarcRecordFromBiblioitem => REGISTRO MARC: ".$marc_record->as_formatted());
    return $marc_record;
}



=head2 getExportFromBiblio

=over 4
Obtenemos un arreglo de  Marc::Record's de un biblio con sus biblioitems y sus items
=back

=cut

sub getExportFromBiblio {
    my ( $biblionumber, $export_ejemplares ) = @_;
    
    my @export = ();
    my $marc_record     = getMarcRecordFromBiblio($biblionumber);
    #Se agrega el registro del biblio
    push (@export,$marc_record);
    
    #buscamos los biblioitems
    my ($count,@biblioitems)    = C4::Biblio::getbiblioitembybiblionumber($biblionumber);

    foreach my $biblioitem (@biblioitems) {
        my $export_biblioitem   = getExportFromBiblioitem($biblioitem->{'biblioitemnumber'}, $export_ejemplares);
        push(@export,@$export_biblioitem);
    }
    
    return \@export;
}

=head2 getExportFromBiblio

=over 4
Obtenemos un arreglo de  Marc::Record's de un biblioitem con todos sus items
=back

=cut

sub getExportFromBiblioitem {
    my ( $biblioitemnumber, $export_ejemplares ) = @_;
    
    my @export=();
    my $marc_record=getMarcRecordFromBiblioitem($biblioitemnumber);
    #Se agrega el registro del biblio
    push (@export,$marc_record);
    

    if ( $export_ejemplares ) {
        #buscamos los items
        my ($count,@items)=  C4::Biblio::getitemsbybiblioitem($biblioitemnumber);
        foreach my $item (@items) {
            my $marc_record=getMarcRecordFromItem($item->{'itemnumber'});
            push(@export,$marc_record);
        }
    }
    
    return \@export;
}

=item sub GetAllBiblios

Retorna todos los registros 
=cut
sub GetAllBiblios {

    my $dbh     = C4::Context->dbh;
    my @result;
    my $query   = "SELECT * FROM biblio;";
    my $sth     = $dbh->prepare($query);
    my $cant    = 0;
    $sth->execute();
  
    while (my $data=$sth->fetchrow_hashref){
      push @result,$data;
      $cant++;
    }

    $sth->finish;
    return($cant,@result);
}

=item sub getRecordsFromRange

Retorna todos los registros para exportar
=cut
sub getRecordsFromRange {
    my ( $params ) = @_;

    my @filtros;
    
    
    
    
    if ($params->param('select_itemtypes') ne "") {
        #filtro por tipo de ejemplar
        push (@filtros, ( template => { eq => $params->param('select_itemtypes')}));
    } 


    if ( ($params->param('registro_ini') ne "") && ($params->param('registro_fin') ne "") ){
        #filtro por rango de blbionumber
        push (@filtros, ( id => { ge => $params->param('registro_ini')}));
        push (@filtros, ( id => { le => $params->param('registro_fin')}));
    } 
      
    if ($params->param('busqueda')){
        push (@filtros, ( marc_record => { like => '%'.$params->param('busqueda').'%'}));
    }
     my $registros_array_ref;
    if($params->param('limit')){
        $registros_array_ref= C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_n1( query => \@filtros, limit => $params->param('limit'),offset  => 0);
    }
    else{
        $registros_array_ref= C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_n1( query => \@filtros);
    }
    return  $registros_array_ref;
}

sub getMarcRecordForOAI {
    my ( $biblionumber ) = @_;

        my  $marc_record_array_ref = C4::AR::ExportacionIsoMARC::getExportFromBiblio($biblionumber,0);

        #Se exporta todo en un registro para  OAI
        my $marc_record_unido = MARC::Record->new();

        foreach my $marc_record (@$marc_record_array_ref){
            $marc_record_unido->append_fields($marc_record->fields());
        }

    return $marc_record_unido;
}

1;
