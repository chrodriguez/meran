package C4::Auth;


=head1 NAME

C4::Auth 

=head1 SYNOPSIS

  use C4::Auth;

=head1 DESCRIPTION

  Descripción del modulo COMPLETAR

=head1 FUNCTIONS

=over 2

=cut



use strict;
use warnings;

require Exporter;
use C4::AR::Authldap;
use C4::Membersldap;
use C4::Context;
use C4::Output;              # to get the template
use C4::Interface::CGI::Output;
use C4::Circulation::Circ2;  # getpatroninformation
use C4::AR::Usuarios; #Miguel lo agregue pq sino no ve la funcion esRegular!!!!!!!!!!!!!!!
use C4::AR::Prestamos;
use CGI::Session qw/-ip-match/;
use C4::Modelo::SistSesion;
use C4::Modelo::SistSesion::Manager;
use JSON;
use Digest::MD5 qw(md5_base64);
use Digest::SHA  qw(sha1 sha1_hex sha1_base64 sha256_base64 );

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
my $codMSG = 'U000';
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
        &getSessionNroSocio
		&_generarNroRandom
        &redirectAndAdvice
        &_hashear_password
		
);

=item sub getSessionLoggedUser

    obtiene el nro_socio de la session
    Parametros: 
    $session

=cut
sub getSessionLoggedUser {
	my ($session) = @_;

	return $session->param('nro_socio');
}

=item sub getSessionUserID

    obtiene el userid de la session
    Parametros: 
    $session

=cut
# FIXME creo q esta deprecated
sub getSessionUserID {
	my ($session) = @_;

    unless($session){
        $session = CGI::Session->load();
    }

    return $session->param('userid');
}

sub _setLocale{

  my ($session) = @_;
  unless($session){
      $session = CGI::Session->load();
  }

  #PARA SACAR EL LOCALE ELEGIDO POR EL SOCIO
  $session->param('usr_locale', getUserLocale());
  $session->save_param();
}


sub getUserLocale{
    my $session = CGI::Session->load();
    my $locale;

    if ($session){
        $locale = $session->param('usr_locale');
        #C4::AR::Debug::debug("Auth => obtengo locale de la session => ".$locale);
    } else {
        $locale = C4::Context->config("defaultLang") || 'es_ES';
        #C4::AR::Debug::debug("Auth => NO obtengo locale de la session => ".$locale);
    }

    return $locale;
}
=item sub getSessionIdSocio

    obtiene el id_socio de la session
    Parametros: 
    $session

=cut
sub getSessionIdSocio {
    my ($session) = @_;

    return $session->param('id_socio');
}

=item sub getSessionNroSocio

    obtiene el nro_socio de la session
    Parametros: 
    $session

=cut
sub getSessionNroSocio {
#     my ($session) = @_;
#     if (!$session){
#       $session = CGI::Session ();
#     }
    my $session= CGI::Session->load();
#     C4::AR::Debug::debug("getSessionNroSocio=> ".$session->param('nro_socio'));

    return $session->param('nro_socio');
}


sub getSessionPassword {
	my ($session) = @_;

	return $session->param('password');
}

sub getSessionNroRandom {
	my ($session) = @_;

	return $session->param('nroRandom');
}

# FXIME DEPRECATED
sub getSessionBorrowerNumber {
	my ($session) = @_;

	return $session->param('borrowernumber');
}

sub getSessionFlagsRequired {
	my ($session) = @_;

	return $session->param('flagsrequired');
}

sub getSistSession{

    my ($sessionID) = @_;
    my @filtros;

    push(@filtros,(sessionID => {eq => $sessionID}) );

    my $session = C4::Modelo::SistSesion::Manager->get_sist_sesion(query => \@filtros,);

    if (scalar(@$session)){
        return($session->[0]);
    }else{
        return(0);
    }
}
=item sub getSessionBrowser

    obtiene el browser de la session que el usuario esta usando
    Parametros: 
    $session

=cut
sub getSessionBrowser {
	my ($session) = @_;

	return $session->param('browser');
}


=item get_template_and_userF

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
	my ($user, $session, $flags, $socio) = checkauth(       $in->{'query'}, 
                                                            $in->{'authnotrequired'}, 
                                                            $in->{'flagsrequired'}, 
                                                            $in->{'type'}, 
                                                            $in->{'changepassword'},
                                                            $in->{'template_params'}
                                            );
	my $nro_socio;
    my ($template, $params)     = C4::Output::gettemplate($in->{'template_name'}, $in->{'type'}, $in->{'loging_out'}, $socio);

    $in->{'template_params'}    = $params;

	if ( $session->param('userid') ) {
        $params->{'loggedinuser'}       = $session->param('userid');
        $params->{'nro_socio'}          = $session->param('userid');

        if (!$socio) {
            $socio = C4::Modelo::UsrSocio->new();
        }

#         $session->param('nro_socio',$nro_socio);
# TODO pasar a una funcion
        my %socio_data;
        $socio_data{'usr_apellido'}             = $session->param('usr_apellido');
        $socio_data{'usr_nombre'}               = $session->param('usr_nombre');
        $socio_data{'usr_tiene_foto'}           = $session->param('usr_tiene_foto');
        $socio_data{'usr_nro_socio'}            = $session->param('nro_socio');
        $socio_data{'usr_documento_nombre'}     = $session->param('usr_documento_nombre');
        $socio_data{'usr_documento_version'}    = $session->param('usr_documento_version');
        $socio_data{'usr_nro_documento'}        = $session->param('usr_nro_documento');
        $socio_data{'usr_calle'}                = $session->param('usr_calle');
        $socio_data{'usr_ciudad_nombre'}        = $session->param('usr_ciudad_nombre');
        $socio_data{'usr_categoria_desc'}       = $session->param('usr_categoria_desc');
        $socio_data{'usr_fecha_nac'}            = $session->param('usr_fecha_nac');
        $socio_data{'usr_sexo'}                 = $session->param('usr_sexo');
        $socio_data{'usr_telefono'}             = $session->param('usr_telefono');
        $socio_data{'usr_alt_telefono'}         = $session->param('usr_alt_telefono');
        $socio_data{'usr_email'}                = $session->param('usr_email');
        $socio_data{'usr_legajo'}               = $session->param('usr_legajo');
        

        $params->{'socio_data'}         = \%socio_data;
		$params->{'token'}              = $session->param('token');
		#para mostrar o no algun submenu del menu principal
 		$params->{'menu_preferences'}   = C4::AR::Preferencias::getMenuPreferences();
	}

    #se cargan todas las variables de entorno de las preferencias del sistema
    $params->{'limite_resultados_autocompletables'} = C4::AR::Preferencias->getValorPreferencia("limite_resultados_autocompletables");

	return ($template, $session, $params, $socio);
}


