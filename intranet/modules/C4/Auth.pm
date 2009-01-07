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
use C4::AR::Issues;
use CGI::Session;

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
open(H, ">>/tmp/debug.txt");

	my ($template, $params) = gettemplate($in->{'template_name'}, $in->{'type'});
# 	my ($user, $sessionID, $flags)
# 		= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});
	my ($user, $cookie, $session, $flags)= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});

print H "desde: get_template_and_user \n";
# print A "Se llamo a checkauth con: \n";
# print A "in-> query: ".$in->{'query'}."\n";
# print A "user: ".$user."\n";
print H "get_template_and_user=> cookie: ".$cookie."\n";
	my $numero_socio;
	if ( $session->param('userid') ) {
		$params->{'loggedinusername'}= $session->param('userid');
# 		$params->{'sessionID'}= $sessionID;
# 		$params->{'sessionID'}= $session->param('sessionID');
		$numero_socio = getborrowernumber($session->param('userid'));
		$session->param('borrowernumber',$numero_socio);
        $session->param('numero_socio',$numero_socio);
		my ($borr, $flags) = getpatroninformation($numero_socio,"");
		my @bordat;
		$bordat[0] = $borr;
		$session->param('USER_INFO', \@bordat);	
	}
close(H);

# print A "get_template_and_user=> imprimo header \n";
	return ($template, $session, $params, $cookie);
}


sub output_html_with_http_headers {
    	my($query, $template, $params, $session, $cookie) = @_;
open(Z, ">>/tmp/debug.txt");
print Z "output_html: \n";

# FIXME este IF es un parche, ya que a veces (especifico de auth.pl) no recibe el parametro session
	 if ( !(defined($session)) ){
            $session = CGI::Session->new();
print Z "output_html=> creo session\n";
        }

#         printSession($session, 'output_html_with_http_headers: ');
    	# send proper HTTP header with cookies:
#  my $session = CGI::Session->load();
#        	print $session->header();


#    	print $query->header(
#    		-cookie => $query->cookie(),
#        	);

print Z "output_html=> session->sessionID: ".$session->param('sessionID')."\n";
print Z "output_html=> query->sessionID: ".$query->cookie('sessionID')."\n";
print Z "output_html=> cookie: ".$cookie."\n";
print Z "\n";
close Z;
=item
	print $query->header(
				-cookie => $session->param('sessionID'),
			);
=cut
	print $session->header();

	$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";
	exit;
}



# ## FIXME no se va a usar mas con el nuevo Template::Toolkit
# sub get_templateexpr_and_user {
#         my $in = shift;
#         my $template = gettemplateexpr($in->{'template_name'}, $in->{'type'});
#         my ($user, $cookie, $sessionID, $flags)
#                 = checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});
# 
#         my $borrowernumber;
#         if ($user) {
#                 $template->param(loggedinusername => $user);
#                 $template->param(sessionID => $sessionID);
# 
#                 $borrowernumber = getborrowernumber($user);
#                 my ($borr, $flags) = getpatroninformation($borrowernumber,"");
#                 my @bordat;
#                 $bordat[0] = $borr;
# 
#                 $template->param(USER_INFO => \@bordat);
#         }
#         return ($template, $borrowernumber, $cookie);
# }


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


