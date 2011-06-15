package C4::AR::Auth;


=head1 NAME

  C4::AR::Auth 

=head1 SYNOPSIS

  use C4::AR::Auth;

=head1 DESCRIPTION

 En este modulo se centraliza todo lo relacionado a la authenticacion del usuario

=head1 VARIABLES DEL meran.conf necesarias

 Hay algunas variables que se deben configurar para controlar el funcionamiento de este modulo:

    charset: controla el charset, en caso de no estar definida utiliza utf8
    authMERAN: controla si se usa la authenticacion de MERAN utilizando el sistema definido internamente con el nroRandom o si utiliza un sistema tradicional simplemente utilizando la password y chequeandola contra un repositorio normal. Por defecto es 0.
    ldapenabled: Define si se utiliza un ldap para la authenticacion, en combinacion con la variables authMERAN se define si es un ldap especialmente formado para soportar el manejo del nroRandom o si es un ldap comun como ser un dominio
    defaultLang: el idioma del sistema, por defecto si no esta definido es es_ES
    expire: controla si las sesiones expiran o no.
    timeout: define el tiempo que demora una sesion en dar timeout. Se usa en conjunto con expire. Si no esta definida, la busca en las preferencias del sistema, y si no esta alli la setea en 600 segundos.


=head1 PREFERENCIAS del sistema necesarias

 Hay algunas variables que se deben configurar para controlar el funcionamiento de este modulo:

    limite_resultados_autocompletables: HELP FIXME
    insecure: HELP FIXME
    habilitar_https: HELP FIXME
    puerto_para_https: HELP FIXME
    defaultissuetype:HELP FIXME
    keeppasswordalive: Define cuantos dias dura una contraseña antes de vencer y ser necesario cambiarla.
    timeout: define el tiempo que demora una sesion en dar timeout. Se usa en conjunto con expire. Si no esta definida en meran.conf la busca en las preferencias del sistema, y si no esta alli la setea en 600 segundos.



=head1 FUNCTIONS

=over 2

=cut

use strict;
use warnings;

require Exporter;
use Digest::MD5 qw(md5_base64);
use Digest::SHA  qw(sha1 sha1_hex sha1_base64 sha256_base64 );
use C4::AR::Usuarios qw(getSocioInfoPorNroSocio);
use Locale::Maketext::Gettext::Functions qw(bindtextdomain textdomain get_handle);
use C4::Output;              # to get the template
use C4::Context;
use C4::Modelo::SistSesion;
use C4::Modelo::SistSesion::Manager;
use C4::Modelo::CircReserva;
use C4::Modelo::UsrSocio;
use C4::Modelo::PrefFeriado;
use C4::AR::Authldap;

use vars qw($VERSION @ISA @EXPORT %EXPORT_TAGS);
my $codMSG = 'U000';
# set the version for version checking

$VERSION = 1.0;
@ISA = qw(Exporter);
@EXPORT = qw(
        checkBrowser
        checkauth		
        get_template_and_user
        output_html_with_http_headers
        getSessionUserID
        getSessionNroSocio
        redirectAndAdvice
        hashear_password
        get_html_content
        getMetodoEncriptacion
        buildSocioDataHashFromSession
        buildSocioData
        updateLoggedUserTemplateParams
        checkBrowser
);


=item 
    Checkea si el browser es uno ideal
    Browser NO soportados:
        FF: 3, IE: 7, Google Chrome 7, 8 y 9, Chromium Browser 5
=cut
sub checkBrowser{

    my @blacklist = qw(
        Firefox_4
        Chrome_7
        MSIE_7
        IceWeasel_3
    );
    
#TODO: cuando clickea en ok se setea: $session->param('check_browser_allowed', '1');


	my $browser         = HTTP::BrowserDetect->new($ENV{'HTTP_USER_AGENT'});
	my $browser_string  = $browser->browser_string();
	my $browser_major   = $browser->major();
	my $search          = $browser_string."_".$browser_major;
	
	if ($search ~~ @blacklist){
	    #redirectTo(C4::AR::Utilidades::getUrlPrefix().'/informacion.pl');
	}
}

=item sub _generarNroRandom

    Función que devuelve un nro random entre 0 100000
    

=cut

sub _generarNroRandom {
    return (int(rand()*100000));  
}
=item sub 
    Función que devuelve el codigo de mensaje 
=cut

sub getMsgCode{
    my ($session) = CGI::Session->load();
    return ($session->param('codMsg') || $codMSG);
 
}

=item sub _getExpireStatus
    Devuelve el valor de la variable de contexto que indica si expiran las sesiones o devuelve true si no esta definido este valor
=cut
sub _getExpireStatus{
  my $expire = C4::Context->config("expire");
#         C4::AR::Debug::debug("EXPIRA => ".$expire);
  if (defined($expire)){
      return ( $expire );
  }else{
      return (1);
  }
}

=item sub _generarSession

    genera una sesion nueva y carga los parametros a la misma y la devuelve
    Parametros:
    $params: (HASH) con los parametros 

=cut
sub _generarSession {
    my ($params) = @_;

    my $session = new CGI::Session(undef, undef, undef);
    #se setea toda la info necesaria en la sesion
    _actualizarSession($session->id(), ($params->{'userid'} || undef), $params->{'userid'}, $params->{'lasttime'}, $params->{'nroRandom'}, $params->{'type'},$params->{'flagsrequired'}, $params->{'token'}, $session);
    my $expire = _getExpireStatus();
    if ($expire){
      $session->expire(_getTimeOut().'s');
    }else{
      $session->expire(0);
    }
    return $session;
}


=item sub _actualizarSession

    Toma una sesion, algunos parametros y actualiza la sesion
    Uso INTERNO
    Parametros:
    $params: $sessionID, $userid, $socioNro, $time, $nroRandom, $type, $flagsrequired, $token, $session

