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

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
			template_name   => 'busquedas/detalleItemResult.tmpl',
			query           => $input,
			type            => "intranet",
			authnotrequired => 0,
			flagsrequired   => {circulate => 1},
    			});

my $dateformat = C4::Date::get_date_format();
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $id3=$obj->{'id3'};
my $fechaIni= $obj->{'fechaIni'};
my $fechaFin= $obj->{'fechaFin'};
my $funcion = $obj->{'funcion'};
my $orden=$obj->{'orden'}||'date';
my $fechaIni=  format_date_in_iso($fechaIni,$dateformat);
my $fechaFin=  format_date_in_iso($fechaFin,$dateformat);

my $ini;
my $cantR;
my $orden;
my $tipoPres;
my $tipoOp;

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,@resultsdata)= &historicoCirculacion('ok',$fechaIni,$fechaFin,'-1',$id3,$ini,$cantR,$orden,$tipoPres, $tipoOp);

C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion);

$template->param(
		HISTORICO => \@resultsdata,
		);

output_html_with_http_headers $input, $cookie, $template->output;