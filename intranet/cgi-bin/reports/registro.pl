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
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::Koha;
use C4::Date;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/registro.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


###Marca la Fecha de Hoy
                                                                                
my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $dateformat = C4::Date::get_date_format();
$template->param( todaydate => format_date($today,$dateformat));
                                                                                
###

my $dateformat = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio =  format_date_in_iso($input->param('dateselected'),$dateformat);
my $fechaFin    =  format_date_in_iso($input->param('dateselectedEnd'),$dateformat);
my @resultsdata;
my $cant;


#Select de usuarios
my @users;
my @select_user;
my %select_users;
my $users=getuser(); #funcion agregada en C4::AR::Estadisticas para buscar a los administradores.

push @select_user, 'SIN SELECCIONAR';

foreach my $userkey (keys %$users) {
        push @select_user, $userkey;
        $select_users{$userkey} = $users->{$userkey}->{'nomCompleto'};
}

my $CGIuser=CGI::scrolling_list(        -name      => 'user',
                                        -id        => 'user',
                                        -values    => \@select_user,
                                        -labels    => \%select_users,
                                        -size      => 1,
					-defaults  => 'SIN SELECCIONAR'
                                 );
#fin select de usuarios


$template->param( 
			selectusuarios   => $CGIuser,
		);

output_html_with_http_headers $input, $cookie, $template->output;