=cut
sub _actualizarSession {
  
  
    my ($sessionID, $userid, $socioNro, $time, $nroRandom, $type, $flagsrequired, $token, $session)= @_;
#     C4::AR::Debug::debug("userid en actualizarSession".$sessionID);
    $session->param('sessionID', $sessionID);
    $session->param('userid', $userid);
#     #C4::AR::Debug::debug("userid en actualizarSession actualizado".$session->param('userid'));
    $session->param('nro_socio', $socioNro);
    $session->param('loggedinusername', $userid);
    $session->param('ip', $ENV{'REMOTE_ADDR'});
    $session->param('lasttime', $time);
    $session->param('nroRandom', $nroRandom);
    $session->param('type', $type); 
    $session->param('secure', ($type eq 'intranet')?1:0); #OPAC o INTRA
    $session->param('flagsrequired', $flagsrequired);
    $session->param('browser', $ENV{'HTTP_USER_AGENT'});
    $session->param('charset', C4::Context->config("charset")||'utf-8'); #se guarda el juego de caracteres
    $session->param('token', $token); #se guarda el token
    #$session->param('SERVER_GENERATED_SID', $sid);


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

=item _session_log
    
    Hace log de la sesion

=cut

sub _session_log {
    (@_) or return 0;
#     C4::AR::Debug::debug(join("\n",@_));
}


=item sub _save_session_db

    Esta funcion guarda una session en la base
    Parametros: 
    $sessionID, $userid, $remote_addr, $nroRandom, $token

=cut
sub _save_session_db{
    my ($sessionID, $userid, $remote_addr, $nroRandom, $token) = @_;
    my ($sist_sesion)= C4::Modelo::SistSesion->new();
    $sist_sesion->setSessionId($sessionID);
    $sist_sesion->setUserid($userid);
    $sist_sesion->setIp($remote_addr);
    $sist_sesion->setLasttime(time());
    $sist_sesion->setNroRandom($nroRandom);
    $sist_sesion->setToken($token);
    $sist_sesion->save();

}

=item sub _eliminarSession

Funcion que realmente borra la sesion

=cut

sub _eliminarSession{
    my $session=shift;
    $session->expire('-1');
    $session->delete();
    $session->flush();
}


=item sub _destruirSession

Funcion que destruye la sesion actual, genera una nueva vacia y despues redirige al auth

=cut


sub _destruirSession{
    
    my ($codMsg,$template_params) = @_;
    $codMsg = $codMsg || 'U406';

    my ($session) = CGI::Session->load();
#     
#    C4::AR::Debug::debug("Template params". $template_params);   
 
    $codMSG = $codMsg;
    
    _eliminarSession($session);
    
    $session = C4::AR::Auth::_generarSession();
    $session->param('sessionID', undef);

    #redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
    $session->param('codMsg', $codMsg);
  

#     C4::AR::Debug::debug("WARNING: ¡¡¡¡Se destruye la session y la cookie!!!!!");
    redirectToAuth($template_params)

}

=item sub inicializarAuth

    Esta funcion inicializa la session para autenticar un usuario, se usa en OPAC e INTRA siempre q se quiere autenticar
    Parametros: 
    $query: CGI
    $t_params: parametros para el template

=cut
sub inicializarAuth{
    my ($t_params) = @_;
    #recupero los datos de la sesion anterior que voy a necesitar y luego la destruyo
    my ($session) = CGI::Session->load();
    my $msjCode = getMsgCode();
#     C4::AR::Debug::debug("inicializarAuth => ".$msjCode);
#     $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($msjCode,'INTRA',[]);

     $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($msjCode,$t_params->{'type'},[]);


    #se destruye la session anterior
    _eliminarSession($session);
    #Genero una nueva sesion.
    my %params;
    $params{'userid'}               = undef;
    $params{'loggedinusername'}     = undef;
    $params{'token'}                = '';
    $params{'nroRandom'}            = C4::AR::Auth::_generarNroRandom();
    $params{'borrowernumber'}       = undef;
    $params{'type'}                 = $t_params->{'type'}; #OPAC o INTRA
    $params{'flagsrequired'}        = '';
    $params{'socio_data'}           = undef;
    $session                        = C4::AR::Auth::_generarSession(\%params);

    #Guardo la sesion en la base
    #FIXME C4::AR::Auth::_save_session_db($session->param('sessionID'), undef, $params{'ip'} , $params{'nroRandom'}, $params{'token'});
    $t_params->{"nroRandom"}=$params{'nroRandom'};
    $t_params->{"authMERAN"}=C4::Context->config('authMERAN');
    $t_params->{'socio_data'}=undef;
    
    return ($session);
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


 get_template_and_user({
                                    template_name => "main.tmpl",
                                    query => $query,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},

=cut
sub get_template_and_user {
    my $in = shift;
    
    my ($user, $session, $flags, $usuario_logueado) = checkauth(         $in->{'query'}, 
                                                                         $in->{'authnotrequired'}, 
                                                                         $in->{'flagsrequired'}, 
                                                                         $in->{'type'}, 
                                                                         $in->{'changepassword'},
                                                                         $in->{'template_params'}
                                                             );
    #C4::AR::Debug::debug("la SESSION en el get template and user ".$session);    
    my ($template, $params)     = C4::Output::gettemplate($in->{'template_name'}, $in->{'type'}, $in->{'loging_out'}, $usuario_logueado);
  
    $in->{'template_params'}    = $params;

    if ( $session->param('userid') ) {
        $params->{'nro_socio'}          = $session->param('userid');
        $params->{'socio'}              = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});
        if (!$usuario_logueado) {
            $usuario_logueado = C4::Modelo::UsrSocio->new();
        }
    
        $params->{'socio_data'}                 = buildSocioDataHashFromSession();
        $params->{'token'}                      = $session->param('token');
        #para mostrar o no algun submenu del menu principal
        $params->{'menu_preferences'}           = C4::AR::Preferencias::getMenuPreferences();
    }

    #se cargan todas las variables de entorno de las preferencias del sistema
    $params->{'limite_resultados_autocompletables'} = C4::AR::Preferencias::getValorPreferencia("limite_resultados_autocompletables");

    return ($template, $session, $params, $usuario_logueado);
}
=item sub _obtenerToken

Funcion que devuelve el token, hay diferencias enter las llamadas tradicionales, tanto sea por AJAX o tradicional y para las llamadas transaccionales comunes

=cut
sub _obtenerToken{
    my $query=shift;
    #Pregunto si es AJAX
    if(defined($ENV{'HTTP_X_REQUESTED_WITH'}) && ($ENV{'HTTP_X_REQUESTED_WITH'} eq 'XMLHttpRequest')){ 
        my $obj = $query->param('obj');
        #PREGUNTO Si ES PARA LAS LLAMADAS AJAX QUE PASSAN UN OBJETO JSON (HELPER DE AJAX)
        if ( defined($obj) ){
            $obj=C4::AR::Utilidades::from_json_ISO($obj);
            return $obj->{'token'};
        }
    }
    #ESTO ES PARA LAS LLAMADAS AJAX TRADICIONALES (PARAMETROS POR URL) o llamados transaccionales habituales
    return $query->param('token');
}

=item sub getUserLocale
  Devuelve el idioma por defecto del Usuario, lo busca en la sesion, sino en el defaultLanguage o devuelve el esES por defecto
=cut

sub getUserLocale{
    my $session = CGI::Session->load();

    my $locale = $session->param('usr_locale') || C4::Context->config("defaultLang") || 'es_ES';
    
    return C4::AR::Utilidades::trim($locale);
    
}

=item
  sub i18n
  setea lo necesario para que el filtro C4::AR::Filtros::i18n pueada realizar la internacionalizacion dinámicamente
=cut
sub _init_i18n {
    my($params) = @_;
    my $locale = C4::AR::Auth::getUserLocale();
    Locale::Maketext::Gettext::Functions::bindtextdomain($params->{'type'}, C4::Context->config("locale"));
    Locale::Maketext::Gettext::Functions::textdomain($params->{'type'});
    Locale::Maketext::Gettext::Functions::get_handle($locale);
}

=item sub _cambioIp
Funcion que devuelve si se cambio la ip o no para la misma session
=cut

sub _cambioIp{ 
    my $session=shift;
    if ($session->param('ip') ne $ENV{'REMOTE_ADDR'}) {
                my $time=localtime(time());
                _session_log(sprintf "%20s from logged out at %30s (ip changed from %16s to %16s).\n", 
                                                            $session->param('userid'), 
                                                            $time, 
                                                            $session->param('ip'), 
                                                            $ENV{'REMOTE_ADDR'}
                 );
            return 1;}
    else{
            return 0;
    }
}
=item sub _verificarSession
Devuelve  sesion_valida sin_sesion o sesion_invalida de acuerdo a lo q corresponda
=cut

sub _verificarSession {

    my ($session,$type,$token)=@_;
    my $valido_token=C4::Context->config("token") || 0;
    my $code_MSG;

    my $type_session    = C4::AR::Utilidades::capitalizarString($session->param('type'));
    $type               = C4::AR::Utilidades::capitalizarString($type);
    
    if ($type ne $type_session){
        C4::AR::Debug::debug("C4::AR::Auth::_verificarSession => SESSION INVALIDA, VENIA DESDE OPAC/INTRA HACIA INTRA/OPAC");
        
        if ($type eq "Opac"){
        	$code_MSG = "U607";
        }else{
        	$code_MSG = "U601";
        }
        	    
    	return ($code_MSG,"sesion_invalida");
    }
    
    if(defined $session and $session->is_expired()){
        #EXPIRO LA SESION
        $code_MSG='U355';     
        C4::AR::Debug::debug("C4::AR::Auth::_verificarSession => expiro");    
    } else {
        #NO EXPIRO LA SESION
        _init_i18n({ type => $type });
        if ($session->param('userid')) {
#             C4::AR::Debug::debug("no hay userid");    
            #Quiere decir que la sesion existe ahora hay q Verificar condiciones
            if (_cambioIp($session)){
                $code_MSG='U356';             
                C4::AR::Debug::debug("C4::AR::Auth::_verificarSession => sesion invalido => cambio la ip");  
            } elsif ($session->param('flag') eq 'LOGUIN_DUPLICADO'){
                $code_MSG='U359';            
                    C4::AR::Debug::debug("C4::AR::Auth::_verificarSession => sesion invalido => loguin duplicado");  
            } elsif (($session->param('token') ne $token) and ($valido_token)){
                    $code_MSG='U354';            
                    C4::AR::Debug::debug("C4::AR::Auth::_verificarSession => sesion invalido => token invalido");    
                  } else {
                         if (C4::AR::Usuarios::needsDataValidation($session->param('userid')) != 0){
                                
                                 $code_MSG='U309';            
                                 C4::AR::Debug::debug("C4::AR::Auth::_verificarSession => datos censales invalidos");  
                                 return ($code_MSG,"datos_censales_invalidos");
                         } else {
                         #ESTA TODO OK
#                        C4::AR::Debug::debug("valida");    
                         return ($code_MSG,"sesion_valida"); }
                  }

        } else {
            #Esto quiere decir que la sesion esta bien pero que no hay nadie logueado
    #         C4::AR::Debug::debug("no hay sesion");    
            return ($code_MSG,"sin_sesion");
        }
    }
#     C4::AR::Debug::debug("sesion invalida");    
    return ($code_MSG,"sesion_invalida");
}

=item sub checkauth



=cut


sub checkauth {
    C4::AR::Debug::debug("desde checkauth==================================================================================================");
    my $query               = shift;

    my $authnotrequired     = shift;
    my $flagsrequired       = shift;
    my $type                = shift;
    my $change_password     = shift || 0;
    my $template_params     = shift;
    my $url                 = '';
    
    my $socio;
    $type                   = 'opac' unless $type;
    my $demo=C4::Context->config("demo") || 0;
    my $token=_obtenerToken($query);
    my $loggedin = 0;
    my ($session) = CGI::Session->load();


# C4::AR::Utilidades::printHASH(\%ENV);
    
    my $userid= $session->param('userid');
    my $flags=0;
    my $sin_captcha=0;
    my $time = localtime(time());
    if ($demo) {
        #Quiere decir que no es necesario una autenticacion
        $userid="demo";
        $flags=1;
        _actualizarSession($userid, $userid,$userid, $time, '', $type, $flagsrequired, _generarToken(), $session);
        $socio=C4::Modelo::UsrSocio->new();
        return ($userid, $session, $flags, $socio);
    } else {
        #No es DEMO hay q hacer todas las comprobaciones de la sesion
                  my ($code_MSG,$estado)=_verificarSession($session,$type,$token);
                  if ($estado eq "sesion_valida"){ 
                      
                      C4::AR::Debug::debug("C4::AR::Auth::checkauth => session_valida");
                      $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($session->param('userid'));
                      $flags=$socio->tienePermisos($flagsrequired);
                      $socio->setLogin_attempts(0);
                      
                      if ($flags) {
                          $loggedin = 1;
                      } else {
                          #redirecciono a una pagina informando q no tiene  permisos
                          $session->param('codMsg', 'U354');
                          $session->param('redirectTo', C4::AR::Utilidades::getUrlPrefix().'/informacion.pl');
                          redirectTo(C4::AR::Utilidades::getUrlPrefix().'/informacion.pl');
                    } 
                  }
                  elsif ($estado eq "datos_censales_invalidos"){
                      C4::AR::Debug::debug("C4::AR::Auth::checkauth => datos_censales_invalidos");
          #             _destruirSession('U309', $template_params);
                      $url = C4::AR::Utilidades::getUrlPrefix().'/auth.pl';
                      $url = C4::AR::Utilidades::addParamToUrl($url,'codMSG','U309');
                      $session->param('codMsg', $code_MSG);
                      $session->param('redirectTo', $url);
                      redirectTo($url); 
                  }
                  elsif ($estado eq "sesion_invalida") { 
                      C4::AR::Debug::debug("C4::AR::Auth::checkauth => session_invalida");
                      $url = C4::AR::Utilidades::getUrlPrefix().'/auth.pl';
                      $url = C4::AR::Utilidades::addParamToUrl($url,'codMSG',$codMSG);
                      $session->param('codMsg', $code_MSG);
                      $session->param('redirectTo', $url);
                      redirectTo($url); 
                  } 
                  elsif ($estado eq "sin_sesion") { 
                      C4::AR::Debug::debug("C4::AR::Auth::checkauth => sin_sesion");
                      #ESTO DEBERIA PASAR solo cuando la sesion esta sin iniciar
                      #_destruirSession('U406', $template_params);
                      $session->param('codMsg', $code_MSG);
                      }
                  else { 
                      #ESTO MENOS
                      C4::AR::Debug::debug("C4::AR::Auth::checkauth => ESTO MENOS ???");
                      _destruirSession(($code_MSG || 'U406'), $template_params);
                      $session->param('codMsg', $code_MSG);
                      $session->param('redirectTo', C4::AR::Utilidades::getUrlPrefix().'/error.pl');
                      redirectTo(C4::AR::Utilidades::getUrlPrefix().'/error.pl'); 
                  }
                  
                  #por aca se permite llegar a paginas que no necesitan autenticarse
                  my $insecure = C4::AR::Preferencias::getValorPreferencia('insecure');
                  if ($loggedin || $authnotrequired || (defined($insecure) && $insecure)) {
                      #Se verifica si el usuario tiene que cambiar la password
                      if ( ($userid) && ( new_password_is_needed($userid, $socio) ) && !$change_password ) {
                          _change_Password_Controller($query, $userid, $type, $token);
                      }
                  return ($userid, $session, $flags, $socio);
                  }

    
                  unless ($userid) { 
                      #si no hay userid, hay que autentificarlo y no existe sesion
                      #No genero un nuevo sessionID
                      #con este sessionID puedo recuperar el nroRandom (si existe) guardado en la base, para verificar la password
                      my $sessionID       = $session->param('sessionID');
                      #recupero el userid y la password desde el cliente
                      $userid             = $query->param('userid');
                      my $password        = $query->param('password');
                      my $nroRandom       = $session->param('nroRandom');
                      my $error_login=0;
                      my $mensaje;
                      my $cant_fallidos;
                      #se verifica la password ingresada
     
                            my $socio_data_temp = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);

                            if ($socio_data_temp){          #ingreso un usuario y exite en la base
                                 
                                    my ($socio)         = _verificarPassword($userid,$password,$nroRandom);
                                    #             C4::AR::Debug::debug("la pass es valida?".$passwordValida);
                                    
                                    if ($socio) {               #ingreso un usuario y pass y coincide

                                            my $login_attempts = $socio_data_temp->getLogin_attempts;
                                            my $captchaResult;
                                          
                                            if (($login_attempts > 2) && (!$query->url_param('welcome'))) {      # se logueo mal mas de 3 veces, debo verificar captcha
                                             
                                                    my $reCaptchaPrivateKey =  C4::AR::Preferencias::getValorPreferencia('re_captcha_private_key');
                                                    my $reCaptchaChallenge  = $query->param('recaptcha_challenge_field');
                                                    my $reCaptchaResponse   = $query->param('recaptcha_response_field');
                                              
                                                    use Captcha::reCAPTCHA;
                                                    my $c = Captcha::reCAPTCHA->new;
                          
                                                    $captchaResult = $c->check_answer(
                                                                $reCaptchaPrivateKey, $ENV{'REMOTE_ADDR'},
                                                                $reCaptchaChallenge, $reCaptchaResponse
                                                    );
                                                
                                          
                                            } else {  #else del  if ($login_attempts > 2 )
                                                    $sin_captcha = 1; 
                                            }  
                                            if ($sin_captcha || $captchaResult->{is_valid}){

                                                   
                                                        #se valido el captcha, la pass y el user y son validos
                                                        #setea loguins duplicados si existe, dejando logueado a un solo usuario a la vez
                                                        
                                                        _setLoguinDuplicado($userid,  $ENV{'REMOTE_ADDR'});
                                                        #$socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
                                                        # TODO todo esto va en una funcion
                                                        $sessionID  = $session->param('sessionID');
                                                        $sessionID.="_".$socio->ui->getNombre;
                                                        _actualizarSession($sessionID, $userid, $socio->getNro_socio(), $time, '', $type, $flagsrequired, _generarToken(), $session);
                                        #                 C4::AR::Debug::debug("userid en actualizarSession actualizadoarafue".$session->param('userid'));
                                                        buildSocioData($session,$socio);
                                        #                 C4::AR::Debug::debug($session->param('usr_apellido'));
                                                        #Logueo una nueva sesion
                                                        _session_log(sprintf "%20s from %16s logged out at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},$time);
                                                        #por defecto no tiene permisos
                                                        if( $flags = $socio->tienePermisos($flagsrequired) ){
                                                            _realizarOperacionesLogin($type,$socio);
                                                        }

                                                        #Si se logueo correctamente en intranet entonces guardo la fecha
                                                        my $now = Date::Manip::ParseDate("now");
                                                        if ($session->param('type') eq "intranet"){
                                                            $socio->setLast_login($now);
                                                            $socio->save();
                                                        }
                                                        if ($type eq 'opac') {
                                                                      $session->param('redirectTo', C4::AR::Utilidades::getUrlPrefix().'/opac-main.pl?token='.$session->param('token'));
                                                                      redirectToNoHTTPS(C4::AR::Utilidades::getUrlPrefix().'/opac-main.pl?token='.$session->param('token'));
                                        # #                               $session->secure(0);
                                            
                                                        }else{
                                                                      $session->param('redirectTo', C4::AR::Utilidades::getUrlPrefix().'/mainpage.pl?token='.$session->param('token'));
                                                                      redirectTo(C4::AR::Utilidades::getUrlPrefix().'/mainpage.pl?token='.$session->param('token'));
                                                        }
                                  
                                              } else {  # if ($sin_captcha || $captchaResult->{is_valid} ) - INGRESA CAPTCHA INVALIDO
#                                                    
                                                   
                                                    $mensaje='U425';
                                                    $cant_fallidos= $socio_data_temp->getLogin_attempts + 1;
                                                    $socio_data_temp->setLogin_attempts($cant_fallidos);
                                                    if ($cant_fallidos => 3){
                                                            $template_params->{'mostrar_captcha'}=1;
                                                           
                                                    }
                                                    
                                                       
                                              }
                                   }  else   {    # else de if ($socio) -----  ingreso password invalida
                                               
                                                    $mensaje= 'U357';
                                                    $cant_fallidos= $socio_data_temp->getLogin_attempts + 1;
                                                    $socio_data_temp->setLogin_attempts($cant_fallidos);
                                                    if ($cant_fallidos >= 3){
                                                            $template_params->{'mostrar_captcha'}=1; 
                                                    }
                                                        
#                                                     _destruirSession('U357', $template_params);  
                                            
                                   }
                              
                             }  else   {     # else de  if ($socio_data_temp) -----  ingreso usuario invalido      
                                            $mensaje= 'U357';
             
                             }
                            
                             if ($query->url_param('welcome')){
                               
                                      $template_params->{'loginAttempt'} = 0;
                                      $mensaje = 'U000';
                             }
                              _destruirSession($mensaje, $template_params);


                  }# end unless ($userid)
                  
    }# el else de DEMO
}# end checkauth

=item sub _realizarOperacionesLogin

Funcion que realiza todas las operaciones asociadas a un inicio de sesion como ser:
- revisar si los dias anteriores huubo actividad en la biblioteca, en aso de no haberla se marcan en la base como días feriados 
- Dar de baja reservas de acuerdo a las sanciones

=cut

sub _realizarOperacionesLogin{
    my ($type,$socio)=@_;
     C4::AR::Debug::debug("_realizarOperacionesLOGIN=> LOGIN\n");
    my $dateformat = C4::Date::get_date_format();
    my $lastlogin= C4::AR::Usuarios::getLastLoginTime();
    if ($type eq 'intranet') {
        #Se entran a realizar las rutinas solo cuando es intranet
        my $auxlastlogin= C4::Date::format_date($lastlogin,$dateformat);
        my $prevWorkDate = C4::Date::format_date(Date::Manip::Date_PrevWorkDay("today",1),$dateformat);
        my $enter=0;
        if ($lastlogin){
            while (Date::Manip::Date_Cmp($auxlastlogin,$prevWorkDate)<0) {
                
                C4::AR::Debug::debug("_realizarOperacionesLOGIN=> COMPARACION ll=".$auxlastlogin." prev=".$prevWorkDate);
                #Se recorren todos los dias entre el lastlogin y el dia previo laboral a hoy, si en esos dias no hubo actividad se marca como no activo al dia en la bdd
                my $dias=Date::Manip::Date_IsWorkDay($auxlastlogin);
                C4::AR::Debug::debug("_realizarOperacionesLOGIN=> dias ".$dias);
                my $nextWorkingDay=C4::Date::format_date(Date::Manip::Date_NextWorkDay($auxlastlogin,$dias),$dateformat);
                C4::AR::Debug::debug("_realizarOperacionesLOGIN=> nextWorkingDay ".$nextWorkingDay);

                if(Date::Manip::Date_Cmp($nextWorkingDay,$prevWorkDate)<=0) {
                       if (C4::AR::Utilidades::setFeriado(C4::Date::format_date_in_iso($nextWorkingDay,$dateformat),"true","Biblioteca sin actividad")){
                            C4::AR::Debug::debug("_realizarOperacionesLOGIN=> agregando dia sin actividad ".$nextWorkingDay);
                        }
                    }
                $auxlastlogin=$nextWorkingDay;
                $enter=1;
            }
            if ($enter) {
                #Se actuliza el archivo con los feriados (.DateManip.cfg) solo si se dieron de alta nuevos feriados en 
                #el while anterior
                my ($count,@holidays)= C4::AR::Utilidades::getholidays();
                C4::AR::Utilidades::savedatemanip(@holidays);
            }
            #Genera una comprobacion una vez al dia, cuando se loguea el primer usuario
            my $today = C4::Date::format_date_in_iso(Date::Manip::ParseDate("today"),$dateformat);

	    C4::AR::Debug::debug("_realizarOperaciones=> TODAY = ".$today);
	    C4::AR::Debug::debug("_realizarOperaciones=> LASTLOGIN = ".$auxlastlogin);
	    C4::AR::Debug::debug("_realizarOperaciones=> Date_Cmp = ".Date::Manip::Date_Cmp($auxlastlogin,$today));
            if (Date::Manip::Date_Cmp($auxlastlogin,$today)<0) {
                # lastlogin es anterior a hoy
                ##Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
                     C4::AR::Debug::debug("_realizarOperaciones=> t_operacionesDeINTRA\n");
                    _operacionesDeINTRA($socio);     
            }
        }#end if ($lastlogin)
    }# end if ($type eq 'intra')
    elsif ($type eq 'opac') {
        #Si es un usuario de opac que esta sancionado entonces se borran sus reservas
        _operacionesDeOPAC($socio);
    } 
}

=item sub getSessionUserID

    obtiene el userid de la session
    Parametros: 
    $session

=cut
sub getSessionUserID {
	my ($session) = @_;
    unless($session){
        $session = CGI::Session->load();
    }
    return $session->param('userid');
}

=item sub getSessionNroSocio

    obtiene el nroSocio de la session
    Parametros: 
    $session

=cut
sub getSessionNroSocio {
    my $session= CGI::Session->load();
    return $session->param('nro_socio');
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
    print_header($session, $params);
    $template->process($params->{'template_name'},$params) || die "Template process failed: ", $template->error(), "\n";
    exit;
}

=item sub print_header
Funcion que genera y decide si se envia o no la cookie

=cut

sub print_header {
    my($session, $template_params) = @_;
    my $query = new CGI;
    my $cookie = undef;
    my $secure;
    if(_isOPAC($template_params)){
        #si la conexion no es segura no se envía la cookie, en el OPAC la conexion no es segura
        $secure = 0;
    }else{
        $secure = 1;
    }
    $cookie = new CGI::Cookie(  
                                -secure     => $secure, 
                                -httponly   => 1, 
                                -name       =>$session->name, 
                                -value      =>$session->id, 
                                -expires    => '+' .$session->expire. 's', 
                            );
                            
#En el header podría ir esto para la parte de las user pictures, 
# pero no vale la pena no cachear me parece por algo que se hace una vez cada tanto
#                         -Cache_Control => join(', ', qw(
#                                                            private
#                                                            no-cache
#                                                            no-store
#                                                            must-revalidate
#                                                            max-age=0
#                                                            pre-check=0
#                                                            post-check=0
#                                                        )),
                            
    print $query->header(   -cookie=>$cookie, 
                            -type=>'text/html', 
                             charset => C4::Context->config("charset")||'UTF-8', 
                             "Cache-control: public",
                         );
}


=item sub _isOPAC

    Indica si es un requerimiento desde el OPAC o desde la INTRA
    Parametros: 
    $template: template que se creo anteriomente

=cut
sub _isOPAC {
    my($template_params) = @_;
    $template_params->{'type'} = $template_params->{'type'} || 'opac';
    return (($template_params->{'type'} eq 'opac')?1:0);
}


=item sub buildSocioData

    Funcion que a partir del socio fija los parametros para la sesion
    Parametros: la sesion y el socio
=cut

sub buildSocioData{

    my ($session,$socio) = @_;
    use C4::Modelo::UsrSocio;
    
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
    $session->param('usr_ciudad_id',$socio->persona->ciudad_ref->id);
    $session->param('usr_categoria_desc', $socio->categoria->getDescription());
    $session->param('usr_fecha_nac', $socio->persona->getNacimiento());
    $session->param('usr_sexo', $socio->persona->getSexo());
    $session->param('usr_telefono', $socio->persona->getTelefono());
    $session->param('usr_alt_telefono', $socio->persona->getAlt_telefono());
    $session->param('usr_email', $socio->persona->getEmail());
    $session->param('usr_legajo', $socio->persona->getLegajo());
    $session->param('usr_credential_type', $socio->getCredentialType());
}

sub buildSocioDataHashFromSession{

    my ($session) = CGI::Session->load();    
    
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
    $socio_data{'ciudad_ref'}{'id'}         = $session->param('usr_ciudad_id'); 

    return (\%socio_data);
}

sub updateLoggedUserTemplateParams{
	my ($session,$t_params,$socio) = @_;
	buildSocioData($session,$socio);
	$t_params->{'socio_data'} = buildSocioDataHashFromSession();
}

=item sub _getTimeOut

    TimeOut para la sesion

    Parametros: 

=cut
sub _getTimeOut {
    my $timeout = C4::Context->config('timeout')|| C4::AR::Preferencias::getValorPreferencia('timeout') ||600;
    return $timeout;
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
#     C4::AR::Debug::debug("hashear_password=> "._hashear_password(_hashear_password($password, 'MD5_B64'), 'SHA_256_B64'));
    return hashear_password(hashear_password($password, 'MD5_B64'), 'SHA_256_B64');
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
    my  $cipher = Crypt::CBC->new( 
                                    -key    => $key,
                                    -cipher => 'Rijndael',
                                    -salt   => 1,
                            );


    my $plaintext = $cipher->decrypt(decode_base64($texto_a_desencriptar));    

    return C4::AR::Utilidades::trim($plaintext);
}

=item sub _change_Password_Controller

    Esta funcion se encarga de manejar el cambio de la password
    Parametros: 
    $dbh, $query, $userid, $type

=cut
sub _change_Password_Controller {
	my ($query, $userid, $type, $token) = @_;
    if ($type eq 'opac') {
            redirectTo(C4::AR::Utilidades::getUrlPrefix().'/change_password.pl?token='.$token);
    } else {
            redirectTo(C4::AR::Utilidades::getUrlPrefix().'/usuarios/change_password.pl?token='.$token);
    }
}
=item sub cerrarSesion

Funcion que cierra la sesion generando una nueva

=cut

sub cerrarSesion{
    my ($t_params) = @_;
    #se genera un nuevo nroRandom para que se autentique el usuario
    my $nroRandom       = C4::AR::Auth::_generarNroRandom();
    #genero una nueva session
    my ($session)           = CGI::Session->load();
    my $msjCode             = getMsgCode();
    $t_params->{'mensaje'}  = C4::AR::Mensajes::getMensaje($msjCode,'INTRA',[]);
    #se destruye la session anterior
    _eliminarSession($session);
    #se genera una nueva session
    my %params;
    $params{'userid'}               = '';
    $params{'loggedinusername'}     = '';
    $params{'token'}                = '';
    $params{'nroRandom'}            = '';
    $params{'borrowernumber'}       = '';
    $params{'type'}                 = $t_params->{'type'}; #OPAC o INTRA
    $params{'flagsrequired'}        = '';
    $t_params->{'sessionClose'}     = 1;
    $session->param('codMsg', 'U358');
    $session = C4::AR::Auth::_generarSession(\%params);
    redirectToAuth($t_params);
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
    return $token;
}

sub session_destroy {
    my $session = new CGI::Session(undef, undef, undef);
    return $session;
}

=item sub _verificarPassword

    Esta funcion verifica si el usuario y la password ingresada son valida, ya se en LDAP o en la base, segun configuracion de preferencia
    Parametros:
    $userid, $password, $nroRandom

=cut
sub _verificarPassword {
    my ($userid, $password, $nroRandom) = @_;
    my ($socio);
    ## FIXME falta verificar la pass en LDAP si esta esta usando
    if (C4::AR::Preferencias::getValorPreferencia('ldapenabled')){
    #se esta usando LDAP
        if (C4::Context->config('authMERAN')){
            #Autenticacion propia de MERAN
            ($socio) = C4::AR::Authldap::checkpwldap($userid,$password,$nroRandom);
        }
        else { 
            #Autenticacion propia de LDAP, en este caso es recomendable HTTPS
            ($socio) = C4::AR::Authldap::checkpwDC($userid,$password);
        }
     }
    else {
        #Si no se usa LDAP
        ($socio) = _checkpw($userid,$password,$nroRandom); 
    }
    return ($socio);
}

sub redirectTo {
    my ($url) = @_;
#     C4::AR::Debug::debug("redirectTo=>");  
    #para saber si fue un llamado con AJAX
    if(C4::AR::Utilidades::isAjaxRequest()){
    #redirijo en el cliente
#      C4::AR::Debug::debug("redirectTo=> CLIENT_REDIRECT"); 		
        my $session = CGI::Session->load();
        # send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
#         C4::AR::Debug::debug("redirectTo=> url: ".$url);
        print_header($session);
        print 'CLIENT_REDIRECT';
        exit;
	}else{
#        C4::AR::Debug::debug("redirectTo=> SERVER_REDIRECT");       
        my $input = CGI->new(); 
        print $input->redirect( 
            -location => $url, 
            -status => 301,
        ); 
#       C4::AR::Debug::debug("redirectTo=> url: ".$url);
        exit;
    }
}

sub redirectToAuth {
    my ($template_params) = @_;

    my $url;
    $url = C4::AR::Utilidades::getUrlPrefix().'/auth.pl';
    if($template_params->{'loginAttempt'}){
        $url = C4::AR::Utilidades::addParamToUrl($url,'loginAttempt',1);
    }elsif($template_params->{'sessionClose'}){
        $url = C4::AR::Utilidades::addParamToUrl($url,'sessionClose',1);
    } 
    if($template_params->{'mostrar_captcha'}){
        $url = C4::AR::Utilidades::addParamToUrl($url,'mostrarCaptcha',1);
    }

    redirectTo($url);    
}

sub redirectToNoHTTPS {
    my ($url) = @_;
#   C4::AR::Debug::debug("\n");
#   C4::AR::Debug::debug("redirectToNoHTTPS=>");
    #PARA SACAR EL LOCALE ELEGIDO POR EL SOCIO
    my $socio = C4::AR::Auth::getSessionNroSocio();
    $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio) || C4::Modelo::UsrSocio->new();
    #para saber si fue un llamado con AJAX
    if(C4::AR::Utilidades::isAjaxRequest()){
    #redirijo en el cliente
#      C4::AR::Debug::debug("redirectToNoHTTPS=> CLIENT_REDIRECT");         
        my $session = CGI::Session->load();
        # send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
#       C4::AR::Debug::debug("SESSION url: ".$session->param('redirectTo'));
#       C4::AR::Debug::debug("redirectToNoHTTPS=> url: ".$url);
        print_header($session);
        print 'CLIENT_REDIRECT';
        exit;
    }else{
        #redirijo en el servidor
#         C4::AR::Debug::debug("redirectToNoHTTPS=> SERVER_REDIRECT");    
        my $input = CGI->new(); 
        print $input->redirect( 
            -location => "http://".$ENV{'SERVER_NAME'}.$url, 
            -status => 301,
        ); 
#         C4::AR::Debug::debug("redirectTo=> url: ".$url);
        exit;
    }
}

