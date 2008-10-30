#!/usr/bin/perl
# NOTE: This file uses standard 8-character tabs

use strict;
require Exporter;
use CGI;
use C4::Auth;         # checkauth, getborrowernumber.
use C4::AR::Reservas;
use C4::Interface::CGI::Output;
use C4::AR::Mensajes;
use C4::AR::Utilidades;
use C4::Date;


my $input = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-reserve.tmpl",
			     query => $input,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

## FIXME se deberia separar el detalle de las resrvas del usuario y aqui solo realizar la reserva e informar al usuario si se realizo
# con exito o no
my $obj=$input->param('obj');

$obj=from_json_ISO($obj);


my $id1= $obj->{'id1'};
my $id2= $obj->{'id2'};

my %params;

$params{'tipo'}= 'OPAC'; 
$params{'id1'}= $id1;
$params{'id2'}= $id2;
$params{'borrowernumber'}= $borrowernumber;
$params{'loggedinuser'}= $borrowernumber;
$params{'issuesType'}= 'DO';

# my ($error, $codMsg, $message)= &C4::AR::Reservas::t_reservarOPAC(\%params);
my ($msg_object)= &C4::AR::Reservas::t_reservarOPAC(\%params);	
my $acciones;

$acciones= C4::AR::Mensajes::getAccion($msg_object->{'codMsg'});


my ($cant, $reservas)= C4::AR::Reservas::DatosReservas($borrowernumber);

if($msg_object->{'error'}){
#SE PRODUJO ALGUN ERROR

	if($acciones->{'maximoReservas'}){
	#EL USUARIO LLEGO AL MAXIMO DE RESERVAS, Y SE MUESTRAN LAS RESERVAS HECHAS
		$template->param (
			RESERVES => $reservas
		);
	}
}else{
# SE REALIZO LA RESERVA CON EXITO

	my $dateformat = C4::Date::get_date_format();
	my $branches = C4::AR::Busquedas::getBranches();
	my @realreserves;
	my $rcount = 0;
	
	my @waiting;
	my $wcount = 0;
	foreach my $res (@$reservas) {

		if ((C4::Date::Date_Cmp(ParseDate("today"),C4::Date::ParseDate($res->{'rreminderdate'})) > 0)){
			$res->{'color'} ='red'; 
		}
	
		$res->{'rreminderdate'} = C4::Date::format_date($res->{'rreminderdate'},$dateformat);
		$res->{'rnotificationdate'} = C4::Date::format_date($res->{'rnotificationdate'},$dateformat);
	
		my $author= C4::AR::Busquedas::getautor($res->{'rautor'});
		#paso como parametro ID de autor de la reserva
		#guardo el Apellido, Nombre del autor
		$res->{'autor'} = $author->{'completo'}; #le paso Apellido y Nombre
		
		if ($res->{'rid3'}) {
			#Reservas para retirar
			$res->{'rbranch'} = $branches->{$res->{'rbranch'}}->{'branchname'};
			push @waiting, $res;
			$wcount++;
		}else{
			push @realreserves, $res;
			$rcount++;
		}
	}#end foreach
	
	$template->param(	
# 				waiting_count => $wcount,
				WAITING => \@waiting,
# 				reserves_count => $rcount,
				RESERVES => \@realreserves,
	);
}




$template->param (
	id1 => $id1,
	id2 => $id2,
	message	=> $msg_object->{'messages'}->[0]->{'message'},
	error	=>  $msg_object->{'error'},
	reservaGrupo => $acciones->{'reservaGrupo'},
	maximoReservas => $acciones->{'maximoReservas'},
	materialParaRetirar => $acciones->{'materialParaRetirar'},
	CirculationEnabled => C4::Context->preference("circulation"),
);

output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
