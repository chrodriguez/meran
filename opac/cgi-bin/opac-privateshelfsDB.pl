#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::BookShelves;
use C4::AR::Utilidades;

my $input=new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});
my $borrowernumber=getborrowernumber($loggedinuser);


my $obj=$input->param('obj');

$obj=from_json_ISO($obj);
my $op= $obj->{'Accion'};
my $shelfvalues = $obj->{'bookmarks'};
my @val=split(/#/,$shelfvalues);


#Se verifica la existencia del contenedor de favoritos
my $pshelf=gotShelf($borrowernumber);

#***********************************ADD PrivateShelfs*************************************
if ($op eq 'ADD'){ 
	my ($error, $codMsg, $message)= C4::BookShelves::t_addPrivateShelfs($borrowernumber, $pshelf,\@val);
	
	print $input->header;
}
#********************************Fin***ADD PrivateShelfs**********************************


#***********************************DELETE PrivateShelfs*************************************
if ($op eq 'DELETE'){ 
	my ($error, $codMsg, $message)= C4::BookShelves::t_delPrivateShelfs($pshelf,\@val);
	
	print $input->header;
}
#********************************Fin***DELETE PrivateShelfs**********************************

