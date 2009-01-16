#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;


open(F, ">>/tmp/debug.txt");
print F "desde redirectController: \n";

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
my $session = CGI::Session->load();


my $cookie= C4::Auth::_generarCookie($query,'sessionID', $session->param('sessionID'), '');
# $session->clear();
# $session->delete();
## FIXME esto esta feo, deberia ser un redirectContrller.pl que deribe  a cada pl
#esta indireccion es pq een el cliente esta fija la url cuando es un CLIENT_REDIRECT
##entonces se fijaria el redirectContrller.pl en el AjaxxHelper y este redirige segun
#lo indicado en el session->param('redirectTo')
print F "redirectContrller->redirect: ".$session->param('redirectTo')."\n";
close(F);
    $session->header(
                -cookie => $cookie,
            );  

    my $input = CGI->new(); 
    print $input->redirect( 
                -location => $session->param('redirectTo'), 
                -status => 301,
                -cookie => $cookie,
    ); 
    exit;
