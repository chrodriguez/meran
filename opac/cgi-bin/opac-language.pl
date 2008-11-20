#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;       # get_template_and_user

my $input = new CGI;

open(A,">>/tmp/debug.txt");
print A "opac-language.pl \n";
my $session = CGI::Session->load();
$session->param('lang', $input->param('lang_server') );
print A "lang desde el parametro: ".$input->param('lang_server')."\n";
print A "lang desde la session: ".$session->param('lang')."\n";
print A "REQUEST_URI: ".$ENV{'REQUEST_URI'}."\n";
print A "vengo desde: ".$input->param('url')."\n";
close(A);
#regreso a la pagina en la que estaba
C4::Auth::redirectTo($input->param('url'));




