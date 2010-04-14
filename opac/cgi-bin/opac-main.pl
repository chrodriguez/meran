#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::AR::Novedades;
use CGI;
use HTML::Template;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main2.tmpl",
								    query => $query,
                                    type => "opac",
									authnotrequired => 0,
									flagsrequired => {  ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
            });

#my($template, $t_params)= C4::Output::gettemplate("opac-main2.tmpl", 'opac');
#my ($session) = CGI::Session->load();

#my ($cantidad,$grupos)= C4::AR::Nivel1::getUltimosGrupos();
my ($cantidad_novedades,$novedades)= C4::AR::Novedades::getUltimasNovedades();
#$t_params{"template_name"}="/usr/local/koha/opac/htdocs/opac-tmpl/opac-main2.tmpl";
#my $template=Template->new({ABSOLUTE=>1,CACHE_SIZE => 200,
#                COMPILE_DIR => '/tmp/ttc'});
#$t_params->{'nro_socio'}= $session->param('nro_socio');
$t_params->{'miguel'}= "JUANCITO";
#$t_params{'SEARCH_RESULTS'}= $grupos;
$t_params->{'novedades'}= $novedades;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
#print "<body>
#<p> GASPO que miras?</p>
#</body>";
