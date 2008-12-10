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
# open(A, ">>/tmp/debug.txt");

	my ($template, $params) = gettemplate($in->{'template_name'}, $in->{'type'});
# 	my ($user, $sessionID, $flags)
# 		= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});
	my ($session)= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});

# print A "desde: get_template_and_user \n";
# print A "Se llamo a checkauth con: \n";
# print A "in-> query: ".$in->{'query'}."\n";
# print A "user: ".$user."\n";
	my $borrowernumber;
	if ( $session->param('userid') ) {
		$params->{'loggedinusername'}= $session->param('userid');
# 		$params->{'sessionID'}= $sessionID;
# 		$params->{'sessionID'}= $session->param('sessionID');
		$borrowernumber = getborrowernumber($session->param('userid'));
		$session->param('borrowernumber',$borrowernumber);
		my ($borr, $flags) = getpatroninformation($borrowernumber,"");
		my @bordat;
		$bordat[0] = $borr;
		$session->param('USER_INFO', \@bordat);	
	}

# print A "get_template_and_user=> imprimo header \n";
	return ($template, $session, $params);
}


sub output_html_with_http_headers {
    	my($query, $template, $params, $session) = @_;
# open(A, ">>/tmp/debug.txt");
# print A "output_html: \n";

# FIXME este IF es un parche, ya que a veces (especifico de auth.pl) no recibe el parametro session
	 if ( !(defined($session)) ){
            $session = CGI::Session->new();
        }

#         printSession($session, 'output_html_with_http_headers: ');
    	# send proper HTTP header with cookies:
    	print $session->header();

# print A "template_name ".$params->{'template_name'}."\n";
# my $key;
# print A "\n";
# print A "SE PARAMS: \n";
#    foreach $key (sort keys(%$params)) {
#       print A "$key = $params->{$key} \n";
#    } 
# print A "\n";

	$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";
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
                $session = new CGI::Session();
		$sessionID= $session->id; #$sessionID=int(rand()*1000000).'-'.time();
		$userid= $query->param('userid');
		my $self_url = $query->url(-absolute => 1);
		$session->param('url', $self_url);
		my $password= $query->param('password');
		my $random_number= $query->param('nroRandom');
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
			$dbh->do("DELETE FROM sessions WHERE sessionID=? AND userid=?",	undef, ($sessionID, $userid));
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

	 	  my $input = new CGI;
		  my $newpassword = $input->param('newpassword') || 0;
	          my $sth=$dbh->prepare("select cardnumber from borrowers where borrowernumber = ?");
        	  $sth->execute(getborrowernumber($userid));
                  my $cardnumber= $sth->fetchrow;
		  my $passwordrepeted= 0;
	
		  if ($newpassword) {
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
printSession($session, 'checkauth: ');


		return ($session);
	}
	# else we have a problem...
	# get the inputs from the incoming query
	#Password incorrecta
	$session->param('nroRandom', $random_number);
	$session->param('codMsg', 'U357');
	redirectTo($url);
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
my $loggedin;
$loggedin = 0;
my $url;
# my $template_name;
if ($session->param('type') eq 'opac') {
# 		$template_name = "opac-auth.tmpl";
		$url= "/cgi-bin/koha/auth.pl";
	} else {
# 		$template_name = "auth.tmpl";
		$url= "/cgi-bin/koha/auth.pl";
}

my $dbh = C4::Context->dbh;
	
if ( $session->param('lasttime') < time() - $session->param('timeout') ) {
	# timed logout
	$session->param('timed_out', 1);
	my ($sessionID, $userid)= _deleteSession( $session->param('sessionID') );
	#Logueo la sesion que se termino por timeout
	_session_log(sprintf "%20s from %16s logged out at %30s (inactivity).\n", 
										$session->param('userid'),#hay q loggear undef ????
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
	my ($sessionID, $userid )= _deleteSession(  $session->param('sessionID') );
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
	$dbh->do("UPDATE sessions SET lasttime=? WHERE sessionID=?",undef, (time(), $session->param('sessionID') ));
	my $flags = haspermission($dbh, $session->param('userid'), $session->param('flagsrequired'));
	if ($flags) {
		$loggedin = 1;
	} else {
		$session->param('nopermission', 1);
		$session->param('codMsg', 'U354');
		redirectTo($url);
	}
  }

  return $loggedin;
}

sub _logout_Controller {
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
		
# 		my $session = new CGI::Session();
		my $session = CGI::Session->load();
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
Elimina la session pasada por parametro que se encuentra en la base
=cut
sub _deleteSession {
	my ($sessionID) = @_;

	my $dbh = C4::Context->dbh;
	my $sth;

	$sth = $dbh->prepare("DELETE FROM sessions WHERE sessionID = ?");
	$sth->execute($sessionID);
	$sessionID = undef;
	my $userid = undef;

	return ($sessionID, $userid);
}

=item
Esta funcion guarda en la base la session 
=cut
sub _insertSession {
	my ($sessionID, $userid, $remote_addr, $time) = @_;

	my $dbh = C4::Context->dbh;
	my $sth;
	$sth = $dbh->prepare("INSERT INTO sessions (sessionID, userid, ip,lasttime) VALUES (?, ?, ?, ?)");
	$sth->execute($sessionID, $userid, $remote_addr, $time);
}

=item
Esta retorna userid,ip,lasttime segun el sessionID
=cut
sub _getInfoSession {
	my ($sessionID) = @_;

	my $dbh = C4::Context->dbh;
	my $sth;
	$sth = $dbh->prepare("SELECT userid,ip,lasttime FROM sessions WHERE sessionid = ?");
 	$sth->execute($sessionID);

# 	my $data= $sth->fetchrow_hashref;
# 
# 	return ($data->{'userid'}, $data->{'ip'}, $data->{'lasttime'});

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
    $sth=$dbh->prepare("SELECT bit, flag, defaulton FROM userflags");
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



























# 
# $s = new CGI::Session( 'driver:mysql', $sid);
# $s = new CGI::Session( 'driver:mysql', $sid, {  DataSource  => 'dbi:mysql:test',
# 						User        => 'sherzodr',
# 						Password    => 'hello',
# 						TableName=>'session',
# 						IdColName=>'my_id',
# 						DataColName=>'my_data',
# 						DataSource=>'dbi:mysql:project',
# 						Handle=>$dbh,
#         					});
# $s = new CGI::Session( 'driver:mysql', $sid, { Handle => $dbh } );







