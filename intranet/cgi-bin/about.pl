#!/usr/bin/perl

use HTML::Template;
use strict;
require Exporter;
# use C4::Database;
use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use C4::Context;
use CGI;

# obtenemos en una HASH la UI
my $ui_id = C4::AR::Preferencias::getValorPreferencia('defaultbranch');    
my $ui    = C4::AR::Referencias::obtenerUIByIdUi($ui_id); 

C4::AR::Utilidades::printHASH($ui);

#agrego una modificacion para testear el plugin del mantisssssssssssssdddfasas

my $dbh   = C4::Context->dbh;
my $input = new CGI;
my ($template, $session, $t_params) = get_template_and_user({
                 template_name      => "about.tmpl",
			     query              => $input,
			     type               => "intranet",
			     authnotrequired    => 0,
			     flagsrequired      => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			     debug              => 1,
			});

#my $kohaVersion = C4::Context->config("kohaversion");
my $osVersion   = `uname -a`;
my $perlVersion = $];

# mysql(1) may not be on the PATH, so we try to do a select statement instead
my $sti = $dbh->prepare("select version()");
$sti->execute;
my $mysqlVersion = ($sti->fetchrow_array)[0]; # `mysql -V`

# The web server may not be httpd, and/or may not be in the PATH
my $apacheVersion =  $ENV{SERVER_SOFTWARE} || `httpd -v`;

#$t_params->{'kohaVersion'}   = $kohaVersion;

#FIXME: ver si son necesarios:
$t_params->{'osVersion'}      = $osVersion;
$t_params->{'perlVersion'}    = $perlVersion;
$t_params->{'mysqlVersion'}   = $mysqlVersion;
$t_params->{'apacheVersion'}  = $apacheVersion;

$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Acerca De MERAN");

C4::AR::Auth::output_html_with_http_headers($template, $t_params,$session);