=item sub _opac_logout

    redirecciona a al login correspondiente

=cut
sub _opac_logout{

    if ( C4::AR::Preferencias::getValorPreferencia("habilitar_https") ){
    #se encuentra habilitado https
        redirectToHTTPS(C4::AR::Utilidades::getUrlPrefix().'/login/auth.pl');
    }else{
        redirectTo(C4::AR::Utilidades::getUrlPrefix().'/auth.pl');
    }
}

sub redirectToHTTPS {
    my ($url) = @_;
#     C4::AR::Debug::debug("\n");
#     C4::AR::Debug::debug("redirectToHTTPS=> \n");
    my $puerto = C4::AR::Preferencias::getValorPreferencia("puerto_para_https")||'80';
    my $protocolo = "https";
    if($puerto eq "80"){
        $protocolo = "http";
    }
    #para saber si fue un llamado con AJAX
    if(C4::AR::Utilidades::isAjaxRequest()){
    #redirijo en el cliente
#         C4::AR::Debug::debug("redirectToHTTPS=> CLIENT_REDIRECT\n");         
        my $session = CGI::Session->load();
        # send proper HTTP header with cookies:
        $session->param('redirectTo', $url);
#         C4::AR::Debug::debug("redirectToHTTPS=> url: ".$url."\n");
        print_header($session);
        print 'CLIENT_REDIRECT';
    }else{
    #redirijo en el servidor
#         C4::AR::Debug::debug("redirectToHTTPS=> SERVER_REDIRECT\n");    
        my $input = CGI->new(); 
        print $input->redirect( 
            -location => $protocolo."://".$ENV{'SERVER_NAME'}.":".$puerto.$url,  
            -status => 301,
        ); 
#         C4::AR::Debug::debug("redirectTo=> url: ".$url."\n");
    }
}
=item sub _operacionesDeOPAC