=item
sub checkauth {
	my $query=shift;
        my $authnotrequired = shift;
	my $flagsrequired = shift;
	my $type = shift;

	my $time=localtime(time());

	my $session = CGI::Session->load();# or die CGI::Session->errstr();
# 	my $sessionID = $session->id();
printSession($session, 'checkauth despues del load');

        my $sessionID = $session->param('sessionID');
	my $self_url = $query->url(-absolute => 1);
	$session->param('url', $self_url);



	# $authnotrequired will be set for scripts which will run without authentication
	
	$type = 'opac' unless $type;

	my $dbh = C4::Context->dbh;
	my $timeout = C4::Context->preference('timeout');
	my $dateformat = C4::Date::get_date_format();
	$timeout = 600 unless $timeout;

	#AGREGADO PARA MANDARLE AL USUARIO UN NUMERO RANDOM PARA QUE REALICE UN HASH
	my $random_number= int(rand()*100000);
	$session->param('nroRandom', $random_number);
	$session->param('time', $time);

# 	my $template_name;
	my $url;
	if ($type eq 'opac') {
# 		$template_name = "opac-auth.tmpl";
		$url= "/cgi-bin/opac/auth.pl";
	} else {
# 		$template_name = "auth.tmpl";
		$url= "/cgi-bin/koha/auth.pl";
	}

	# state variables
	my $loggedin = 0;
	my %info;
	my ($userid, $flags);
	my $logout = $query->param('logout.x');

	if ( $sessionID = $session->param('sessionID') ) {
	#Hay una session activa
 		my ($ip , $lasttime);
		($userid, $ip, $lasttime)= _getInfoSession($sessionID);
		$session->param('lasttime', $lasttime);
		$session->param('timeout', $timeout);
		$session->param('ip', $ip);
		if ($logout) {
		# voluntary logout the user
 			_logout_Controller($session);
		}

		if ($userid) {
		#la sesion existia en la bdd, chequeo que no se haya vencido el tiempo
			$loggedin= _loggedin_Controller($session);
 		}
	}#eslif se requiere cookie

	unless ($userid) {
	#si no hay userid, hay que autentificarlo y no existe sesion

print A "checkauth=> Usuario no logueado, intento de autenticacion \n";		
		#No genero un nuevo sessionID, tomo el que viene del cliente
		#con este sessionID puedo recuperar el nroRandom (si existe) guardado en la base, para verificar la password
		my $sessionID= $query->cookie('sessionID');
		$userid=$query->param('userid');
		my $password=$query->param('password');
print A "checkauth=> busco el sessionID: ".$sessionID." de la base \n";
		my $random_number= _getNroRandom($dbh, $sessionID);
print A "checkauth=> random_number desde la base: ".$random_number."\n";


                $session = new CGI::Session();
		$sessionID= $session->id;
		my $self_url = $query->url(-absolute => 1);
		$session->param('url', $self_url);
		#Se guarda la info en la session
		$session->param('userid', $userid);
		$session->param('loggedinusername',$session->param('userid'));
		$session->param('password', $password);
		$session->param('nroRandom', $random_number);
		$session->param('borrowernumber', '0');
		$session->param('type', $type); #OPAC o INTRA
		$session->param('flagsrequired', $flagsrequired);
		$session->param('browser', $ENV{'HTTP_USER_AGENT'});
	
# 		$session->param('locale', 'es_ES');
		#$session->expire('3m');
		$session->expire(0); #para Desarrollar, luego pasar a 3m
		#--------------------------------------------

		# Si se quiere dejar de usar el servidor ldap para hacer la autenticacion debe cambiarse 
		# la llamada a la funcion checkpwldap por checkpw

        	my $sth=$dbh->prepare("select value from systempreferences where variable=?");
        	$sth->execute("ldapenabled");

		my ($return, $cardnumber);
		# El branch lo agregue para que cada usuario maneje la branch por defecto que quiera
		my $branch;
		if ($sth->fetchrow eq 'yes') {
			($return, $cardnumber,$branch) = checkpwldap($dbh,$userid,$password,$random_number);
		} else {
			($return, $cardnumber,$branch) = checkpw($dbh,$userid,$password,$random_number);
		}
		#------------------------------------------------------------------------------
		
		#modifica el session ID
                $sessionID.="_".$branch;
		$session->param('sessionID', $sessionID);
                

		if ($return) {
			$dbh->do("DELETE FROM sist_sesion WHERE sessionID=? AND userid=?",	undef, ($sessionID, $userid));
			_insertSession($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());
			#Logueo una nueva sesion
			_session_log(sprintf "%20s from %16s logged out at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},$time);

			#se verifican los permisos
			if ($flags = haspermission($dbh, $userid, $flagsrequired)) {
				$loggedin = 1;
#WARNING: REVISAR ver si es solo de intranet el usuario q se loguear Cuando pasan dias habiles sin actividad se consideran automaticamente
# feriados
# Miguel- esta consutla no deberia formar parte de una transaccion????
				my $sth=$dbh->prepare("select max(lastlogin) as lastlogin from borrowers");
				$sth->execute();
				my $lastlogin= $sth->fetchrow;
				my $prevWorkDate = C4::Date::format_date_in_iso(Date::Manip::Date_PrevWorkDay("today",1),$dateformat);
				my $enter=0;
				if ($lastlogin){
					while (Date::Manip::Date_Cmp($lastlogin,$prevWorkDate)<0) {
						# lastlogin es anterior a prevWorkDate
						# desde el dia siguiente a lastlogin hasta el dia prevWorkDate no hubo actividad
						$lastlogin= C4::Date::format_date_in_iso(Date::Manip::Date_NextWorkDay($lastlogin,1),$dateformat);
						my $sth=$dbh->prepare("INSERT INTO feriados (fecha) values (?)");
						$sth->execute($lastlogin);
						$enter=1;
					}
					
					#Genera una comprovacion una vez al dia, cuando se loguea el primer usuario
					my $today = C4::Date::format_date_in_iso(Date::Manip::ParseDate("today"),$dateformat);
					if (Date::Manip::Date_Cmp($lastlogin,$today)<0) {
						# lastlogin es anterior a hoy
						# Hoy no se enviaron nunca los mails de recordacion
						open L, ">>/tmp/avisos";
						printf L "Enviar MAIL! \n";
						close L;
						C4::AR::Issues::enviar_recordatorios_prestamos();
					}
	
				}
				if ($enter) {
			#Se actuliza el archivo con los feriados (.DateManip.cfg) solo si se dieron de alta nuevos feriados en el while anterior
					my ($count,@holidays)= C4::AR::Utilidades::getholidays();
					C4::AR::Utilidades::savedatemanip(@holidays);
				}
	#-------------------------------------- SECCION CRITICA	--------------------------------------------------------
				#Se borran las reservas de los usuarios sancionados			
				if ($type eq 'opac') {
	
					t_operacionesDeOPAC($userid);
	
				} else {
					t_operacionesDeINTRA($userid, $cardnumber);

				}
	#--------------------------------------------FIN---- SECCION CRITICA--------------------------------------------
			} else {
				$session->param('nopermission', 1);
				$session->param('codMsg', 'U354');
				redirectTo($url);
				
			}
		} else {
			if ($userid) {
				$session->param('invalid_username_or_password', 1);
				$session->param('codMsg', 'U357');
				redirectTo($url);
			}
		}
	}#end unless ($userid) 
	
        
	my $insecure = C4::Context->boolean_preference('insecure');
	# finished authentification, now respond
	if ($loggedin || $authnotrequired || (defined($insecure) && $insecure)) {
		# Added by Luciano to check if the borrower have to change the password or not
		if (($userid) && (new_password_is_needed($dbh,getborrowernumber($userid)))) {

	 	#se verifica la password ingresada
		my ($passwordValida, $cardnumber, $branch)= _verificarPassword($dbh,$userid,$password,$random_number);

		if ($passwordValida) {
			# Check if the password is repeted
			if (C4::Context->preference("ldapenabled") eq "yes") { # check in ldap
				my $oldpassword= getldappassword($cardnumber,$dbh);
				$passwordrepeted= ($oldpassword eq $newpassword);
			} else { 
			# check in database
				$sth=$dbh->prepare("select password from borrowers where cardnumber=?");
				$sth->execute($cardnumber);
				my $oldpassword= $sth->fetchrow;
				$passwordrepeted= ($oldpassword eq $newpassword);
			}
		  }#end if ($newpassword)

		  if ($newpassword && !$passwordrepeted) {
			# The new password is sent

			if (C4::Context->preference("ldapenabled") eq "yes") { # update the ldap password
				addupdateldapuser($dbh,$cardnumber,$newpassword);
				$sth=$dbh->prepare("update borrowers set lastchangepassword=now() where cardnumber=?");
		                $sth->execute($cardnumber);
			} else { # update the database password
				$sth=$dbh->prepare("update borrowers set password=?, lastchangepassword=now() where cardnumber=?");
		                $sth->execute($newpassword, $cardnumber);
			}

		  } else {
		# The new password is requested
	
# 		   	if ($type eq 'opac') {
#                   	     $template_name = "opac-changepassword.tmpl";
#                   	} else {
#                   	     $template_name = "changepassword.tmpl";
#                   	}

			## FIXME hay q redirigirlo a la ventana para cambiar el password
			$session->param('nroRandom', $random_number);
			redirectTo('/cgi-bin/koha/changepassword.pl');
       			exit;
		  }#END The new password is requested
		}

# successful login
$session->param('REQUEST_URI',$ENV{'REQUEST_URI'});
# printSession($session, 'checkauth: ');

         return ($session);
		
	}
	# else we have a problem...
	# get the inputs from the incoming query
	#Password incorrecta
	$session->param('nroRandom', $random_number);
	$session->param('codMsg', 'U357');
	redirectTo($url);
}
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
	my $timeout = C4::Context->preference('timeout');
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
#  	my $session;
# 	my $session = new CGI::Session();  #recupero la session
 	my $session = CGI::Session->load();
	my ($userid, $cookie, $sessionID, $flags);
	my $logout = $query->param('logout.x')||0;

	if ($userid = $ENV{'REMOTE_USER'}) {
		# Using Basic Authentication, no cookies required
		$cookie= _generarCookie($query,'sessionID', '', '');

		$loggedin = 1;
print A "checkauth=> entro a REMOTE_USER \n";
#    	} elsif ($sessionID=$query->cookie('sessionID')) {
# 	} elsif ($sessionID=$query->cookie('CGISESSID')) {
 	} elsif ($sessionID=$session->param('sessionID')) {
# 	} elsif ($sessionID=$session->param('CGISESSID')) {
print A "checkauth=> sessionID seteado \n";
print A "checkauth=> recupero de la cookie con sessionID (desde query->cookie): ".$query->cookie('sessionID')."\n";
print A "checkauth=> recupero de la cookie con sessionID (desde session->param): ".$session->param('sessionID')."\n";

		my ($ip , $lasttime, $nroRandom, $flag);
		($userid, $ip, $lasttime, $nroRandom, $flag) = $dbh->selectrow_array(
				"SELECT userid,ip,lasttime,nroRandom,flag FROM sist_sesion WHERE sessionid=?", undef, $sessionID);

		if ($logout) {
			#se maneja el logout del usuario
			_logOut_Controller($dbh, $query, $userid, $ip, $sessionID);
			$sessionID = undef;
			$userid = undef;
# 			$session->clear();
# 			$session->delete();
print A "checkauth=> sessionID de CGI-Session: ".$session->id."\n";
#  			_goToLoguin($dbh, $query, $template_name, $userid, $type, \%info, 'U358');
			$session->param('codMsg', 'U358');
 			redirectTo('/cgi-bin/koha/auth.pl');
			#EXIT
		}

		if ($userid) { 
		#la sesion existia en la bdd, chequeo que no se halla vencido el tiempo
		#se verifican algunas condiciones de finalizacion de session
print A "checkauth=> El usuario se encuentra logueado \n";
		  if ($lasttime<time()-$timeout) {
			# timed logout
			$info{'timed_out'} = 1;
			#elimino la session del usuario porque caduco
			_deleteSessionDeUsuario($sessionID, $userid);
print A "checkauth=> caduco la session \n";
			#Logueo la sesion que se termino por timeout
			my $time=localtime(time());
			_session_log(sprintf "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time);
			$userid = undef;
			$sessionID = undef;
			#redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
# 			_goToLoguin($dbh, $query, $template_name, $userid, $type, \%info, 'U355');
			$session->param('codMsg', 'U355');
			redirectTo('/cgi-bin/koha/auth.pl');
			#EXIT

 		     } elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
#  		   } elsif ($ip ne '127.0.0.2') {
			# Different ip than originally logged in from
			$info{'oldip'} = $ip;
			$info{'newip'} = $ENV{'REMOTE_ADDR'};
			$info{'different_ip'} = 1;
			#elimino la session del usuario porque caduco
			_deleteSessionDeUsuario($sessionID, $userid);
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
# 			_goToLoguin($dbh, $query, $template_name, $userid, $type, \%info, 'U356');
			$session->param('codMsg', 'U356');
			redirectTo('/cgi-bin/koha/auth.pl');
			#EXIT
			} elsif ($flag eq 'LOGUIN_DUPLICADO') {
			#Se encuentra una session activa con el mismo userid
			#se eliminan las sessiones, solo se permite una session activa a la vez
			$info{'loguin_duplicado'} = 1;
			#elimino la session del usuario porque caduco
			_deleteSessionDeUsuario($sessionID, $userid);
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
# 			_goToLoguin($dbh, $query, $template_name, $userid, $type, \%info, '');
			$session->param('codMsg', 'U359');
			redirectTo('/cgi-bin/koha/auth.pl');
			#EXIT
			} else {
		
			#esta todo OK, continua logueado y se actualiza la session, lasttime
print A "checkauth=> continua logueado, actualizo lasttime de sessionID: ".$sessionID."\n";
				$dbh->do("UPDATE sist_sesion SET lasttime=? WHERE sessionID=?",
				undef, (time(), $sessionID));
				$flags = haspermission($dbh, $userid, $flagsrequired);
print A "checkauth=> imprimo los flags: \n";
				_printHASH($flags);

				if ($flags) {
					$loggedin = 1;
				} else {
					$info{'nopermission'} = 1;
					#redirecciono a una pagina informando q no tiene  permisos
 					_goToSinPermisos($dbh, $query, $session, $template_name, $userid, $type, \%info);
					$session->param('codMsg', 'U354');
# 					redirectTo('/cgi-bin/koha/auth.pl');
					#EXIT
				}
			}
		  }#if de la sesion que existia en la bdd
		}#end ($sessionID=$query->cookie('sessionID'))


	#por aca se permite llegar a paginas que no necesitan autenticarse
	my $insecure = C4::Context->boolean_preference('insecure');
	# finished authentification, now respond
	if ($loggedin || $authnotrequired || (defined($insecure) && $insecure)) {
print A "checkauth=> if (loggedin || authnotrequired || (defined(insecure) && insecure)) \n";
print A "checkauth=> authnotrequired: ".$authnotrequired."\n";
		#Se verifica si el usuario tiene que cambiar la password
		if ( ($userid) && ( new_password_is_needed($dbh,getborrowernumber($userid)) ) ) {

			_change_Password_Controller($dbh, $query, $userid, $type,\%info);
			#EXIT
		}#end if (($userid) && (new_password_is_needed($dbh,getborrowernumber($userid))))
		
		$cookie= _generarCookie($query,'sessionID', $sessionID, '');	
print A "checkauth=> EXIT => userid: ".$userid." cookie=> sessionID: ".$query->cookie('sessionID')." sessionID: ".$sessionID."\n";
# print A "checkauth=> EXIT => userid: ".$userid." cookie=> sessionID: ".$session->param('sessionID')." sessionID: ".$sessionID."\n";
print A "\n";
close(A);
		return ($userid, $cookie, $session, $flags);
	}#end if ($loggedin || $authnotrequired || (defined($insecure) && $insecure))



	unless ($userid) { 
		#si no hay userid, hay que autentificarlo y no existe sesion
print A "checkauth=> Usuario no logueado, intento de autenticacion \n";		
		#No genero un nuevo sessionID, tomo el que viene del cliente
		#con este sessionID puedo recuperar el nroRandom (si existe) guardado en la base, para verificar la password
#  		my $sessionID= $query->cookie('sessionID');
 		my $sessionID= $session->param('sessionID');
		$userid=$query->param('userid');
		my $password=$query->param('password');
print A "checkauth=> busco el sessionID: ".$sessionID." de la base \n";
		my $random_number= _getNroRandom($dbh, $sessionID);
print A "checkauth=> random_number desde la base: ".$random_number."\n";


		#se verifica la password ingresada
		my ($passwordValida, $cardnumber, $branch)= _verificarPassword($dbh,$userid,$password,$random_number);

		if ($passwordValida) {
			#se valido la password y es valida

			# setea loguins duplicados si existe, dejando logueado a un solo usuario a la vez
			_setLoguinDuplicado($dbh, $userid,  $ENV{'REMOTE_ADDR'});
print A "checkauth=> password valida: ".$sessionID."\n";
print A "checkauth=> elimino el sessionID de la base: ".$sessionID."\n";
			#el usuario se logueo bien, se elimina la session de logueo y se genera un sessionID nuevo
			_deleteSession($sessionID);

			my %params;
			$params{'userid'}= $userid;
			$params{'loggedinusername'}= $userid;
			$params{'password'}= $password;
			$params{'nroRandom'}= $random_number;
			$params{'borrowernumber'}= getborrowernumber($userid);
			$params{'type'}= $type; #OPAC o INTRA
			$params{'flagsrequired'}= $flagsrequired;
			$params{'browser'}= $ENV{'HTTP_USER_AGENT'};
			#genero una nueva session
			$session= _generarSession(\%params);
# 			$sessionID= $session->param('sessionID');
			$sessionID= C4::Auth::_generarSessionID();
# # print A "checkauth=> sessionID de CGI-Session: ".$session->id."\n";
print A "checkauth=> genero un nuevo sessionID ".$sessionID."\n";
			$sessionID.="_".$branch;
			$session->param('sessionID', $sessionID);
			print A "checkauth=> modifico el sessionID: ".$sessionID." \n";
			
			#el usuario se logueo bien, ya no es necessario el nroRandom
			$random_number= 0;
			#guardo la session en la base
			_save_session_db($dbh, $sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

			#Logueo una nueva sesion
			my $time=localtime(time());
			_session_log(sprintf "%20s from %16s logged out at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},$time);

			$cookie= _generarCookie($query,'sessionID', $sessionID, '');	
			$session->header(
				-cookie => $cookie,
			);		
	
			#por defecto no tiene permisos
			$info{'nopermission'} = 1;
			if ($flags = haspermission($dbh, $userid, $flagsrequired)) {
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
						my $sth=$dbh->prepare("INSERT INTO feriados (fecha) VALUES (?)");
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
# 					_operacionesDeOPAC($dbh,$userid);

					t_operacionesDeOPAC($userid);
	
				} else {
					t_operacionesDeINTRA($userid, $cardnumber);

				##Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
# 					_operacionesDeINTRA($dbh, $userid, $cardnumber);
				}# end if ($type eq 'opac')
	
			}# end if ($flags = haspermission($dbh, $userid, $flagsrequired))

		} else {
		#usuario o password invalida
			if ($userid) {
print A "checkauth=> usuario o password incorrecta dentro del if\n";
				$info{'invalid_username_or_password'} = 1;
			}
print A "checkauth=> usuario o password incorrecta \n";
# close(A);
			#elimino la session vieja
			_deleteSession($sessionID);
print A "checkauth=> eliminino la sesssion ".$sessionID."\n";
			$userid= undef;
			#genero una nueva session y redirecciono a auth.tmpl para que se loguee nuevamente
# 			_goToLoguin($dbh, $query, $template_name, $userid, $type, \%info, 'U357');
			$session->param('codMsg', 'U357');
			redirectTo('/cgi-bin/koha/auth.pl');
			#EXIT
		}#end if ($passwordValida)
 
	}# end unless ($userid) 

	$cookie= _generarCookie($query,'sessionID', $sessionID, '');
# print A "checkauth=> 2do EXIT => userid: ".$userid." cookie=> sessionID: ".$query->cookie('sessionID')." sessionID: ".$sessionID."\n";
print A "checkauth=> 2do EXIT => userid: ".$userid." cookie=> sessionID: ".$session->param('sessionID')." sessionID: ".$sessionID."\n";
print A "\n";
close(A);
	return ($userid, $cookie, $session, $flags);

}# end checkauth

=item
Esta funcion guarda una session en la base
=cut
sub _save_session_db{
	my ($dbh, $sessionID, $userid, $remote_addr, $random_number) = @_;

	$dbh->do("INSERT INTO sist_sesion (sessionID, userid, ip,lasttime, nroRandom) VALUES (?, ?, ?, ?, ?)", undef, 
												($sessionID, 
												$userid, $remote_addr, 
												time(), 
												$random_number)
		);

}
=item
Esta funcion recurpera de la base el nroRandom entregado al cliente segun un sessionID
=cut
sub _getNroRandom {
	my ($dbh, $sessionID) = @_;

	my $sth=$dbh->prepare("SELECT nroRandom FROM sist_sesion WHERE sessionID = ?");
        $sth->execute($sessionID);
	my $random_number= $sth->fetchrow;

	return $random_number;
}



=item
Esta funcion modifica el flag de todos las sessiones con usuarios duplicados, seteando el mismo a LOGUIN_DUPLICADO
cuando el usuario remoto con session duplicada intente navegar, sera redireccionado al loguin
=cut
sub _setLoguinDuplicado {
	my ($dbh, $userid, $ip) = @_;

	my $sth=$dbh->prepare("UPDATE sist_sesion  SET flag = 'LOGUIN_DUPLICADO' WHERE userid = ? AND ip <> ? ");
        $sth->execute($userid, $ip);

	my $random_number= $sth->fetchrow;
}

sub _getCardnumber {
	my ($dbh, $userid) = @_;
	
	my $sth=$dbh->prepare("SELECT cardnumber FROM borrowers WHERE borrowernumber = ?");
	$sth->execute(getborrowernumber($userid));
	my $cardnumber= $sth->fetchrow;

	return $cardnumber;
}

=item
Esta funcion se encarga del logout del usuario
=cut
sub _logOut_Controller {
	my ($dbh, $query, $userid, $ip, $sessionID) = @_;
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
	_deleteSessionDeUsuario($sessionID, $userid);

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
	my $cardnumber= _getCardnumber($dbh, $userid);
	my $passwordrepeted= 0;
	
	if ($newpassword) {
	# Check if the password is repeted
		if (C4::Context->preference("ldapenabled") eq "yes") { # check in ldap
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
		if (C4::Context->preference("ldapenabled") eq "yes") { # update the ldap password
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
		my @inputs =();
		foreach my $name (param $query) {
			(next) if ($name eq 'userid' || $name eq 'password' || $name eq 'nroRandom' || $name eq 'newpassword'  || $name eq 'newpassword1' || $name eq 'newpassword2');
			my $value = $query->param($name);
			push @inputs, {name => $name , value => $value};
		}


		my ($template, $t_params) = gettemplate($template_name, $type);
print J "_change_Password_Controller=> template_name: ".$template_name."\n";	
# 		$template->param(passwordrepeted => $passwordrepeted);
		$t_params->{'passwordrepetedv'}= $passwordrepeted;

		#PARA QUE EL USUARIO REALICE UN HASH CON EL NUMERO RANDOM
		my $random_number= _generarNroRandom();
# 		$template->param(RANDOM_NUMBER => $random_number);
		$t_params->{'RANDOM_NUMBER'}= $random_number;
print J "_change_Password_Controller=> genera otro random: ".$random_number."\n";

# 		$template->param(INPUTS => \@inputs);
#  		$template->param(loginprompt => 1) unless $info->{'nopermission'};
		$t_params->{'loginprompt'}= $info->{'nopermission'};

		my $self_url = $query->url(-absolute => 1);
# 		$template->param(url => $self_url);
		$t_params->{'url'}= $self_url;
# 		$template->param($info);
		$t_params->{$info};
	
		my %params;
		$params{'userid'}= $userid;
		$params{'loggedinusername'}= '';
		$params{'password'}= '';
		$params{'nroRandom'}= $random_number;
		$params{'borrowernumber'}=  '';
		$params{'type'}= $type; #OPAC o INTRA
		$params{'flagsrequired'}= '';
		$params{'browser'}= $ENV{'HTTP_USER_AGENT'};
		
		my $session= _generarSession(\%params);
		#se genenra un nuevo sessionID y se guarda en la base junto con el nuevo nroRandom
	#  	my $sessionID= _generarSessionID();
		my $sessionID= $session->param('sessionID');
print J "_change_Password_Controller=> genero cookie:".$sessionID."\n";	
		#guardo la session en la base
		_save_session_db($dbh, $sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);
		my $cookie= _generarCookie($query,'sessionID', $sessionID, '');

# 		print $query->header(
# 					-type => guesstype($template->output),
# 					-cookie => $cookie
# 				), $template->output;
		C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);
print J "\n";
close(J);
		exit;
	
	}#end  if ($newpassword && !$passwordrepeted)
}


sub _printHASH {
	my ($hash_ref) = @_;
open(Z, ">>/tmp/debug.txt");
print Z "\n";
print Z "PRINT HASH: \n";

if($hash_ref){
	while ( my ($key, $value) = each(%$hash_ref) ) {
        	print Z "key: $key => value: $value\n";
    	}
}
print Z "\n";
close(Z);
}

sub _generarNroRandom {
	#PARA QUE EL USUARIO REALICE UN HASH CON EL NUMERO RANDOM
	#Y NO VIAJE LA PASS DEL USUARIO ENCRIPTADA SOLO CON MD5
	my $random_number= int(rand()*100000);

	return $random_number;
}

sub _generarSessionID {
	
	my $time= localtime(time());
	my $sessionID= int(rand()*100000).'-'.time();

	return $sessionID;
}

sub _generarSession {
	my ($params) = @_;

	my $session = new CGI::Session();
#	$sessionID= $session->id;
# 	my $self_url = $query->url(-absolute => 1);
# 	$session->param('url', $self_url);
	#Se guarda la info en la session
	$session->param('userid', $params->{'userid'});
# 	$session->param('sessionID', $sessionID= _generarSessionID());
	$session->param('sessionID', $session->id());
	$session->param('loggedinusername', $params->{'userid'});
	$session->param('password', $params->{'password'});
	$session->param('nroRandom', $params->{'random_number'});
	$session->param('borrowernumber', getborrowernumber($params->{'userid'}));
	$session->param('type', $params->{'type'}); #OPAC o INTRA
	$session->param('flagsrequired', $params->{'flagsrequired'});
	$session->param('browser', $params->{'HTTP_USER_AGENT'});
	$session->param('locale', C4::Context->config("defaultLang")|'es_ES');
	$session->expire(0); #para Desarrollar, luego pasar a 3m

	return $session;
}

sub _goToSinPermisos {
	my ($dbh, $query, $session, $template_name, $userid, $type, $info) = @_;

open(H, ">>/tmp/debug.txt");
print H "\n";
	my ($template, $t_params) = gettemplate($template_name, $type);
	my $sessionID= $query->cookie('sessionID');
print H "_goToSinPermisos=> recupero sessionID: ".$sessionID."\n";
print H "_goToSinPermisos=> template_name: ".$template_name."\n";
	my $cookie= _generarCookie($query,'sessionID', $sessionID, '');
	$t_params->{$info};
  	$t_params->{'loginprompt'}= 1 unless $info->{'nopermission'};
# 	my $self_url = $query->url(-absolute => 1);
# 	$template->param(url => $self_url);

print H "\n";
close(H);

	print $query->header(
				-cookie => $cookie,
		);

	C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);
	exit;
}

sub _goToLoguin {
	my ($dbh, $query, $template_name, $userid, $type, $info, $codMsg) = @_;

open(H, ">>/tmp/debug.txt");
print H "\n";
	my ($template, $t_params) = gettemplate($template_name, $type);
	#se genera un nuevo nroRandom para que se autentique el usuario
	my $random_number= _generarNroRandom();
	
print H "goToLoguin=> random_number: ".$random_number."\n";
	my %params;
	$params{'userid'}= $userid;
	$params{'loggedinusername'}= '';
	$params{'password'}= '';
	$params{'nroRandom'}= $random_number;
	$params{'borrowernumber'}=  '';
	$params{'type'}= $type; #OPAC o INTRA
	$params{'flagsrequired'}= '';
	$params{'browser'}= $ENV{'HTTP_USER_AGENT'};
	#genero una nueva session
	my $session= _generarSession(\%params);
	#se genera una nueva session
#  	my $sessionID= _generarSessionID();
	my $sessionID= $session->param('sessionID');
	$session->param('codMsg', $codMsg);
print H "goToLoguin=> sessionID de CGI-Session: ".$session->id."\n";

print H "goToLoguin=> sessionID: ".$sessionID."\n";
print H "goToLoguin=> template_name: ".$template_name."\n";
	my $cookie= _generarCookie($query,'sessionID', $sessionID, '');
print H "goToLoguin=> cookie: ".$cookie."\n";
	$session->header(
				-cookie => $cookie,
			);
	#guardo la session en la base
	_save_session_db($dbh, $sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number);

	#envio la info necesaria al cliente
# 	$template->param(RANDOM_NUMBER => $random_number);
	$t_params->{'RANDOM_NUMBER'}= $random_number;
	$t_params->{$info};
	$t_params->{'loginprompt'}= $info->{'nopermission'};
	$t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param('codMsg'),$type,[]);
#   	$template->param(loginprompt => 1) unless $info->{'nopermission'};
	my $self_url = $query->url(-absolute => 1);
	$t_params->{'url'}= $self_url;

print H "\n";
close(H);

  	C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);
	exit;
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

	my $sth=$dbh->prepare("SELECT value FROM pref_preferencia_sistema WHERE variable=?");
	$sth->execute("ldapenabled");

	my ($passwordValida, $cardnumber);
	
	my $branch;
	if ($sth->fetchrow eq 'yes') {
	#se esta usando LDAP
		($passwordValida, $cardnumber,$branch) = checkpwldap($dbh,$userid,$password,$random_number);
	} else {
		($passwordValida, $cardnumber,$branch) = checkpw($dbh,$userid,$password,$random_number);
	}
