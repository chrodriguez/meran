#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;


use POSIX;
use Locale::TextDomain; # libintl-perl
use Locale::Maketext::Gettext::Functions; # Locale::Maketext::Gettext::Functions
use Locale::Maketext;
open(A,">>/tmp/debug.txt");
my $locale = "es_ES";
my $setlocale= setlocale(LC_MESSAGES, $locale); #puede ser LC_ALL
print A $setlocale."\n";

my $bind= bindtextdomain("usuarios", "/usr/local/koha/intranet/locale/es_ES/usuarios.mo");
textdomain("usuarios");
get_handle("es_ES");

print A "bind: ".$bind."\n";
# print A Locale::Maketext::Gettext::Functions::maketext("Hello, world!"),"\n";
print A maketext("Hello, world!");
# print A __("Hello, world!"),"\n";


# my $bind= bindtextdomain("usuarios", "/usr/local/koha/intranet/locale/es_ES/");
# textdomain("usuarios.mo");
# get_handle("es_ES");
# print A "get_handle: ".get_handle("es_ES")."\n";
# print A "bind: ".$bind."\n";
# print A Locale::Maketext::Gettext::Functions::maketext("Hello, world!"),"\n";
# print A maketext("Hello, world!"),"\n";
# print A __("Hello, world!"),"\n";




my $input = new CGI;

my ($template, $loggedinuser, $cookie, $params)
    = get_template_and_user({
				template_name => "usuarios/reales/buscarUsuario.tmpl",
			     	query => $input,
			     	type => "intranet",
			     	authnotrequired => 0,
			     	flagsrequired => {borrowers => 1},
			     	debug => 1,
			     });


$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";