=item sub output_html_with_http_headers

    imprime el header y procesa el template
    Parametros: 
    $template: template que se creo anteriomente
    $params: parametros para el template
    $session: sesion acutal

=cut
sub output_html_with_http_headers {
    my($template, $params, $session) = @_;

    _setLocale($session);
    print_header($session, $params);

	$template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";
	exit;
}


sub print_header {
    my($session, $template_params) = @_;
    use CGI::Cookie;

    my $query = new CGI;
    my $cookie = undef;
    my $secure;

    if(is_OPAC($template_params)){
#         C4::AR::Debug::debug("is_OPAC => REQUERIMIENTO DESDE OPAC");
        #si la conexion no es segura no se envía la cookie, en el OPAC la conexion no es segura
        $secure = 0;
    }else{
#         C4::AR::Debug::debug("is_OPAC => REQUERIMIENTO DESDE INTRANET");
        $secure = 1;
    }


    $cookie = new CGI::Cookie(  
                                -secure     => $secure, 
                                -httponly   => 1, 
                                -name       =>$session->name, 
                                -value      =>$session->id, 
                                -expires    => '+' .$session->expire. 's', 
                            );


    print $query->header(-cookie=>$cookie, -type=>'text/html', charset => C4::Context->config("charset")||'UTF-8', "Cache-control: public");
}

=item sub is_OPAC

    Indica si es un requerimiento desde el OPAC o desde la INTRA
    Parametros: 
    $template: template que se creo anteriomente

