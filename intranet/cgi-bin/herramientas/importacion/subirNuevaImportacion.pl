#!/usr/bin/perl


use strict;
use CGI;
use C4::AR::Auth;

use C4::AR::Utilidades;
use C4::AR::ImportacionIsoMARC;
use JSON;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "/herramientas/importacion/importar.tmpl",
                                    query => $query,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY',
                                                        tipo_documento => 'ANY',
                                                        accion => 'ALTA',
                                                        entorno => 'undefined'},
                                    debug => 1,
            });
$t_params->{'combo_formatos'}          = C4::AR::Utilidades::generarComboFormatosImportacion();
$t_params->{'combo_esquemas'}          = C4::AR::Utilidades::generarComboEsquemasImportacion();


my $titulo      = $input->param('titulo');
my $file_name   = $input->param('upfile');
my $file_data   = $input->upload('upfile');
my $comentario  = $input->param('comentario');
my $esquema     = $input->param('esquemaImportacion');
my $formato     = $input->param('formatoImportacion');

#Si el esquema es nuevo hay que crearlo vacio al menos!
my ($msg) = C4::AR::UploadFile::uploadImport($file_name,$titulo,$comentario,$formato,$esquema,$file_data);


$t_params->{'mensaje'} = $msg;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
