#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::Date;
use Date::Manip;
use C4::AR::Usuarios;
use C4::AR::Utilidades;


my $input = new CGI;

my ($template, $loggedinuser, $cookie, $params)
    = get_template_and_user({
				template_name => "usuarios/reales/buscarUsuarioResult.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
			     });


my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $orden=$obj->{'orden'}||'surname';
my $member=$obj->{'member'};
my $ini=$obj->{'ini'};
my $funcion=$obj->{'funcion'};
my $inicial=$obj->{'inicial'};
my $env;


my ($cantidad,$results);
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);


if (defined($inicial)){
	($cantidad,$results)=&ListadoDeUsuarios($member,"inicial",$orden,$ini,$cantR,$inicial);
}
elsif($member ne ""){
	if((length($member) == 1)&&(defined $member)) {
		($cantidad,$results)=&ListadoDeUsuarios($member,"simple",$orden,$ini,$cantR);
	} else {
		($cantidad,$results)=&ListadoDeUsuarios($member,"advanced",$orden,$ini,$cantR);
	}
}

my $paginador= &C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion);

my @resultsdata;
for (my $i=0; $i < $cantR; $i++){
  #find out stats
    if($results->[$i]{'borrowernumber'} ne ""){
	my $clase="";
 	my ($od,$issue)=C4::AR::Issues::cantidadDePrestamosPorUsuario($results->[$i]{'borrowernumber'});
 	my $regular= &C4::AR::Usuarios::esRegular($results->[$i]{'borrowernumber'});

 	if ($regular eq 1){$regular="Regular"; $clase="prestamo";}	
	else{
		if($regular eq 0){$regular="Irregular";$clase="fechaVencida";}
		else{
			$regular="---";
		}
	}

  	my %row = (
		clase=>$clase,
        	borrowernumber => $results->[$i]{'borrowernumber'},
        	cardnumber => $results->[$i]{'cardnumber'},
        	surname => $results->[$i]{'surname'},
        	firstname => $results->[$i]{'firstname'},
		completo => $results->[$i]{'surname'}.", ".$results->[$i]{'firstname'},
        	categorycode => $results->[$i]{'categorycode'},
        	streetaddress => $results->[$i]{'streetaddress'},
        	documenttype => $results->[$i]{'documenttype'},
        	documentnumber => $results->[$i]{'documentnumber'},
        	studentnumber => $results->[$i]{'studentnumber'},
        	city => $results->[$i]{'city'},
        	odissue => "$od/$issue",
        	issue => "$issue",
        	od => "$od",
        	regular => $regular,
        	borrowernotes => $results->[$i]{'borrowernotes'}
	);
	push(@resultsdata, \%row);
     }
}

$params->{'resultsloop'}= \@resultsdata;
$params->{'member'}= $member;
$params->{'cantidad'}= $cantidad;
$params->{'paginador'}= $paginador;


$template->process($params->{'template_name'}, $params) || die $template->error(), "\n";