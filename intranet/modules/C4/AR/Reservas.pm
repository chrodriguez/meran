package C4::AR::Reservas;

#Este modulo provee funcionalidades para la reservas de documentos
#
#Copyright (C) 2003-2008  Linti, Facultad de Inform�tica, UNLP
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
	&sePuedeReservar
	&cant_reservas
	&getReservasDeGrupo
);

sub reservar(){
	my($params)=@_;

=item
	my $tipo= $params->{'tipo'}= ; #INTRA u OPAC
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issuesType= $params->{'issuesType'};
=cut
	my ($error, $codMsg)= sePuedeReservar($params);

	if(!$error){
#No hay error
		my ($data)= getItemsParaReserva($params->{'id2'});

#Numer de diasas que tiene el usuario para retirar el libro si la reserva se efectua sobre un item
		my $numeroDias= C4::Context->preference("reserveItem");
		my ($desde,$hasta,$apertura,$cierre)=proximosHabiles($numeroDias,1);

		my %paramsReserva;
		
		$paramsReserva{'id2'}= $params->{'id2'};
		$paramsReserva{'id3'}= $data->{'id3'};
		$paramsReserva{'borrowernumber'}= $params->{'borrowernumber'};
		$paramsReserva{'reservedate'}= $desde;
		$paramsReserva{'reminderdate'}= $hasta;
		$paramsReserva{'branchcode'}= $data->{'holdingbranch'};

		insertarReserva($paramsReserva);

		return ($error, $codMsg);

	}else{
		return ($error, $codMsg);
	}
	
}

sub getNotForLoan(){
#Devuelve la disponibilidad del item ('SA'= Sala, 'DO'= Domiciliaria)
	my ($id3)=@_;
	
	my $dbh = C4::Context->dbh;

	my $query= "	SELECT notforloan
			FROM nivel3
			WHERE (id3 = ?)";

	my $sth=$dbh->prepare($query);
	$sth->execute($id3);

	return $sth->fetchrow();
}

sub verificarTipoReserva() {
#Verifica que el usuario no reserve un item que ya tenga una reserva para el mismo grupo y 
#para el mismo tipo de prestamo

	my ($borrowernumber, $id2, $id3, $tipo)=@_;

	my $error= 0;

	my ($cant, $reservas)= getReservasDeBorrower($borrowernumber, $id2);


	if($tipo eq "INTRA"){
#Si ya tiene una reserva se verifica que no sean para el mismo tipo de prestamo
#Es un prestamo inmediato desde la INTRA
		if( ($cant == 1) && (getNotForLoan($reservas[0]->{'id3'}) eq getNotForLoan($id3) ) ){
			$error= 1;
		}
	
	}else{
#Se intento reservar desde el OPAC sobre el mismo GRUPO
		if ($cant == 1){$error= 1;}
	}

	return ($error);
}

sub getReservasDeBorrower() {
#devuelve las reservas de grupo del usuario
	my ($borrowernumber, $id2)=@_;
	my $dbh = C4::Context->dbh;

	my $query= "	SELECT *
			FROM reserves
			WHERE (borrowernumber = ?) AND (id2 = ?)
			AND (estado <> 'P')";

	my $sth=$dbh->prepare($query);
	$sth->execute($borrowernumber, $id2);

	my @results;
	my $cant= 0;
	while (my $data=$sth->fetchrow_hashref){

		push (@results,$data);
		$cant++;
	}
	
	$sth->finish;
	return($cant,\@results);
}

sub cant_reservas{
#Cantidad de reservas totales de GRUPO y EJEMPLARES
        my ($bor)=@_;
        my $dbh = C4::Context->dbh;
        my $query="	SELECT count(*) as cant FROM reserves"; 
        $query .= " 	WHERE  borrowernumber = ? 
                        AND cancellationdate IS NULL AND estado <> 'P'";

        my $sth=$dbh->prepare($query);
        $sth->execute($bor);
        my $result=$sth->fetchrow();
        $sth->finish;

        return($result);
}

sub getItemsParaReserva(){
#Busca los items sin reservas para los prestamos 
	my ($id2)=@_;
        my $dbh = C4::Context->dbh;

	my $query= "	SELECT n3.id3, n3.holdingbranch 
			FROM nivel3 n3 WHERE n3.id2 = ? AND n3.notforloan='0' AND n3.wthdrawn='0' 
			AND n3.id3 NOT IN (SELECT reserves.id3 FROM reserves WHERE id2 = ?) FOR UPDATE ";

	$sth=$dbh->prepare($query);
	$sth->execute($id2, $id2);

	return $sth->fetchrow_hashref;

}

sub sePuedeReservar(){
	
	my($params)=@_;

	my $tipo= $params->{'tipo'}; #INTRA u OPAC
	my $id2= $params->{'id2'};
	my $id3= $params->{'id3'};
	my $borrowernumber= $params->{'borrowernumber'};
	my $loggedinuser= $params->{'loggedinuser'};
	my $issuesType= $params->{'issuesType'};

	my $error= 0;

#Se verifica que el usuario sea Regular
	if( &C4::AR::Usuarios::esRegular($borrowernumber) ){
		$error= 1;
		$codMsg= 'U300';
	}	

#Se verfica si el usuario esta sancionado	
	if( !($error) && (C4::AR::Usuarios::estaSancionado($borrowernumber, $issuesType)) ){
		$error= 1;
		$codMsg= 'S200';
	}

#Se verifica que el usuario no supere el numero maximo de reservas posibles seteadas en el sistema
	if( !($error) && (C4::AR::Usuarios::llegoMaxReservas($borrowernumber)) ){
		$error= 1;
		$codMsg= 'R001';
	}

#Se verifica que el usuario no tenga dos reservas sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && (&verificarTipoReserva($borrowernumber, $id2, $id3, $tipo)) ){
		$error= 1;
		$codMsg= 'R002';
	}

#Se verifica que el usuario no tenga dos prestamos sobre el mismo grupo para el mismo tipo prestamo
	if( !($error) && (&C4::AR::Issues::getCountPrestamosDeGrupo($borrowernumber, $id2, $issueType)) ){
		$error= 1;
		$codMsg= 'P100';
	}	

	return ($error, $codMsg);
}

sub insertarReserva(){
	my($params)=@_;
	my $dbh=C4::Context->dbh;

	my $query="INSERT INTO reserves (id3,id2,borrowernumber,reservedate,notificationdate,reminderdate,branchcode) 
	VALUES (?,?,?,?,NOW(),?,?) ";

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
