#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use JSON;

my $input = new CGI;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

=item
Aca se maneja el cambio de la password para el usuario
=cut
if($tipoAccion eq "CAMBIAR_PASSWORD"){

	my %params;
	$params{'usuario'}= $obj->{'usuario'};
	$params{'newpassword'}= $obj->{'newpassword'};
	$params{'newpassword1'}= $obj->{'newpassword1'};

	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_cambiarPassword(\%params);

	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "CAMBIAR_PASSWORD")

=item
Aca se maneja el cambio de permisos para el usuario
=cut
if($tipoAccion eq "GUARDAR_PERMISOS"){

	my %params;
	$params{'usuario'}= $obj->{'usuario'};
	$params{'array_permisos'}= $obj->{'array_permisos'};
	
 	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_cambiarPermisos(\%params);

	#se arma el mensaje para informar al usuario
	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_PERMISOS")


=item
Se buscan los permisos del usuario y se muestran por pantalla
=cut
if($tipoAccion eq "MOSTRAR_PERMISOS"){
	
	my $flagsrequired;
	$flagsrequired->{permissions}=1;

	my ($template, $loggedinuser, $cookie)= get_template_and_user({	template_name => "usuarios/reales/permisos-usuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => $flagsrequired,
									debug => 1,
				});


	my ($bor,$flags,$accessflags)= C4::Circulation::Circ2::getpatroninformation( $obj->{'usuario'},'');
	
	my $dbh=C4::Context->dbh();
	my $sth=$dbh->prepare("SELECT bit,flag,flagdesc FROM userflags ORDER BY bit");
	$sth->execute;
	my @loop;

	while (my ($bit, $flag, $flagdesc) = $sth->fetchrow) {
		my $checked='';
		if ( $accessflags->{$flag} ) {
			$checked='checked';
		}
		
		my %row = ( 	bit => $bit,
				flag => $flag,
				checked => $checked,
				flagdesc => $flagdesc );

		push @loop, \%row;
	}

	$template->param(	
  				surname => $bor->{'surname'},
  				firstname => $bor->{'firstname'},
				loop => \@loop
		);
	
	print  $template->output;

} #end if($tipoAccion eq "MOSTRAR_PERMISOS")


=item
Se elimina el usuario
=cut
if($tipoAccion eq "ELIMINAR_USUARIO"){

	my %params;
	my $usuario_hash_ref= C4::AR::Usuarios::getBorrower($obj->{'borrowernumber'});
	$params{'usuario'}= $usuario_hash_ref->{'surname'}.', '.$usuario_hash_ref->{'firstname'};
   	$params{'borrowernumber'}= $usuario_hash_ref->{'borrowernumber'};
	
 	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_eliminarUsuario(\%params);

	#se arma el mensaje para informar al usuario
	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "ELIMINAR_USUARIO")


=item
Se elimina el usuario
=cut
if($tipoAccion eq "AGREGAR_USUARIO"){
	
  	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_addBorrower($obj);
# 	my ($error,$codMsg,$message);

	#se arma el mensaje para informar al usuario
	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "AGREGAR_USUARIO")


=item
Se guarda la modificacion los datos del usuario
=cut
if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO"){
	
  	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_updateBorrower($obj);
# 	my ($error,$codMsg,$message);

	#se arma el mensaje para informar al usuario
	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO")


=item
Se genra la ventana para modificar los datos del usuario
=cut
if($tipoAccion eq "MODIFICAR_USUARIO"){

	my ($template, $loggedinuser, $cookie) = get_templateexpr_and_user({
						template_name => "usuarios/reales/agregarUsuario.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => {borrowers => 1},
						debug => 1,
	});

	my $borrowernumber =$obj->{'borrowernumber'};

	#Obtenemos los datos del borrower
	my $datosBorrower_hashref= &C4::AR::Usuarios::getBorrowerInfo($borrowernumber);

	#se genera el combo de categorias de usuario
	my $comboDeCategorias= &C4::AR::Utilidades::generarComboCategorias();
	
	#se genera el combo de tipos de documento
	my $comboDeTipoDeDoc= &C4::AR::Utilidades::generarComboTipoDeDoc();

	#se genera el combo de las bibliotecas
	my $comboDeBranches= &C4::AR::Utilidades::generarComboDeBranches();

	$template->param(	

				documentloop    => $comboDeTipoDeDoc,
				catcodepopup	=> $comboDeCategorias,
				CGIbranch 	=> $comboDeBranches,
		
				type		=> $datosBorrower_hashref->{'type'},
				address         => $datosBorrower_hashref->{'adress'},
				firstname       => $datosBorrower_hashref->{'firstname'},
				surname         => $datosBorrower_hashref->{'surname'},
				streetaddress   => $datosBorrower_hashref->{'streetaddress'},
				zipcode 	=> $datosBorrower_hashref->{'zipcode'},
				streetcity      => $datosBorrower_hashref->{'streetcity'},
				dstreetcity     => $datosBorrower_hashref->{'dstreetcity'},
				homezipcode 	=> $datosBorrower_hashref->{'homezipcode'},
				city		=> $datosBorrower_hashref->{'city'},
				dcity           => $datosBorrower_hashref->{'dcity'},
				phone           => $datosBorrower_hashref->{'phone'},
				phoneday        => $datosBorrower_hashref->{'phoneday'},
				emailaddress    => $datosBorrower_hashref->{'emailaddress'},
				borrowernotes	=> $datosBorrower_hashref->{'borrowernotes'},
				documentnumber  => $datosBorrower_hashref->{'documentnumber'},
				studentnumber 	=> $datosBorrower_hashref->{'studentnumber'},
				dateenrolled	=> $datosBorrower_hashref->{'dateenrolled'},
				expiry		=> $datosBorrower_hashref->{'expiry'},
				cardnumber	=> $datosBorrower_hashref->{'cardnumber'},
				dateofbirth	=> $datosBorrower_hashref->{'dateofbirth'},
				addBorrower	=> 0,
# 				dateformat      => display_date_format($dateformat),
		);

 	print $input->header;
 	print  $template->output;

} #end if($tipoAccion eq "MODIFICAR_USUARIO")

