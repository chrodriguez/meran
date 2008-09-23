#!/usr/bin/perl

# $Id: moremember.pl,v 1.33.2.1 2003/12/22 10:40:55 tipaul Exp $

# script to do a borrower enquiry/bring up borrower details etc
# Displays all the details about a borrower
# written 20/12/99 by chris@katipo.co.nz
# last modified 21/1/2000 by chris@katipo.co.nz
# modified 31/1/2001 by chris@katipo.co.nz
#   to not allow items on request to be renewed
#
# needs html removed and to use the C4::Output more, but its tricky
#


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use Date::Manip;
use C4::Date;
use C4::AR::Reservas;
use C4::AR::Issues;
use C4::AR::Sanctions;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "usuarios/reales/datosUsuario.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $bornum=$input->param('bornum');
my $completo=$input->param('completo');
my $mensaje=$input->param('mensaje');#Mensaje que viene desde libreDeuda si es que no se puede imprimir

my $data=C4::AR::Usuarios::getBorrowerInfo($bornum);
$data->{'updatepassword'}= $data->{'changepassword'};

my $dateformat = C4::Date::get_date_format();
# Curso de usuarios#
if (C4::Context->preference("usercourse")){
	$data->{'course'}=1;
	$data->{'usercourse'} = C4::Date::format_date($data->{'usercourse'},$dateformat);
}
#
$data->{'dateenrolled'} = C4::Date::format_date($data->{'dateenrolled'},$dateformat);
$data->{'expiry'} = C4::Date::format_date($data->{'expiry'},$dateformat);
$data->{'dateofbirth'} = C4::Date::format_date($data->{'dateofbirth'},$dateformat);
$data->{'IS_ADULT'} = ($data->{'categorycode'} ne 'I');

$data->{'city'}=C4::AR::Busquedas::getNombreLocalidad($data->{'city'});
$data->{'streetcity'}=C4::AR::Busquedas::getNombreLocalidad($data->{'streetcity'});

# Converts the branchcode to the branch name
$data->{'branchcode'} = C4::AR::Busquedas::getBranch($data->{'branchcode'})->{'branchname'};

# Converts the categorycode to the description
$data->{'categorycode'} = C4::AR::Busquedas::getborrowercategory($data->{'categorycode'});


# my $issues = prestamosPorUsuario($bornum);
my $count=0;
my $venc=0;
my $overdues_count = 0;
my @overdues;
# my @issuedat;
my $sanctions = hasSanctions($bornum);
####Es regular el Usuario?####
my $regular =&C4::AR::Usuarios::esRegular($bornum);

$template->param(regular       => $regular);
####
foreach my $san (@$sanctions) {
	if ($san->{'id3'}) {
		my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
		$san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; 
	}

	$san->{'nddate'}=format_date($san->{'enddate'},$dateformat);
	$san->{'startdate'}=format_date($san->{'startdate'},$dateformat);
}
#

=item
foreach my $key (keys %$issues) {

	my $issue = $issues->{$key};
    	$issue->{'date_due'} = format_date($issue->{'date_due'},$dateformat);
	my ($vencido,$df)= &C4::AR::Issues::estaVencido($issue->{'id3'},$issue->{'issuecode'});
    	$issue->{'date_fin'} = format_date($df,$dateformat);
	if ($vencido){ 
		$venc=1;
          	$issue->{'color'} ='red';
        }
    	push @issuedat, $issue;
    	$count++;
}
=cut

=item
my ($rcount, $reserves) = DatosReservas($bornum);
my @realreserves;
my @waiting;
my $rcount = 0;
my $wcount = 0;

foreach my $res (@$reserves) {	
    	$res->{'rreminderdate'} = format_date($res->{'rreminderdate'},$dateformat);

	my $author=C4::AR::Busquedas::getautor($res->{'rautor'});
        $res->{'rauthor'} = $author->{'completo'};
	$res->{'id'} = $author->{'id'}; 
    	if ($res->{'rid3'}) {
		my $item=C4::AR::Catalogacion::buscarNivel3($res->{'rid3'});
		$res->{'barcode'} = $item->{'barcode'};
		$res->{'signatura_topografica'} = $item->{'signatura_topografica'};
        	$res->{'rbranch'} = C4::AR::Busquedas::getBranch($res->{'rbranch'})->{'branchname'};
        	push @realreserves, $res;
        	$rcount++;
  	}
        else{
        	push @waiting, $res;
        	$wcount++;
        }
}
=cut

#### Verifica si la foto ya esta cargada
my $picturesDir= C4::Context->config("picturesdir");
my $foto;
if (opendir(DIR, $picturesDir)) {
	my $pattern= $bornum."[.].";
	my @file = grep { /$pattern/ } readdir(DIR);
	$foto= join("",@file);
	closedir DIR;
} else {
	$foto= 0;
}
####

#### Verifica si hay problemas para subir la foto
my $msgFoto=$input->param('msg');
($msgFoto) || ($msgFoto=0);
####

#### Verifica si hay problemas para borrar un usuario
my $msgError=$input->param('error');
($msgError) || ($msgError=0);
####

$template->param($data);
$template->param(
		bornum          => $bornum,
		completo	=> $completo,
		mensaje		=> $mensaje,
#los libros que tiene "en espera para retirar"
# 		waiting		=> \@waiting,
#los libros que tiene esperando un ejemplar
# 		realreserves    => \@realreserves,
###
# 		prestamos       => \@issuedat,
		foto_name 	=> $foto,
		sanctions       => $sanctions,
		mensaje_error_foto   => $msgFoto,
		mensaje_error_borrar => $msgError,
	);

output_html_with_http_headers $input, $cookie, $template->output;
