#!/usr/bin/perl

# $Id: actualizarPersonas.pl,v 1.0 2005/05/3 10:44:45 tipaul Exp $

#script para actualizar los datos de los posibles usuarios
#written 3/05/2005  by einar@info.unlp.edu.ar



use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Koha;
use HTML::Template;
use C4::AR::Persons_Members;

my $input = new CGI;
my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 1, $flagsrequired);
my $msg='';
my @names=$input->param;
my @data;
for (my $i=0;$i<$input->param('cantidad');$i++){
 if (($names[$i] ne 'member')&&($names[$i] ne 'cantidad')&&
     ($names[$i] ne 'accion')&&($names[$i] ne 'number')&&($names[$i] ne 'orden')){  #Quito los parametros no necesarios
		push(@data,$names[$i]);
 
 		#Aca se recuperan los valores de los parametros que voy a modificar, 
 		#pero como no se cuales van a venir los tengo que recuperar asi.
		}
	}
if ($input->param('accion') eq "habilitar"){

	$msg=addmembers(@data);
	
	}
else{
	$msg=delmembers (@data);
	
	}


my $redirect="/cgi-bin/koha/member2.pl";

my $member=$input->param('member');
my $number=$input->param('number');
my $orden=$input->param('orden');
$redirect.="?ini=".$number."&orden=".$orden."&member=".$member;

if($msg ne ''){$redirect.="&msg=".$msg; }

my $referer = $input->referer();
print $input->redirect($redirect);