=cut
sub is_OPAC {
    my($template_params) = @_;

    $template_params->{'type'} = $template_params->{'type'} || 'opac';

    return (($template_params->{'type'} eq 'opac')?1:0);
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

sub _destruirSession{
    
    my ($codMsg,$template_params) = @_;

    $codMsg = $codMsg || 'U406';
#     $url = $url || '/cgi-bin/koha/auth.pl';

    my ($session) = CGI::Session->load();
    $codMSG = $codMsg;
    $session->expire('-1');
    $session->delete();
    $session->flush();
    $session = C4::Auth::_generarSession();
    $session->param('sessionID', undef);
    #redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
    $session->param('codMsg', $codMsg);
#     $session->param('redirectTo', $url);

    C4::AR::Debug::debug("WARNING: ¡¡¡¡Se destruye la session y la cookie!!!!!");

#     redirectTo($url);        
    redirectToAuth($template_params)

}


#checkauth RECORTADO
sub checkauth {
C4::AR::Debug::debug("desde checkauth==================================================================================================");    
    my $query               = shift;
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired     = shift;
    my $flagsrequired       = shift;
    my $type                = shift;
    my $change_password     = shift || 0;
    my $template_params     = shift;
    my $dbh                 = C4::Context->dbh;
    my $socio;
	my $token;
    $type                   = 'opac' unless $type;

	if(defined($ENV{'HTTP_X_REQUESTED_WITH'}) && ($ENV{'HTTP_X_REQUESTED_WITH'} eq 'XMLHttpRequest')){
		my $obj = $query->param('obj');

		if ( defined($obj) ){
			$obj=C4::AR::Utilidades::from_json_ISO($obj);
            #ESTO ES PARA LAS LLAMADAS AJAX QUE PASSAN UN OBJETO JSON (HELPER DE AJAX)
		    $token = $obj->{'token'};
            C4::AR::Debug::debug("checkauth=> Token desde AjaxHelper: ".$token);
        }else{
            #ESTO ES PARA LAS LLAMADAS AJAX TRADICIONALES (PARAMETROS POR URL)
            $token = $query->param('token');
            C4::AR::Debug::debug("checkauth=> Token desde Ajax comun: ".$token);
        }
	}else{
		$token = $query->param('token');
        C4::AR::Debug::debug("checkauth=> Token desde GET: ".$token);
	}

    # state variables
    my $loggedin = 0;
    my %info;
    my ($session) = CGI::Session->load();
    my ($userid, $cookie, $sessionID, $flags);

    # C4::AR::Debug::debug("DUMP checkauth => ".$session->dump());

    if(defined $session and _session_expired($session)){
    #EXPIRO LA SESION
        $session->param('codMsg', 'U355');
        $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
        redirectTo('/cgi-bin/koha/auth.pl');
    }else{
    #NO EXPIRO LA SESION
        $sessionID = $session->param('sessionID');

        C4::AR::Debug::debug("checkauth=> sessionID seteado \n".$sessionID);

        my ($ip , $lasttime, $nroRandom, $flag, $tokenDB);

        $userid     = $session->param('userid');
        $ip         = $session->param('ip');
        $lasttime   = $session->param('lasttime');
        $nroRandom  = $session->param('nroRandom');
        $tokenDB    = $session->param('token');
        $flag       = $session->param('flagsrequired');


        if ($userid) {

            $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);

            #la sesion existia en la bdd, chequeo que no se halla vencido el tiempo
            #se verifican algunas condiciones de finalizacion de session
            C4::AR::Debug::debug("checkauth=> El usuario se encuentra logueado");
#           if ($lasttime<time()-$timeout) {      
            if ($lasttime < time() - _getTimeOut()) {

                # timed logout
                $info{'timed_out'} = 1;
                #elimino la session del usuario porque caduco
                _destruirSession('U406', $template_params);
                C4::AR::Debug::debug("checkauth=> caduco la session \n");
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
# TODO ver esta mierda del TOKEN
# #             }elsif ($tokenDB ne $token){
#                 C4::AR::Debug::debug("Token <> o no existe, posible CSRF");
#                 C4::AR::Debug::debug("tokenDB: ".$tokenDB);
#                 C4::AR::Debug::debug("query->param('token'): ".$query->param('token'));
# 			    $session->param('codMsg', 'U354');
# 			    $session->param('redirectTo', '/cgi-bin/koha/informacion.pl');
# 			    redirectTo('/cgi-bin/koha/informacion.pl');
# 			    #EXIT
            } elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
#                 $session->_ip_matches probar
    #              } elsif ($ip ne '127.0.0.2') {
                # Different ip than originally logged in from
                $info{'oldip'} = $ip;
                $info{'newip'} = $ENV{'REMOTE_ADDR'};
                $info{'different_ip'} = 1;
                #elimino la session del usuario porque caduco
                _destruirSession('U406', $template_params);
                C4::AR::Debug::debug("checkauth=> cambio la IP, se elimina la session\n");
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
                _destruirSession('U406', $template_params);
                C4::AR::Debug::debug("checkauth=> se loguearon con el mismo userid desde otro lado\n");
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
                C4::AR::Debug::debug("checkauth=> continua logueado, actualizo lasttime de sessionID: ".$sessionID."\n");

                $session->param('lasttime', time());

#                 TODO ver si se pueden guardar los permisos en la sesion para evitar cargar el socio mas arriba
                $flags = $socio->tienePermisos($flagsrequired);

                if ($flags) {
                    $loggedin = 1;
                    C4::AR::Debug::debug("checkauth=> TIENE PERMISOS: \n");
                } else {
                    $info{'nopermission'} = 1;
                    C4::AR::Debug::debug("checkauth=> NO TIENE PERMISOS: \n");
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
        C4::AR::Debug::debug("checkauth=> if (loggedin || authnotrequired || (defined(insecure) && insecure)) \n");
        #Se verifica si el usuario tiene que cambiar la password
        if ( ($userid) && ( new_password_is_needed($userid, $socio) ) && !$change_password ) {

            C4::AR::Debug::debug("checkauth=> redirectTo desde el servidor \n");
             _change_Password_Controller($dbh, $query, $userid, $type,\%info, $token);
            #EXIT
        }#end if (($userid) && (new_password_is_needed($userid)))

        C4::AR::Debug::debug("checkauth=> EXIT => userid: ".$userid." sessionID: ".$sessionID."\n");
        return ($userid, $session, $flags, $socio);
    }#end if ($loggedin || $authnotrequired || (defined($insecure) && $insecure))



    unless ($userid) { 
        #si no hay userid, hay que autentificarlo y no existe sesion
        C4::AR::Debug::debug("checkauth=> Usuario no logueado, intento de autenticacion \n");     
        #No genero un nuevo sessionID
        #con este sessionID puedo recuperar el nroRandom (si existe) guardado en la base, para verificar la password
        my $sessionID       = $session->param('sessionID');
        #recupero el userid y la password desde el cliente
        $userid             = $query->param('userid');
        my $password        = $query->param('password');
        my $random_number   = $session->param('nroRandom');
        C4::AR::Debug::debug("checkauth=> random_number desde la session: ".$random_number);
        #se verifica la password ingresada
        my ($passwordValida, $cardnumber, $branch) = _verificarPassword($dbh,$userid,$password,$random_number);
        if ($passwordValida) {
           #se valido la password y es valida
           # setea loguins duplicados si existe, dejando logueado a un solo usuario a la vez
            _setLoguinDuplicado($userid,  $ENV{'REMOTE_ADDR'});
            C4::AR::Debug::debug("checkauth=> password valida");

            $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);

# TODO todo esto va en una funcion
            $sessionID  = $session->param('sessionID');
            $sessionID.="_".$branch;
            $session->param('sessionID', $sessionID);
            $session->param('userid', $userid);
            $session->param('nro_socio', $socio->getNro_socio());
            $session->param('loggedinusername', $userid);
            $session->param('ip', $ENV{'REMOTE_ADDR'});
            $session->param('lasttime', time());
            $session->param('nroRandom', '');
            $session->param('type', $type); #OPAC o INTRA
            $session->param('secure', ($type eq 'intranet')?1:0); #OPAC o INTRA
            $session->param('flagsrequired', $flagsrequired);
            $session->param('browser', $ENV{'HTTP_USER_AGENT'} );
            $session->param('charset', C4::Context->config("charset")||'utf-8'); #se guarda el juego de caracteres
            $session->param('token', _generarToken()); #se guarda el token
            $session->param('SERVER_GENERATED_SID', 1);
            $session->param('urs_theme', $socio->getTheme());
            $session->param('usr_theme_intra', $socio->getThemeINTRA());
            $session->param('usr_locale', $socio->getLocale());
            $session->param('usr_apellido', $socio->persona->getApellido());
            $session->param('usr_nombre', $socio->persona->getNombre());
            $session->param('usr_tiene_foto', $socio->tieneFoto());
            $session->param('usr_documento_nombre', $socio->persona->documento->nombre());
            $session->param('usr_documento_version', $socio->persona->getVersion_documento());
            $session->param('usr_nro_documento', $socio->persona->getNro_documento());
            $session->param('usr_calle', $socio->persona->getCalle());
            $session->param('usr_ciudad_nombre', $socio->persona->ciudad_ref->getNombre());
            $session->param('usr_categoria_desc', $socio->categoria->getDescription());
            $session->param('usr_fecha_nac', $socio->persona->getNacimiento());
            $session->param('usr_sexo', $socio->persona->getSexo());
            $session->param('usr_telefono', $socio->persona->getTelefono());
            $session->param('usr_alt_telefono', $socio->persona->getAlt_telefono());
            $session->param('usr_email', $socio->persona->getEmail());
            $session->param('usr_legajo', $socio->persona->getLegajo());
            $session->param('usr_credential_type', $socio->getCredentialType());

            #Si se logueo correctamente en intranet entonces guardo la fecha
            my $today = Date::Manip::ParseDate("today");
            $socio->setLast_login($today);
            $socio->save();

            #Logueo una nueva sesion
            my $time = localtime(time());
            _session_log(sprintf "%20s from %16s logged out at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},$time);
    
            #por defecto no tiene permisos
            $info{'nopermission'} = 1;
            if( $flags = $socio->tienePermisos($flagsrequired) ){
                C4::AR::Debug::debug("checkauth=> tiene permisos!!!!!!!!LAST LOGUIN");
                $info{'nopermission'} = 0;
                $loggedin = 1;
                #WARNING: Cuando pasan dias habiles sin actividad se consideran automaticamente feriados
                my $sth=$dbh->prepare("SELECT MAX(last_login) AS lastlogin FROM usr_socio");
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
#                         _realizarOperaciones({ type => $type , socio => $socio });
                        if ($type eq 'intranet') {
                        ##Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
                            C4::AR::Debug::debug("_realizarOperaciones=> t_operacionesDeINTRA\n");
                            t_operacionesDeINTRA($socio);
                        }# end if ($type eq 'intra')
                    }
                }#end if ($lastlogin)

                if ($enter) {
                #Se actuliza el archivo con los feriados (.DateManip.cfg) solo si se dieron de alta nuevos feriados en 
                #el while anterior
                    my ($count,@holidays)= C4::AR::Utilidades::getholidays();
                    C4::AR::Utilidades::savedatemanip(@holidays);
                }

                if ($type eq 'opac') {
                    #Si es un usuario de opac que esta sancionado entonces se borran sus reservas
                    C4::AR::Debug::debug("_realizarOperaciones=> t_operacionesDeOPAC\n");
                    t_operacionesDeOPAC($socio);
                } 
    
            }# end if ($flags = haspermission($dbh, $userid, $flagsrequired))

            if ($type eq 'opac') {
                $session->param('redirectTo', '/cgi-bin/koha/opac-main.pl?token='.$session->param('token'));
#                 redirectTo('/cgi-bin/koha/opac-user.pl?token='.$params{'token'});
                redirectToNoHTTPS('/cgi-bin/koha/opac-main.pl?token='.$session->param('token'));
                $session->secure(0);
            }else{
                C4::AR::Debug::debug("DESDE Auth, redirect al MAIN");
                $session->param('redirectTo', '/cgi-bin/koha/mainpage.pl?token='.$session->param('token'));
                redirectTo('/cgi-bin/koha/mainpage.pl?token='.$session->param('token'));
            }

        } else {
            #usuario o password invalida
            if ($userid) {
                #intento de loguin
#                 C4::AR::Debug::debug("checkauth=> usuario o password incorrecta dentro del if");
                $template_params->{'loginAttempt'} = 1;
                _destruirSession('U406', $template_params);
            }
            #genero una nueva session y redirecciono a auth.tmpl para que se loguee nuevamente
            redirectToAuth($template_params);
            #EXIT
        }#end if ($passwordValida)
 
    }# end unless ($userid) 
}# end checkauth


