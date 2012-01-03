package C4::AR::ImportacionIsoMARC;

#
#para la importacion de codigos iso a marc y donde estan las descripciones de cada campo y sus
#subcampos
#

use strict;
require Exporter;

use C4::Context;
use Date::Manip;
use C4::AR::ExportacionIsoMARC;
use MARC::Record;
use MARC::File::USMARC;
use C4::AR::Utilidades;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&ui
           &campoIso
       &subCampoIso
       &datosCompletos
       &insertDescripcion
       &listadoDeCodigosDeCampo
       &mostrarCamposMARC
       &mostrarSubCamposMARC
       &list
       &insertNuevo
       &update
       &getImportacionFromDB
);

=item sub save_marc_import

=cut
sub save_marc_import {
    my ($archivo, $comentario, $estado) = @_;


    my $fechaHoy = C4::Date::format_date_in_iso(ParseDate("today"));
    my $dbh = C4::Context->dbh;

    my $query   =  " INSERT INTO marc_import (archivo, comentario, estado, fecha_upload) ";
    $query      .= " VALUES (?, ?, ?, ?) ";

    my $sth     = $dbh->prepare($query);
    $sth->execute($archivo, $comentario, $estado, $fechaHoy);
    $sth->finish;

# TODO falata lockear la tabla para q no se meta otro

    my $query   = " SELECT max(id) as max_id
                    FROM marc_import ";

    my $sth     = $dbh->prepare($query);
    $sth->execute();
    my $data    = $sth->fetchrow_hashref;

    return $data->{'max_id'};
}

=item sub update_marc_import


=cut
sub update_marc_import {
    my ($params) = @_;

    my $dbh = C4::Context->dbh;

    my $query   = " SELECT *
                    FROM marc_import WHERE id = ? ";

    my $sth     = $dbh->prepare($query);
    $sth->execute($params->{'id'});
    my $data    = $sth->fetchrow_hashref;

    my $query   =  " UPDATE marc_import SET archivo = ?, comentario = ?, estado = ?, cant_biblios = ?, ";
    $query      .= " fecha_import = ?, fecha_upload = ?, cant_biblioitems = ?, cant_items = ?, cant_desconocidos = ?,";
    $query      .= " accion_general = ?, accion_sinmatcheo = ?, accion_item = ?, accion_barcode = ?, reglas_matcheo = ? ";
    $query      .= " WHERE id = ? ";

    my $sth                         = $dbh->prepare($query);

    $params->{'archivo'}            = $params->{'archivo'} || $data->{'archivo'};
    $params->{'comentario'}         = $params->{'comentario'} || $data->{'comentario'};
    $params->{'estado'}             = $params->{'estado'} || $data->{'estado'};
    $params->{'fecha_upload'}       = $params->{'fecha_upload'} || $data->{'fecha_upload'};
    $params->{'fecha_upload'}       = $params->{'fecha_upload'} || $data->{'fecha_import'};
    $params->{'cant_biblios'}       = $params->{'cant_biblios'} || $data->{'cant_biblios'};
    $params->{'cant_biblioitems'}   = $params->{'cant_biblioitems'} || $data->{'cant_biblioitems'};
    $params->{'cant_items'}         = $params->{'cant_items'} || $data->{'cant_items'};
    $params->{'cant_desconocidos'}  = $params->{'cant_reg_desconocido'} || $data->{'cant_desconocidos'};
    $params->{'accion_general'}     = $params->{'accion_general'} || $data->{'accion_general'};
    $params->{'accion_sinmatcheo'}  = $params->{'accion_sinmatcheo'} || $data->{'accion_sinmatcheo'};
    $params->{'accion_item'}        = $params->{'accion_item'} || $data->{'accion_item'};
    $params->{'accion_barcode'}     = $params->{'accion_barcode'} || $data->{'accion_barcode'};
    $params->{'reglas_matcheo'}     = $params->{'reglas_matcheo'} || $data->{'reglas_matcheo'};

    $sth->execute($params->{'archivo'}, $params->{'comentario'}, $params->{'estado'}, $params->{'cant_biblios'},
    $params->{'fecha_import'}, $params->{'fecha_upload'}, $params->{'cant_biblioitems'}, $params->{'cant_items'}, $params->{'cant_desconocidos'},
    $params->{'accion_general'}, $params->{'accion_sinmatcheo'}, $params->{'accion_item'}, $params->{'accion_barcode'}, $params->{'reglas_matcheo'}, $params->{'id'});


    $sth->finish;
}

=item sub save_marc_import_record


=cut
sub save_marc_import_record {
    my ($id_marc_import, $marc) = @_;

    my $dbh = C4::Context->dbh;

    my $query   =  " INSERT INTO marc_import_record (id_marc_import,type,biblionumber,biblioitemnumber,itemnumber, marc_record) ";
    $query      .= " VALUES (?,?,?,?,?,?) ";

    my $sth     = $dbh->prepare($query);

    my $type=$marc->subfield('090', 'a');

    C4::AR::Debug::debug("import_upload => file: ".$marc->as_formatted);
    C4::AR::Debug::debug("save_marc_import_record => type: ".$type);
    my $biblionumber=0;
    my $biblioitemnumber=0;
    my $itemnumber=0;

    if($type eq "Biblio") {
        $biblionumber=$marc->subfield('090', 'c');
        C4::AR::Debug::debug("save_marc_import_record => biblio: ".$biblionumber);
    }elsif($type eq "Biblioitem") {
        $biblionumber=$marc->subfield('090', 'd');
        $biblioitemnumber=$marc->subfield('090', 'f');
        C4::AR::Debug::debug("save_marc_import_record => biblio: ".$biblionumber." biblionumber: ".$biblioitemnumber);
    }elsif($type eq "Item") {
        $biblionumber=$marc->subfield('090', 'e');
        $biblioitemnumber=$marc->subfield('090', 'g');
        $itemnumber=$marc->subfield('090', 'h');
        C4::AR::Debug::debug("save_marc_import_record => biblio: ".$biblionumber." biblionumber: ".$biblioitemnumber." itemnumber: ".$itemnumber);
    }
    else{
        C4::AR::Debug::debug("save_marc_import_record => REGISTRO DESCONOCIDO");
        $type="Desconocido";
    }

    my $marc_record= $marc->as_usmarc();
    $sth->execute($id_marc_import,$type,$biblionumber,$biblioitemnumber,$itemnumber,$marc_record);
    $sth->finish;
}


sub update_marc_import_record {
    my ($id_marc_import_record, $match, $id_match) = @_;

    my $dbh = C4::Context->dbh;

    my $query   =  " UPDATE marc_import_record SET matching = ? ,  id_matching = ?";
    $query      .= " WHERE id = ? ";

    my $sth     = $dbh->prepare($query);
    $sth->execute($match,$id_match, $id_marc_import_record);
    $sth->finish;
}

=item sub delete_marc_import_record

  Elimina todos los registros de una importacion
=cut
sub delete_marc_import_record {
    my ($id_marc_import) = @_;

    my $dbh = C4::Context->dbh;

    my $query   =  " DELETE FROM marc_import_record WHERE id_marc_import = ? ";

    my $sth     = $dbh->prepare($query);
    $sth->execute($id_marc_import);
    $sth->finish;
}

=item sub delete_registro_marc_import_record

   Elimina el registro pasado por parametro de una importacion
=cut
# sub delete_registro_marc_import_record {
#     my ($id) = @_;
#
#     my $dbh = C4::Context->dbh;
#
#     my $query   =  " DELETE FROM marc_import_record WHERE id = ? ";
#
#     my $sth     = $dbh->prepare($query);
#     $sth->execute($id);
#     $sth->finish;
# }

