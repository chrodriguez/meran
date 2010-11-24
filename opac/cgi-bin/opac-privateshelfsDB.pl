#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;

use C4::BookShelves;
use C4::AR::Utilidades;

my $input=new CGI;
my ($userid, $session, $flags) = checkauth($input, 0,{borrow => 1});


my $obj=$input->param('obj');

$obj=from_json_ISO($obj);
my $op= $obj->{'Accion'};
my $shelfvalues=$obj->{'datosArray'};


#Se verifica la existencia del contenedor de favoritos
my $pshelf=gotShelf($userid);

#***********************************ADD PrivateShelfs*************************************
if ($op eq 'ADD'){ 

	my ($error, $codMsg, $message)= C4::BookShelves::t_addPrivateShelfs(	$userid,
										$pshelf,
										$shelfvalues
									);
	
# 	print $input->header;
	C4::Auth::output_html_with_http_headers($template, $t_params, $session, $cookie);
}
#********************************Fin***ADD PrivateShelfs**********************************


#***********************************DELETE PrivateShelfs*************************************
if ($op eq 'DELETE'){ 

	my ($error, $codMsg, $message)= C4::BookShelves::t_delPrivateShelfs(	$pshelf,
										$shelfvalues
									);
	
# 	print $input->header;
	C4::Auth::output_html_with_http_headers($template, $t_params, $session, $cookie);
}
#********************************Fin***DELETE PrivateShelfs**********************************