=item sub _session_expired

    Verifica si expiró la sesion, no me esta funcionando el método del CGI::Session  is_expired

    Parametros: 

=cut
sub _session_expired {
    my ($session) = @_;
#     C4::AR::Debug::debug("dump desde _session_expired ".$session->dump());

#     C4::AR::Debug::debug("_session_expired=>  (session->atime + session->etime): ".($session->atime + $session->etime));
#     C4::AR::Debug::debug("_session_expired=>  time(): ".time());
#     C4::AR::Debug::debug("_session_expired=>  session->id(): ".$session->id);

    if( (($session->atime + $session->etime) <= time()) && (_getExpireStatus()) ){
        C4::AR::Debug::debug("_session_expired=> EXPIRO LA SESSION DE LA COOKIE CON: ".(($session->atime + $session->etime) <= time())." Y _getExpireStatus: "._getExpireStatus());

        C4::AR::Debug::debug("atime: ".$session->atime."etime: ".$session->etime);
        return 1;
    }

    return 0;
}

=item sub _getTimeOut

    TimeOut para la sesion

    Parametros: 

=cut
sub _getTimeOut {
    my $timeout = C4::AR::Preferencias->getValorPreferencia('timeout') || C4::Context->config('timeout') ||600;
    
#     C4::AR::Debug::debug("_getTimeOut => ".$timeout);
    return $timeout;
}

=item sub _clear_sessions_from_DB

    Limpia la tabla sist_sesion, todas las sesiones "colgadas" que queraron por ej. cuando se cierra el navegador y no se sale de 
    la sesion.

    Parametros: 

=cut
sub _clear_sessions_from_DB {
# TODO esto no esta 100% confirmado de que pueda dejar a gente afuera de la sesion    
    use C4::Context;
    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare("DELETE FROM sist_sesion WHERE lasttime < ? ");
    my $tope = time() - _getTimeOut();
    my $count = $sth->execute($tope);
    if($count ne '0E0'){
        C4::AR::Debug::debug("_clear_sessions_from_DB=> TAREAS DE MANTENIMIENTO DE LA TABLA DE sist_sesion");
        C4::AR::Debug::debug("_clear_sessions_from_DB=> se borraron ".$count." sessiones viejas");
    }
}


=item sub _realizarOperaciones

    Parametros: 
    $type: INTRA | OPAC
    $socio

=cut
# FIXME DEPRECATED??????
sub _realizarOperaciones {
    my ($params) = @_;
    
    if ($params->{'type'} eq 'opac') {
    #Si es un usuario de opac que esta sancionado entonces se borran sus reservas
        C4::AR::Debug::debug("_realizarOperaciones=> t_operacionesDeOPAC\n");
        t_operacionesDeOPAC($params->{'socio'});
    } else {
    ##Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
        C4::AR::Debug::debug("_realizarOperaciones=> t_operacionesDeINTRA\n");
        t_operacionesDeINTRA($params->{'socio'});
    }# end if ($type eq 'opac')
}

=item sub prepare_password

    Esta funcion "prepara" la password para ser guardada en la base de datos
    este es el tratamiento actual que se le esta dando a la password antes de guardar en la base de datos,
    si cambia, solo deberia cambiarse este metodo

    Parametros: 
    $password

=cut
sub prepare_password{
    my ($password) = @_;

    #primero se hashea la pass con MD5 (esto se mantiene por compatibilidad hacia atras KOHA V2), luego con SHA_256_B64
    $password = C4::AR::Utilidades::trim($password);
    C4::AR::Debug::debug("_hashear_password=> "._hashear_password(_hashear_password($password, 'MD5_B64'), 'SHA_256_B64'));

    return _hashear_password(_hashear_password($password, 'MD5_B64'), 'SHA_256_B64');
}