sub getImportacionFromDB {
    my ($ini, $fin) = @_;

    my $dbh         = C4::Context->dbh;
    my @results;
    my $clase       = 'par';
    my $nro_orden   = $ini;

    my $query       = " SELECT count(*) AS cant FROM marc_import ";
    my $sth         = $dbh->prepare($query);
    $sth->execute();
    my $data        = $sth->fetchrow_hashref;

    my $cant        = $data->{'cant'};

    $query          = " SELECT * FROM marc_import LIMIT ".$ini.",".$fin;
    $sth            = $dbh->prepare($query);
    $sth->execute();

    my $dateformat = C4::Date::get_date_format();


    while (my $data = $sth->fetchrow_hashref) {
        $nro_orden              = $nro_orden + 1;
        $data->{'nro_orden'}    = $nro_orden;
        $data->{'fecha_upload'} = &C4::Date::format_dateNEW($data->{'fecha_upload'}, $dateformat);
        $data->{'fecha_import'} = &C4::Date::format_dateNEW($data->{'fecha_import'}, $dateformat);

        $data->{'show_eliminar'} = 1;
        $data->{'show_importar'} = 1;

        if($data->{'estado'} eq "I"){
            $data->{'estado'} = "Importado";
            $data->{'show_importar'} = 0;
        } elsif($data->{'estado'} eq "S"){
            $data->{'estado'} = "Subido";
        } elsif($data->{'estado'} eq "E"){
            $data->{'estado'}           = "Eliminado";
            $data->{'show_eliminar'} = 0;
            $data->{'show_importar'} = 0;
        }

        if ($clase eq 'par') {$clase ='impar';} else {$clase='par'};
        $data->{'clase'}            = $clase;
        $data->{'importacion'}      = $data->{'id'};

        push(@results, $data);
    }

    return ($cant, \@results);
}


sub getDetalleImportacionFromDB {
    my ($id, $ini, $fin) = @_;

    my @results;
    my $clase       = 'par';
    my $nro_orden   = $ini;

    my $dbh         = C4::Context->dbh;
    my @results;
    my $biblionumber;
    my $biblioitemnumber;

    my $query       =   " SELECT count(*) AS cant FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? ";
    my $sth         = $dbh->prepare($query);
    $sth->execute($id);
    my $data        = $sth->fetchrow_hashref;
    my $cant        = $data->{'cant'};

    $query           = " SELECT mi.reglas_matcheo, mir.id, mir.id_marc_import, mir.matching, mir.marc_record, mir.estado, mir.biblionumber, mir.type, ";
    $query          .= " mi.accion_general, mi.accion_sinmatcheo, mi.accion_item, mi.accion_barcode ";
    $query          .= " FROM marc_import mi ";
    $query          .= " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .= " WHERE mi.id = ? LIMIT ".$ini.",".$fin;
    $sth            = $dbh->prepare($query);
    $sth->execute($id);


    my $marc_record;

    while (my $data = $sth->fetchrow_hashref) {
            $marc_record            = MARC::Record->new_from_usmarc($data->{'marc_record'});

        $nro_orden              = $nro_orden + 1;
        $data->{'nro_orden'}    = $nro_orden;

        my $map = getCampoSubcampoFromMap('title', 'biblio', 'biblio');
        $data->{'titulo'}       = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});

        my $map = getCampoSubcampoFromMap('author', 'biblio', 'biblio');
        $data->{'autor'}        = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});
        if ($clase eq 'par') {$clase ='impar';} else {$clase='par'};
        $data->{'clase'}        = $clase;


        if($data->{'type'} eq "Biblio") {
            $data->{'texto'}    = $data->{'titulo'}." (".$data->{'autor'}.")";
        }elsif($data->{'type'} eq "Biblioitem") {
            my $map = getCampoSubcampoFromMap('volume', 'biblioitems', 'biblioitem');
            my $volume          = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});

            my $map = getCampoSubcampoFromMap('number', 'biblioitems', 'biblioitem');
            my $number          = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});

            my $map = getCampoSubcampoFromMap('publicationyear', 'biblioitems', 'biblioitem');
            my $publicationyear = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});

            $data->{'texto'}    = $volume." (".$number.")"." (".$publicationyear.")";
        }elsif($data->{'type'} eq "Item") {
            my $map = getCampoSubcampoFromMap('bulk', 'items', 'item');
            my $bulk            = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});

            my $map = getCampoSubcampoFromMap('barcode', 'items', 'item');
            my $barcode         = $marc_record->subfield($map->[0]->{campo},$map->[0]->{subcampo});

            $data->{'texto'}    = $barcode." - ".$bulk;
        }


        if($data->{'estado'} eq "I"){
            $data->{'estado'}               = "Importado";
            $data->{'show_importar'}        = 0;
        } elsif($data->{'estado'} eq "II"){
        #importado ignorado
            $data->{'estado'}               = "Ignorado";
            $data->{'biblionumber'}         = 0;
            $data->{'show_link_to_detail'}  = 0;
            $data->{'show_importar'}        = 1;
        } elsif($data->{'estado'} eq "NI"){
        #no importado
            $data->{'estado'}               = "No Importado";
            $data->{'biblionumber'}         = 0;
            $data->{'show_eliminar'}        = 1;
#             $data->{'show_importar'} = 0;
        }

        push(@results, $data);
    }

    return ($cant, \@results);
}


    sub getBiblioFromMarc_import_recordByBiblionumber {
    my ($id, $biblionumber) = @_;

    my $dbh         = C4::Context->dbh;
    my @results;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.biblionumber = ? AND type = 'Biblio'";

    my $sth         = $dbh->prepare($query);
    $sth->execute($id, $biblionumber);

    my $biblio = $sth->fetchrow;

    return ($biblio);
}

sub getBiblioitemFromMarc_import_recordByBiblioitemnumber {
    my ($id, $biblioitemnumber) = @_;

    my $dbh         = C4::Context->dbh;
    my @results;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.biblioitemnumber = ? AND type = 'Biblioitem'";

    my $sth         = $dbh->prepare($query);
    $sth->execute($id, $biblioitemnumber);

    my $biblioitem = $sth->fetchrow;

    return ($biblioitem);
}

sub getImportacionByID {
    my ($id) = @_;

    my $dbh         = C4::Context->dbh;
    my @results;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? ";
    my $sth         = $dbh->prepare($query);
    $sth->execute($id);

    my $dateformat = C4::Date::get_date_format();


    while (my $data = $sth->fetchrow_hashref) {

        $data->{'fecha_upload'} = &C4::Date::format_dateNEW($data->{'fecha_upload'}, $dateformat);
        $data->{'fecha_import'} = &C4::Date::format_dateNEW($data->{'fecha_import'}, $dateformat);


        push(@results, $data);
    }

    return (scalar(@results), \@results);
}

