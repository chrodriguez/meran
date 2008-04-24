#!/usr/bin/perl
# Please use 8-character tabs for this file (indents are every 4 characters)

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
# use C4::Reserves2;
use C4::Output;
# use C4::Print;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;
use CGI::Util;
use C4::AR::Reserves;
use C4::AR::Issues;
use Date::Manip;

my $query=new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0,{borrow => 1},"intranet");
$loggedinuser = getborrowernumber($loggedinuser);
my %env;
my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", ($datearr[3]));
my $flags;
my $borrower;
my $bornum = $query->param('borrnumber');
# my $issuecode = $query->param('issuetype');
# my $itemnumber = $query->param('itemnumber');
# my $olditemnumber = $query->param('olditemnumber');
my $branchcode = $query->param('branch');
my $bib;
my $bibit;
my $barcode;

#Damian - Para prestar varios item a la vez.
my $strItemnumber = $query->param('strItemnumber');
my @numerosItems=split("#",$strItemnumber);
my $strResult="";
my $mensajeError="";
my $error=0;
my $itemnumber;
my $issuecode;
my $i=0;

for my $olditemnumber (@numerosItems){ 

	$issuecode = $query->param('issuetype'.$i);
	$itemnumber = $query->param('itemnumber'.$i);

#por si los combos estan vacios
if(($issuecode)&&($itemnumber)){
	$i++;
#busca la informacion del item y del usuario
	my $biblio = getiteminformation(\%env,$itemnumber);
	if ($biblio){
		$bib=$biblio->{'biblionumber'};
		$bibit=$biblio->{'biblioitemnumber'};
		$barcode=$biblio->{'barcode'};
	} 
	else{ #No existe el item
		print $query->redirect("circulation.pl?borrnumber=".$bornum);
	}

	($borrower, $flags) = getpatroninformation(\%env,$bornum,0);
	if (!$borrower) { #no existe el usuario
		print $query->redirect("circulation.pl?itemnumber=".$itemnumber);
	}
#si existe el borrower sigo, sino devuelvo que el borrower no existe

	my @resultado=reservaritem($bornum,$bibit,$itemnumber,$branchcode,1,$issuecode);


#se hace el prestamo
	if ($resultado[0] eq 0){#quiere decir que dio algun tipo de error
		if ($resultado[1] eq 5){#quiere decir que el item ya esta reservado
			if (efectivizar_reserva($bornum,$bibit,$issuecode,$loggedinuser)) {
				if ($issuecode eq "DO"){#Si llego al maximo se caen las demas reservas
					my ($cant, @issuetypes) = PrestamosMaximos ($bornum);
					foreach my $iss (@issuetypes){
						if ($iss->{'issuecode'} eq "DO"){#Domiciliario al maximo
							 C4::AR::Reserves::cancelar_reservas_inmediatas($bornum,$loggedinuser);
						}
					}
				}
		
# 			print $query->redirect("circulation.pl?borrnumber=".$bornum."&ticket=".$itemnumber);
				$strResult.=$itemnumber."/";
			}
			else{
				cancelar_reserva($bibit,$bornum,$loggedinuser);
			}
		}
		elsif($resultado[1] eq 3){
	# El usuario ya tiene una reserva sobre este grupo pero sobre olditemnumber => hay que hacer un intercambio 
	# de itemnumbers ($itemnumber <=> $olditemnumber)
			intercambiar_itemnumber($bornum, $bibit, $itemnumber, $olditemnumber);
			if (efectivizar_reserva($bornum,$bibit,$issuecode,$loggedinuser)){
				if ($issuecode eq "DO"){#Si llego al maximo se caen las demas reservas
					my ($cant, @issuetypes) = PrestamosMaximos ($bornum);
					foreach my $iss (@issuetypes){
						if ($iss->{'issuecode'} eq "DO"){#Domiciliario al maximo
							 C4::AR::Reserves::cancelar_reservas_inmediatas($bornum,$loggedinuser);
						}
					}
				}

		
# 			print $query->redirect("circulation.pl?borrnumber=".$bornum."&ticket=".$itemnumber);
			$strResult.=$itemnumber."/";
			}
			else{
				cancelar_reserva($bibit,$bornum,$loggedinuser);
			}
		} 
		else{
			my $msg=""; #FIXME hay que codificar los mensajes de error
			if ($resultado[1] eq 1) {
				$msg= "SANCIONADO_O_LIBROS_VENCIDOS"; #El usuario esta sancionado o tiene libros vencidos
			} elsif ($resultado[1] eq 2) {
				$msg= "SUPERA_MAX_RESERVAS"; #El usuario supera el numero maximo de reservas";
			} elsif ($resultado[1] eq 4) {
				$msg= "YA_TIENE_PRESTAMO_SOBRE_EL_GRUPO"; #El usuario ya tiene un prestamo sobre este grupo";
			} elsif ($resultado[1] eq 6) {
                        	$msg= "IRREGULAR"; #El usuario no es regular
			} elsif ($resultado[1] eq 7) {
                        	$msg= "YA_TIENE_TODOS_LOS_EJEMPLARES_PARA_EL_TIPO_DE_PRESTAMO"; #El usuario ya tiene todos los prestamos para el tipo de prestamo
                	} elsif ($resultado[1] eq 8) {
		        	$msg= "NO_ES_HORA_DEL_PRESTAMO_ESPECIAL"; #No se puede realizar el prestamo especial por la hora
			}
			$error=1;
			$mensajeError.=$itemnumber."-".$msg."/";
# 		print $query->redirect("circulation.pl?borrnumber=".$bornum."&error=1&codError=".$msg);
		}
	} 
	elsif ($resultado[0] eq 2){#quiere decir que se reservo el item que se queria
		if (efectivizar_reserva($bornum,$bibit,$issuecode,$loggedinuser)) {
			if ($issuecode eq "DO"){#Si llego al maximo se caen las demas reservas
				my ($cant, @issuetypes) = PrestamosMaximos ($bornum);
				foreach my $iss (@issuetypes){
					if ($iss->{'issuecode'} eq "DO"){#Domiciliario al maximo
						 C4::AR::Reserves::cancelar_reservas_inmediatas($bornum,$loggedinuser);
					}
				}
			}
# 		print $query->redirect("circulation.pl?borrnumber=".$bornum."&ticket=".$itemnumber);
			$strResult.=$itemnumber."/";
		}
		else{
			cancelar_reserva($bibit,$bornum,$loggedinuser);
		}
	}
	elsif ($resultado[0] eq 1) {
		if ($resultado[1] eq 0) { #No hay mas ejemplares disponibles. Se realizo una reserva sobre el grupo.
# 		print $query->redirect("circulation.pl?borrnumber=".$bornum."&error=1&codError=NO_HAY_MAS_EJEMPLARES_RESERVA_SOBRE_GRUPO");
			$mensajeError.=$itemnumber."-NO_HAY_MAS_EJEMPLARES_RESERVA_SOBRE_GRUPO/";
		}
		elsif ($resultado[1] eq -1) { #No hay mas ejemplares disponibles y el usuario no puede tener mas reservas => no se hace nada
# 		print $query->redirect("circulation.pl?borrnumber=".$bornum."&error=1&codError=NO_HAY_MAS_EJEMPLARES_NO_RESERVA");
			$mensajeError.=$itemnumber."-NO_HAY_MAS_EJEMPLARES_NO_RESERVA/";
		}
	}
  }#end if(($issuecode)&&($itemnumber))
  else{
	$error= 1;
	$mensajeError .= $itemnumber."-FALTAN_PARAMETROS/";
  }
	
}#end for principal

print $query->redirect("circulation.pl?borrnumber=".$bornum."&ticket=".$strResult."&error=".$error."&codError=".$mensajeError);

# Local Variables:
# tab-width: 8
# End:
