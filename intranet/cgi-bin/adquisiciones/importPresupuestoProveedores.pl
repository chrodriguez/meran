#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use C4::AR::UploadFile;
use Spreadsheet::Read;
use Spreadsheet::ParseExcel;

 
# my $query       = new CGI;
# my $prov   = $query->param('id');


my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

# my $filepath=$input->param('formPlanilla');


$obj=C4::AR::Utilidades::from_json_ISO($obj);


my $prov= $obj->{'id_proveedor'}||"";
my $tipoAccion= $obj->{'tipoAccion'}||"";



# PARA FILEUPLOAD
my $filepath    = $input->param('planilla');

#----------------


# PARA INPUT COMUN
# my $filepath    = $query->param('file');
#-----------------


my $authnotrequired = 0;
my $presupuestos_dir= "/usr/share/meran/intranet/htdocs/intranet-tmpl/proveedores";
my $write_file  = $presupuestos_dir."/".$filepath;


($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
                      template_name   => '/adquisiciones/mostrarPresupuesto.tmpl',
                      query       => $input,
                      type        => "intranet",
                      authnotrequired => 0,
                      flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
});

my ($error,$codMsg,$message) = &C4::AR::UploadFile::uploadFile($prov,$write_file,$filepath, $presupuestos_dir);

# my $parser  = Spreadsheet::ParseExcel->new();
# 
# my $workbook = $parser->parse($write_file);
# 
# if ( !defined $workbook ) {
#             die $parser->error(), ".\n";
# }
#  
# my @table;
# my @reg;
# my $presupuesto;
#      
# 
# for my $worksheet ( $workbook->worksheets() ) {
#      my ( $row_min, $row_max ) = $worksheet->row_range();
#      my ( $col_min, $col_max ) = $worksheet->col_range();
#      for my $row ( $row_min + 1 .. $row_max ) {
#         my %hash;
#         my $cell = $worksheet->get_cell( $row, $col );
#         
#         $hash{'renglon'}            = $worksheet->get_cell( $row, 0 )->value();
#         $hash{'cantidad'}           = $worksheet->get_cell( $row, 1 )->value();
#         $hash{'articulo'}           = $worksheet->get_cell( $row, 2 )->value();       
#         $hash{'precio_unitario'}    = $worksheet->get_cell( $row, 3 )->value();
#         $hash{'total'}              = $worksheet->get_cell( $row, 4 )->value();
#         C4::AR::Debug::debug("MI RENGLON:".$hash{'renglon'});
#        
#         push(@reg, \%hash);  
#   }
# }
# 
# 
# $t_params->{'datos_presupuesto'} = \@reg;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);