sub realizar_importacion_fromDB{
    my ($id, $responsable) = @_;

    my $dbh         = C4::Context->dbh;
    my $biblionumber;
    my $biblioitemnumber;
    my $itemnumber;
    my $tengo_padre=1;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.type = 'Biblio' ";
    my $sth         = $dbh->prepare($query);
    $sth->execute($id);


    my $marc_record;
    while (my $biblio = $sth->fetchrow_hashref) {
        #recorro los marc_records por BIBLIO
        $marc_record = MARC::Record->new_from_usmarc($biblio->{'marc_record'});


# FIXME este IF estaría de mas
        if($marc_record->subfield('090', 'a') eq "Biblio") {

            my $biblio_info = marc_record_to_biblio($marc_record);

# TODO falta modularizar!!!!!!!
            if ($biblio->{'matching'} eq 'MATCH') {
                if($biblio->{'accion_general'} eq 'create_new') {
                    # genero un BIBLIO nuevo
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIO - MATCH (overlay_action) => create_new ");
                    $biblionumber   = save_biblio_from_marc_record($biblio_info,$responsable);
                } elsif($biblio->{'accion_general'} eq 'ignore') {
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIO - MATCH (overlay_action) => ignore ");
                    # no se hace nada con el BIBLIO, ni BIBLIOITEM ni ITEM ???????????
                } elsif($biblio->{'accion_general'} eq 'replace') {
                    # actualizo el BIBLIO
                    $biblio_info->{'biblionumber'} = $biblio->{'id_matching'}; #lo recupero de la base
                    $biblionumber= $biblio->{'id_matching'}; #lo recupero de la base

                    update_biblio_from_marc_record($biblio_info,$responsable);
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIO - MATCH (overlay_action) => replace ");
                }
            } else {
            # NO_MATCH or TOO_MATCH
                if($biblio->{'accion_sinmatcheo'} eq 'create_new') {
                    # genero un BIBLIO nuevo
                    $biblionumber   = save_biblio_from_marc_record($biblio_info,$responsable);
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIO - MATCH (nomatch_action) => create_new ");
                } elsif($biblio->{'accion_sinmatcheo'} eq 'ignore') {
                    # no se hace nada con el BIBLIO
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIO - MATCH (nomatch_action) => ignore ");
                }
            }


            my $mc_biblioitems_array_ref = getBiblioitemsFromMarc_import_record($id, $marc_record->subfield('090', 'c'));
            foreach my $biblioitem (@$mc_biblioitems_array_ref){
                #recorro los marc_records por BIBLIOITEM
                $tengo_padre=1;

                my $mc_biblioitem   = MARC::Record->new_from_usmarc($biblioitem->{'marc_record'});
                my $biblioitem_info = marc_record_to_biblioitem($mc_biblioitem, $biblionumber);

                if ($biblioitem->{'matching'} eq 'MATCH') {
                    if($biblioitem->{'accion_general'} eq 'create_new') {
                    # genero un BIBLIOITEM nuevo
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIOITEM - MATCH (overlay_action) => create_new ");
                        $biblioitemnumber   = save_biblioitem_from_marc_record($biblioitem_info,$responsable);
                    } elsif($biblioitem->{'accion_general'} eq 'ignore') {
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIOITEM - MATCH (overlay_action) => ignore ");
                    # no se hace nada con el BIBLIOITEM ni ITEM ???????????
                    } elsif($biblioitem->{'accion_general'} eq 'replace') {
                    # actualizo el BIBLIOITEM
# TODO falta el biblionumber del q matcheo
                        $biblioitem_info->{'biblioitemnumber'} = $biblioitem->{'id_matching'}; #lo recupero de la base
                        $biblioitemnumber = $biblioitem->{'id_matching'};
                        update_biblioitem_from_marc_record($biblioitem_info, $responsable);
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIOITEM - MATCH (overlay_action) => replace ");
                    }
                } else {
                  # NO_MATCH or TOO_MATCH
                    if($biblioitem->{'accion_sinmatcheo'} eq 'create_new') {
                        # genero un BIBLIOITEM nuevo
                        $biblioitemnumber   = save_biblioitem_from_marc_record($biblioitem_info,$responsable);
            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIOITEM - MATCH (nomatch_action) => create_new ");
                    } elsif($biblioitem->{'accion_sinmatcheo'} eq 'ignore') {
                        # no se hace nada con el BIBLIOITEM
                        #NO HAY MATCHEO Y SE IGNORA EL REGISTRO => LOS ITEMS NO VAN A TENER PADRE
                        $tengo_padre=0;

            C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => BIBLIOITEM - MATCH (nomatch_action) => ignore ");
                    }

                }

                my $mc_items_array_ref = getItemsFromMarc_import_record($id, $mc_biblioitem->subfield('090', 'd'), $mc_biblioitem->subfield('090', 'f'));

                foreach my $item (@$mc_items_array_ref){
        # FIXME no estan claros las acciones a realizar en el nivel 3

                    my $mc_item = MARC::Record->new_from_usmarc($item->{'marc_record'});
                    my $item_info = marc_record_to_item($mc_item, $biblionumber,$biblioitemnumber);

                    if($item->{'accion_item'} eq 'always_add') {
                        # Se agrega siempre el ejemplar (siempre que exista el registro padre!!! OJO!!!)
                        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => ITEM - accion_item => always_add ");

                        if($tengo_padre) { #TENGO EL BIBLIOITEM PADRE
                          $itemnumber   = save_item_from_marc_record($item_info,$item->{'accion_barcode'},$responsable);
                        }

                    } elsif($item->{'accion_item'} eq 'add_only_for_matches'){
                        # Se agrega el ejemplar solo si el registro padre matcheo!!
                        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => ITEM - accion_item => add_only_for_matches ");

                        if(($biblio->{'matching'} eq 'MATCH')||($biblioitem->{'matching'} eq 'MATCH')){ #MATCHEA O EL BIBLIO O EL BIBLIOITEM
                          $itemnumber   = save_item_from_marc_record($item_info,$item->{'accion_barcode'},$responsable);
                        }

                    } elsif($item->{'accion_item'} eq 'add_only_for_new'){
                        # Se agrega el ejemplar solo si el registro padre es nuevo!!
                        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => ITEM - accion_item => add_only_for_new ");

                        if((($biblioitem->{'matching'} eq 'MATCH')&&($biblioitem->{'accion_general'} eq 'create_new'))
                          ||(($biblioitem->{'matching'} ne 'MATCH')&&($biblioitem->{'accion_sinmatcheo'} eq 'create_new'))) {
                          #EL GRUPO ES NUEVO!!
                          $itemnumber   = save_item_from_marc_record($item_info,$item->{'accion_barcode'},$responsable);
                        }

                    } elsif($item->{'accion_item'} eq 'ignore'){
                        # Se ignora el ejemplar
                        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => ITEM - accion_item => ignore ");
                    }
                }
            }
        }
    }
}


sub realizar_importacion_registros_desconocidos_fromDB{
    my ($id, $responsable) = @_;

    my $dbh         = C4::Context->dbh;
    my $biblionumber;
    my $biblioitemnumber;
    my $itemnumber;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.type = 'Desconocido' ";
    my $sth         = $dbh->prepare($query);
    $sth->execute($id);


    my $marc_record;
    while (my $registro = $sth->fetchrow_hashref) {
        #recorro todos los marc_records
        $marc_record = MARC::Record->new_from_usmarc($registro->{'marc_record'});
                    # NO_MATCH or TOO_MATCH
        if($registro->{'accion_sinmatcheo'} eq 'create_new') {
                # genero un BIBLIO nuevo
                my $biblio_info = marc_record_to_biblio($marc_record);
                if(scalar %$biblio_info){
                    $biblionumber   = save_biblio_from_marc_record($biblio_info,$responsable);

                    # y un BIBLIOITEM nuevo para ese BIBLIO
                    my $biblioitem_info = marc_record_to_biblioitem($marc_record, $biblionumber);
                    if(scalar %$biblioitem_info){
                        $biblioitemnumber   = save_biblioitem_from_marc_record($biblioitem_info,$responsable);

                        # y si hay, un ITEM para ese BIBLIOITEM
                        my $item_info = marc_record_to_item($marc_record, $biblionumber,$biblioitemnumber);
                        if(scalar %$item_info){
                            $itemnumber = save_item_from_marc_record($item_info,$registro->{'accion_barcode'},$responsable);
                        }
                    }
                }

                C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_fromDB => DESCONOCIDO - MATCH (nomatch_action) => create_new ");

            } elsif($registro->{'accion_sinmatcheo'} eq 'ignore') {
                # no se hace nada
          C4::AR::Debug::debug("ImportacionIsoMARC => realizar_importacion_registros_desconocidos_fromDB => DESCONOCIDO - MATCH (nomatch_action) => ignore ");
        }
    }
}

