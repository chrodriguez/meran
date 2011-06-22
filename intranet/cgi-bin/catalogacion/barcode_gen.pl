#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Nivel3;
use C4::AR::PdfGenerator;

my $input = new CGI;


my ($template, $session, $t_params) =  get_template_and_user ({
			template_name	=> 'reports/usuariosResult.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> {    ui => 'ANY', 
                                    tipo_documento => 'ANY', 
                                    accion => 'CONSULTA', 
                                    entorno => 'undefined'},
    });

my $id3             = $input->param('id');
my $nivel3          = C4::AR::Nivel3::getNivel3FromId3($id3);

my @arreglo = ();
push (@arreglo, $nivel3);
C4::AR::PdfGenerator::batchBookLabelGenerator(1,\@arreglo);