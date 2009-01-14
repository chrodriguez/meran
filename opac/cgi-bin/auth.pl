#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;

my $query = new CGI;

my ($template, $t_params)= C4::Output::gettemplate("opac-auth.tmpl", 'opac');

# my $session = CGI::Session->load();

open(F, ">>/tmp/debug.txt");
print F "opac auth=>: \n";
#se genera un nuevo nroRandom para que se autentique el usuario
my $random_number= C4::Auth::_generarNroRandom();
print F "opac auth=> numero random: ".$random_number."\n";
#se genera una nueva session
# my $sessionID= C4::Auth::_generarSessionID();
my %params;
$params{'userid'}= '';
$params{'loggedinusername'}= '';
$params{'password'}= '';
$params{'nroRandom'}= '';
$params{'borrowernumber'}= '';
$params{'type'}= 'opac'; #OPAC o INTRA
$params{'flagsrequired'}= '';
$params{'browser'}= $ENV{'HTTP_USER_AGENT'};
#genero una nueva session
# my $session = CGI::Session->load();
# $session->clear();
# $session->delete();
my $session= C4::Auth::_generarSession(\%params);
my $sessionID= $session->param('sessionID');
# my $sessionID= C4::Auth::_generarSessionID();
# $session->param('sessionID', $sessionID);
my $cookie= C4::Auth::_generarCookie($query,'sessionID', $sessionID, '');

$session->header(
				-cookie => $cookie,
			);	


print F "opac auth=> cookie: ".$cookie."\n";
my $userid= undef;
print F "opac auth=> sessionID: ".$sessionID."\n";
# print A "cookie input->cookie: ".$input->cookie."\n";
#guardo la session en la base
C4::Auth::_save_session_db(C4::Context->dbh, $sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

$t_params->{'RANDOM_NUMBER'}= $random_number;
# $params->{'RANDOM_NUMBER'}= $session->param('nroRandom');
my $self_url = $query->url(-absolute => 1);
## FIXME
$t_params->{'url'}= $self_url;#se le esta pasando la url para el action del FORM, se podria dejar fijo
$t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),'INTRA',[]);
close(F);
# $query, $template, $params, $session, $cookie
C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);