sub printImportacionFromDB {
    my ($id) = @_;

    my $dbh         = C4::Context->dbh;
    my $biblionumber;
    my $biblioitemnumber;
    my $itemnumber;
    my @result;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.type = 'Biblio' ";
    my $sth         = $dbh->prepare($query);
    $sth->execute($id);


    my $marc_record;
    while (my $biblio = $sth->fetchrow_hashref) {
        #recorro los marc_records por BIBLIO
        $marc_record = MARC::Record->new_from_usmarc($biblio->{'marc_record'});

        foreach my $field ($marc_record->fields()){
            foreach my $subfield ($field->subfields()) {
                my %data_hash;
                $data_hash{'campo'}     = $field->tag;
                $data_hash{'subcampo'}  = $subfield->[0];
                $data_hash{'dato'}      = $subfield->[1];

                push(@result, \%data_hash);
            }
        }

        my $mc_biblioitems_array_ref = getBiblioitemsFromMarc_import_record($id, $marc_record->subfield('090', 'c'));
        foreach my $biblioitem (@$mc_biblioitems_array_ref){
            #recorro los marc_records por BIBLIOITEM
            my $mc_biblioitem   = MARC::Record->new_from_usmarc($biblioitem->{'marc_record'});

            foreach my $field ($mc_biblioitem->fields()){
                foreach my $subfield ($field->subfields()) {
                    my %data_hash;
                    $data_hash{'campo'}         = $field->tag;
                    $data_hash{'subcampo'}  = $subfield->[0];
                    $data_hash{'dato'}      = $subfield->[1];

                    push(@result, \%data_hash);
                }
            }

            my $mc_items_array_ref = getItemsFromMarc_import_record($id, $mc_biblioitem->subfield('090', 'd'), $mc_biblioitem->subfield('090', 'f'));

            foreach my $item (@$mc_items_array_ref){
    # FIXME no estan claros las acciones a realizar en el nivel 3

                my $mc_item = MARC::Record->new_from_usmarc($item->{'marc_record'});
                foreach my $field ($mc_item->fields()){
                    foreach my $subfield ($field->subfields()) {
                        my %data_hash;
                        $data_hash{'campo'}     = $field->tag;
                        $data_hash{'subcampo'}  = $subfield->[0];
                        $data_hash{'dato'}      = $subfield->[1];

                        push(@result, \%data_hash);
                    }
                }

            }

        }

    } #END while (my $biblio = $sth->fetchrow_hashref)

    return (\@result);
}

sub verificarMatcheo {
   #Verifica si un conjunto de reglas matchean con un marc record (contra UN Y SOLO UN registro de la base)
    my ($marc_record,$reglas) = @_;

    my $dbh             = C4::Context->dbh;
    my $cant_resultados = 0;
    my $id_resultado    = 0;
    my $query           = "";
    my @bind = ();

    if($marc_record->subfield('090', 'a') eq "Biblio") { #Las reglas son de Biblio

       $query    = " SELECT DISTINCT biblio.biblionumber  AS id FROM biblio ";
       $query   .= " LEFT JOIN additionalauthors ON biblio.biblionumber = additionalauthors.biblionumber ";
       $query   .= " LEFT JOIN bibliosubject ON biblio.biblionumber = bibliosubject.biblionumber ";
       $query   .= " LEFT JOIN bibliosubtitle ON biblio.biblionumber = bibliosubtitle.biblionumber ";
       $query   .= " LEFT JOIN colaboradores ON biblio.biblionumber = colaboradores.biblionumber ";

       @bind=();

       my $first=1;
       foreach my $regla (@$reglas){

    if($first){$query   .= " WHERE "; $first=0;} else {$query   .= " AND ";}

    if ($regla->{'tablaKoha'} eq 'biblio'){ #campo simple
        my $datoSimple = $marc_record->subfield($regla->{'campo'}, $regla->{'subcampo'});
        if(!$datoSimple){ #NO existe el dato NO HAY MATCH
        return 0;
        }
        if ($regla->{'campo'}.$regla->{'subcampo'} eq "100a"){ #Hay que buscar la referencia al autor
        $datoSimple = C4::Search::getReferenciaAutor($datoSimple);
        if(!$datoSimple){ #Si no existe la referencia ya no hay matcheo
            return 0;
            }
        }
        $query   .= " $regla->{'tablaKoha'}.$regla->{'campoKoha'} = ? ";
        push(@bind,$datoSimple);
    }
    else {  #campo compuesto
        my @datos = $marc_record->subfield($regla->{'campo'}, $regla->{'subcampo'});

        if(scalar(@datos) == 0){  #NO existen datos NO HAY MATCH
        return 0;
        }

        my $ft=1;
        $query .= " ( ";
        foreach my $dato (@datos){
            if($ft){$ft=0;}
        else{$query .= " OR ";}

         use Switch;

        switch($regla->{'campo'}.$regla->{'subcampo'}) {
        # Referencias a Autores
        case "700a" { $dato = C4::Search::getReferenciaAutor($dato); }  # - additionalauthors.author (700 a) --> autores.id --> autores.completo
        case "710a" { $dato = C4::Search::getReferenciaAutor($dato); }  # - colaboradores.idColaborador (710 a) --> autores.id --> autores.completo
        # Referencias a Temas
        case "650a" { $dato = C4::Search::getReferenciaTema($dato); }     # - bibliosubjet.subject (650 a) --> temas.id --> temas.nombre
        }
        if(!$dato){ #Si no existe la referencia, ya no hay matcheo
            return 0;
            }
        $query   .= " $regla->{'tablaKoha'}.$regla->{'campoKoha'} = ? ";
        push(@bind,$dato);
        }
        $query .= " ) ";
    }
       }

    }
    elsif($marc_record->subfield('090', 'a') eq "Biblioitem") { #Las reglas son de Biblioitem

    $query   = "SELECT DISTINCT biblioitems.biblioitemnumber AS id FROM biblioitems ";
    $query   .= " LEFT JOIN publisher ON biblioitems.biblioitemnumber = publisher.biblioitemnumber ";
    $query   .= " LEFT JOIN isbns ON biblioitems.biblioitemnumber = isbns.biblioitemnumber ";

    @bind=();
    my $first=1;
    foreach my $regla (@$reglas){
        if($first){$query   .= " WHERE "; $first=0;} else {$query   .= " AND ";}

        if ($regla->{'tablaKoha'} eq 'biblioitem'){ #campo simple
        my $datoSimple = $marc_record->subfield($regla->{'campo'}, $regla->{'subcampo'});
        if(!$datoSimple){ #NO existe el dato NO HAY MATCH
            return 0;
        }
        $query   .= " $regla->{'tablaKoha'}.$regla->{'campoKoha'} = ? ";
        push(@bind,$datoSimple);
        }
        else {  #campo compuesto
        my @datos = $marc_record->subfield($regla->{'campo'}, $regla->{'subcampo'});
        if(scalar(@datos) == 0){  #NO existen datos NO HAY MATCH
            return 0;
        }
        my $ft=1;
        $query .= " ( ";
        foreach my $dato (@datos){
            if($ft){$ft=0;}
            else{$query .= " OR ";}
            $query   .= " $regla->{'tablaKoha'}.$regla->{'campoKoha'} = ? ";
            push(@bind,$dato);
        }
        $query .= " ) ";
        }
    }
    }
    elsif($marc_record->subfield('090', 'a') eq "Item") { #Las reglas son de Item
    $query   = "SELECT DISTINCT items.itemnumber AS id FROM items ";

    @bind=();
    my $first=1;
    foreach my $regla (@$reglas){
        if($first){$query   .= " WHERE "; $first=0;} else {$query   .= " AND ";}

        my $datoSimple = $marc_record->subfield($regla->{'campo'}, $regla->{'subcampo'});
        if(!$datoSimple){ #NO existe el dato NO HAY MATCH
        return 0;
        }
        $query   .= " $regla->{'tablaKoha'}.$regla->{'campoKoha'} = ? ";
        push(@bind,$datoSimple);
    }
    }

        my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    $cant_resultados=$sth->rows;
    if ($sth->rows == 1) {
           $id_resultado=$sth->fetchrow;
         }

    return ($cant_resultados,$id_resultado);
}

