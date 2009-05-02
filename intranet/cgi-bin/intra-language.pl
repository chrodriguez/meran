#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;       # get_template_and_user

my $input = new CGI;

C4::AR::Debug::debug("intr-language.pl \n");
my $session = CGI::Session->load();
$session->param('locale', $input->param('lang_server'));
C4::AR::Debug::debug("lang desde el parametro: ".$input->param('lang_server')."\n");
C4::AR::Debug::debug("lang desde la session: ".$session->param('lang')."\n");
C4::AR::Debug::debug("REQUEST_URI: ".$ENV{'REQUEST_URI'}."\n");
C4::AR::Debug::debug("vengo desde: ".$input->param('url')."\n");
#regreso a la pagina en la que estaba
C4::Auth::redirectTo($input->param('url')."?token=".$session->param('token'));



