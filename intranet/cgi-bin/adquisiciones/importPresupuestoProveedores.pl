#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use Spreadsheet::Read;
use Spreadsheet::ParseExcel;


my $query       = new CGI;
my $prov   = $query->param('id');
my $filepath    = $query->param('datafile');
my $authnotrequired = 0;

 C4::AR::Debug::debug($filepath);

my ($template, $session, $t_params)= get_template_and_user({
                                template_name => "adquisiciones/cargaPresupuesto.tmpl",
                                query => $query,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},# revisar el entorno
                                debug => 1,
                 });

   
if ((open(WFD,">$write_file"))) {
                while ($bytes_read=read($filepath,$buff,2096)) {
                    $size += $bytes_read;
                    binmode WFD;
                    print WFD $buff;
                }
                close(WFD);  
}

my $workbook = $parser->parse("/usr/share/meran/intranet/htdocs/intranet-tmpl/proveedores/nota.xls");



my $parser   = Spreadsheet::ParseExcel->new();

 
# my $workbook = $parser->parse($input->param('datafile')); 
 
my $presupuesto;

if ( !defined $workbook ) {
                die $parser->error(), ".\n";
 }
 
for my $worksheet ( $workbook->worksheets() ) {
     my ( $row_min, $row_max ) = $worksheet->row_range();
     my ( $col_min, $col_max ) = $worksheet->col_range();
 
     for my $row ( $row_min .. $row_max ) {
         for my $col ( $col_min .. $col_max ) {
 
             my $cell = $worksheet->get_cell( $row, $col );
#              if ($cell->value() ne "")
                


              next unless $cell;

             C4::AR::Debug::debug($cell->value());
        
         }
     }
}

my ($error,$codMsg,$message) = &C4::AR::UploadFile::uploadPhoto($nro_socio, $filepath);



C4::Auth::output_html_with_http_headers($template, $t_params, $session);

