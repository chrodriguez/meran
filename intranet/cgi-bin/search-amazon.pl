#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Context;
use HTML::Template;
use C4::AR::Amazon;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ catalogue => 1});

#tipo = primero (imagen de cualquier edicion) || grupo (el especifico de un grupo)
my $tipo= $input->param('tipo')||"";
my $id= $input->param('id')||"";
my $url='';

#***************************************************************************************************
if($tipo eq 'id1' ){
	$url= C4::AR::Amazon::getImageForId1($id); #C4::AR::Amazon
}
elsif($tipo eq 'id2'){
	$url= C4::AR::Amazon::getImageForId2($id); #C4::AR::Amazon
}

 print "Content-type: text/html\n\n";

if ($url){print $url;}
#**************************************************************************************************
