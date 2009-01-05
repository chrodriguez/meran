#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;

my $input = new CGI;

my ($template, $session, $t_params, $cookie)= get_template_and_user({
									template_name => "opac-main.tmpl",
									type => "opac",
									query => $input,
									authnotrequired => 1,
									flagsrequired => {borrow => 1},
			 });


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
#se genera un nuevo nroRandom para que se autentique el usuario
my $random_number= C4::Auth::_generarNroRandom();
print A "numero random: ".$random_number."\n";
#se genera una nueva session
# my $sessionID= C4::Auth::_generarSessionID();
my %params;
$params{'userid'}= '';
$params{'loggedinusername'}= '';
$params{'password'}= '';
$params{'nroRandom'}= $random_number;
$params{'borrowernumber'}= '';
$params{'type'}= 'opac'; #OPAC o INTRA
$params{'flagsrequired'}= '';
$params{'browser'}= $ENV{'HTTP_USER_AGENT'};
#genero una nueva session
# my $session = CGI::Session->load();
# $session->clear();
# $session->delete();
my $session= C4::Auth::_generarSession(\%params);
my $sessionID= C4::Auth::_generarSessionID();
# my $sessionID= $session->param('sessionID');
$session->param('sessionID', $sessionID);
my $cookie= C4::Auth::_generarCookie($input,'sessionID', $sessionID, '');
print A "cookie: ".$cookie."\n";
my $userid= undef;
print A "sessionID: ".$sessionID."\n";
# print A "cookie input->cookie: ".$input->cookie."\n";
#guardo la session en la base
C4::Auth::_save_session_db(C4::Context->dbh, $sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

#envio la info necesaria al cliente
# my $self_url = $input->url(-absolute => 1);
# $template->param(url => $self_url);
$t_params->{'CGIitemtype'}= $CGIitemtype;
$t_params->{'RANDOM_NUMBER'}= $random_number;
$t_params->{'loginprompt'}= 1;
}
close(A);
$t_params->{'LibraryName'}= C4::Context->preference("LibraryName");

# $query, $template, $params, $session, $cookie
C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
