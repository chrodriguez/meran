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

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params)
    = get_template_and_user({template_name => "reports/historicoSanciones.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {circulate => 1},
			     debug => 1,
			     });


my $orden= "date"; 

###Marca la Fecha de Hoy          
my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $dateformat = C4::Date::get_date_format();
#$template->param( todaydate => format_date($today,$dateformat));
$t_params->{'todaydate'}=C4::AR::Date::format_date($today,$dateformat);

#Select de usuarios
my $CGIuser=C4::AR::Utilidades::generarComboDeSocios();

$t_params->{'selectusuarios'}=$CGIuser;
#fin select de usuarios


#*********************************Select Tipos de Prestamos*****************************************

my $CGISelectTiposPrestamos=C4::AR::Utilidades::generarComboTipoPrestamo();

#Se lo paso al template
#$template->param(selectTiposPrestamos => $CGISelectTiposPrestamos);
$t_params->{'selectTiposPrestamos'}=$CGISelectTiposPrestamos;
#*******************************Fin**Select Tipos de Prestamos***************************************

#*********************************Select tipo Operacion*****************************************

$t_params->{'selectTipoOperacion'}=C4::AR::Utilidades::generarComboTipoDeOperacion();
#*******************************Fin**Select Tipos de Operacion***************************************
C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
