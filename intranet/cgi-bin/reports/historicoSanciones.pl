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
use C4::Koha;
use C4::Date;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
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
$template->param( todaydate => format_date($today,$dateformat));

#Select de usuarios
my @users;
my @select_user;
my %select_users;
my $users=getuser(); #funcion agregada en C4::AR::Estadisticas para buscar a los administradores.

push @select_user, '-1';
$select_users{'-1'}= 'SIN SELECCIONAR';

foreach my $userkey (keys %$users) {
        push @select_user, $users->{$userkey}->{'borrowernumber'};
        $select_users{$users->{$userkey}->{'borrowernumber'}} = $users->{$userkey}->{'nomCompleto'};
}

my $CGIuser=CGI::scrolling_list(        -name      => 'user',
                                        -id        => 'user',
                                        -values    => \@select_user,
                                        -labels    => \%select_users,
                                        -size      => 1,
					-defaults  => 'SIN SELECCIONAR'
                                 );

$template->param(selectusuarios   => $CGIuser);
#fin select de usuarios


#*********************************Select Tipos de Prestamos*****************************************
#Miguel no se si existe una funcion q devuelva los tipos de items, si esta vuela
my $dbh= C4::Context->dbh;

my $query= "SELECT * FROM issuetypes ";
my $sth= $dbh->prepare($query);
$sth->execute();

my @select_tiposPrestamos_Values;
my %select_tiposPrestamos_Labels;

push @select_tiposPrestamos_Values, '-1';
$select_tiposPrestamos_Labels{'-1'}= 'SIN SELECCIONAR';
my @result;

while (my $data=$sth->fetchrow_hashref){
	push @result, $data;
}


foreach my $tipoPrestamo (@result) {
 	push @select_tiposPrestamos_Values, $tipoPrestamo->{'issuecode'};
   	$select_tiposPrestamos_Labels{$tipoPrestamo->{'issuecode'}} = $tipoPrestamo->{'description'};
}

my $CGISelectTiposPrestamos=CGI::scrolling_list(	-name      => 'tiposPrestamos',
                                        		-id        => 'tiposPrestamos',
                                        		-values    => \@select_tiposPrestamos_Values,
                                        		-labels    => \%select_tiposPrestamos_Labels,
                                        		-size      => 1,
							-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectTiposPrestamos => $CGISelectTiposPrestamos);
#*******************************Fin**Select Tipos de Prestamos***************************************

#*********************************Select tipo Operacion*****************************************
#Miguel no se si existe una funcion q devuelva los tipos de items, si esta vuela
my $dbh= C4::Context->dbh;
my @select_tipoOperacion_Values;
my %select_tipoOperacion_Labels;

#Miguel - deberia haber una tabla de referencia
my @result= (
		{type => '-1',
		description => 'SIN SELECCIONAR'
		},
		{type => 'Insert',
		description => 'Agregado'
		},
		{type => 'Delete',
		description => 'Borrado'
		}
);


foreach my $tipoOperacion (@result) {
	push @select_tipoOperacion_Values, $tipoOperacion->{'type'};
  	$select_tipoOperacion_Labels{$tipoOperacion->{'type'}} = $tipoOperacion->{'description'};
}

my $CGISelectTipoOperacion=CGI::scrolling_list(		-name      => 'tipoOperacion',
                                        		-id        => 'tipoOperacion',
                                        		-values    => \@select_tipoOperacion_Values,
                                        		-labels    => \%select_tipoOperacion_Labels,
                                        		-size      => 1,
							-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectTipoOperacion => $CGISelectTipoOperacion);
#*******************************Fin**Select Tipos de Operacion***************************************

output_html_with_http_headers $input, $cookie, $template->output;
