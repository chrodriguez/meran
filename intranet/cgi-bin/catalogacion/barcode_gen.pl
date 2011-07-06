#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Nivel3;
use C4::AR::PdfGenerator;


my $input = new CGI;

# my $obj= $input->param('obj');
# $obj= C4::AR::Utilidades::from_json_ISO($obj);


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


my $id = $input->param('id');
my @arreglo = ();


if ($id){
    my $nivel3          = C4::AR::Nivel3::getNivel3FromId3($id);
    push (@arreglo, $nivel3);
} else {

    my $hash=$input->{'param'};

    my @keys=keys %$hash;
    my $key_string= @keys[0];
  
    my $array_ref= $hash->{$key_string};

    foreach my $id3 (@$array_ref) {
                my $nivel3 = C4::AR::Nivel3::getNivel3FromId3($id3);
                push (@arreglo, $nivel3);
    }
}



# my $id1 = $input->param('id1');
# my $id2 = $input->param('id2');
# my $id3 = $input->param('id');
# my @arreglo = ();
# 
# 
# if ($id3){
#     my $id3             = $input->param('id');
#     my $nivel3          = C4::AR::Nivel3::getNivel3FromId3($id3);
#     push (@arreglo, $nivel3);
# } else {
#     
#     my $i;
# 
#     for($i = $id1; $i < $id2 + 1; $i++) { 
#           my $nivel3 = C4::AR::Nivel3::getNivel3FromId3($i);
#           push (@arreglo, $nivel3);
#     }
# }

C4::AR::PdfGenerator::batchBookLabelGenerator(scalar(@arreglo),\@arreglo);

