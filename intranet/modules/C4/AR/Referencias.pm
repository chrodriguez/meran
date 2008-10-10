package C4::AR::Referencias;

#Este modulo provee funcionalidades varias sobre las tablas de referencias en general
#Escrito el 8/9/2006 por einar@info.unlp.edu.ar
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

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use JSON;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
	&obtenerTiposDeDocumentos
	);


sub obtenerTiposDeDocumentos {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT nombre from  tipo_documento order by idTipoDoc");
	$sth->execute();
	my @results;
	while (my $data = $sth->fetchrow_hashref) {
  		push (@results,  $data->{'nombre'});
	}
	$sth->finish;
	return(@results);
}

1;
