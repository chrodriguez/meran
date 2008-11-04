#!/usr/bin/perl

# script to generate cards for the borrowers
# written 03/2005
# by Luciano Iglesias - li@info.unlp.edu.ar - LINTI, Facultad de Inform�tica, UNLP Argentina

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

require Exporter;

use strict;
use CGI;
use C4::AR::PdfGenerator;
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::AR::Busquedas;

my $input= new CGI;
my $bornum = $input->param('bornum');
my $accion = $input->param('tipoAccion');
my $biblioDestino = C4::AR::Busquedas::getBranch($input->param('branchcode'));
$biblioDestino = $biblioDestino->{'branchname'};
my $director = $input->param('director')||"___________________";
my @autores=split("#",$input->param('autores'));
my @titulos=split("#",$input->param('titulos'));
my @otros=split("#",$input->param('otros'));
my @datos;
for(my $i=0;$i<scalar(@titulos);$i++){
	if($i<scalar(@autores)){
		$datos[$i]->{'autor'}=$autores[$i];
	}
	else{$datos[$i]->{'autor'}="";}
	if($i<scalar(@otros)){
		$datos[$i]->{'otros'}=$otros[$i];
	}
	else{$datos[$i]->{'otros'}="";}
	$datos[$i]->{'titulo'}=$titulos[$i];
}
my $borrewer= C4::AR::Usuarios::getBorrower($bornum);
&prestInterBiblio($bornum,$borrewer,$biblioDestino,$director,\@datos);



