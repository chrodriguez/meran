#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "main.tmpl",
									query => $query,
									type => "intranet",
									authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
									debug => 1,
			});

C4::AR::Debug::debug("antes: ".C4::Modelo::DB::AutoBase1->use_cache_during_apache_startup());
C4::Modelo::DB::AutoBase1->use_cache_during_apache_startup(1);
C4::Modelo::DB::AutoBase1->db_cache->prepare_for_apache_fork();
C4::AR::Debug::debug("despues: ".C4::Modelo::DB::AutoBase1->use_cache_during_apache_startup());


C4::Auth::output_html_with_http_headers($template, $t_params,$session);
