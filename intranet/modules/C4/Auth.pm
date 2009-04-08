#ESTE ARCHIVO ESTA MODIFICADO PARA PERMITIR LA AUTENTICACION EN LDAP (el original es Auth.pm.ori)
#IMPORTA EL ARCHIVO Authldap.pm

# -*- tab-width: 8 -*-
# NOTE: This file uses 8-character tabs; do not change the tab size!

package C4::Auth;

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
use Digest::MD5 qw(md5_base64);

require Exporter;
use C4::AR::Authldap;
use C4::Membersldap;
use C4::Context;
use C4::Output;              # to get the template
use C4::Interface::CGI::Output;
use C4::Circulation::Circ2;  # getpatroninformation
use C4::AR::Usuarios; #Miguel lo agregue pq sino no ve la funcion esRegular!!!!!!!!!!!!!!!
use C4::AR::Prestamos;
use CGI::Session;
use C4::Modelo::SistSesion;
use C4::Modelo::SistSesion::Manager;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI;
  use C4::Auth;

  my $query = new CGI;

  my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name   => "opac-main.tmpl",
                             query           => $query,
			     type            => "opac",
			     authnotrequired => 1,
			     flagsrequired   => {borrow => 1},
			  });

  print $query->header(
    -type => guesstype($template->output),
    -cookie => $cookie
  ), $template->output;


=head1 DESCRIPTION

    The main function of this module is to provide
    authentification. However the get_template_and_user function has
    been provided so that a users login information is passed along
    automatically. This gets loaded into the template.

=head1 FUNCTIONS

=over 2

=cut


#Agregrue la exportacin de getborrowernumber para poder obetenerlo si necesitar un template
#
@ISA = qw(Exporter);
@EXPORT = qw(
		&checkauth
		&t_operacionesDeINTRA
		&t_operacionesDeOPAC		
		&get_template_and_user
		&get_templateexpr_and_user
		&getborrowernumber
		&getuserflags
		&output_html_with_http_headers


		&getSessionLoggedUser
		&getSessionUserID
		&getSessionPassword
		&getSessionNroRandom
		&getSessionBorrowerNumber
		&getSessionFlagsRequired
		&getSessionBrowser
		&_generarNroRandom
		
);


sub getSessionLoggedUser {
	my ($session) = @_;

	return $session->param('loggedinusername');
}

sub getSessionUserID {
	my ($session) = @_;

	return $session->param('userid');
}

sub getSessionIdSocio {
    my ($session) = @_;

    return $session->param('id_socio');
}

sub getSessionPassword {
	my ($session) = @_;

	return $session->param('password');
}

sub getSessionNroRandom {
	my ($session) = @_;

	return $session->param('nroRandom');
}

sub getSessionBorrowerNumber {
	my ($session) = @_;

	return $session->param('borrowernumber');
}

sub getSessionFlagsRequired {
	my ($session) = @_;

	return $session->param('flagsrequired');
}

sub getSessionBrowser {
	my ($session) = @_;

	return $session->param('browser');
}


=item get_template_and_user

  my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name   => "opac-main.tmpl",
                             query           => $query,
			     type            => "opac",
			     authnotrequired => 1,
			     flagsrequired   => {borrow => 1},
			  });

    This call passes the C<query>, C<flagsrequired> and C<authnotrequired>
    to C<&checkauth> (in this module) to perform authentification.
    See C<&checkauth> for an explanation of these parameters.

    The C<template_name> is then used to find the correct template for
    the page. The authenticated users details are loaded onto the
    template in the HTML::Template LOOP variable C<USER_INFO>. Also the
    C<sessionID> is passed to the template. This can be used in templates
    if cookies are disabled. It needs to be put as and input to every
    authenticated page.

    More information on the C<gettemplate> sub can be found in the
    Output.pm module.

=cut


sub get_template_and_user {
	my $in = shift;

	my ($template, $params) = C4::Output::gettemplate($in->{'template_name'}, $in->{'type'});
	my ($user, $session, $flags)= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});

	my $nro_socio;
	if ( $session->param('userid') ) {
		$params->{'loggedinusername'}= $session->param('userid');
		$params->{'loggedinuser'}= $session->param('userid');
		$nro_socio = $session->param('userid');
# FIXME sacar luego de pasar todo a los nombre nuevos
		$session->param('borrowernumber',$nro_socio);#se esta pasadon por ahora despues sacar

        my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($session->param('userid'));
        $socio->load();
        $session->param('nro_socio',$nro_socio);
        $session->param('id_socio',$socio->getId_socio);
		my ($borr, $flags) = getpatroninformation($nro_socio,"");
		my @bordat;
		$bordat[0] = $borr;
		$session->param('USER_INFO', \@bordat);	
	}

	return ($template, $session, $params);
}


