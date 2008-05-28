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
             &get_template_and_user
	     &get_templateexpr_and_user
             &getborrowernumber
	     &getuserflags
);


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
	my $template = gettemplate($in->{'template_name'}, $in->{'type'});
	my ($user, $cookie, $sessionID, $flags)
		= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});

	my $borrowernumber;
	if ($user) {
		$template->param(loggedinusername => $user);
		$template->param(sessionID => $sessionID);
		$borrowernumber = getborrowernumber($user);
		my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
		my @bordat;
		$bordat[0] = $borr;
		$template->param(USER_INFO => \@bordat);
	}
	return ($template, $borrowernumber, $cookie);
}

sub get_templateexpr_and_user {
        my $in = shift;
        my $template = gettemplateexpr($in->{'template_name'}, $in->{'type'});
        my ($user, $cookie, $sessionID, $flags)
                = checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});

        my $borrowernumber;
        if ($user) {
                $template->param(loggedinusername => $user);
                $template->param(sessionID => $sessionID);

                $borrowernumber = getborrowernumber($user);
                my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
                my @bordat;
                $bordat[0] = $borr;

                $template->param(USER_INFO => \@bordat);
        }
        return ($template, $borrowernumber, $cookie);
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

	my $dbh = C4::Context->dbh;
	my $timeout = C4::Context->preference('timeout');
	my $dateformat = C4::Date::get_date_format();
	$timeout = 600 unless $timeout;

	my $template_name;
	if ($type eq 'opac') {
		$template_name = "opac-auth.tmpl";
	} else {
		$template_name = "auth.tmpl";
	}

	# state variables
	my $loggedin = 0;
	my %info;
	my ($userid, $cookie, $sessionID, $flags);
	my $logout = $query->param('logout.x');
	if ($userid = $ENV{'REMOTE_USER'}) {
		# Using Basic Authentication, no cookies required
		$cookie=$query->cookie(-name => 'sessionID',
				-value => '',
				-expires => '');
		$loggedin = 1;
	} elsif ($sessionID=$query->cookie('sessionID')) {
		my ($ip , $lasttime);
		($userid, $ip, $lasttime) = $dbh->selectrow_array(
				"SELECT userid,ip,lasttime FROM sessions WHERE sessionid=?",
								undef, $sessionID);
		if ($logout) {
		# voluntary logout the user
		$dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
		$sessionID = undef;
		$userid = undef;
		#Logueo la sesion que se termino voluntariamente
		open L, ">>/tmp/sessionlog";
		my $time=localtime(time());
		printf L "%20s from %16s logged out at %30s (manually).\n", $userid, $ip, $time;
		close L;
		
		}
		if ($userid) { #la sesion existia en la bdd, chequeo que no se halla vencido el tiempo
		  if ($lasttime<time()-$timeout) {
			# timed logout
			$info{'timed_out'} = 1;
			$dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
			$userid = undef;
			$sessionID = undef;
			#Logueo la sesion que se termino por timeout
			open L, ">>/tmp/sessionlog";
			my $time=localtime(time());
			printf L "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time;
			close L;
		     } elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
			# Different ip than originally logged in from
			$info{'oldip'} = $ip;
			$info{'newip'} = $ENV{'REMOTE_ADDR'};
			$info{'different_ip'} = 1;
			$dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
			$sessionID = undef;
			$userid = undef;
			#Logueo la sesion que se cambio la ip
			open L, ">>/tmp/sessionlog";
			my $time=localtime(time());
			printf L "%20s from logged out at %30s (ip changed from %16s to %16s).\n", $userid, $time, $ip, $info{'newip'};
			close L;
		     					} else {
								$cookie=$query->cookie(-name => 'sessionID',
											-value => $sessionID,
											-expires => '');
								$dbh->do("UPDATE sessions SET lasttime=? WHERE sessionID=?",
								undef, (time(), $sessionID));
								$flags = haspermission($dbh, $userid, $flagsrequired);
								if ($flags) {
										$loggedin = 1;
									    } else {
										$info{'nopermission'} = 1;
									    }
								}
			  }#if de la sesion que existia en la bdd
		}#eslif se requiere cookie
	unless ($userid) { #si no hay userid, hay que autentificarlo y no existe sesion
		$sessionID=int(rand()*100000).'-'.time();
		$userid=$query->param('userid');
		my $password=$query->param('password');
		#AGREGADO PARA HACER EL HASH DE LA PASSWORD
		my $random_number=$query->param('nroRandom');
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

                $sessionID.="_".$branch;
		if ($return) {
		$dbh->do("DELETE FROM sessions WHERE sessionID=? AND userid=?",
			undef, ($sessionID, $userid));
		$dbh->do("INSERT INTO sessions (sessionID, userid, ip,lasttime) VALUES (?, ?, ?, ?)",
			undef, ($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time()));
		#Logueo una nueva sesion
		open L, ">>/tmp/sessionlog";
		my $time=localtime(time());
		printf L "%20s from %16s logged in  at %30s.\n", $userid, $ENV{'REMOTE_ADDR'}, $time;
		close L;
		$cookie=$query->cookie(-name => 'sessionID',
					-value => $sessionID,
					-expires => '');
		if ($flags = haspermission($dbh, $userid, $flagsrequired)) {
			$loggedin = 1;
			#WARNING: Cuando pasan dias habiles sin actividad se consideran automaticamente feriados
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
				my $sth=$dbh->prepare("insert into feriados (fecha) values (?)");
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
				&C4::AR::Issues::enviar_recordatorios_prestamos();
			}

			}
			if ($enter) {
				#Se actuliza el archivo con los feriados (.DateManip.cfg) solo si se dieron de alta nuevos feriados en el while anterior
				my ($count,@holidays)= C4::AR::Utilidades::getholidays();
				C4::AR::Utilidades::savedatemanip(@holidays);
			}
			
			#Se borran las reservas de los usuarios sancionados			
			if ($type eq 'opac') {
				#Si es un usuario de opac que esta sancionado entonces se borran sus reservas
				my ($isSanction,$endDate)= C4::AR::Sanctions::permitionToLoan(getborrowernumber($userid), C4::Context->preference("defaultissuetype"));
				my $regular= &C4::AR::Usuarios::esRegular(getborrowernumber($userid));
				
				if ($isSanction || !$regular ){
				&C4::AR::Reserves::cancelar_reservas($userid,getborrowernumber($userid));
				}
			} else {
				#Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
				&C4::AR::Reserves::cancelar_reservas($userid,C4::AR::Sanctions::getBorrowersSanctions($dbh, C4::Context->preference("defaultissuetype")));
				#Ademas, se borran las reservas de los usuarios que no son alumnos regulares
				&C4::AR::Reserves::cancelar_reservas($userid,C4::AR::Reserves::FindNotRegularUsersWithReserves());
				&C4::AR::Reserves::eliminarReservasVencidas($userid);	
				#Si se logueo correctamente en intranet entonces guardo la fecha
				$dbh->do("update borrowers set lastlogin=now() where cardnumber = ?", undef, $cardnumber);
			}

		} else {
			$info{'nopermission'} = 1;
		}
		} else {
		if ($userid) {
			$info{'invalid_username_or_password'} = 1;
		}
		}
	}
	
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
		    } else { # check in database
			$sth=$dbh->prepare("select password from borrowers where cardnumber=?");
		        $sth->execute($cardnumber);
		        my $oldpassword= $sth->fetchrow;
			$passwordrepeted= ($oldpassword eq $newpassword);
		    }
		  }

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
	
		   	if ($type eq 'opac') {
                  	     $template_name = "opac-changepassword.tmpl";
                  	} else {
                  	     $template_name = "changepassword.tmpl";
                  	}

			my @inputs =();
			foreach my $name (param $query) {
                		(next) if ($name eq 'userid' || $name eq 'password' || $name eq 'nroRandom' || $name eq 'newpassword'  || $name eq 'newpassword1' || $name eq 'newpassword2');
                		my $value = $query->param($name);
                		push @inputs, {name => $name , value => $value};
        		}

        		my $template = gettemplate($template_name, $type);

		        $template->param(passwordrepeted => $passwordrepeted);

        		#AGREGADO PARA MANDARLE AL USUARIO UN NUMERO RANDOM PARA QUE REALICE UN HASH
        		my $random_number= int(rand()*100000);
        		$template->param(RANDOM_NUMBER => $random_number);
        		#---------------------------------------------------------------------------

		        $template->param(INPUTS => \@inputs);
       			$template->param(loginprompt => 1) unless $info{'nopermission'};

		        my $self_url = $query->url(-absolute => 1);
		        $template->param(url => $self_url);
		        $template->param(\%info);
		        $cookie=$query->cookie(-name => 'sessionID',
                                        -value => $sessionID,
                                        -expires => '');

		        print $query->header(
               			 -type => guesstype($template->output),
               			 -cookie => $cookie
               			 ), $template->output;
       			 exit;
		  }
		}
		# Added by Luciano

		# successful login
		unless ($cookie) {
		$cookie=$query->cookie(-name => 'sessionID',
					-value => '',
					-expires => '');
		}
		return ($userid, $cookie, $sessionID, $flags);
	}
	# else we have a problem...
	# get the inputs from the incoming query
	my @inputs =();
	foreach my $name (param $query) {
		(next) if ($name eq 'userid' || $name eq 'password' || $name eq 'nroRandom' || $name eq 'newpassword' || $name eq 'newpassword1' || $name eq 'newpassword2');
		my $value = $query->param($name);
		push @inputs, {name => $name , value => $value};
	}

	my $template = gettemplate($template_name, $type);

	#AGREGADO PARA MANDARLE AL USUARIO UN NUMERO RANDOM PARA QUE REALICE UN HASH
	my $random_number= int(rand()*100000);
	$template->param(RANDOM_NUMBER => $random_number);
	#---------------------------------------------------------------------------

	$template->param(INPUTS => \@inputs);
	$template->param(loginprompt => 1) unless $info{'nopermission'};

	my $self_url = $query->url(-absolute => 1);
	$template->param(url => $self_url);
	$template->param(\%info);
	$cookie=$query->cookie(-name => 'sessionID',
					-value => $sessionID,
					-expires => '');

	print $query->header(
		-type => guesstype($template->output),
		-cookie => $cookie
		), $template->output;
	exit;
}



sub checkpw {

# This should be modified to allow a selection of authentication schemes
# (e.g. LDAP), as well as local authentication through the borrowers
# tables passwd field
#
	#my ($dbh, $userid, $password) = @_;

        my ($dbh, $userid, $password, $random_number) = @_;
	
	my $sth=$dbh->prepare("select password,cardnumber,branchcode from borrowers where userid=?");
	$sth->execute($userid);
	if ($sth->rows) {
		my ($md5password,$cardnumber,$branchcode) = $sth->fetchrow;

		if (md5_base64($password) eq $md5password) {
			return 1,$cardnumber,$branchcode;
		}
	}
	my $sth=$dbh->prepare("select password,branchcode,documentnumber from borrowers where cardnumber=?");
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
