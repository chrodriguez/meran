#!/usr/bin/perl

# use strict;
use C4::Auth;
use CGI;
use Spreadsheet::Read;




my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                template_name => "adquisiciones/cargaPresupuesto.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},# revisar el entorno
                                debug => 1,
                 });



#  my $ref = ReadData ("test.ods");
my $ref = ReadData ($input->param('datafile'));


my $cell = cr2cell (2, 9);
C4::AR::Debug::debug("Celda:".$cell);











# 
# my $parser   = Spreadsheet::ParseExcel->new();
# my $workbook = $parser->parse($input->param('datafile'));
# 
# #$input->param('datafile')
# 
# 
# 
# for my $worksheet ( $workbook->worksheets() ) {
#         my ( $row_min, $row_max ) = $worksheet->row_range();
#         my ( $col_min, $col_max ) = $worksheet->col_range();
# 
#         for my $row ( $row_min .. $row_max ) {
#             for my $col ( $col_min .. $col_max ) {
# 
#                 my $cell = $worksheet->get_cell( $row, $col );
#                 next unless $cell;
#                 C4::AR::Debug::debug($cell->value());
#             }
#         }
# }

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

