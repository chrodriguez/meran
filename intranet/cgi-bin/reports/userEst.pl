#!/usr/bin/perl
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
#
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;
use C4::AR::StatGraphs;
use ooolib;

my $input = new CGI;

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/userEst.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


#Genero la hoja de calculo Openoffice
my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title","Estadística Usuarios por categoría");
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject","Estadistica");
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 11);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Ministerio de Educación
Universidad Nacional de La Plata
");
$sheet->oooSet("text-size", 10);
$pos++;
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Categoría");
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", "Cantidad");
$sheet->oooSet("bold", "off");
$pos++;
##



#Por los branches
my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}
my $branch=$input->param('branch');
($branch ||($branch=(split("_",(split(";",$cookie))[0]))[1]));
                                                                                                                             
my $CGIbranch=CGI::scrolling_list(      -name      => 'branch',
                                        -id        => 'branch',
                                        -values    => \@select_branch,
                                        -defaults  => $branch,
                                        -labels    => \%select_branches,
                                        -size      => 1,
                                        -onChange  =>'hacerSubmit()'
                                 );
#Fin: Por los branches

my ($cantidad,@resultsdata)= &userCategReport($branch);
&userCategPie($branch,$cantidad, @resultsdata);
&userCategHBars($branch,$cantidad, @resultsdata);

#Contenido de la planilla.
foreach my $cat (@resultsdata) {
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", $cat->{'categoria'});
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-text", $cat->{'cant'});
	$pos++;
}

my $name='usuarioEstadistica-'.$loggedinuser;
$sheet->oooGenerate($name);

$template->param( 
			resultsloop      => \@resultsdata,
			unidades         => $CGIbranch,
			cantidad         => $cantidad,
			branch           => $branch,
			name		 => $name,
		);

output_html_with_http_headers $input, $cookie, $template->output;
