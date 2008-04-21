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
use C4::AR::Utilidades;
use C4::Koha;


my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrowers => 1},"intranet");

my @results = mailDeUsuarios();

# Nombre del archivo
my $fileTXT = "mailUsuarios.txt";

# Se abre el archivo para escritura
open(A,">/tmp/$fileTXT");

my $row;
my $line;
foreach $row (@results){
	print A $row->{'emailaddress'}."\n";
	
}

close(A);

# Para que se guarde o muestre el archivo
# my $line;
print "Content-type: text/plain\n";
print "Content-Disposition: attachment; filename=\"$fileTXT\"\n\n";

# Se abre el archivo para lectura
open (A, "</tmp/$fileTXT");

# Se recorre el archivo para imprimir en la pantalla cuando se abre.
while (<A>){
	print $line=$_;
}

close (A);

# Se saco para que no se imprima en el archivo, de todas forma se queda en la misma pagina
# print $input->redirect("users.pl");