sub realizar_matcheo_importacion_biblio {
    my ($id,$reglas) = @_;

    my $dbh         = C4::Context->dbh;

    my $reglas_biblio=$reglas->{'biblio'};
    my $reglas_biblioitem=$reglas->{'biblioitem'};

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.type = 'Biblio' ";
    my $sth         = $dbh->prepare($query);
    $sth->execute($id);

    my $marc_record;
    while (my $data = $sth->fetchrow_hashref) {
    $marc_record = MARC::Record->new_from_usmarc($data->{'marc_record'});
    my ($cant_resultados,$id_resultado) = C4::AR::ImportacionIsoMARC::verificarMatcheo($marc_record,$reglas_biblio);
    if($cant_resultados ==1){
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_biblio => EXISTE");
        update_marc_import_record($data->{'id'}, "MATCH",$id_resultado);
        #ACA HAY QUE VERIFICAR LOS BIBLIOITEMS
        if(scalar(@$reglas_biblioitem)){ #HAY REGLAS DE MATCHEO DE LOS BIBLIOITEMS DE ESTE BIBLIO??
            realizar_matcheo_importacion_biblioitem($id,$reglas,$data->{'biblionumber'});
        }
    } elsif($cant_resultados == 0) {
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_biblio => NO EXISTE");
        update_marc_import_record($data->{'id'}, "NO_MATCH",0);
    } elsif($cant_resultados > 0) {
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_biblio => MATCHEO CONTRA MUCHOS!!! NO SIRVE");
        update_marc_import_record($data->{'id'}, "TOO_MATCH",0);
    }
   }
}

sub realizar_matcheo_importacion_biblioitem {
#Importa los biblioitems de un biblio o todos si no viene ningún biblionumber
    my ($id,$reglas,$biblionumber) = @_;

    my $dbh         = C4::Context->dbh;

    my $reglas_biblio=$reglas->{'biblio'};
    my $reglas_biblioitem=$reglas->{'biblioitem'};
    my $reglas_item=$reglas->{'item'};

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.type = 'Biblioitem' ";
    if($biblionumber){  $query .=  " AND mir.biblionumber = ? ";}

    my $sth         = $dbh->prepare($query);

    if($biblionumber){ $sth->execute($id,$biblionumber);}
    else{ $sth->execute($id);}

    my $marc_record;
    while (my $data = $sth->fetchrow_hashref) {
    $marc_record = MARC::Record->new_from_usmarc($data->{'marc_record'});
    my ($cant_resultados,$id_resultado) = C4::AR::ImportacionIsoMARC::verificarMatcheo($marc_record,$reglas_biblioitem);
    if($cant_resultados ==1){
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_biblioitem => EXISTE");
        update_marc_import_record($data->{'id'}, "MATCH",$id_resultado);

        #ACA HAY QUE VERIFICAR LOS ITEMS
        if(scalar(@$reglas_item)){ #HAY REGLAS DE MATCHEO DE LOS ITEMS DE ESTE BIBLIOITEM??
            realizar_matcheo_importacion_item($id,$reglas,$data->{'biblioitemnumber'});
        }
    } elsif($cant_resultados == 0) {
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_biblioitem => NO EXISTE");
        update_marc_import_record($data->{'id'}, "NO_MATCH",0);
    } elsif($cant_resultados > 0) {
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_biblioitem => MATCHEO CONTRA MUCHOS!!! NO SIRVE");
        update_marc_import_record($data->{'id'}, "TOO_MATCH",0);
    }
   }
}

sub realizar_matcheo_importacion_item {
#Importa los items de un biblioitem o todos si no viene ningún biblioitemnumber
    my ($id,$reglas,$biblioitemnumber) = @_;

    my $dbh         = C4::Context->dbh;

    my $reglas_item=$reglas->{'item'};

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.type = 'Item' ";

    if($biblioitemnumber){  $query .=  " AND mir.biblioitemnumber = ? ";}

    my $sth = $dbh->prepare($query);

    if($biblioitemnumber){ $sth->execute($id,$biblioitemnumber);}
    else{ $sth->execute($id);}

    my $marc_record;
    while (my $data = $sth->fetchrow_hashref) {
    $marc_record = MARC::Record->new_from_usmarc($data->{'marc_record'});
    my ($cant_resultados,$id_resultado) = C4::AR::ImportacionIsoMARC::verificarMatcheo($marc_record,$reglas_item);
    if($cant_resultados ==1){
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_item => EXISTE");
        update_marc_import_record($data->{'id'}, "MATCH",$id_resultado);
    } elsif($cant_resultados == 0) {
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_item => NO EXISTE");
        update_marc_import_record($data->{'id'}, "---",0);
    } elsif($cant_resultados > 0) {
        C4::AR::Debug::debug("ImportacionIsoMARC => realizar_matcheo_importacion_item => MATCHEO CONTRA MUCHOS!!! NO SIRVE");
        update_marc_import_record($data->{'id'}, "---",0);
    }
   }
}


sub realizar_matcheo_importacion_fromDB {
    my ($id,$reglas) = @_;

    my $dbh         = C4::Context->dbh;
    #Primero ponemos TODOS los registros en NO_MATCH
    my $query   =  " UPDATE marc_import_record SET matching  = 'NO_MATCH' ,  id_matching = '0' ";
    $query      .= " WHERE id_marc_import = ? ";
    my $sth     = $dbh->prepare($query);
    $sth->execute($id);

    my $reglas_biblio=$reglas->{'biblio'};
    my $reglas_biblioitem=$reglas->{'biblioitem'};
    my $reglas_item=$reglas->{'item'};

    if(scalar(@$reglas_biblio)){ #HAY REGLAS DE MATCHEO DE BIBLIO??
        realizar_matcheo_importacion_biblio($id,$reglas);
    }
    elsif(scalar(@$reglas_biblioitem)){ #HAY REGLAS DE MATCHEO DE BIBLIOITEMS??
        realizar_matcheo_importacion_biblioitem($id,$reglas,0);
    }
    elsif(scalar(@$reglas_item)){ #HAY REGLAS DE MATCHEO DE ITEMS??
        realizar_matcheo_importacion_item($id,$reglas,0);
    }
}

sub getBiblioitemsFromMarc_import_record {
    my ($id, $biblionumber) = @_;

    my $dbh         = C4::Context->dbh;
    my @results;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.biblionumber = ? AND type = 'Biblioitem'";

    my $sth         = $dbh->prepare($query);
    $sth->execute($id, $biblionumber);

    while (my $data = $sth->fetchrow_hashref) {
        push (@results, $data);
    }

    return (\@results);
}

sub getItemsFromMarc_import_record {
    my ($id, $biblionumber, $biblioitemnumber) = @_;

    my $dbh         = C4::Context->dbh;
    my @results;

    my $query       =   " SELECT * FROM marc_import mi ";
    $query          .=  " INNER JOIN marc_import_record mir ON (mi.id = mir.id_marc_import) ";
    $query          .=  " WHERE mi.id = ? AND mir.biblionumber = ? AND mir.biblioitemnumber = ? AND type = 'Item' ";

    my $sth         = $dbh->prepare($query);
    $sth->execute($id, $biblionumber, $biblioitemnumber);

    while (my $data = $sth->fetchrow_hashref) {
        push (@results, $data);
    }

    return (\@results);
}

sub marc_record_to_biblio {
    my ($marc_record) = @_;

    my $biblio = {
        title               => getValorFromMap($marc_record,'title', 'biblio', 'biblio'),
        unititle            => getValorFromMap($marc_record,'unititle', 'biblio', 'biblio'),
        abstract            => getValorFromMap($marc_record,'abstract', 'biblio', 'biblio'),
        notes               => getValorFromMap($marc_record,'notes', 'biblio', 'biblio'),
        seriestitle         => getValorFromMap($marc_record,'seriestitle', 'biblio', 'biblio'),
        responsability      => getValorFromMap($marc_record,'responsability', 'biblio', 'biblio'),
        author              => getValorFromMap($marc_record,'author', 'biblio', 'biblio'),
        biblioitemnumber    => 0, # Da un error al agregarlo sino
    }; # my $biblio


    my $subtitle = getArregloValoresFromMap($marc_record,'subtitle', 'bibliosubtitle', 'biblio');
    if($subtitle){
        $biblio->{'subtitle'} = join("\n", @$subtitle);
    }

    my $additionalauthors = getArregloValoresFromMap($marc_record,'author', 'additionalauthors', 'biblio');
    if($additionalauthors){
        $biblio->{'additionalauthors'} = join("\n", @$additionalauthors);
    }

    my $colaboradores = getArregloValoresFromMap($marc_record,'idColaborador', 'colaboradores', 'biblio');
    if($colaboradores){
        my $tiposcolaboradores = getArregloValoresFromMap($marc_record,'tipo', 'colaboradores', 'biblio');
        #Los colaboradores y sus funciones
        for (my $i=0; $i < scalar(@$colaboradores); $i++){
            $colaboradores->[$i]=$colaboradores->[$i]." colaborando como: ".$tiposcolaboradores->[$i];
        }
        $biblio->{'colaboradores'} = join("\n", @$colaboradores);
    }

    my $subjectheadings = getArregloValoresFromMap($marc_record,'subject', 'bibliosubject', 'biblio');
    if($subjectheadings){
        $biblio->{'subjectheadings'} = join("\n", @$subjectheadings);
    }

    return $biblio;
}

sub marc_record_to_biblioitem{
    my ($marc_record, $bilbionumber) = @_;

    my $biblioitem = {
        biblionumber        => $bilbionumber,
        volume              => getValorFromMap($marc_record,'volume', 'biblioitems', 'biblioitem'),
        number              => getValorFromMap($marc_record,'number', 'biblioitems', 'biblioitem'),
        classification      => getValorFromMap($marc_record,'classification', 'biblioitems', 'biblioitem'),
        itemtype            => getValorFromMap($marc_record,'itemtype', 'biblioitems', 'biblioitem'),
        url                 => getValorFromMap($marc_record,'url', 'biblioitems', 'biblioitem'),
        issn                => getValorFromMap($marc_record,'issn', 'biblioitems', 'biblioitem'),
        dewey               => getValorFromMap($marc_record,'dewey', 'biblioitems', 'biblioitem'),
        subclass            => getValorFromMap($marc_record,'subclass', 'biblioitems', 'biblioitem'),
        publicationyear     => getValorFromMap($marc_record,'publicationyear', 'biblioitems', 'biblioitem'),
        volumedate          => getValorFromMap($marc_record,'volumedate', 'biblioitems', 'biblioitem'),
        volumeddesc         => getValorFromMap($marc_record,'volumeddesc', 'biblioitems', 'biblioitem'),
        illus               => getValorFromMap($marc_record,'illus', 'biblioitems', 'biblioitem'),
        pages               => getValorFromMap($marc_record,'pages', 'biblioitems', 'biblioitem'),
        notes               => getValorFromMap($marc_record,'notes', 'biblioitems', 'biblioitem'),
        size                => getValorFromMap($marc_record,'size', 'biblioitems', 'biblioitem'),
        lccn                => getValorFromMap($marc_record,'lccn', 'biblioitems', 'biblioitem'),
        marc                => getValorFromMap($marc_record,'marc', 'biblioitems', 'biblioitem'),
        place               => getValorFromMap($marc_record,'place', 'biblioitems', 'biblioitem'),
        seriestitle         => getValorFromMap($marc_record,'seriestitle', 'biblioitems', 'biblioitem'),
        language            => getValorFromMap($marc_record,'idLanguage', 'biblioitems', 'biblioitem'),
        country             => getValorFromMap($marc_record,'idCountry', 'biblioitems', 'biblioitem'),
        support             => getValorFromMap($marc_record,'idSupport', 'biblioitems', 'biblioitem'),
        fasc                => getValorFromMap($marc_record,'fasc', 'biblioitems', 'biblioitem'),
        indice              => getValorFromMap($marc_record,'indice', 'biblioitems', 'biblioitem'),
        itemtype            => getValorFromMap($marc_record,'itemtype', 'biblioitems', 'biblioitem'),
        state               => getValorFromMap($marc_record,'state', 'biblioitems', 'biblioitem'),
        source              => getValorFromMap($marc_record,'source', 'biblioitems', 'biblioitem'),
        frequency_type      => getValorFromMap($marc_record,'frequency_type', 'biblioitems', 'biblioitem'),
        frequency_num       => getValorFromMap($marc_record,'frequency_num', 'biblioitems', 'biblioitem'),
    }; # my $biblioitem

    if(length($biblioitem->{'country'}) eq 3){
        #es un iso 3, hay que pasarlo a iso
             C4::AR::Debug::debug("Pais ".$biblioitem->{'country'});
        my $country=C4::Biblio::getCountryFromIso3( $biblioitem->{'country'} );
        if($country){$biblioitem->{'country'}=$country->{'iso'};}
    }

    if($biblioitem->{'frequency_type'}) {
        #Tenemos que calcular la frecuencia
        ($biblioitem->{'frequency_type'},$biblioitem->{'frequency_num'})= calcularFrecuenciaPublicacion($biblioitem->{'frequency_type'});

        C4::AR::Debug::debug("REV FREQ ".$biblioitem->{'frequency_type'}."-".$biblioitem->{'frequency_num'});
    }

    if(!$biblioitem->{'itemtype'}){
        #Si no tiene itemtype se deduce uno o se pone uno por defecto
        if ($biblioitem->{'issn'} || $biblioitem->{'frequency_type'} ||  $biblioitem->{'frequency_num'}) {
            #Si posee issn o frecuencia es una revista (REV)
            $biblioitem->{'itemtype'}='REV'
        }else{
            #Por defecto es un Libro (LIB)
            $biblioitem->{'itemtype'}='LIB';
        }
    }

    if(!$biblioitem->{'classification'}){
        #Si no tiene itemtype se deduce uno o se pone uno por defecto
        if ($biblioitem->{'itemtype'} eq  'REV') {
            $biblioitem->{'classification'}='s'
        }else{
            #Por defecto es un Libro (LIB)
            $biblioitem->{'classification'}='m';
        }
    }


    if(!$biblioitem->{'support'}) {
        #Si no hay soporte ponemos uno por defecto - imrpeso en papel
       $biblioitem->{'support'} ='1';
    }

    if($biblioitem->{'language'}) {
        #Recalculamos el Lenguaje para Koha
       if($biblioitem->{'language'} eq 'SPA'){
            $biblioitem->{'language'}='es';
        } elsif($biblioitem->{'language'} eq 'ENG'){
            $biblioitem->{'language'}='en';
        }
    }

    my $publisher = getArregloValoresFromMap($marc_record,'publisher', 'publisher', 'biblioitem');
    if($publisher){
    $biblioitem->{'publishercode'} = join("\n", @$publisher);
    }

    my $isbn = getArregloValoresFromMap($marc_record,'isbn', 'isbns', 'biblioitem');
    if($isbn){
        $biblioitem->{'isbncode'} = join("\n", @$isbn);
    }

    return $biblioitem;
}


