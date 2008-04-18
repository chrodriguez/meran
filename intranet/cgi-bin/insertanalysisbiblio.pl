#!/usr/bin/perl

# $Id: modbib.pl,v 1.14 2003/07/15 11:34:52 slef Exp $

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/2002 by hdl@ifrance.com : templating


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
use HTML::Template;
use strict;
require Exporter;
use C4::Context;
use C4::Output;  # contains gettemplate
use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::AnalysisBiblio;


my $input = new CGI;

my $bibnum=$input->param('bibnum');
my $bibnumitems=$input->param('biblioitemnumber');
my $analyticalauthor=$input->param('analysisauthor'); # Autores
my $analyticaltitle=$input->param('analysistitle'); #Titulo
my $analyticalunititle=$input->param('analysisunititle'); #Subtitulo
my $subjectheadings=$input->param('subjectheadings'); #TEMA
my $classification=$input->param('classification');
my $parts=$input->param('parts');
my $resumen=$input->param('resumen');
my $url=$input->param('url');
my $keywords=$input->param('keywords'); #analyticalauthors

my $ok=0;
my $string = "";

# my @errors;
if ($analyticaltitle eq ''){
#  	push @errors,"El campo T�tulo no puede ser nulo";
    $string = "El campo T�tulo no puede ser nulo. ";
    $ok=1;
}

if($ok == 0){
#si esta todo ok inserto
	&BiblioAnalysisInsert($analyticaltitle,$analyticalunititle,$subjectheadings,$classification,$bibnum,$analyticalauthor,$bibnumitems,$parts,$resumen,$url,$keywords);
}

my $true='true';

print $input->redirect("addanalysisagregar.pl?reload=$true&biblionumber=$bibnum&biblioitemnumber=$bibnumitems&mensajeError=$string");


#output_html_with_http_headers $input, $cookie, $template->output;

