package C4::AR::Reservas;

#Este modulo provee funcionalidades para la reservas de documentos
#
#Copyright (C) 2003-2008  Linti, Facultad de Informática, UNLP
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

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
	&reservar
	&insertarReserva
);

sub reservar(){
	my($params)=@_;
}

sub insertarReserva(){
	my($params)=@_;
	my $dbh=C4::Context->dbh;
	my $query="INSERT INTO reserves (itemnumber,biblioitemnumber,borrowernumber,reservedate,notificationdate,reminderdate,branchcode) VALUES (?,?,?,?,NOW(),?,?) ";
	my $sth2=$dbh->prepare($query);
	$sth2->execute( $params->{'id3'},
			$params->{'id2'},
			$params->{'borrowernumber'},
			$params->{'reservedate'},
			$params->{'reminderdate'},
			$params->{'branchcode'}
		);
}

1;
