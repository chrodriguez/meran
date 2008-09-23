#!/usr/bin/perl

# $Id: deletemem.pl,v 1.9.2.1 2004/01/08 17:05:03 slef Exp $

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz


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
use C4::Circulation::Circ2;
use C4::Auth;
use C4::AR::Persons_Members;

my $input = new CGI;


my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, {borrowers => 1} ,'intranet');


#print $input->header;
my $member=$input->param('member');
my @sepuede=sepuedeeliminar($member); #Devuelve un arreglo con codigos, que indica (0,0,0)si el borrower se puede borrar y numeros negativos si no se puede, cada nro indica un tipo de problema como se indica [0] Items on Issue, [1] Charges y [2] Guarantees. E indica en la posicion 3 del arreglo que fue lo que paso, si es 1 entonces esta todo bien, si es cero hubo algun problema.

if ($sepuede[3] < 0 ) {
  my $error="";
  if ($sepuede[0] < 0 ) {
      $error.= "No se puede borrar el usuario porque tiene ejemplares prestados.<br>";
  }
  if ($sepuede[1] < 0 ) {
      $error.= "No se puede borrar el usuario porque tiene deudas<br>";
  }
  if ($sepuede[2] < 0 ) {
      $error.= "No se puede borrar el usuario porque tiene garant&iacute;as<br>";
  }
  print $input->redirect("/cgi-bin/koha/usuarios/reales/datosUsuario.pl?bornum=$member&error=$error");

} else {
         delmember($member);
         print $input->redirect("/cgi-bin/koha/usuarios/reales/buscarUsuario.pl");
}

