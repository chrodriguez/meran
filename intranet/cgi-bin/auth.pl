#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;

my ($template, $t_params)= C4::Output::gettemplate("auth.tmpl", 'intranet');

open(F, ">>/tmp/debug.txt");
print F "intra auth=>: \n";
#se genera un nuevo nroRandom para que se autentique el usuario
my $random_number= C4::Auth::_generarNroRandom();
print F "intra auth=> numero random: ".$random_number."\n";

#genero una nueva session
my $session = CGI::Session->load();
#se destruye la session anterior
$session->clear();
$session->delete();

#se genera una nueva session
my %params;
$params{'userid'}= '';
$params{'loggedinusername'}= '';
$params{'password'}= '';
$params{'nroRandom'}= '';
$params{'borrowernumber'}= '';
$params{'type'}= 'opac'; #OPAC o INTRA
$params{'flagsrequired'}= '';
$params{'browser'}= $ENV{'HTTP_USER_AGENT'};

$session= C4::Auth::_generarSession(\%params);
my $sessionID= $session->param('sessionID');
my $cookie= C4::Auth::_generarCookie($query,'sessionID', $sessionID, '');

$session->header(
                -cookie => $cookie,
            );   

print F "intra auth=> cookie: ".$cookie."\n";
print F "intra auth=> sessionID: ".$sessionID."\n";

my $userid= undef;
#guardo la session en la base
C4::Auth::_save_session_db(C4::Context->dbh, $sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

$t_params->{'RANDOM_NUMBER'}= $random_number;
$t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),'INTRA',[]);

close(F);

&C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);