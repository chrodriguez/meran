#!/usr/bin/perl
# NOTE: This file uses standard 8-character tabs

use strict;
require Exporter;
use CGI;

use C4::Search;
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
# use C4::AR::Reserves;
use C4::AR::Reservas;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Date;
use C4::Context;
use C4::AR::Mensajes;


my $query = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-reserve.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

=item
my $dateformat = C4::Date::get_date_format();
my $pagetitle = "Reserva de ejemplares";
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
###CURSO DE USUARIO###
if ((C4::Context->preference("usercourse"))&&($borr->{'usercourse'} == "NULL" )) {
	#el usuario no hizo el curso!!!
	$template->param(message => 1,no_user_course => 1);
} 
else { #No esta seteado lo del curso  o ya lo hizo
=cut


#Hay que ver que no este sancionado ni supere el nro maximo de reservas.
#Si ninguna de las dos es verdadera entonces se efectua la reserva, si alguno de los items esta disponible se reserva el item, sino se agrega a la lista de espera del grupo
my $branch=(split("_",(split(";",$cookie))[0]))[1];
my $branches = getbranches();
my $id2 = $query->param('id2');
my $id1 = $query->param('id1');

my %params;

$params{'tipo'}= 'OPAC'; #INTRA u OPAC
$params{'id1'}= $id1;
$params{'id2'}= $id2;
$params{'borrowernumber'}= $borrowernumber;
$params{'loggedinuser'}= $borrowernumber;
$params{'issuesType'}= 'DO';

my ($error, $codMsg,$paraMens)= &C4::AR::Reservas::reservar(\%params);

my $message= &C4::AR::Mensajes::getMensaje($codMsg,$paraMens);

$template->param (
	message	=> $message,
	error	=> $error,
	codMsg	=> $codMsg,
);

=item
if ($result[0]){#si no ocurrio ningun error, entonces puedo reservar el libro
	#Busco la data del biblioitem, esto me devuelve tambien la data del biblio
	my $biblioitemdata=bibitemdata($biblioitemnumber);
	#Se la paso al tmpl
	$template-> param($biblioitemdata);
	$pagetitle = "Usted acaba de reservar:";
	#Ahora intento hacer la reserva, de acuerdo al resultado que me de la consulta se si se puedo hacer en un ejemplar o se agrego a la cola de reservas del grupo
 	if ($result[1]){#quiere decir que se logro reservar un item
                $template->param( itemReserve => $result[1],
                                  desde => format_date($result[2],$dateformat),
                                  desdeh => $result[5],
                                  hasta => format_date($result[3],$dateformat),
                                  hastah => $result[6],
				  donde=> $branches->{$result[4]}->{'branchname'});
                my $itemdata=itemdata2($result[1]);
                $template-> param($itemdata);
	}
	else { #quiere decir que la reserva se hizo sobre un grupo, no sobre el item, se comunica la fecha tentativa deberia devolver un 2 
		$template->param(tentativeDate => $result[2]);
        }
	#Arreglar, falta lo de la fecha tentativa y el branch
	# pass the pickup branch along....
	$template->param(branch => $branch);
	$template->param(branchname => $branches->{$branch}->{'branchname'});
	# make branch selection options...
	my @branches;
	my @select_branch;
	my %select_branches;
	foreach my $branchaux (keys %$branches) {
		if ($branchaux) {
			push @select_branch, $branchaux;
			$select_branches{$branchaux} = $branches->{$branchaux}->{'branchname'};
		}
	}
	my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
			-defaults => $branch,
			-values   => \@select_branch,
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );
	$template->param( CGIbranch => $CGIbranch);

}
else{#quiere decir que result es 0 por lo tanto, no se efectuo la reserva
       		#si esta sancionado o por ser sancionado aviso eso y listo
		$template->param(message => 1);
        	if ($result[1] == 1){ #esta sancionado o por ser sancionado
			if ($result[2]){#esta efectuvamente sancionado
				$template->param(sancionado => format_date($result[2],$dateformat)); #aca le paso el parametro que podria indicar la cantidad de dias que deberia ser por la variable result en el 2 
			}else{
                		#esta por ser sancionado
				$template->param(casisancionado => 1);
			}
		}	#no esta sancionado ni por ser sancionado
		elsif($result[1] == 2){ #si tiene un nro de reservas máximo alcanzado 
			$template->param(RESERVES => $result[2]);
			# get biblioitemnumber.....
			$template->param(bib => $query->param('bib'));
			$template->param(too_many_reserves => $result[3]);
		}  elsif($result[1] == 5){ #si tiene un nro de reservas en espera máximo alcanzado 
                        $template->param(RESERVES => $result[2]);
                        # get biblioitemnumber.....
                        $template->param(bib => $query->param('bib'));
                        $template->param(too_many_waitreserves => $result[3]);
                }
		elsif($result[1]==3) {
			#el usuario ya tiene una reserva de ese grupo
			$template->param(already_reserved => 1);
		}
		elsif($result[1]==4) {
			#el usuario ya tiene un prestamo de ese grupo
			$template->param(already_issued => 1);
		}
		elsif($result[1]==6) {
                        #el usuario no es regular
                        $template->param(not_regular => 1);
                }  elsif($result[1] == 9){ #muchos prestamos no se puede reservar un item
                        $template->param(bib => $query->param('bib'));
                        $template->param(too_many_issues => 1);
		}

}

}

$template->param (	MAIL  => $borr->{'emailaddress'},
			borrowernumber => $borrowernumber,
			CirculationEnabled => C4::Context->preference("circulation"),
			pagetitle => $pagetitle);

# check that you can actually make the reserve.
=cut

output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
