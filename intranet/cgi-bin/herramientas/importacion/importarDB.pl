#!/usr/bin/perl


use strict;
use CGI;
use C4::AR::Auth;

use C4::AR::Utilidades;
use C4::AR::ImportacionIsoMARC;
use JSON;

my $input = new CGI;

my $upfile      = $input->param('upfile');
C4::AR::ImportacionIsoMARC::subirArchivoISO($upfile);

my $comentario  = $input->param('comentario');
my $esquema     = $input->param('esquemaImportacion');









#$obj = C4::AR::Utilidades::from_json_ISO($obj);
#my $accion = $obj->{'tipoAccion'} || "";


#my $query                   = new CGI;
#my $archivo                 = $query->param('upfile');
#my $comentario              = $query->param('comentario');
#my $accion                  = $query->param('accion');
#my $importacion             = $query->param('importacion');
#my $registro_importacion    = $query->param('registro_importacion');

#my $flagsrequired;
#$flagsrequired->{'borrow'} = 1;
#my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0, $flagsrequired,"intranet");



#if ($accion eq "UPLOAD"){
    #my ($id)        = &C4::AR::ImportacionIsoMARC::save_marc_import($archivo, $comentario, "S");

  ##  my $filename    = C4::AR::UploadFile::uploadISO( $archivo );

    #my $file;
    #if($query->param('file_format') eq 'iso'){
        #$file = MARC::File::USMARC->in( $archivo );
     #} else {
        #$file = MARC::File::XML->in( $archivo );
     #}
##     C4::AR::Debug::debug("import_upload => file: ".$file);

    #my $cant_biblios        = 0;
    #my $cant_biblioitems    = 0;
    #my $cant_items          = 0;
    #my $cant_reg_desconocido = 0;

    #while ( my $marc = $file->next() ) {

        #C4::AR::Debug::debug("importDB.pl => import_upload => file: ".$marc->as_usmarc);
        #C4::AR::ImportacionIsoMARC::save_marc_import_record($id, $marc);

        #if($marc->subfield('090', 'a') eq "Biblio") {
            #$cant_biblios++;
        #}elsif($marc->subfield('090', 'a') eq "Biblioitem") {
            #$cant_biblioitems++;
        #}elsif($marc->subfield('090', 'a') eq "Item") {
            #$cant_items++;
        #}else{
               #$cant_reg_desconocido++;
            #}
    #}

    #$file->close();
    #undef $file;

    #my %params;
    #$params{'cant_biblios'}     = $cant_biblios;
    #$params{'cant_biblioitems'} = $cant_biblioitems;
    #$params{'cant_items'}       = $cant_items;
    #$params{'cant_reg_desconocido'} = $cant_reg_desconocido;
    #$params{'id'}               = $id;

    #C4::AR::ImportacionIsoMARC::update_marc_import(\%params);

#} elsif ($accion eq "ELIMINAR_IMPORTACION"){

    #C4::AR::ImportacionIsoMARC::delete_marc_import_record($importacion);

    #my %params;
    #$params{'estado'}   = "E";
    #$params{'id'}       = $importacion;

    #C4::AR::ImportacionIsoMARC::update_marc_import(\%params);

#} elsif ($accion eq "ELIMINAR_REGISTRO_IMPORTACION"){

##     C4::AR::ImportacionIsoMARC::delete_registro_marc_import_record($registro_importacion);

##     my %params;
##     $params{'estado'}   = "E";
##     $params{'id'}       = $importacion;
##
##     C4::AR::ImportacionIsoMARC::update_marc_import(\%params);
##     print $query->redirect("/cgi-bin/koha/import/manage_import_batch_detail.pl");

#} elsif ($accion eq "IMPORTAR"){

##     C4::AR::ImportacionIsoMARC::delete_marc_import_record();
    #C4::AR::ImportacionIsoMARC::realizar_importacion_fromDB($importacion,$loggedinuser);
    #C4::AR::ImportacionIsoMARC::realizar_importacion_registros_desconocidos_fromDB($importacion,$loggedinuser);
    #my %params;
    #$params{'estado'}           = "I";
    #$params{'id'}               = $importacion;
    #$params{'fecha_import'}     = C4::Date::format_date_in_iso(ParseDate("today"));

    #C4::AR::ImportacionIsoMARC::update_marc_import(\%params);

#} elsif ($accion eq "VERIFICAR_MATCHEO"){

    ##Reglas de matcheo
    #my $reglas    = $query->param('reglas_matcheo');

    ##Acciones
    #my $acciones;
    #$acciones->{'accion_general'}       = $query->param('accion_general');
    #$acciones->{'accion_sinmatcheo'}    = $query->param('accion_sinmatcheo');
    #$acciones->{'accion_item'}          = $query->param('accion_item');
    #$acciones->{'accion_barcode'}       = $query->param('accion_barcode');
    #$acciones->{'id'}                   = $importacion;
    #$acciones->{'reglas_matcheo'}       = $reglas;

    #my $reglas_matcheo = C4::AR::ImportacionIsoMARC::procesar_reglas_matcheo($reglas);
    #C4::AR::ImportacionIsoMARC::realizar_matcheo_importacion_fromDB($importacion,$reglas_matcheo,$acciones);

    ##actualizo el header del registro de la importacion
    #C4::AR::ImportacionIsoMARC::update_marc_import($acciones);

    #print $query->redirect("/cgi-bin/koha/import/manage_import_batch_detail.pl?import=".$importacion);

#}


#print $query->redirect("/cgi-bin/koha/import/manage_import_batch.pl");
