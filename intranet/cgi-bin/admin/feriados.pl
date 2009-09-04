#!/usr/bin/perl

#script to administer the systempref table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey


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
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Context;
use C4::AR::Utilidades;
use Date::Manip;
use C4::Date;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "admin/feriados.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug => 1,
			    });


my $feriadosh =$input->param('feriadosh');
&saveholidays($feriadosh);

my ($cant,@feriados)=getholidays();
my @loop_data;

for (my $i=0; $i < $cant; $i++){
	my %row_data;
	my @fecha = split('-',@feriados[$i]);
	$row_data{anio} = $fecha[0];
	$row_data{mes} = $fecha[1] - 1; # Porque en la inicializacion javascript los meses van del 0 al 11
	$row_data{dia} = $fecha[2];
	push(@loop_data, \%row_data);
}

$t_params->{'loop'}= \@loop_data;
$t_params->{'cant'}= $cant;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
