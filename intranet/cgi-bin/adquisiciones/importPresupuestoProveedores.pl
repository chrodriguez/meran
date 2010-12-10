#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use C4::AR::UploadFile;
use Spreadsheet::Read;
use Spreadsheet::ParseExcel;

 
my $query       = new CGI;
my $prov   = $query->param('id');
my $filepath    = $query->param('fake_file');
my $authnotrequired = 0;
my $presupuestos_dir= "/usr/share/meran/intranet/htdocs/intranet-tmpl/proveedores";
my $write_file  = $presupuestos_dir."/".$filepath;


C4::AR::Debug::debug($write_file);


  ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
                      template_name   => '/adquisiciones/cargaPresupuesto.tmpl',
                      query       => $query,
                      type        => "intranet",
                      authnotrequired => 0,
                      flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
   });




my ($error,$codMsg,$message) = &C4::AR::UploadFile::uploadFile($prov,$write_file,$filepath, $presupuestos_dir);

my $parser  = Spreadsheet::ParseExcel->new();

my $workbook = $parser->parse($write_file);

if ( !defined $workbook ) {
            die $parser->error(), ".\n";
}
 
my @table;
my @reg;

     
for my $worksheet ( $workbook->worksheets() ) {
     my ( $row_min, $row_max ) = $worksheet->row_range();
     my ( $col_min, $col_max ) = $worksheet->col_range();
 
     for my $row ( $row_min .. $row_max ) {
         for my $col ( $col_min .. $col_max ) {
                 my $cell = $worksheet->get_cell( $row, $col );
                 next unless $cell;
                 @reg[$col]= $cell->value();
                 C4::AR::Debug::debug($reg[$col])      
         }
     @table[$row]= @reg; 
     }
}


$t_params->{'datos_presupuesto'} = $table;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);