sub output_html_with_http_headers {
    my($query, $template, $params, $session, $cookie) = @_;
	print $session->header();

	$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";
	exit;
}

=item checkauth

  ($userid, $cookie, $sessionID) = &checkauth($query, $noauth, $flagsrequired, $type);

Verifies that the user is authorizete_and_userd to run this script.  If
the user is authorized, a (userid, cookie, session-id, flags)
quadruple is returned.  If the user is not authorized but does
not have the required privilege (see $flagsrequired below), it
displays an error page and exits.  Otherwise, it displays the
login page and exits.

Note that C<&checkauth> will return if and only if the user
is authorized, so it should be called early on, before any
unfinished operations (e.g., if you've opened a file, then
C<&checkauth> won't close it for you).

C<$query> is the CGI object for the script calling C<&checkauth>.

The C<$noauth> argument is optional. If it is set, then no
authorization is required for the script.

C<&checkauth> fetches user and session information from C<$query> and
ensures that the user is authorized to run scripts that require
authorization.

The C<$flagsrequired> argument specifies the required privileges
the user must have if the username and password are correct.
It should be specified as a reference-to-hash; keys in the hash
should be the "flags" for the user, as specified in the Members
intranet module. Any key specified must correspond to a "flag"
in the userflags table. E.g., { circulate => 1 } would specify
that the user must have the "circulate" privilege in order to
proceed. To make sure that access control is correct, the
C<$flagsrequired> parameter must be specified correctly.

The C<$type> argument specifies whether the template should be
retrieved from the opac or intranet directory tree.  "opac" is
assumed if it is not specified; however, if C<$type> is specified,
"intranet" is assumed if it is not "opac".

If C<$query> does not have a valid session ID associated with it
(i.e., the user has not logged in) or if the session has expired,
C<&checkauth> presents the user with a login page (from the point of
view of the original script, C<&checkauth> does not return). Once the
user has authenticated, C<&checkauth> restarts the original script
(this time, C<&checkauth> returns).

The login page is provided using a HTML::Template, which is set in the
systempreferences table or at the top of this file. The variable C<$type> 
selects which template to use, either the opac or the intranet 
authentification template.

C<&checkauth> returns a user ID, a cookie, and a session ID. The
cookie should be sent back to the browser; it verifies that the user
has authenticated.

=cut

sub checkauth {
    
    my $query=shift;
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired = shift;
    my $flagsrequired = shift;
    my $type = shift;
    $type = 'opac' unless $type;
open(A, ">>/tmp/debug.txt");
print A "desde checkauth============================================================================================================= \n";
    my $dbh = C4::Context->dbh;
    my $timeout = C4::AR::Preferencias->getValorPreferencia('timeout');
    $timeout = 600 unless $timeout;

    my $template_name;
    if ($type eq 'opac') {
        $template_name = "opac-auth.tmpl";
    } else {
        $template_name = "auth.tmpl";
    }

print A "checkauth=> template_name: ".$template_name."\n";
print A "checkauth=> authnotrequired: ".$authnotrequired."\n";

    # state variables
    my $loggedin = 0;
    my %info;
    my $session = CGI::Session->load();
    my ($userid, $cookie, $sessionID, $flags);
    my $logout = $query->param('logout.x')||0;

print A "checkauth=> info antes de verificar si hay session \n";
print A "checkauth=> recupero de la cookie con sessionID (desde query->cookie): ".$query->cookie('sessionID')."\n";
print A "checkauth=> recupero de la cookie con sessionID (desde session->param): ".$session->param('sessionID')."\n";

   if ($sessionID=$session->param('sessionID')) {
print A "checkauth=> sessionID seteado \n";
print A "checkauth=> recupero de la cookie con sessionID (desde query->cookie): ".$query->cookie('sessionID')."\n";
print A "checkauth=> recupero de la cookie con sessionID (desde session->param): ".$session->param('sessionID')."\n";

        #Se recupera la info de la session guardada en la base segun el sessionID
        my ($sist_sesion)= C4::Modelo::SistSesion->new(sessionID => $sessionID);
        $sist_sesion->load();

        my ($ip , $lasttime, $nroRandom, $flag);

        $userid= $sist_sesion->getUserid;
        $ip= $sist_sesion->getIp;
        $lasttime= $sist_sesion->getLasttime;
        $nroRandom= $sist_sesion->getNroRandom;
        $flag= $sist_sesion->getFlag;

        if ($logout) {
            #se maneja el logout del usuario
            _logOut_Controller($dbh, $query, $userid, $ip, $sessionID, $sist_sesion);
            $sessionID = undef;
            $userid = undef;

print A "checkauth=> sessionID de CGI-Session: ".$session->id."\n";
print A "checkauth=> sessionID en logout: ". $session->param('sessionID')."\n";
            $session->param('codMsg', 'U358');
            $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
            redirectTo('/cgi-bin/koha/auth.pl');
            #EXIT
        }

        if ($userid) {
#         if($sist_sesion->getUserid){ 
        #la sesion existia en la bdd, chequeo que no se halla vencido el tiempo
        #se verifican algunas condiciones de finalizacion de session
print A "checkauth=> El usuario se encuentra logueado \n";
          if ($lasttime<time()-$timeout) {
            # timed logout
            $info{'timed_out'} = 1;
            #elimino la session del usuario porque caduco
            $sist_sesion->delete;
print A "checkauth=> caduco la session \n";
            #Logueo la sesion que se termino por timeout
            my $time=localtime(time());
            _session_log(sprintf "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time);
            $userid = undef;
            $sessionID = undef;
            #redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
            $session->param('codMsg', 'U355');
            $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
            redirectTo('/cgi-bin/koha/auth.pl');
            #EXIT

             } elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
#              } elsif ($ip ne '127.0.0.2') {
            # Different ip than originally logged in from
            $info{'oldip'} = $ip;
            $info{'newip'} = $ENV{'REMOTE_ADDR'};
            $info{'different_ip'} = 1;
            #elimino la session del usuario porque caduco
            $sist_sesion->delete;
print A "checkauth=> cambio la IP, se elimina la session\n";
            #Logueo la sesion que se cambio la ip
            my $time=localtime(time());
            _session_log(sprintf "%20s from logged out at %30s (ip changed from %16s to %16s).\n", 
                                                        $userid, 
                                                        $time, 
                                                        $ip, 
                                                        $info{'newip'}
                  );
            $sessionID = undef;
            $userid = undef;    
            #redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
            $session->param('codMsg', 'U356');
            $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
            redirectTo('/cgi-bin/koha/auth.pl');
            #EXIT
            } elsif ($flag eq 'LOGUIN_DUPLICADO') {
            #Se encuentra una session activa con el mismo userid
            #se eliminan las sessiones, solo se permite una session activa a la vez
            $info{'loguin_duplicado'} = 1;
            #elimino la session del usuario porque caduco
            $sist_sesion->delete;
print A "checkauth=> se loguearon con el mismo userid desde otro lado\n";
            #Logueo la sesion que se cambio la ip
            my $time=localtime(time());
            _session_log(sprintf "%20s from logged out at %30s (ip changed from %16s to %16s).\n", 
                                                        $userid, 
                                                        $time, 
                                                        $ip, 
                                                        $info{'newip'}
                  );
            $sessionID = undef;
            $userid = undef;    
            #redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
            $session->param('codMsg', 'U359');
            $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
            redirectTo('/cgi-bin/koha/auth.pl');
            #EXIT
            } else {
            #esta todo OK, continua logueado y se actualiza la session, lasttime
print A "checkauth=> continua logueado, actualizo lasttime de sessionID: ".$sessionID."\n";
                $sist_sesion->setLasttime(time());
                $sist_sesion->save();

                my ($socio)= C4::Modelo::UsrSocio->new(nro_socio => $userid);
                $socio->load();
                $flags = $socio->tienePermisos($flagsrequired);

                if ($flags) {
                    $loggedin = 1;
print A "checkauth=> TIENE PERMISOS: \n";
                } else {
                    $info{'nopermission'} = 1;
print A "checkauth=> NO TIENE PERMISOS: \n";
                    #redirecciono a una pagina informando q no tiene  permisos
                    $session->param('codMsg', 'U354');
                    $session->param('redirectTo', '/cgi-bin/koha/informacion.pl');
                    redirectTo('/cgi-bin/koha/informacion.pl');
                    #EXIT
                }
            }
          }#if de la sesion que existia en la bdd
        }#end ($sessionID=$query->cookie('sessionID'))


    #por aca se permite llegar a paginas que no necesitan autenticarse
    my $insecure = C4::AR::Preferencias->getValorPreferencia('insecure');
    # finished authentification, now respond
    if ($loggedin || $authnotrequired || (defined($insecure) && $insecure)) {
print A "checkauth=> if (loggedin || authnotrequired || (defined(insecure) && insecure)) \n";
print A "checkauth=> insecure: ".$insecure."\n";
print A "checkauth=> authnotrequired: ".$authnotrequired."\n";
        #Se verifica si el usuario tiene que cambiar la password
        if ( ($userid) && ( new_password_is_needed($userid) ) ) {

print A "checkauth=> changePassword \n";
            _change_Password_Controller($dbh, $query, $userid, $type,\%info);
            #EXIT
        }#end if (($userid) && (new_password_is_needed($dbh,getborrowernumber($userid))))

print A "checkauth=> EXIT => userid: ".$userid." cookie=> sessionID: ".$query->cookie('sessionID')." sessionID: ".$sessionID."\n";
print A "\n";
close(A);
        return ($userid, $session, $flags);
    }#end if ($loggedin || $authnotrequired || (defined($insecure) && $insecure))



    unless ($userid) { 
        #si no hay userid, hay que autentificarlo y no existe sesion
print A "checkauth=> Usuario no logueado, intento de autenticacion \n";     
        #No genero un nuevo sessionID, tomo el que viene del cliente
        #con este sessionID puedo recuperar el nroRandom (si existe) guardado en la base, para verificar la password
        my ($sist_sesion)= C4::Modelo::SistSesion->new(sessionID => $sessionID);
        $sist_sesion->load();

        my $sessionID= $session->param('sessionID');
        #recupero el userid y la password desde el cliente
        $userid= $query->param('userid');
        my $password= $query->param('password');
print A "checkauth=> busco el sessionID: ".$sessionID." de la base \n";
        my $random_number= $sist_sesion->getNroRandom;
print A "checkauth=> random_number desde la base: ".$random_number."\n";

        #se verifica la password ingresada
        my ($passwordValida, $cardnumber, $branch)= _verificarPassword($dbh,$userid,$password,$random_number);

        if ($passwordValida) {
           #se valido la password y es valida
           # setea loguins duplicados si existe, dejando logueado a un solo usuario a la vez
            _setLoguinDuplicado($userid,  $ENV{'REMOTE_ADDR'});
print A "checkauth=> password valida de sessionID: ".$sessionID."\n";
print A "checkauth=> elimino el sessionID de la base: ".$sessionID."\n";
            #el usuario se logueo bien, se elimina la session de logueo y se genera un sessionID nuevo
            $sist_sesion->delete;

            my %params;
            $params{'userid'}= $userid;
            $params{'loggedinusername'}= $userid;
            $params{'password'}= $password;
            $params{'nroRandom'}= $random_number;
#             $params{'borrowernumber'}= getborrowernumber($userid);
            $params{'type'}= $type; #OPAC o INTRA
            $params{'flagsrequired'}= $flagsrequired;
C4::AR::Debug::debug("user_agent".$ENV{'HTTP_USER_AGENT'});
            $params{'browser'}= $ENV{'HTTP_USER_AGENT'};
            #genero una nueva session
            $session= _generarSession(\%params);
C4::AR::Debug::debug("user_agent desde sesion".$session->param('browser'));
            $sessionID= $session->param('sessionID');
print A "checkauth=> genero un nuevo sessionID ".$sessionID."\n";
            $sessionID.="_".$branch;
            $session->param('sessionID', $sessionID);
            print A "checkauth=> modifico el sessionID: ".$sessionID." \n";
            my ($socio) = C4::Modelo::UsrSocio->new(nro_socio => $userid);
            $socio->load();
            #el usuario se logueo bien, ya no es necessario el nroRandom
            $random_number= 0;
            #guardo la session en la base
            _save_session_db($sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

            #Logueo una nueva sesion
            my $time=localtime(time());
            _session_log(sprintf "%20s from %16s logged out at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},$time);
    
            #por defecto no tiene permisos
            $info{'nopermission'} = 1;
            if( $flags = $socio->tienePermisos($flagsrequired) ){
                $info{'nopermission'} = 0;
                $loggedin = 1;
                #WARNING: Cuando pasan dias habiles sin actividad se consideran automaticamente feriados
                my $sth=$dbh->prepare("SELECT MAX(lastlogin) AS lastlogin FROM borrowers");
                $sth->execute();
                my $lastlogin= $sth->fetchrow;
                my $prevWorkDate = C4::Date::format_date_in_iso(Date::Manip::Date_PrevWorkDay("today",1));
                my $enter=0;
                if ($lastlogin){
                    while (Date::Manip::Date_Cmp($lastlogin,$prevWorkDate)<0) {
                    # lastlogin es anterior a prevWorkDate
                    # desde el dia siguiente a lastlogin hasta el dia prevWorkDate no hubo actividad
                        $lastlogin= C4::Date::format_date_in_iso(Date::Manip::Date_NextWorkDay($lastlogin,1));
                        my $sth=$dbh->prepare("INSERT INTO pref_feriado (fecha) VALUES (?)");
                        $sth->execute($lastlogin);
                        $enter=1;
                    }
                    
                    #Genera una comprovacion una vez al dia, cuando se loguea el primer usuario
                    my $today = C4::Date::format_date_in_iso(Date::Manip::ParseDate("today"));
                    if (Date::Manip::Date_Cmp($lastlogin,$today)<0) {
                        # lastlogin es anterior a hoy
                        # Hoy no se enviaron nunca los mails de recordacion
                        _enviarCorreosDeRecordacion($today);
                    }
                }#end if ($lastlogin)

                if ($enter) {
                #Se actuliza el archivo con los feriados (.DateManip.cfg) solo si se dieron de alta nuevos feriados en 
                #el while anterior
                    my ($count,@holidays)= C4::AR::Utilidades::getholidays();
                    C4::AR::Utilidades::savedatemanip(@holidays);
                }
                
                #Se borran las reservas de los usuarios sancionados         
                if ($type eq 'opac') {
                #Si es un usuario de opac que esta sancionado entonces se borran sus reservas
print A "checkauth=> t_operacionesDeOPAC\n";
                    t_operacionesDeOPAC($userid, $socio);
                } else {
                ##Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
print A "checkauth=> t_operacionesDeINTRA\n";
                    t_operacionesDeINTRA($userid, $cardnumber, $socio);
                }# end if ($type eq 'opac')
    
            }# end if ($flags = haspermission($dbh, $userid, $flagsrequired))

        } else {
        #usuario o password invalida
            if ($userid) {
print A "checkauth=> usuario o password incorrecta dentro del if\n";
                $info{'invalid_username_or_password'} = 1;
                #elimino la session vieja
                $sist_sesion->delete;
            }
print A "checkauth=> usuario o password incorrecta \n";
print A "checkauth=> eliminino la sesssion ".$sessionID."\n";
            $userid= undef;
            #genero una nueva session y redirecciono a auth.tmpl para que se loguee nuevamente
            $session->param('codMsg', 'U357');
            $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
            redirectTo('/cgi-bin/koha/auth.pl');
            #EXIT
        }#end if ($passwordValida)
 
    }# end unless ($userid) 

print A "checkauth=> 2do EXIT => userid: ".$userid." cookie=> sessionID: ".$session->param('sessionID')." sessionID: ".$sessionID."\n";
print A "\n";
close(A);
    return ($userid, $session, $flags);

}# end checkauth

=item
Esta funcion guarda una session en la base
=cut
sub _save_session_db{
	my ($sessionID, $userid, $remote_addr, $random_number) = @_;
    my ($sist_sesion)= C4::Modelo::SistSesion->new();
    $sist_sesion->load();
    $sist_sesion->setSessionId($sessionID);
    $sist_sesion->setUserid($userid);
    $sist_sesion->setIp($remote_addr);
    $sist_sesion->setLasttime(time());
    $sist_sesion->setNroRandom($random_number);
    $sist_sesion->save();

}

=item
Esta funcion modifica el flag de todos las sessiones con usuarios duplicados, seteando el mismo a LOGUIN_DUPLICADO
cuando el usuario remoto con session duplicada intente navegar, sera redireccionado al loguin
=cut
sub _setLoguinDuplicado {
	my ($userid, $ip) = @_;
    #Verifica si existe sesiones abiertas con el mismo userid, pero con <> ip, si es asi se les setea un flag de LOGUIN_DIPLICADO
    #y ni bien intente navegar el usuario será redireccionado al loguin.
    my ($sist_sesion_array_ref) = C4::Modelo::SistSesion::Manager->get_sist_sesion( query => [ 
                                                                                                ip => { ne => $ip },
                                                                                                userid => { eq => $userid }
                                                                                     ]);

    if( scalar($sist_sesion_array_ref->[0]) > 0){
    #si retorna un objeto
        $sist_sesion_array_ref->[0]->setFlag('LOGUIN_DUPLICADO');
        $sist_sesion_array_ref->[0]->save();
    }
}

=item
Esta funcion se encarga del logout del usuario
=cut
sub _logOut_Controller {
	my ($dbh, $query, $userid, $ip, $sessionID, $sist_sesion) = @_;
	# voluntary logout the user
open(E, ">>/tmp/debug.txt");
print E "\n";
print E "_logOut_Controller=> LOGOUT: \n";
print E "_logOut_Controller=> sessionID: ".$sessionID."\n";
print E "_logOut_Controller=> userID: ".$userid."\n";
	#Logueo la sesion que se termino voluntariamente
	my $time=localtime(time());
	_session_log(sprintf "%20s from %16s logged out at %30s (manually).\n", $userid, $ip, $time);
	#se elimina la session del usuario que se esta deslogueando
    $sist_sesion->delete;

print E "_logOut_Controller=> Elimino de la base la session de userid: ".$userid." sessionID: ".$sessionID."\n";
print E "\n";

close(E);
}

=item
Esta funcion se encarga de manejar el cambio de la password
=cut
sub _change_Password_Controller {
	my ($dbh, $query, $userid, $type, $info) = @_;
open(J, ">>/tmp/debug.txt");
print J "\n";
print J "_change_Password_Controller=> \n";
	my $input = new CGI;
print J "_change_Password_Controller=> type: ".$type."\n";
	my $template_name;
	my $newpassword = $input->param('newpassword') || 0;
print J "_change_Password_Controller=> newpassword: ".$newpassword."\n";
# 	my $cardnumber= _getCardnumber($dbh, $userid);
## FIXME sacar!!!!
    my $cardnumber= '26320';
	my $passwordrepeted= 0;
	
	if ($newpassword) {
	# Check if the password is repeted
		if (C4::AR::Preferencias->getValorPreferencia("ldapenabled") eq "yes") { # check in ldap
			my $oldpassword= getldappassword($cardnumber,$dbh);
			$passwordrepeted= ($oldpassword eq $newpassword);
		} else { # check in database
			my $sth=$dbh->prepare("select password from borrowers where cardnumber=?");
			$sth->execute($cardnumber);
			my $oldpassword= $sth->fetchrow;
			$passwordrepeted= ($oldpassword eq $newpassword);
		}
	}#end if ($newpassword)

	if ($newpassword && !$passwordrepeted) {
	# The new password is sent
## FIXME esto se hace en memebr-password.pl tb?????	
		if (C4::AR::Preferencias->getValorPreferencia("ldapenabled") eq "yes") { # update the ldap password
			addupdateldapuser($dbh,$cardnumber,$newpassword);
			my $sth=$dbh->prepare("update borrowers set lastchangepassword=now() where cardnumber=?");
			$sth->execute($cardnumber);
		} else { # update the database password
			my $sth=$dbh->prepare("update borrowers set password=?, lastchangepassword=now() where cardnumber=?");
			$sth->execute($newpassword, $cardnumber);
		}

	} else {
		# The new password is requested
		if ($type eq 'opac') {
			$template_name = "opac-changepassword.tmpl";
		} else {
			$template_name = "changepassword.tmpl";
		}
print J "_change_Password_Controller=> template_name: ".$template_name."\n";

		my ($template, $t_params) = gettemplate($template_name, $type);
print J "_change_Password_Controller=> template_name: ".$template_name."\n";	
		$t_params->{'passwordrepetedv'}= $passwordrepeted;

		#PARA QUE EL USUARIO REALICE UN HASH CON EL NUMERO RANDOM
		my $random_number= _generarNroRandom();
## FIXME falta cambiar la pass del LDAP
		$t_params->{'RANDOM_NUMBER'}= $random_number;
print J "_change_Password_Controller=> genera otro random: ".$random_number."\n";
        my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
        $t_params->{'userid'}= $userid;
        $t_params->{'id_socio'}= $socio->getId_socio;
        $t_params->{'loggedinusername'}= $userid;
	
        my $session = CGI::Session->load();
 		my $sessionID= $session->param('sessionID');
print J "_change_Password_Controller=> genero cookie:".$sessionID."\n";	

        C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);
print J "\n";
close(J);
	
	}#end  if ($newpassword && !$passwordrepeted)
}

=item
Esta funcion inicializa la session para autenticar un usuario, se usa en OPAC e INTRA siempre q se quiere autenticar
=cut
sub inicializarAuth{
    my ($query, $t_params) = @_;

open(F, ">>/tmp/debug.txt");
print F "C4::Auth::inicializarAuth=> \n";
    #se genera un nuevo nroRandom para que se autentique el usuario
    my $random_number= C4::Auth::_generarNroRandom();
print F "C4::Auth::inicializarAuth=> numero random: ".$random_number."\n";
    
    #genero una nueva session
    my $session = CGI::Session->load();
    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),'INTRA',[]);
    #se destruye la session anterior
    $session->clear();
    $session->delete();
    
    #se genera una nueva session
    my %params;
    $params{'userid'}= '';
    $params{'loggedinusername'}= '';
    $params{'password'}= '';
    $params{'nroRandom'}= '';
    $params{'borrowernumber'}= '';
    $params{'type'}= 'opac'; #OPAC o INTRA
    $params{'flagsrequired'}= '';
    $params{'browser'}= $ENV{'HTTP_USER_AGENT'};
    
    #esto realmente destruye la session
    undef($session);
    $session= C4::Auth::_generarSession(\%params);
    my $sessionID= $session->param('sessionID');
print F "C4::Auth::inicializarAuth=> sessionID: ".$sessionID."\n";
    
    my $userid= undef;
    #guardo la session en la base
    C4::Auth::_save_session_db($sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

    $t_params->{'RANDOM_NUMBER'}= $random_number;
    
close(F);

    return ($session);
}

sub _generarNroRandom {
	#PARA QUE EL USUARIO REALICE UN HASH CON EL NUMERO RANDOM
	#Y NO VIAJE LA PASS DEL USUARIO ENCRIPTADA SOLO CON MD5
	my $random_number= int(rand()*100000);

	return $random_number;
}

sub _generarSession {
	my ($params) = @_;

    my $session = new CGI::Session(undef, undef, undef);
    #se setea toda la info necesaria en la sesion
	$session->param('userid', $params->{'userid'});
	$session->param('sessionID', $session->id());
	$session->param('loggedinusername', $params->{'userid'});
	$session->param('password', $params->{'password'});
	$session->param('nroRandom', $params->{'random_number'});
# 	$session->param('borrowernumber', getborrowernumber($params->{'userid'}));
	$session->param('type', $params->{'type'}); #OPAC o INTRA
	$session->param('flagsrequired', $params->{'flagsrequired'});
 	$session->param('browser', "".C4::AR::Utilidades::trim($params->{'HTTP_USER_AGENT'})."" );
	$session->param('locale', C4::Context->config("defaultLang")|'es_ES');
	$session->expire(0); #para Desarrollar, luego pasar a 3m

	return $session;
}

=item
Esta funcion verifica si el usuario y la password ingresada son valida, ya se en LDAP o en la base, segun configuracion de preferencia
=cut
sub _verificarPassword {
	my ($dbh, $userid, $password, $random_number) = @_;
open(F, ">>/tmp/debug.txt");
print F "\n";
print F "_verificarPassword=> verificarPassword: \n";
print F "_verificarPassword=> userID: ".$userid."\n";
print F "_verificarPassword=> nroRandom: ".$random_number."\n";
# Si se quiere dejar de usar el servidor ldap para hacer la autenticacion debe cambiarse 
# la llamada a la funcion checkpwldap por checkpw

	my ($passwordValida, $cardnumber);
## FIXME falta verificar la pass en LDAP si esta esta usando
	my $branch;
	if ( C4::AR::Preferencias->getValorPreferencia('ldapenabled')) {
	#se esta usando LDAP
		($passwordValida, $cardnumber,$branch) = checkpwldap($dbh,$userid,$password,$random_number);
	} else {
         ($passwordValida, $cardnumber,$branch) = _checkpw($userid,$password,$random_number); 
	}
print F "_verificarPassword=> password valida?: ".$passwordValida."\n";
print F "\n";
close (F);
	return ($passwordValida, $cardnumber, $branch);
}

sub printSession {
	my ($session, $desde) = @_;

	open(S, ">>/tmp/debug.txt");
	print S "\n";
	print S "*******************************************SESSION******************************************************\n";
	print S "Desde: ".$desde."\n";
	print S "session->userid: ".$session->param('userid')."\n";
	print S "session->loggedinusername: ".$session->param('loggedinusername')."\n";
	print S "session->borrowernumber: ".$session->param('borrowernumber')."\n";
	print S "session->password: ".$session->param('password')."\n";
	print S "session->nroRandom: ".$session->param('nroRandom')."\n";
	print S "session->sessionID: ".$session->param('sessionID')."\n";
	print S "session->lang: ".$session->param('lang')."\n";
	print S "session->type: ".$session->param('type')."\n";
	print S "session->flagsrequired: ".$session->param('flagsrequired')."\n";
	print S "session->REQUEST_URI: ".$session->param('REQUEST_URI')."\n";
	print S "session->browser: ".$session->param('browser')."\n";
	print S "*****************************************END**SESSION****************************************************\n";
	print S "\n";
	close(S);
}

sub redirectTo {
	my ($url) = @_;
open(P, ">>/tmp/debug.txt");
print P "\n";
print P "redirectTo=> \n";
	#para saber si fue un llamado con AJAX
	if($ENV{'HTTP_X_REQUESTED_WITH'} eq 'XMLHttpRequest'){
	#redirijo en el cliente
		
print P "redirectTo=> CLIENT_REDIRECT\n"; 		
  		my $session = CGI::Session->load();
		# send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
#         $session->header();
print P "redirectTo=> url: ".$url."\n";
     	print $session->header();
 		print 'CLIENT_REDIRECT';
		exit;
	}else{
	#redirijo en el servidor
print P "redirectTo=> SERVER_REDIRECT\n";       
		my $input = CGI->new(); 
		print $input->redirect( 
					-location => $url, 
					-status => 301,
		); 
		exit;
	}
print P "\n";
close(P);
}


=item
Esta retorna userid,ip,lasttime segun el sessionID
=cut
sub _getInfoSession {
	my ($sessionID) = @_;

	my $dbh = C4::Context->dbh;
	my $sth;
	$sth = $dbh->prepare("SELECT userid,ip,lasttime FROM sist_sesion WHERE sessionid = ?");
 	$sth->execute($sessionID);

	my ($userid, $ip, $lasttime)= $sth->fetchrow;

	return ($userid, $ip, $lasttime);
}

sub _session_log {
    (@_) or return 0;
    open L, ">>/tmp/sessionlog";
    printf L join("\n",@_);
    close L;
}

sub t_operacionesDeOPAC{

	my ($userid, $socio) = @_;
## FIXME mantengo userid para q no se rompa, cuando se termine circulacion, sacar
	my $db= $socio->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

	my ($error,$codMsg,$paraMens);
	my $tipo= 'OPAC';

	eval{
		#Si es un usuario de opac que esta sancionado entonces se borran sus reservas
		my ($isSanction,$endDate)= C4::AR::Sanciones::permitionToLoan(getborrowernumber($userid), C4::AR::Preferencias->getValorPreferencia("defaultissuetype"));
        my $regular= $socio->esRegular;
				
		if ($isSanction || !$regular ){
			&C4::AR::Reservas::cancelar_reservas($userid,getborrowernumber($userid));
		}
		$db->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B408';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$db->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R010';
	}
	$db->{connect_options}->{AutoCommit} = 1;
}

sub t_operacionesDeINTRA{

	my ($userid, $cardnumber, $socio) = @_;
## FIXME mantengo userid y cardnumber para q no se rompa, cuando se termine circulacion, sacar

	my ($error,$codMsg,$paraMens);
	my $tipo= 'INTRA';
    my $db= $socio->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

	eval{
		use C4::Modelo::CircReserva;
		my $reserva=C4::Modelo::CircReserva->new(db=> $db);
		#Se borran las reservas de todos los usuarios sancionados
		$reserva->cancelar_reservas_sancionados($userid);
		#Ademas, se borran las reservas de los usuarios que no son alumnos regulares
		$reserva->cancelar_reservas_no_regulares($userid);
		#Ademas, se borran las reservas vencidas
		$reserva->cancelar_reservas_vencidas($userid);	
		#Si se logueo correctamente en intranet entonces guardo la fecha
        my $today = Date::Manip::ParseDate("today");
        $socio->setLast_login($today);
        $socio->save();
		$db->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B409';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$db->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R010';
	}
    $db->{connect_options}->{AutoCommit} = 1;
}

sub _checkpw {
    my ($userid, $password, $random_number) = @_;
open(Z, ">>/tmp/debug.txt");
print Z "_checkpw=> \n";

     my ($socio) = C4::Modelo::UsrSocio->new(nro_socio => $userid);
     $socio->load();

      if ( ($socio->persona)&&($socio->getActivo) ) {
print Z "_checkpw=> tengo persona y socio\n";
        #existe el socio y se encuentra activo
        my $md5password= $socio->getPassword;
        my $branchcode= $socio->getId_ui;
        my $dni= $socio->persona->getNro_documento;

        if ($md5password eq ''){# La 1ra vez esta vacio se usa el dni
            $md5password=md5_base64($dni);
print Z "_checkpw=> es la 1era vez que se loguea, se usa el DNI\n";
        }

        if ($password eq md5_base64($md5password.$random_number)) {
print Z "_checkpw=> password del cliente: ".$password."\n";
print Z "_checkpw=> md5password.random_number: ".$md5password.$random_number."\n";
print Z "_checkpw=> md5_base64(md5password.random_number): ".md5_base64($md5password.$random_number)."\n";
print Z "_checkpw=> md5password de la base: ".$md5password."\n";
print Z "_checkpw=> las pass son = todo OK\n";
            return 1,$userid,$branchcode;
        }
     }

print Z "_checkpw=> las pass son <> \n";
close(Z);

    return 0;
}

sub getborrowernumber {
    my ($userid) = @_;
    my $dbh = C4::Context->dbh;
    for my $field ('userid', 'cardnumber') {
      my $sth=$dbh->prepare
	  ("select borrowernumber from borrowers where $field=?");
      $sth->execute($userid);
      if ($sth->rows) {
	my ($bnumber) = $sth->fetchrow;
	return $bnumber;
      }
    }
    return 0;
}

sub new_password_is_needed {
# Added by Luciano
# Verify if the borrower have or have not to change the current password to a new one
# There are two fields (lastchangepassword, changepassword) in the table borrowers used to that pourpose
# lastchangepassword: it has the date when the borrower change the password for last time
# changepassword: it is a bool that indicate if the password must be change or not
    my ($nro_socio) = @_;
    my ($socio)= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

    my $days = C4::AR::Preferencias->getValorPreferencia("keeppasswordalive");

    if ($days ne '0') {
        my $err;
        my $today = Date::Manip::DateCalc("today","- ".$days." days",\$err);
        my $lastChangePasswordDate = Date::Manip::ParseDate($socio->getLastchangepassword);
        return ( $socio->getChange_password && ((Date::Manip::Date_Cmp($today,$lastChangePasswordDate)) > 0) );
    } else {
        return ( $socio->getChange_password && $socio->getLast_change_password eq '0000-00-00');
    }
}



END { }       # module clean-up code here (global destructor)
1;
__END__

=back

=head1 SEE ALSO

CGI(3)

C4::Output(3)

Digest::MD5(3)

=cut








