#!/usr/bin/perl
#Este script sirve para realizar alta baja y modificaciones de Analiticas
#Escrito el 11/09/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


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
my $bibnumitems=$input->param('bibnumitems');


#Biblio
my $biblionumber=$bibnum;
my $dat=bibdata($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
my ($websitecount, @websites) = &getwebsites($biblionumber);
my ($subtitlecount,$subtitles) = &subtitle($biblionumber);
my @subjects;
my $len= scalar(split(",",$dat->{'subject'}));
my $i= 1;
my $coma;
foreach my $elem (split(",",$dat->{'subject'})) {
if ($len==$i){$coma=""} else {$coma=","};
for ($elem) {s/^\s+//;} # delete the spaces at the begining of the string
push(@subjects, {subject => $elem, separator => $coma});
$i+=1;
}
$dat->{'SUBJECTS'} = \@subjects;

my @autorPPAL= &getautor($dat->{'author'});
my @autoresAdicionales=&getautoresAdicionales($biblionumber);
my @colaboradores=&getColaboradores($biblionumber);
$dat->{'author'}=\@autorPPAL;
$dat->{'ADDITIONAL'}=\@autoresAdicionales;
$dat->{'COLABS'}=\@colaboradores;
if ($subtitlecount) {
$dat->{'subtitle'}=" " . $subtitles->[0]->{'subtitle'};
for (my $i = 1; $i < $subtitlecount; $i++) {
$dat->{'subtitle'} .= ", " . $subtitles->[$i]->{'subtitle'};
} # for
} # if
my @results3;
$results3[0]=$dat;

#Biblioitem
my $data=bibitemdata($bibnumitems);
my @autorPPAL= &getautor($data->{'author'});
$data->{'author'}=\@autorPPAL;
my @result;
$result[0]=$data;
my @result2;
my (@result2)=&BiblioAnalysisData($bibnum, $bibnumitems);
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "addanalysis.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });
 
$template->param ( biblionumber => $bibnum,
	           biblioitemnumber => $bibnumitems,
                   ANALYSIS => \@result2,
                   BIBITEM_DATA => \@result,
		   BIBLIO_DATA => \@results3);

output_html_with_http_headers $input, $cookie, $template->output;

