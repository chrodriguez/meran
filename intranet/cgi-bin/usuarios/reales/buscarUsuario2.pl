#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use POSIX;
# # use Locale::TextDomain; # libintl-perl
use Locale::Maketext::Gettext::Functions; # Locale::Maketext::Gettext::Functions



my $input = new CGI;

my ($template, $session, $params) = get_template_and_user({
									template_name => "usuarios/reales/buscarUsuario2.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {borrowers => 1},
									debug => 1,
			    });



# print $session->header;
my $locale = "es_ES";
my $setlocale= setlocale(LC_MESSAGES, $locale); #puede ser LC_ALL
print bindtextdomain("usuarios", "/usr/local/koha/intranet/locale/");
textdomain("usuarios");
get_handle("es_ES");


C4::Auth::output_html_with_http_headers($input, $template, $params);