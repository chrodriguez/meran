#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "/herramientas/exportar.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'undefined'},
									debug => 1,
			});


my $op          = $query->param("op") || '';
my $filename    = $query->param("filename");

if (!$filename){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $year       += 1900;
    my $dt      = "$hour$min-$mday/$mon/$year";
    $filename   = 'export-'.$dt.'.'.$query->param('export_format');
}

use C4::AR::ExportacionIsoMARC;

if ($op eq "export") {

    print $query->header(
                                -type           => 'application/octet-stream', 
                                -attachment     => $filename,
                                -expires        => '0',
                      );

    eval {

        C4::AR::ExportacionIsoMARC::marc_record_to_ISO_from_range( $query );
    };

    if($@){
          my $msg_error = "ERORROROROR $@";
          C4::AR::Debug::debug($msg_error);
    }
}

my %params_combo;
$params_combo{'default'}                    = C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");
$t_params->{'combo_tipo_documento'}         = C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);

my %params_combo;
$params_combo{'default'}                    = C4::AR::Preferencias->getValorPreferencia("defaultUI");
$t_params->{'combo_ui'}                     = C4::AR::Utilidades::generarComboUI(\%params_combo);

my %params_combo;
$params_combo{'default'}                    = C4::AR::Preferencias->getValorPreferencia("defaultUI");
$t_params->{'combo_nivel_bibliogratico'}    = C4::AR::Utilidades::generarComboNivelBibliografico(\%params_combo);

C4::Auth::output_html_with_http_headers($template, $t_params,$session);