print F "_verificarPassword=> password valida?: ".$passwordValida."\n";
print F "\n";
close (F);
	return ($passwordValida, $cardnumber, $branch);
}


=item
Elimina la session pasada por parametro que se encuentra en la base
=cut
sub _deleteSession {
	my ($sessionID) = @_;
open(D, ">>/tmp/debug.txt");
print D "\n";
print D "_deleteSession=> DELETE SESSION: \n";
	my $dbh = C4::Context->dbh;
	my $sth;
print D "_deleteSession=> elimino el sessionID: ".$sessionID."\n";
	$sth = $dbh->prepare("DELETE FROM sist_sesion WHERE sessionID = ?");
	$sth->execute($sessionID);
print D "\n";
close(D);
}


=item
Elimina todos los userid que se encuentran en sessions, solo se permite un userid activo a la vez
=cut
sub _deleteUsersFromSessions {
	my ($userid) = @_;
open(D, ">>/tmp/debug.txt");
print D "\n";
print D "_deleteUsersFromSessions=> DELETE SESSION: \n";
	my $dbh = C4::Context->dbh;
	my $sth;
print D "_deleteUsersFromSessions=> elimino el sessionID: ".$userid."\n";
	$sth = $dbh->prepare("DELETE FROM sist_sesion WHERE userid = ?");
	$sth->execute($userid);
print D "\n";
close(D);
}

