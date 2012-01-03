#!/usr/bin/perl


use strict;
use CGI;
use C4::AR::Auth;

use C4::AR::Utilidades;
use C4::AR::ImportacionIsoMARC;
use JSON;

my $input = new CGI;

my $titulo      = $input->param('titulo');
my $upfile      = $input->param('upfile');
C4::AR::ImportacionIsoMARC::subirArchivoISO($upfile);
my $comentario  = $input->param('comentario');
my $esquema     = $input->param('esquemaImportacion');
