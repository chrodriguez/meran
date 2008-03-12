#!/usr/bin/perl

# $Id: moditem.pl,v 1.7 2003/03/18 09:52:30 tipaul Exp $


#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/02 by hdl@ifrance.com : Templating

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
require Exporter;

use C4::Search;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Koha;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Estadisticas;

my $input = new CGI;
my $itemnumber=$input->param('itemnum');
my $bibitemnum=$input->param('bibit');
my $biblionum=$input->param('bib');
my $bulk=$input->param('bulk');
my $barcode=$input->param('barcode');


my $data=bibitemdata($bibitemnum);
my $itemdata=itemdata2($itemnumber);

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => 'item-detail.tmpl',
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {circulate => 1},
    });

my %inputs;
my ($count, $detail)=availDetail($itemnumber);
my @results;

for (my $i=0; $i < $count; $i++){
my $avail='';
if ($detail->[$i]{'avail'} eq 'Disponible'){$avail='<font size=3 color=green> Disponible </font>'; }
	else {$avail='<font size=3 color=red>'.$detail->[$i]{'avail'}.'</font>';}	

my $loan='';
if ($detail->[$i]{'loan'} eq 'PRESTAMO'){$loan='<font size=3 color=green> PRESTAMO </font>'; }
	else {$loan='<font size=3 color=blue>'.$detail->[$i]{'loan'}.'</font>';}
  my %row = (
        avail=> $avail,
	loan=>$loan,
        date=> format_date($detail->[$i]{'date'})
        );
  push(@results, \%row);
}

my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $dateSelected= $input->param('dateselected')||format_date($today);
my $dateSelectedEnd= $input->param('dateselectedEnd')||format_date($today);

my $fechaInicio =  format_date_in_iso($input->param('dateselected'))||$today;
my $fechaFin    =  format_date_in_iso($input->param('dateselectedEnd'))||$today;

# my ($cant,@resultsdata)= &historicoCirculacion("ok",$fechaInicio,$fechaFin,"","",$itemnum,"","","date");
# $chkfecha,$fechaIni,$fechaFin,$user,$itemnumber,$ini,$cantR,$orden,
# $tipoPrestamo,$tipoOperacion
my $ini;
my $cantR;
my $orden;
my $tipoPrestamo;
my $tipoOperacion;

my ($cant,@resultsdata)=&historicoCirculacion('ok',$fechaInicio,$fechaFin,'-1',$itemnumber,$ini,$cantR,$orden,$tipoPrestamo, $tipoOperacion);

$template->param(DETAIL => \@results,
		HISTORICO => \@resultsdata,
		title => $data->{'title'},
	        author => $data->{'author'},
		itemnotes => $itemdata->{'itemnotes'},
		biblionumber => $data->{'biblionumber'},
        	biblioitemnumber => $data->{'biblioitemnumber'},
		itemnumber => $itemnumber,
		barcode => $barcode,
		bulk => $bulk,
		dateselected => $dateSelected,
		dateselectedEnd => $dateSelectedEnd,
		);

print $input->header(
        -type => C4::Interface::CGI::Output::guesstype($template->output),
        -expires=>'now'
), $template->output;