sub marc_record_to_item{
    my ($marc_record, $biblionumber, $biblioitemnumber) = @_;

    my $item             = {
        biblionumber        => $biblionumber,
        biblioitemnumber    => $biblioitemnumber,
        homebranch          => getValorFromMap($marc_record,'homebranch', 'items', 'item'),
        holdingbranch       => getValorFromMap($marc_record,'homebranch', 'items', 'item'),
        replacementprice    => getValorFromMap($marc_record,'replacementprice', 'items', 'item'),
        bulk                => getValorFromMap($marc_record,'bulk', 'items', 'item'),
        itemnotes           => getValorFromMap($marc_record,'itemnotes', 'items', 'item'),
        notforloan          => getValorFromMap($marc_record,'notforloan', 'items', 'item'),
        wthdrawn            => getValorFromMap($marc_record,'wthdrawn', 'items', 'item'),
        barcode             => getValorFromMap($marc_record,'barcode', 'items', 'item'),
    }; # my $item_info

    if(length($item->{'homebranch'}) >= 4){
        #es un iso 3, hay que pasarlo a iso
        my $branch=C4::Koha::getBranchByName( $item->{'homebranch'});
        if($branch){
                $item->{'homebranch'}=$branch->{'branchcode'};
                $item->{'holdingbranch'}=$branch->{'branchcode'};
            }
    }

    return $item;
}

# getCampoSubcampoFromMap obtengo el arreglo de campos MARC que corresponden a un campo en Koha
sub getCampoSubcampoFromMap {
    my ($campo_tabla, $tabla, $tablahash) = @_;

    my $mapeo_koha_marc = C4::AR::ExportacionIsoMARC::getMapeoKohaMarc();
    return (\@{$mapeo_koha_marc->{$tablahash}->{$tabla.".".$campo_tabla}});

}

sub getValorFromMap {
    my ($marc_record,$campo_tabla, $tabla, $tablahash) = @_;

    my $campos    = getCampoSubcampoFromMap($campo_tabla, $tabla, $tablahash);

    foreach my $campo (@$campos) {
        if ($marc_record->subfield($campo->{campo},$campo->{subcampo})){
            return $marc_record->subfield($campo->{campo},$campo->{subcampo});
        }
    }
    return '';
}

sub getArregloValoresFromMap {
    my ($marc_record,$campo_tabla, $tabla, $tablahash) = @_;

    my $campos    = getCampoSubcampoFromMap($campo_tabla, $tabla, $tablahash);

my @arregloValores;
    foreach my $campo (@$campos) {
        if ($marc_record->subfield($campo->{"campo"},$campo->{"subcampo"})){
            push(@arregloValores, $marc_record->subfield($campo->{"campo"},$campo->{"subcampo"}));
         }
    }
    return \@arregloValores;
}

sub calcularFrecuenciaPublicacion{
    my ($freq) = @_;

    my $frequency_type='G'; #Generica por defecto
    my $frequency_num='';

    use Switch;
    switch ($freq) {
        case ["Anual"]                   { $frequency_type='A'; $frequency_num="1"; }
        case ["Bimestral","Bimest"]      { $frequency_type='A'; $frequency_num="6"; }
        case ["Trimestral","Trimest"]    { $frequency_type='A'; $frequency_num="4"; }
        case ["Cuatrimestral","Cuatrim"] { $frequency_type='A'; $frequency_num="3"; }
        case ["Semestral","Semest"]      { $frequency_type='A'; $frequency_num="2"; }
        case ["Semanal","Sem"]           { $frequency_type='M'; $frequency_num="4"; }
        case ["Diaria",]                 { $frequency_type='M'; $frequency_num="30";}
        case ["Mensual","Mens"]          { $frequency_type='A'; $frequency_num="12";}
        case ["Quincenal","Quinc"]       { $frequency_type='M'; $frequency_num="2"; }
     }

    return ($frequency_type,$frequency_num);
}

sub save_biblio_from_marc_record {
    my ($biblio,$responsable) = @_;

    my $biblionumber = C4::Biblio::newbiblio($biblio, $responsable);

    return $biblionumber;
}

sub update_biblio_from_marc_record{
    my ($biblio,$responsable) = @_;

    my $biblionumber = C4::Biblio::modbiblio($biblio, $responsable);

    return $biblionumber;
}

sub save_biblioitem_from_marc_record{
    my ($biblioitem,$responsable) = @_;

    my $biblioitem = C4::Biblio::newbiblioitem($biblioitem, $responsable);

    return $biblioitem;
}

sub update_biblioitem_from_marc_record{
    my ($biblioitem,$responsable) = @_;

    my $biblioitem = C4::Biblio::modbibitem($biblioitem, $responsable);

    return $biblioitem;
}

sub save_item_from_marc_record {
    my ($item,$accion_barcode,$responsable) = @_;

    my $errors;
    my $barcodes;
    my $existe_barcode=0;
    if($item->{'barcode'}){
    if (C4::Biblio::checkitems(1,$item->{'barcode'})){
        $existe_barcode=1;
    }#if checkitems
    }

    if($accion_barcode eq 'add_unique') {
    # Agrego solo si no existe el barcode
        C4::AR::Debug::debug("save_item_from_marc_record => barcode => add_unique ");
        if(!$existe_barcode){
            my @barcodes;
            @barcodes[0] = $item->{'barcode'} || 'generar';
            C4::AR::Debug::debug("ImportacionIsoMARC => save_item_from_marc_record => barcode => ".@barcodes[0]);
            my ($errors,$barcodes) = C4::Biblio::newitems($item, $responsable,@barcodes);
        }
    } elsif($accion_barcode eq 'generate_all') {
    # Siempre genero el barcode
        C4::AR::Debug::debug("save_item_from_marc_record => barcode => generate_all ");
        my @barcodes;
        @barcodes[0] = 'generar';
        C4::AR::Debug::debug("ImportacionIsoMARC => save_item_from_marc_record => barcode => ".@barcodes[0]);
        ($errors,$barcodes) = C4::Biblio::newitems($item, $responsable,@barcodes);

    } elsif($accion_barcode eq 'generate_repeat') {
    # Genero solo si está repetido
        C4::AR::Debug::debug("save_item_from_marc_record => barcode => generate_repeat ");
        my @barcodes;
        if($existe_barcode){ @barcodes[0] = 'generar';}
            else { @barcodes[0] = $item->{'barcode'} || 'generar';}
        C4::AR::Debug::debug("ImportacionIsoMARC => save_item_from_marc_record => barcode => ".@barcodes[0]);
         ($errors,$barcodes) = C4::Biblio::newitems($item, $responsable,@barcodes);
    }

    return ($errors,$barcodes);
}

