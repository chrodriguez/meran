#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use C4::AR::UploadFile;
use Spreadsheet::Read;
use Spreadsheet::ParseExcel;

 
my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);


my $prov= $obj->{'id_proveedor'}||"";
my $tipoAccion= $obj->{'tipoAccion'}||"";



# DEBUG (21-12-2010 12:32:7) => elemento id_prov
# DEBUG (21-12-2010 12:32:7) => elemento upload
# DEBUG (21-12-2010 12:32:7) => elemento planilla


# PARA FILEUPLOAD
# my $filepath    = $input->param('planilla');

# C4::AR::Debug::debug("plantilla ????????? ". $input->param('planilla'));
# C4::AR::Debug::debug("upload ????????? ". $input->param('upload'));
# 
# C4::AR::Debug::debug("???????????????????????????????");
# C4::AR::Utilidades::printHASH($input);
# 
# foreach my $e (@{$input->{'.parameters'}}){
# C4::AR::Debug::debug("elemento ".$e);    
# # C4::AR::Debug::debug("value ".@input->{'.parameters'}->{$e});  
# }

#----------------

my $authnotrequired = 0;
my $presupuestos_dir= "/usr/share/meran/intranet/htdocs/intranet-tmpl/proveedores";

($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
                      template_name   => '/adquisiciones/mostrarPresupuesto.tmpl',
                      query       => $input,
                      type        => "intranet",
                      authnotrequired => 0,
                      flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
});

my $filepath= $input->param('planilla');

my $write_file  = $presupuestos_dir."/".$filepath;

my ($error,$codMsg,$message) = &C4::AR::UploadFile::uploadFile($prov,$write_file,$filepath,$presupuestos_dir);


C4::Auth::output_html_with_http_headers($template, $t_params, $session);