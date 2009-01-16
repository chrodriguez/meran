#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									type => "opac",
									query => $input,
									authnotrequired => 1,
									flagsrequired => {borrow => 1},
			 });


## FIXME usar generador de combo para itemtypes
my $dbh = C4::Context->dbh;
my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
my  @itemtype;
my %itemtypes;
while (my ($value,$lib) = $sth->fetchrow_array) {
	push @itemtype, $value;
	$itemtypes{$value}=$lib;
}

my $CGIitemtype=CGI::scrolling_list( -name     => 'itemtype',
			-values   => \@itemtype,
			-labels   => \%itemtypes,
			-size     => 1,
			-multiple => 0 );
$sth->finish;

open(A, ">>/tmp/debug.txt");
print A "desde opac-main: \n";
if( $session->param('borrowernumber') ){
print A "tengo borrower: ".$session->param('borrowernumber')."\n";
}else{
=item
    #se genera un nuevo nroRandom para que se autentique el usuario
    my $random_number= C4::Auth::_generarNroRandom();
print A "opac auth=> numero random: ".$random_number."\n";

    #genero una nueva session
    my $session = CGI::Session->load();
    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),'INTRA',[]);
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

    #esto realmente destruye la session
    undef($session);
    $session= C4::Auth::_generarSession(\%params);
    my $sessionID= $session->param('sessionID');
    my $cookie= C4::Auth::_generarCookie($input,'sessionID', $sessionID, '');

    $session->header(
                    -cookie => $cookie,
                );   
        
print A "opac auth=> cookie: ".$cookie."\n";
print A "opac auth=> sessionID: ".$sessionID."\n";
    
    my $userid= undef;
    #guardo la session en la base
    C4::Auth::_save_session_db($sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);
    
    
    $t_params->{'RANDOM_NUMBER'}= $random_number;
=cut
    ($session)= C4::Auth::inicializarAuth($input, $t_params);
}
close(A);
$t_params->{'CGIitemtype'}= $CGIitemtype;
$t_params->{'LibraryName'}= C4::Context->preference("LibraryName");

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