=item sub _getEncriptionKey

    Esta funcion retorna la key para el cifrado simétrico
    en este momento, la key se esta generando con SHA_256_B64(MD5_B64(password))
    si cambia, modificar esta funcion

    Parametros: 
    $password

=cut
sub _getEncriptionKey{
    my ($texto) = @_;

    return prepare_password($texto);
}


=item sub desencriptar

    Esta funcion desencripta el texto_a_desencriptar con la clave $key usando AES
    Parametros: 
    $texto_a_desencriptar
    $key= clave para desencriptar

=cut
sub desencriptar{
    my ($texto_a_desencriptar, $key) = @_;

    use Crypt::CBC;
    use MIME::Base64;
 C4::AR::Debug::debug("desencriptar=> ".$texto_a_desencriptar);
    my  $cipher = Crypt::CBC->new( 
                                    -key    => $key,
                                    -cipher => 'Rijndael',
                                    -salt   => 1,
                            );


    my $plaintext = $cipher->decrypt(decode_base64($texto_a_desencriptar));    

    return C4::AR::Utilidades::trim($plaintext);
}

=item sub _save_session_db

    Esta funcion guarda una session en la base
    Parametros: 
    $sessionID, $userid, $remote_addr, $random_number, $token

=cut
# FIXME DEPRECATED????????????
sub _save_session_db{
	my ($sessionID, $userid, $remote_addr, $random_number, $token) = @_;

    my ($sist_sesion)= C4::Modelo::SistSesion->new();

    $sist_sesion->setSessionId($sessionID);
    $sist_sesion->setUserid($userid);
    $sist_sesion->setIp($remote_addr);
    $sist_sesion->setLasttime(time());
    $sist_sesion->setNroRandom($random_number);
	$sist_sesion->setToken($token);
#     C4::AR::Debug::debug("_save_session_db => token: ".$token);
    $sist_sesion->save();

}

=item sub _setLoguinDuplicado

    Esta funcion modifica el flag de todos las sessiones con usuarios duplicados, seteando el mismo a LOGUIN_DUPLICADO
    cuando el usuario remoto con session duplicada intente navegar, sera redireccionado al loguin
    Parametros: 
    $userid, $ip

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

=item sub _logout_Controller

    Esta funcion se encarga del logout del usuario
    Parametros: 
    $query, $userid, $ip, $sessionID, $sist_sesion

=cut
sub _logout_Controller {
	my ($userid, $ip, $sessionID, $sist_sesion) = @_;
	# voluntary logout the user
    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("_logOut_Controller=> LOGOUT:");
    C4::AR::Debug::debug("_logOut_Controller=> sessionID: ".$sessionID);
    C4::AR::Debug::debug("_logOut_Controller=> userID: ".$userid);
	#Logueo la sesion que se termino voluntariamente
	my $time=localtime(time());
	_session_log(sprintf "%20s from %16s logged out at %30s (manually).\n", $userid, $ip, $time);
	#se elimina la session del usuario que se esta deslogueando
    $sist_sesion->delete;

    C4::AR::Debug::debug("_logOut_Controller=> Elimino de la base la session de userid: ".$userid." sessionID: ".$sessionID);
    C4::AR::Debug::debug("\n");
}

=item sub _change_Password_Controller

    Esta funcion se encarga de manejar el cambio de la password
    Parametros: 
    $dbh, $query, $userid, $type, $info

=cut
sub _change_Password_Controller {
	my ($dbh, $query, $userid, $type, $info, $token) = @_;


    if ($type eq 'opac') {
            redirectTo('/cgi-bin/koha/change_password.pl?token='.$token);
    } else {
            redirectTo('/cgi-bin/koha/usuarios/change_password.pl?token='.$token);
    }
}


sub getMsgCode{

    my ($session) = CGI::Session->load();
    return ($session->param('codMsg') || $codMSG);

}

=item sub inicializarAuth

    Esta funcion inicializa la session para autenticar un usuario, se usa en OPAC e INTRA siempre q se quiere autenticar
    Parametros: 
    $query: CGI
    $t_params: parametros para el template

=cut
sub inicializarAuth{
    my ($t_params) = @_;

    #se genera un nuevo nroRandom para que se autentique el usuario
    my $random_number = C4::Auth::_generarNroRandom();
    
    #genero una nueva session

    my ($session) = CGI::Session->load();
#     $session->flush();
    C4::AR::Debug::debug("inicializarAuth => ".$session->param('codMsg'));
    my $msjCode = getMsgCode();
    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($msjCode,'INTRA',[]);
    #se destruye la session anterior
    $session->clear();
    $session->delete();
    $session->flush();
     #se genera una nueva session
    my %params;
    $params{'userid'}               = undef;
    $params{'loggedinusername'}     = undef;
    $params{'password'}             = undef;
    $params{'token'}                = '';
    $params{'random_number'}        = $random_number;#undef;
    $params{'borrowernumber'}       = undef;
    $params{'type'}                 = $t_params->{'type'}; #OPAC o INTRA
    $params{'flagsrequired'}        = '';
    $params{'browser'}              = $ENV{'HTTP_USER_AGENT'};

# C4::AR::Utilidades::printHASH(\%ENV);

    $params{'SERVER_GENERATED_SID'} = 1;
    #esto realmente destruye la session
    undef($session);
    $session                        = C4::Auth::_generarSession(\%params);
    my $sessionID                   = $session->param('sessionID');
    my $userid                      = undef;

    #guardo la session en la base
#     C4::Auth::_save_session_db($sessionID, $userid, $ENV{'REMOTE_ADDR'}, $random_number, $params{'token'});
    #se pasa el RANDOM_NUMBER al cliente, $t_params es una REFERENCIA
    $t_params->{'RANDOM_NUMBER'}    = $random_number;
#     C4::AR::Debug::debug("DUMP inicializarAuth => ".$session->dump());

    return ($session);
}