Funcion que realiza las operaciones para un socio cuando se esta logueando en el opac de ser necesario.
Por ejemplo borrar las reservas que tiene si esta sancionado

=cut

sub _operacionesDeOPAC{
	my ($socio) = @_;
#     C4::AR::Debug::debug("_operacionesDeOPAC !!!!!!!!!!!!!!!!!");
    my $msg_object                          = C4::AR::Mensajes::create();
	my $db                                  = $socio->db;
    $db->{connect_options}->{AutoCommit}    = 0;
    $db->begin_work;
	eval{
	    #Si es un usuario de opac que esta sancionado entonces se borran sus reservas
	    my ($isSanction,$endDate)= C4::AR::Sanciones::permisoParaPrestamo($socio, C4::AR::Preferencias::getValorPreferencia("defaultissuetype"));
	    my $regular = $socio->esRegular;
	    my $userid = $socio->getNro_socio();
	    if ($isSanction || !$regular ){
			&C4::AR::Reservas::cancelar_reserva_socio($userid, $socio);
		}

		$db->commit;
	};
	if ($@){
	  #Se loguea error de Base de Datos
	  &C4::AR::Mensajes::printErrorDB($@, 'B411',"OPAC");
	  #Se setea error para el usuario
	  $msg_object->{'error'}= 1;
	  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'R010', 'params' => []} ) ;
	  $db->rollback;
	}
	$db->{connect_options}->{AutoCommit} = 1;
}
=item _operacionesDeOPAC

    Funcion que se invoca cuando ingresa el primer usuario del día en intranet y realiza todas las operaciones necesarias como
    - borrar las reservas de los usuarios sancionados
    - se borran las reservas de los usuarios que no son alumnos regulares
    - se borran las reservas vencidas
    
