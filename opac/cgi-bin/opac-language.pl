#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;       # get_template_and_user

my $input = new CGI;

##Aca se controlo el cambio de idioma
my $session = CGI::Session->load();
$session->param('lang', $input->param('lang_server') );
#regreso a la pagina en la que estaba
C4::Auth::redirectTo($input->param('url'));