sub cerrarSesion{
    my ($t_params) = @_;

    #se genera un nuevo nroRandom para que se autentique el usuario
    my $random_number       = C4::Auth::_generarNroRandom();
    #genero una nueva session
    my ($session)           = CGI::Session->load();

#     C4::AR::Debug::debug("cerrarSesion => ".$session->param('codMsg'));
    my $msjCode             = getMsgCode();
    $t_params->{'mensaje'}  = C4::AR::Mensajes::getMensaje($msjCode,'INTRA',[]);
    #se destruye la session anterior
    $session->clear();
    $session->delete();
    $session->flush();
    
    #se genera una nueva session
# TODO para que esta esto? no se usa!!!!!!!
    my %params;
    $params{'userid'}               = '';
    $params{'loggedinusername'}     = '';
    $params{'password'}             = '';
    $params{'token'}                = '';
    $params{'nroRandom'}            = '';
    $params{'borrowernumber'}       = '';
    $params{'type'}                 = $t_params->{'type'}; #OPAC o INTRA
    $params{'flagsrequired'}        = '';
    $params{'browser'}              = $ENV{'HTTP_USER_AGENT'};
    $params{'SERVER_GENERATED_SID'} = 1;

    $t_params->{'sessionClose'}     = 1;
    $session->param('codMsg', 'U358');
    
    
    #esto realmente destruye la session
    undef($session);
#     $session = CGI::Session->new();
    $session = C4::Auth::_generarSession(\%params);

    redirectToAuth($t_params);
}



sub _generarNroRandom {
	#PARA QUE EL USUARIO REALICE UN HASH CON EL NUMERO RANDOM
	#Y NO VIAJE LA PASS DEL USUARIO ENCRIPTADA SOLO CON MD5
	my $random_number= int(rand()*100000);

	return $random_number;
}


=item sub _generarToken

    genera el token para evitar CSRF a partir del sessionID, le hace un SHA(sessionID)
    Parametros: 

=cut
sub _generarToken {

	my $session = CGI::Session->load();

    my $digest;
    #se le hace SHA al sessionID para generar el TOKEN 
    $digest = sha1_hex($session->id);

	my $token= $digest;

#descomentar para ver que son totalmente disintos
# C4::AR::Debug::debug("_generarToken => token: ".$digest);	
# C4::AR::Debug::debug("_generarToken => sessionID: ".$session->param('sessionID'));   

	return $token;
}

=item sub _generarSession

    genera una sesion nueva y carga los parametros a la misma
    Parametros:
    $params: (HASH) con los parametros 

=cut
sub _generarSession {
	my ($params) = @_;

    my $session = new CGI::Session(undef, undef, undef);
#     $session->httponly; #seteo flag HTTPONLY para evitar robo de cookie con javascript
    #se setea toda la info necesaria en la sesion
	$session->param('userid', $params->{'userid'} || undef);
    $session->param('nro_socio', $params->{'userid'});
	$session->param('sessionID', $session->id());
	$session->param('loggedinusername', $params->{'userid'});
	$session->param('password', $params->{'password'});
    $session->param('ip', $params->{'ip'});
    $session->param('lasttime', $params->{'lasttime'});
	$session->param('nroRandom', $params->{'random_number'});
	$session->param('type', $params->{'type'}); #OPAC o INTRA
    $session->param('secure', ($params->{'type'} eq 'intranet')?1:0); #OPAC o INTRA
	$session->param('flagsrequired', $params->{'flagsrequired'});
 	$session->param('browser', $params->{'browser'} );
 	$session->param('charset', C4::Context->config("charset")||'utf-8'); #se guarda el juego de caracteres
	$session->param('token', $params->{'token'}); #se guarda el token
    $session->param('SERVER_GENERATED_SID', 1);
    my $expire = _getExpireStatus();
    
    if ($expire){
      $session->expire(_getTimeOut().'s');
    }else{
      $session->expire(0);
    }

#     C4::AR::Debug::debug("dump desde _generarSession ".$session->dump());

	return $session;
}

sub _getExpireStatus{

  my $expire = C4::Context->config("expire");

  if (defined($expire)){
        C4::AR::Debug::debug("EXPIRA".$expire);
      return ( $expire );
  }else{
      return (1);
  }
}

sub session_destroy {
    my $session = new CGI::Session(undef, undef, undef);

    return $session;
}

=item sub _verificarPassword

    Esta funcion verifica si el usuario y la password ingresada son valida, ya se en LDAP o en la base, segun configuracion de preferencia
    Parametros:
    $dbh, $userid, $password, $random_number

=cut
sub _verificarPassword {
	my ($dbh, $userid, $password, $random_number) = @_;
    
    C4::AR::Debug::debug(" ");
    C4::AR::Debug::debug("_verificarPassword=> verificarPassword:");
    C4::AR::Debug::debug("_verificarPassword=> userID: ".$userid);
    C4::AR::Debug::debug("_verificarPassword=> nroRandom: ".$random_number);
# Si se quiere dejar de usar el servidor ldap para hacer la autenticacion debe cambiarse 
# la llamada a la funcion checkpwldap por checkpw

	my ($passwordValida, $cardnumber, $ui);
## FIXME falta verificar la pass en LDAP si esta esta usando
	
	if ( C4::AR::Preferencias->getValorPreferencia('ldapenabled')) {
	#se esta usando LDAP
		($passwordValida, $cardnumber, $ui) = checkpwldap($dbh,$userid,$password,$random_number);
	} else {
         ($passwordValida, $cardnumber, $ui) = _checkpw($userid,$password,$random_number); 
	}

    C4::AR::Debug::debug("_verificarPassword=> password valida?: ".$passwordValida);
    C4::AR::Debug::debug(" ");

	return ($passwordValida, $cardnumber, $ui);
}

=item sub printSession

    imprime los datos de la sesion
    Parametros:
    $session: sesion de la cual se sacan los datos a imprimir
    $desde: desde donde se llama esta funcion