=item
Elimina la session pasada por parametro que se encuentra en la base
=cut
sub _deleteSessionDeUsuario {
	my ($sessionID, $userid) = @_;
open(K, ">>/tmp/debug.txt");
print K "\n";
print K "_deleteSessionDeUsuario=> DELETE SESSION: \n";
	my $dbh = C4::Context->dbh;
	my $sth;
print K "_deleteSessionDeUsuario=> elimino el sessionID: ".$sessionID." del usuario: ".$userid."\n";
	$sth = $dbh->prepare("DELETE FROM sist_sesion WHERE sessionID = ? AND userid=?");
	$sth->execute($sessionID, $userid);
print K "\n";
close(K);
}

=item
Genera la cookie segun los parametros
=cut
sub _generarCookie {
	my ($query, $sessionName, $value, $expires) = @_;
open(G , ">>/tmp/debug.txt");
print G "\n";
print G "_generarCookie=> Genero una Cookie: \n";
	my $cookie= $query->cookie(
					-name => $sessionName,
					-value => $value,
					-expires => $expires
		);
print G "_generarCookie=> cookie: ".$cookie."\n";
print G "\n";
	return $cookie;
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

sub _loggedin_Controller {
	my ($session) = @_;
open (A, ">>/tmp/debug.txt");	
print A "\n";
print A "_loggedin_Controller=> \n";
	my $loggedin;
	$loggedin = 0;
	my $sessionID= $session->id;
	my $url;

	if ($session->param('type') eq 'opac') {
			$url= "/cgi-bin/koha/auth.pl";
		} else {
			$url= "/cgi-bin/koha/auth.pl";
	}
	
	my $dbh = C4::Context->dbh;
		
	if ( $session->param('lasttime') < time() - $session->param('timeout') ) {
		# timed logout
		$session->param('timed_out', 1);
		#elimino la session del usuario porque caduco
		_deleteSessionDeUsuario($sessionID, $session->param('userid'));
print A "_loggedin_Controller=> caduco la session sessionID: ".$sessionID."\n";
		#Logueo la sesion que se termino por timeout
		_session_log(sprintf "%20s from %16s logged out at %30s (inactivity).\n", 
											$session->param('userid'),
											$session->param('ip'),
											$session->param('time')
				);
	
		$session->param('codMsg', 'U355');
		redirectTo($url);
	
	} elsif ($session->param('ip') ne $ENV{'REMOTE_ADDR'}) {
		# Different ip than originally logged in from
		$session->param('oldip', $session->param('ip'));
		$session->param('newip', $ENV{'REMOTE_ADDR'});
		$session->param('different_ip', 1);
		_deleteSessionDeUsuario($sessionID, $session->param('userid'));
print A "_loggedin_Controller=> cambio la IP se elimina la session: ".$sessionID."\n";
				#Logueo la sesion que se cambio la ip
		#Logueo la sesion que se cambio la ip
		_session_log(sprintf "%20s from logged out at %30s (ip changed from %16s to %16s).\n", 
				$session->param('userid'),#hay q loggear undef ???
				$session->param('time'),
				$session->param('ip'),
				$session->param('newip')
			);
		$session->param('codMsg', 'U356');
		redirectTo($url);
	} else {
		#esta todo OK, continua logueado y se actualiza la session, lasttime
print A "_loggedin_Controller=> continua logueado, actualizo lasttime de sessionID: ".$sessionID."\n";
		$dbh->do("UPDATE sist_sesion SET lasttime=? WHERE sessionID=?",undef, (time(), $session->param('sessionID') ));
		my $flags = haspermission($dbh, $session->param('userid'), $session->param('flagsrequired'));
		if ($flags) {
			$loggedin = 1;
		} else {
			$session->param('nopermission', 1);
			$session->param('codMsg', 'U354');
			redirectTo($url);
		}
	}
close(A);	

	return $loggedin;
}

sub _logout_Controller2 {
	my ($session) = @_;
	my ($sessionID, $userid)= _deleteSession( $session->param('sessionID') );
	#Logueo la sesion que se termino voluntariamente
	_session_log(sprintf "%20s from %16s logged out at %30s (manually).\n", 
										$session->param('userid'),
										$session->param('ip'),
										$session->param('time')
			);
	

	$session->clear();
	if ( $session->is_expired ) {
		print A "la session EXPIRO\n";
	}
	
	if ( $session->is_empty ) {
	print A "la session esta EMPTY\n";
	}
	
	#AGREGADO PARA MANDARLE AL USUARIO UN NUMERO RANDOM PARA QUE REALICE UN HASH
	my $random_number= int(rand()*100000);
 	$session->param('nroRandom', $random_number);
	$session->param('codMsg', 'U358');
	redirectTo('/cgi-bin/koha/auth.pl');
}

sub redirectTo {
	my ($url) = @_;

	#para saber si fue un llamado con AJAX
	if($ENV{'HTTP_X_REQUESTED_WITH'} eq 'XMLHttpRequest'){
	#redirijo en el cliente
		
 		
 		my $session = CGI::Session->load();
		$session->clear();
		$session->delete();
		my $session = new CGI::Session();
		# send proper HTTP header with cookies:
    		print $session->header();
		print 'CLIENT_REDIRECT';
		exit;
# 		return ;
	}else{
	#redirijo en el servidor
# 		print ("Location: ".$url."\n\n");
		my $input = CGI->new(); 
		print $input->redirect( 
					-location => $url, 
					-status => 301,
		); 
		exit;
	}
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

	my ($userid) = @_;

	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

	my ($error,$codMsg,$paraMens);
	my $tipo= 'OPAC';

	eval{
		#Si es un usuario de opac que esta sancionado entonces se borran sus reservas
		my ($isSanction,$endDate)= C4::AR::Sanctions::permitionToLoan(getborrowernumber($userid), C4::Context->preference("defaultissuetype"));
		my $regular= &C4::AR::Usuarios::esRegular(getborrowernumber($userid));
				
		if ($isSanction || !$regular ){
			&C4::AR::Reservas::cancelar_reservas($userid,getborrowernumber($userid));
		}
		$dbh->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B408';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R010';
	}
	$dbh->{AutoCommit} = 1;
# 	return($error,$codMsg,$paraMens);
}

sub t_operacionesDeINTRA{

	my ($userid, $cardnumber) = @_;

	my $dbh = C4::Context->dbh;
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

	my ($error,$codMsg,$paraMens);
	my $tipo= 'INTRA';

	eval{
		#Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
		&C4::AR::Reservas::cancelar_reservas(	$userid,
							C4::AR::Sanctions::getBorrowersSanctions($dbh,C4::Context->preference("defaultissuetype"))
						);
		#Ademas, se borran las reservas de los usuarios que no son alumnos regulares
		&C4::AR::Reservas::cancelar_reservas($userid,C4::AR::Reservas::FindNotRegularUsersWithReserves());
		&C4::AR::Reservas::eliminarReservasVencidas($userid);	
		#Si se logueo correctamente en intranet entonces guardo la fecha
		$dbh->do("UPDATE borrowers SET lastlogin=now() WHERE cardnumber = ?", undef, $cardnumber);
		$dbh->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		$codMsg= 'B409';
		C4::AR::Mensajes::printErrorDB($@, $codMsg,$tipo);
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$error= 1;
		$codMsg= 'R010';
	}
	$dbh->{AutoCommit} = 1;
# 	return($error,$codMsg,$paraMens);
}


sub checkpw {

# This should be modified to allow a selection of authentication schemes
# (e.g. LDAP), as well as local authentication through the borrowers
# tables passwd field
#
	#my ($dbh, $userid, $password) = @_;

        my ($dbh, $userid, $password, $random_number) = @_;
	
	my $sth=$dbh->prepare("SELECT password,cardnumber,branchcode FROM borrowers WHERE userid=?");
	$sth->execute($userid);

	if ($sth->rows) {
		my ($md5password,$cardnumber,$branchcode) = $sth->fetchrow;

		if (md5_base64($password) eq $md5password) {
			return 1,$cardnumber,$branchcode;
		}
	}

	my $sth=$dbh->prepare("SELECT password,branchcode,documentnumber FROM borrowers WHERE cardnumber=?");
	$sth->execute($userid);

	if ($sth->rows) {

		my ($md5password,$branchcode,$dni) = $sth->fetchrow;
	
		if ($md5password eq ''){# La 1ra vez esta vacio se usa el dni
			$md5password=md5_base64($dni);
		}
			
		
		if ($password eq md5_base64($md5password.$random_number)) {
			return 1,$userid,$branchcode;
		}
		
		
	}



        my $superpasswd=C4::Context->config('pass');
        my $superbranch=C4::Context->config('branch');
        $superpasswd= md5_base64(md5_base64($superpasswd).$random_number);
        if ($userid eq C4::Context->config('user') && $password eq $superpasswd) {
                # Koha superuser account
                return 2,0,$superbranch;
        }

	if ($userid eq 'demo' && $password eq 'demo' && C4::Context->config('demo')) {
		# DEMO => the demo user is allowed to do everything (if demo set to 1 in koha.conf
		# some features won't be effective : modify systempref, modify MARC structure,
		return 2;
	}

	return 0;
}

sub getuserflags {
    my $cardnumber=shift;
    my $dbh=shift;
    my $userflags;
    my $sth=$dbh->prepare("SELECT flags FROM borrowers WHERE cardnumber=?");
    $sth->execute($cardnumber);
    my ($flags) = $sth->fetchrow;
    $sth=$dbh->prepare("SELECT bit, flag, defaulton FROM usr_permiso");
    $sth->execute;
    while (my ($bit, $flag, $defaulton) = $sth->fetchrow) {
	if (($flags & (2**$bit)) || $defaulton) {
	    $userflags->{$flag}=1;
	}
    }
    return $userflags;
}

sub haspermission {
    my ($dbh, $userid, $flagsrequired) = @_;
    my $sth=$dbh->prepare("SELECT cardnumber FROM borrowers WHERE userid=?");
    $sth->execute($userid);
    my ($cardnumber) = $sth->fetchrow;
    ($cardnumber) || ($cardnumber=$userid);
    my $flags=getuserflags($cardnumber,$dbh);
    my $configfile;
    if ($userid eq C4::Context->config('user')) {
	# Super User Account from /etc/koha.conf
	$flags->{'superlibrarian'}=1;
    }
    if ($userid eq 'demo' && C4::Context->config('demo')) {
	# Demo user that can do "anything" (demo=1 in /etc/koha.conf)
	$flags->{'superlibrarian'}=1;
    }
    return $flags if $flags->{superlibrarian};
    foreach (keys %$flagsrequired) {
	return $flags if $flags->{$_};
    }
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
    my ($dbh,$borrowernumber) = @_;
    my $sth = $dbh->prepare("select lastchangepassword, changepassword from borrowers where borrowernumber=?");
    $sth->execute($borrowernumber);
    my ($data) = $sth->fetchrow_hashref;
    my $days = C4::Context->preference("keeppasswordalive");
    if ($days ne '0') {
	my $err;
	my $date1 = Date::Manip::DateCalc("today","- ".$days." days",\$err);
	my $date2 = Date::Manip::ParseDate($data->{'lastchangepassword'});
	return($data->{'changepassword'} && ((Date::Manip::Date_Cmp($date1,$date2)) > 0));
    } else {
	return($data->{'changepassword'} && !$data->{'lastchangepassword'});
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