#================================================================================================================


#
#Dado una Unid. de Informacion sus campos y subcampos ISO me devuelve la descripcion correspondiente
#
sub checkDescription{
    my $dbh = C4::Context->dbh;
    my $query ="Select descripcion
                  From isomarc
                  Where (campoIso=? and subCampoIso=?  and ui=?) ";
    my $sth=$dbh->prepare($query);
    $sth->execute(&ui,&campoIso,&subCampoIso);

    return ($sth->fetchrow_hashref);
}


#
#Dado una Unid. de Informacion  inserto la descripcion correspondiente

sub insertDescripcion{
        my ($descripcion,$id)=@_;
        my $dbh = C4::Context->dbh;
    my $query ="update  isomarc set descripcion=?
                 Where (id=?)";
    my $sth=$dbh->prepare($query);
    $sth->execute($descripcion,$id);
        $sth->finish;
}


sub insertUnidadInformacion{
    my $dbh = C4::Context->dbh;
    my $query ="Insert into isomarc (ui) values (?)";
    my $sth=$dbh->prepare($query);
    $sth->execute(&ui);
    $sth->finish;
}

#Datos para mostrar que estan en la tabla iso2709, para que carguen las descripciones de los
#campos y subcampos asi despues se puede hacer la importacion
#
sub datosCompletos{
    my ($campoIso,$branchcode)=@_;
    my $dbh = C4::Context->dbh;
    my @results;
    my $query ="Select * from isomarc ";
    $query.= "where campoIso = ".$campoIso." and ui='".$branchcode."'"; #Comentar para lograr el listado completo
    my $sth=$dbh->prepare($query);
    $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
         #if ($data->{'ui'} eq "") {$data->{'ui'}="-" };
         if ($data->{'subCampoIso'} eq "") {
                        $data->{'subCampoIso'}="-" };
                push(@results,$data);
        }
    return (@results);
}

#Muestro todas las tablas de la base de datos

#sub mostrarTablas{
#        my $dbh = C4::Context->dbh;
#        my @results;
#        my $query ="show tables";
#        my $sth=$dbh->prepare($query);
#        $sth->execute();
#   push(@results,""); #Agrago un primer elemento vacio
#        while (my $data=$sth->fetchrow_hashref){
#   #   if (($data->{'Tables_in_Econo'} eq 'items')
#   #       || ($data->{'Tables_in_Econo'} eq 'biblio')
#   #       || ($data->{'Tables_in_Econo'} eq 'biblioitems')
#   #   ) {
#           my $nombre = $data->{'Tables_in_Econo'};
#           push(@results,$nombre);
#   #   }
#   }
#   return (@results);
#}

#Dado el nombre de una tabla me devuelve todos sus campos
#

sub mostrarCamposMARC{
       my $dbh = C4::Context->dbh;
    my @results;
       my $query ="select distinct (tagfield) from marc_subfield_structure order by tagfield";
       my $sth=$dbh->prepare($query);
        $sth->execute();
    while (my $data=$sth->fetchrow_hashref){
    push(@results,$data->{'tagfield'});
    }
        $sth->finish;
        return (@results);
}
#Devuelve todos los campos y subcampos marc
#

sub mostrarSubCamposMARC {
       my $dbh = C4::Context->dbh;
    my @results;
       my $query ="select tagfield,tagsubfield,liblibrarian,repeatable from marc_subfield_structure order by tagfield";
       my $sth=$dbh->prepare($query);
        $sth->execute();
       while (my $data=$sth->fetchrow_hashref){
        push(@results,$data);
        }
        $sth->finish;
        return (@results);
}

#Inserto una tupla completa nueva
#
sub insertNuevo {
        my($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield)=@_;
    if ($descripcion eq "") {$descripcion= undef;}
        my $dbh = C4::Context->dbh;
        my $query ="insert into isomarc (campo5,campo9,campoIso, subCampoIso,descripcion,ui,orden,separador,MARCfield,MARCsubfield) values(?,?,?,?,?,?,?,?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield);
        $sth->finish;
}

#Inserto una tupla completa nueva
#
sub update {
        my($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield,$id)=@_;
    if ($descripcion eq "") {$descripcion= undef;}
        my $dbh = C4::Context->dbh;
        my $query ="update  isomarc set campo5=?,campo9=?,campoIso=?, subCampoIso=?,descripcion=?,ui=?,orden=?,separador=?,MARCfield=?,MARCsubfield=? where (id=?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield,$id);
        $sth-> finish;
}
#Inserto una tupla completa nueva
#
sub borrar {
        my($id)=@_;
        my $dbh = C4::Context->dbh;
        my $query ="delete  isomarc (id=?)";
        my $sth=$dbh->prepare($query);
        $sth->execute($id);
        $sth-> finish;
}


sub listadoDeCodigosDeCampo{
        my($ui)=@_;
        my $dbh = C4::Context->dbh;
        my @results;
        my $query ="select campoIso from isomarc where ui=? group by campoIso order by campoIso";
        my $sth=$dbh->prepare($query);
        $sth->execute($ui);
        while (my $data=$sth->fetchrow_hashref){
                push(@results,$data);
        }
        return (@results);
}

sub list {
        my $dbh = C4::Context->dbh;
        my %results;
        my $query ="select campoIso,subCampoIso,MARCfield as tagfield ,MARCsubfield as tagsubfield from isomarc order by campoIso;";
        my $sth=$dbh->prepare($query);
        $sth->execute();
        while (my $data=$sth->fetchrow_hashref){
        my @resp;
        @resp= ($data->{'tagfield'},$data->{'tagsubfield'});
        $results{$data->{'campoIso'},$data->{'subCampoIso'}}=@resp;
            }
        return (%results);
 }


=item sub procesar_reglas_matcheo

=cut
sub procesar_reglas_matcheo{
        my($reglas)=@_;

        my $reglas_matcheo;
        my @reglas_biblio=();
        my @reglas_biblioitem=();
        my @reglas_item=();
        my @rule_line =  split(/\n/,$reglas);

        foreach my $rule (@rule_line) {
        my $regla;
        $rule = C4::AR::Utilidades::trim($rule);
        $regla->{'campo'}=substr($rule,0,3);
        $regla->{'subcampo'}=substr($rule,3,1);
        ($regla->{'tablaKoha'},$regla->{'campoKoha'})=C4::AR::ExportacionIsoMARC::getTablaFromSubfieldByCampoSubcampo($regla->{'campo'},$regla->{'subcampo'});

        if(($regla->{'tablaKoha'} eq 'biblio')||($regla->{'tablaKoha'} eq 'additionalauthors')||($regla->{'tablaKoha'} eq 'bibliosubject')||($regla->{'tablaKoha'} eq 'bibliosubtitle')||($regla->{'tablaKoha'} eq 'colaboradores')) {
        push(@reglas_biblio,$regla);
        }
        elsif(($regla->{'tablaKoha'} eq 'biblioitems')||($regla->{'tablaKoha'} eq 'publisher')||($regla->{'tablaKoha'} eq 'isbns')){
        push(@reglas_biblioitem,$regla);
        }
        else {
        push(@reglas_item,$regla);
        }
        }

        $reglas_matcheo->{'biblio'}=\@reglas_biblio;
        $reglas_matcheo->{'biblioitem'}=\@reglas_biblioitem;
        $reglas_matcheo->{'item'}=\@reglas_item;

        return ($reglas_matcheo);
}