=cut
# FIXME deberia ir en DEBUG
sub printSession {
	my ($session, $desde) = @_;

    C4::AR::Debug::debug("\n");
	C4::AR::Debug::debug("*******************************************SESSION******************************************************");
	C4::AR::Debug::debug("Desde: ".$desde);
	C4::AR::Debug::debug("session->userid: ".$session->param('userid'));
	C4::AR::Debug::debug("session->loggedinusername: ".$session->param('loggedinusername'));
	C4::AR::Debug::debug("session->borrowernumber: ".$session->param('borrowernumber'));
	C4::AR::Debug::debug("session->password: ".$session->param('password'));
	C4::AR::Debug::debug("session->nroRandom: ".$session->param('nroRandom'));
	C4::AR::Debug::debug("session->sessionID: ".$session->param('sessionID'));
	C4::AR::Debug::debug("session->lang: ".$session->param('lang'));
	C4::AR::Debug::debug("session->type: ".$session->param('type'));
	C4::AR::Debug::debug("session->flagsrequired: ".$session->param('flagsrequired'));
	C4::AR::Debug::debug("session->REQUEST_URI: ".$session->param('REQUEST_URI'));
	C4::AR::Debug::debug("session->browser: ".$session->param('browser'));
	C4::AR::Debug::debug("*****************************************END**SESSION****************************************************");
	C4::AR::Debug::debug("\n");
}

sub redirectTo {
	my ($url) = @_;
    C4::AR::Debug::debug("redirectTo=>");  
	#para saber si fue un llamado con AJAX
    if(C4::AR::Utilidades::isAjaxRequest()){
	#redirijo en el cliente
        C4::AR::Debug::debug("redirectTo=> CLIENT_REDIRECT"); 		
   		my $session = CGI::Session->load();
		# send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
#         C4::AR::Debug::debug("redirectTo=> session->dump(): ".$session->dump());;
        C4::AR::Debug::debug("redirectTo=> url: ".$url);
#      	print $session->header();
        print_header($session);
 		print 'CLIENT_REDIRECT';
		exit;
	}else{
	#redirijo en el servidor
        C4::AR::Debug::debug("redirectTo=> SERVER_REDIRECT");       
		my $input = CGI->new(); 
		print $input->redirect( 
					-location => $url, 
					-status => 301,
		); 
        C4::AR::Debug::debug("redirectTo=> url: ".$url);
		exit;
	}
    C4::AR::Debug::debug(" ");
}

sub redirectToAuth {
    my ($template_params) = @_;
    my $url;
    $url = '/cgi-bin/koha/auth.pl';

# TODO deprecated ???
=item
    if(is_OPAC($template_params)){
#         $url = '/cgi-bin/koha/auth.pl';
#         $session->param('redirectTo', $url);
    }else{
#         $url = '/cgi-bin/koha/auth.pl?sessionClose=1';
#         $session->param('redirectTo', $url);
    }
=cut
    if($template_params->{'loginAttempt'}){
        $url = $url.'?loginAttempt=1'
    }elsif($template_params->{'sessionClose'}){
        $url = $url.'?sessionClose=1';
    }

    redirectTo($url);    
}

sub redirectToNoHTTPS {
    my ($url) = @_;

    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("redirectToNoHTTPS=>");
    #PARA SACAR EL LOCALE ELEGIDO POR EL SOCIO
    my $socio = C4::Auth::getSessionNroSocio();

    $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio) || C4::Modelo::UsrSocio->new();

    #para saber si fue un llamado con AJAX
    if(C4::AR::Utilidades::isAjaxRequest()){
    #redirijo en el cliente
        C4::AR::Debug::debug("redirectToNoHTTPS=> CLIENT_REDIRECT");         
        my $session = CGI::Session->load();
        # send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
        C4::AR::Debug::debug("SESSION url: ".$session->param('redirectTo'));
        C4::AR::Debug::debug("redirectToNoHTTPS=> url: ".$url);
#         print $session->header();
        print_header($session);
        print 'CLIENT_REDIRECT';
        exit;
    }else{
    #redirijo en el servidor
        C4::AR::Debug::debug("redirectToNoHTTPS=> SERVER_REDIRECT");    

        my $input = CGI->new(); 
        print $input->redirect( 
# FIXME ta fijo arreglar
# FIXME falta parametrizar el server
                    -location => "http://".$ENV{'SERVER_NAME'}.$url, 
                    -status => 301,
        ); 

        C4::AR::Debug::debug("redirectTo=> url: ".$url);
        exit;
    }

    C4::AR::Debug::debug("\n");
}

=item sub _opac_logout

    redirecciona a al login correspondiente

=cut
sub _opac_logout{

    if ( C4::AR::Preferencias->getValorPreferencia("habilitar_https") ){
    #se encuentra habilitado https
        redirectToHTTPS('/cgi-bin/koha/login/auth.pl');
    }else{
        redirectTo('/cgi-bin/koha/auth.pl');
    }
}

sub redirectToHTTPS {
    my ($url) = @_;

    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("redirectToHTTPS=> \n");

    my $puerto = C4::AR::Preferencias->getValorPreferencia("puerto_para_https")||'80';
    my $protocolo = "https";

    if($puerto eq "80"){
        $protocolo = "http";
    }

    #para saber si fue un llamado con AJAX
    if(C4::AR::Utilidades::isAjaxRequest()){
    #redirijo en el cliente
        C4::AR::Debug::debug("redirectToHTTPS=> CLIENT_REDIRECT\n");         
        my $session = CGI::Session->load();
        # send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
        C4::AR::Debug::debug("redirectToHTTPS=> url: ".$url."\n");
#         print $session->header();
        print_header($session);
        print 'CLIENT_REDIRECT';
        exit;
    }else{
    #redirijo en el servidor
        C4::AR::Debug::debug("redirectToHTTPS=> SERVER_REDIRECT\n");    

        my $input = CGI->new(); 
        print $input->redirect( 
                    -location => $protocolo."://".$ENV{'SERVER_NAME'}.":".$puerto.$url,  
                    -status => 301,
        ); 

        C4::AR::Debug::debug("redirectTo=> url: ".$url."\n");
        exit;
    }

    C4::AR::Debug::debug("\n");
}



sub _session_log {
    (@_) or return 0;
    open L, ">>/tmp/sessionlog";
    printf L join("\n",@_);
    close L;
}