=cut

sub _operacionesDeINTRA{
	my ($socio) = @_;
     C4::AR::Debug::debug("t_operacionesDeINTRA !!!!!!!!!!!!!!!!!");
    my $msg_object= C4::AR::Mensajes::create();
    my $db= $socio->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    my $userid = $socio->getNro_socio();
	eval{
		my $reserva=C4::Modelo::CircReserva->new(db=> $db);

		#Se borran las reservas vencidas
		C4::AR::Debug::debug("_operacionesDeINTRA=> Se cancelan las reservas vencidas ");
		$reserva->cancelar_reservas_vencidas($userid);

		#Ademas, se borran las reservas vencidas de usuarios con prestamos vencidos
		C4::AR::Debug::debug("_operacionesDeINTRA=> Se cancelan las reservas de usuarios con prestamos vencidos ");
		$reserva->cancelar_reservas_usuarios_morosos($userid);

		#Ademas, se borran las reservas de todos los usuarios sancionados
                C4::AR::Debug::debug("_operacionesDeINTRA=> Se cancelan las reservas de todos los usuarios sancionados ");
		$reserva->cancelar_reservas_sancionados($userid);

		#Ademas, se borran las reservas de los usuarios que no son alumnos regulares
		C4::AR::Debug::debug("_operacionesDeINTRA=> Se cancelan las reservas de los usuarios que no son alumnos regulares ");
		$reserva->cancelar_reservas_no_regulares($userid);
	
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
    $userid, $password, $nroRandom

=cut
sub _checkpw {
    my ($userid, $password, $nroRandom) = @_;
    my ($socio)= C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
    if ($socio){
         C4::AR::Debug::debug("_checkpw=> busco el socio ".$userid."\n");
         return _verificar_password_con_metodo($password, $socio, $nroRandom, getMetodoEncriptacion());
    }
    return 0;
}

sub getMetodoEncriptacion {
    return 'SHA_256_B64';#'MD5'
}

=item sub _verificar_password_con_metodo

    Verifica la password ingresada por el usuario con la password recuperada de la base, todo esto con el metodo indicado por parametros   
    Parametros:
    $socio: recuperada de la base
    $metodo: MD5, SHA
    $nroRandom: el nroRandom previamente generado
    $password: ingresada por el usuario

=cut
sub _verificar_password_con_metodo {
    my ($password, $socio, $nroRandom, $metodo) = @_;
     C4::AR::Debug::debug("_verificar_password_con_metodo=> password del cliente: ".$password."\n");
     C4::AR::Debug::debug("_verificar_password_con_metodo=> password de la base: ".$socio->getPassword."\n");
     C4::AR::Debug::debug("_verificar_password_con_metodo=> nroRandom: ".$nroRandom."\n"); 
     C4::AR::Debug::debug("_verificar_password_con_metodo=> password_hasheada_con_metodo.nroRandom: ".hashear_password($socio->getPassword.$nroRandom, $metodo)."\n");
    if ($password eq hashear_password($socio->getPassword.$nroRandom, $metodo)) {
        #PASSWORD VALIDA
        return $socio;
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
sub hashear_password {
    my ($password, $metodo) = @_;
    if($metodo eq 'SHA'){
        return sha1_hex($password);
    }elsif($metodo eq 'SHA_256_B64'){
        return sha256_base64($password);
    }elsif($metodo eq 'MD5_B64'){
        return md5_base64($password);
    }
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
    if (!$socio) {
        $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
    }
    my $days = C4::AR::Preferencias::getValorPreferencia("keeppasswordalive");
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
    my ($cod_msg,$destination)= @_;
    my ($session) = CGI::Session->load();
    $codMSG = $cod_msg;
    $cod_msg = getMsgCode();
    $session->param('codMsg',$cod_msg);
    if(!$destination){
        $destination=C4::AR::Utilidades::getUrlPrefix().'/informacion.pl';
    }
    C4::AR::Auth::redirectTo($destination);
}

sub get_html_content {
    my($template, $params) = @_;
    my $out = '';
    $template->process($params->{'template_name'},$params,\$out) || die "Template process failed: ", $template->error(), "\n";
    return($out);
}


END { }       # module clean-up code here (global destructor)
1;
__END__
