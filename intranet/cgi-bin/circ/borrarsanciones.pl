#!/usr/bin/perl

# $Id: updateitem.pl,v 1.8.2.1 2004/01/08 16:34:36 slef Exp $

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
use C4::Interface::CGI::Output;
use Date::Manip;
use C4::Date;
use C4::AR::Sanciones;


my $input=new CGI;

my ($userid, $session, $flags) = checkauth($input, 0,{circulate=> 1,updatesanctions=> 1},"intranet");

C4::AR::Debug::debug("CirculacionDB:: responsable -> ".$userid);

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $array_ids=$obj->{'datosArray'};
my $loop=scalar(@$array_ids);
for(my $i=0;$i<$loop;$i++){
        my $id_sancion=$array_ids->[$i];
        my $sancion = C4::Modelo::CircSancion->new(id_sancion => $id_sancion);
        $sancion->load();
        $sancion->eliminar_sancion($userid);
}

print $input->redirect("sanciones.pl");