# FIXME fatal acomodar
sub t_operacionesDeOPAC{
	my ($socio) = @_;

    C4::AR::Debug::debug("t_operacionesDeOPAC !!!!!!!!!!!!!!!!!");
    my $msg_object                          = C4::AR::Mensajes::create();
	my $db                                  = $socio->db;
    $db->{connect_options}->{AutoCommit}    = 0;
    $db->begin_work;

	eval{
		#Si es un usuario de opac que esta sancionado entonces se borran sus reservas
		my ($isSanction,$endDate)= C4::AR::Sanciones::permitionToLoan($socio, C4::AR::Preferencias->getValorPreferencia("defaultissuetype"));
        my $regular = $socio->esRegular;
        my $userid = $socio->getNro_socio();
				
		if ($isSanction || !$regular ){
			&C4::AR::Reservas::cancelar_reserva_socio($userid, $socio);
		}

		$db->commit;
	};
	if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B408',"OPAC");
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R010', 'params' => []} ) ;
        $db->rollback;
	}

	$db->{connect_options}->{AutoCommit} = 1;
}

# FIXME fata acomodar
sub t_operacionesDeINTRA{
	my ($socio) = @_;

    C4::AR::Debug::debug("t_operacionesDeINTRA !!!!!!!!!!!!!!!!!");
    my $msg_object= C4::AR::Mensajes::create();
    my $db= $socio->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    my $userid = $socio->getNro_socio();

	eval{
		use C4::Modelo::CircReserva;
		my $reserva=C4::Modelo::CircReserva->new(db=> $db);
		#Se borran las reservas de todos los usuarios sancionados
		$reserva->cancelar_reservas_sancionados($userid);
		#Ademas, se borran las reservas de los usuarios que no son alumnos regulares
		$reserva->cancelar_reservas_no_regulares($userid);
		#Ademas, se borran las reservas vencidas
		$reserva->cancelar_reservas_vencidas($userid, $db);	
# 		#Si se logueo correctamente en intranet entonces guardo la fecha
#         my $today = Date::Manip::ParseDate("today");
#         $socio->setLast_login($today);
#         $socio->save();

		$db->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B409',"INTRA");
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R010', 'params' => []} ) ;
        $db->rollback;
	}

    $db->{connect_options}->{AutoCommit} = 1;
}


=item sub _checkpw

    verifica la password
    Parametros:
    $userid, $password, $random_number

=cut
sub _checkpw {
    my ($userid, $password, $random_number) = @_;
    C4::AR::Debug::debug("_checkpw=> \n");

    my ($socio)= C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);

    if ($socio){
        C4::AR::Debug::debug("_checkpw=> busco el socio ".$userid."\n");
          if ( ($socio->persona)&&($socio->getActivo) ) {
            C4::AR::Debug::debug("_checkpw=> tengo persona y socio\n");
            #existe el socio y se encuentra activo
            my $hashed_password= $socio->getPassword;
            my $ui= $socio->getId_ui;
            my $dni= $socio->persona->getNro_documento;
    
            return _verificar_password_con_metodo($hashed_password, $password, $dni, $random_number, _getMetodoEncriptacion()), $userid, $ui;
        }# END  if ( ($socio->persona)&&($socio->getActivo) )
    }

    C4::AR::Debug::debug("_checkpw=> las pass son <> \n");

    return 0;
}


sub _getMetodoEncriptacion {
    return 'SHA_256_B64';#'MD5'
}

=item sub _verificar_password_con_metodo

    Verifica la password ingresada por el usuario con la password recuperada de la base, todo esto con el metodo indicado por parametros    
    
    Parametros:
    $hashed_password: password recuperada de la base
    $metodo: MD5, SHA
    $password: ingresada por el usuario

=cut
sub _verificar_password_con_metodo {
    my ($hashed_password, $password, $dni, $random_number, $metodo) = @_;

#     if ($hashed_password eq undef){
#     # La 1ra vez esta vacio se usa el dni o password reseteada
#         $hashed_password= _hashear_password(md5_base64($dni), $metodo);
#         C4::AR::Debug::debug("_verificar_password_con_metodo=> es la 1era vez que se loguea, se usa el DNI\n");
#     }

C4::AR::Debug::debug("_verificar_password_con_metodo=> password del cliente: ".$password."\n");
C4::AR::Debug::debug("_verificar_password_con_metodo=> password de la base: ".$hashed_password."\n");
C4::AR::Debug::debug("_verificar_password_con_metodo=> password_hasheada_con_metodo.random_number: "._hashear_password($hashed_password.$random_number, $metodo)."\n");

    if ($password eq _hashear_password($hashed_password.$random_number, $metodo)) {
        C4::AR::Debug::debug("_verificar_password_con_metodo=> las pass son = todo OK\n");
        #PASSWORD VALIDA
        return 1;
    }else {
        #PASSWORD INVALIDA
        return 0;
    }
}


=item sub hashear_password

    Hashea una password segun el metodo pasado por parametro
    si se agrega otro metodo de encriptacion se debe agregar aca
    
    Parametros:
    $password: password del usuario a hashear
    $metodo: MD5, SHA

=cut
sub _hashear_password {
    my ($password, $metodo) = @_;

    if($metodo eq 'SHA'){
        return sha1_hex($password);
    }elsif($metodo eq 'SHA_256_B64'){
        return sha256_base64($password);
    }elsif($metodo eq 'MD5_B64'){
        return md5_base64($password);
    }

    C4::AR::Debug::debug("C4::Auth::_hashear_password => Error al intentar hashear password, falta METODO de encriptacion");
}


=item sub new_password_is_needed

    Verifica si el usuario tiene que cambiar o no la password
    
    Hay dos campos (lastchangepassword, changepassword) en urs_socio 
    lastchangepassword: fecha en la que el socio cambio la password por ultima vez
    changepassword: booleano, indica si la password debe ser cambiada o no
    Parametros:
    $nro_socio

=cut
sub new_password_is_needed {
    my ($nro_socio, $socio) = @_;

#     my ($socio)= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
#     my $socio = C4::Auth::getSessionSocio();
    if (!$socio) {
        $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
    }

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



sub redirectAndAdvice{

    my ($cod_msg)= @_;
    my ($session) = CGI::Session->load();

    $codMSG = $cod_msg;
    $cod_msg = getMsgCode();
    $session->param('codMsg',$cod_msg);
    redirectTo('/cgi-bin/koha/informacion.pl');
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








