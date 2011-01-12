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
use Digest::MD5 qw(md5_base64);
use Digest::SHA  qw(sha1 sha1_hex sha1_base64 sha256_base64 );
use C4::AR::Usuarios qw(getSocioInfoPorNroSocio); #Miguel lo agregue pq sino no ve la funcion esRegular!!!!!!!!!!!!!!!
use Locale::Maketext::Gettext::Functions qw(bindtextdomain textdomain get_handle);
use C4::Output;              # to get the template
use C4::Context;
use C4::Modelo::SistSesion;
use C4::Modelo::SistSesion::Manager;
use C4::Modelo::CircReserva;
use C4::Modelo::UsrSocio;
use C4::Modelo::PrefFeriado;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
my $codMSG = 'U000';
# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Auth - Este modulo es para el manejo de authenticacion en Meran

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

@ISA = qw(Exporter);
@EXPORT = qw(
		&checkauth		
		&get_template_and_user
		&getborrowernumber
		&getuserflags
		&output_html_with_http_headers
		&getSessionUserID
		&getSessionNroSocio
        &redirectAndAdvice
        &_hashear_password
);

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

=iemt sub _getExpireStatus
    Devuelve el valor de la variable de contexto que indica si expiran las sesiones o devuelve true si no esta definido este valor
=cut
sub _getExpireStatus{
  my $expire = C4::Context->config("expire");
  if (defined($expire)){
      C4::AR::Debug::debug("EXPIRA".$expire);
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
    C4::AR::Debug::debug("userid en actualizarSession".$sessionID);
    $session->param('sessionID', $sessionID);
    $session->param('userid', $userid);
    #C4::AR::Debug::debug("userid en actualizarSession actualizado".$session->param('userid'));
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
    C4::AR::Debug::debug(join("\n",@_));
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
    $codMSG = $codMsg;
    _eliminarSession($session);
    $session = C4::Auth::_generarSession();
    $session->param('sessionID', undef);
    #redirecciono a loguin y genero una nueva session y nroRandom para que se loguee el usuario
    $session->param('codMsg', $codMsg);
    C4::AR::Debug::debug("WARNING: ¡¡¡¡Se destruye la session y la cookie!!!!!");
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
    C4::AR::Debug::debug("inicializarAuth => ".$msjCode);
    $t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($msjCode,'INTRA',[]);
    #se destruye la session anterior
    _eliminarSession($session);
    #Genero una nueva sesion.
    my %params;
    $params{'userid'}               = undef;
    $params{'loggedinusername'}     = undef;
    $params{'token'}                = '';
    $params{'nroRandom'}            = C4::Auth::_generarNroRandom();
    $params{'borrowernumber'}       = undef;
    $params{'type'}                 = $t_params->{'type'}; #OPAC o INTRA
    $params{'flagsrequired'}        = '';
    $session                        = C4::Auth::_generarSession(\%params);

    #Guardo la sesion en la base
    #FIXME C4::Auth::_save_session_db($session->param('sessionID'), undef, $params{'ip'} , $params{'nroRandom'}, $params{'token'});
    $t_params->{"nroRandom"}=$params{'nroRandom'};
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
    C4::AR::Debug::debug("la SESSION en el get template and user ".$session);    
    my ($template, $params)     = C4::Output::gettemplate($in->{'template_name'}, $in->{'type'}, $in->{'loging_out'}, $usuario_logueado);

    $in->{'template_params'}    = $params;

    if ( $session->param('userid') ) {
        $params->{'loggedinuser'}       = $session->param('userid');
        $params->{'nro_socio'}          = $session->param('userid');
        $params->{'socio'}              = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});
        if (!$usuario_logueado) {
            $usuario_logueado = C4::Modelo::UsrSocio->new();
        }
    
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
        $socio_data{'ciudad_ref'}{'id'}         = $session->param('usr_ciudad_id');
        $params->{'socio_data'}                 = \%socio_data;
        $params->{'token'}                      = $session->param('token');
        #para mostrar o no algun submenu del menu principal
        $params->{'menu_preferences'}           = C4::AR::Preferencias::getMenuPreferences();
    }

    #se cargan todas las variables de entorno de las preferencias del sistema
    $params->{'limite_resultados_autocompletables'} = C4::AR::Preferencias->getValorPreferencia("limite_resultados_autocompletables");

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

    return $session->param('usr_locale') || C4::Context->config("defaultLang") || 'es_ES';
}

=item
  sub i18n
  setea lo necesario para que el filtro C4::AR::Filtros::i18n pueada realizar la internacionalizacion dinámicamente
=cut
sub _init_i18n {
    my($params) = @_;
    my $locale = C4::Auth::getUserLocale();
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
    my $codeMSG;
    if(defined $session and $session->is_expired()){
        #EXPIRO LA SESION
        $codeMSG='U355';     
        C4::AR::Debug::debug("expiro");    
    }else{
        #NO EXPIRO LA SESION
        _init_i18n({ type => $type });
        if ($session->param('userid')) {
            C4::AR::Debug::debug("no hay userid");    
            #Quiere decir que la sesion existe ahora hay q Verificar condiciones
            if (_cambioIp($session)){
                $codeMSG='U356';             
                C4::AR::Debug::debug("invalida cambioip");    
            } elsif ($session->param('flag') eq 'LOGUIN_DUPLICADO'){
                $codeMSG='U359';            
                C4::AR::Debug::debug("invalida duplicado");    
             } elsif ($session->param('token') ne $token){
                $codeMSG='U354';            
                C4::AR::Debug::debug("invalida token");    
                }else {
                #ESTA TODO OK
                C4::AR::Debug::debug("valida");    
                 return ($codeMSG,"sesion_valida");
            }
          }
        else {
        #Esto quiere decir que la sesion esta bien pero que no hay nadie logueado
        C4::AR::Debug::debug("no hay sesion");    
        return ($codeMSG,"sin_sesion");
        }
    }
    C4::AR::Debug::debug("sesion invalida");    
    return ($codeMSG,"sesion_invalida");
}

=item sub checkauth



=cut


sub checkauth {
    C4::AR::Debug::debug("desde checkauth==================================================================================================");    
    my $context = new C4::Context;
    my $query               = shift;
    my $authnotrequired     = shift;
    my $flagsrequired       = shift;
    my $type                = shift;
    my $change_password     = shift || 0;
    my $template_params     = shift;
    my $socio;
    $type                   = 'opac' unless $type;
    my $demo=C4::Context->config("demo") || 0;
    my $token=_obtenerToken($query);
    my $loggedin = 0;
    my ($session) = CGI::Session->load();
    my $userid= $session->param('userid');
    my $flags=0;
    my $time = localtime(time());
    if ($demo){
        #Quiere decir que no es necesario una autenticacion
        $userid="demo";
        $flags=1;
        _actualizarSession($userid, $userid,$userid, $time, '', $type, $flagsrequired, _generarToken(), $session);
        $socio=C4::Modelo::UsrSocio->new();
        return ($userid, $session, $flags, $socio);
    }
    else
    {
        #No es DEMO hay q hacer todas las comprobaciones de la sesion
        my ($codeMSG,$estado)=_verificarSession($session,$type,$token);
        if ($estado eq "sesion_valida"){ 
            $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($session->param('userid'));
            $flags=$socio->tienePermisos($flagsrequired);
            if ($flags) {
                $loggedin = 1;
            } else {
                #redirecciono a una pagina informando q no tiene  permisos
                $session->param('codMsg', 'U354');
                $session->param('redirectTo', '/cgi-bin/koha/informacion.pl');
                redirectTo('/cgi-bin/koha/informacion.pl');
            }
        } 
        elsif ($estado eq "sesion_invalida") { 
            _destruirSession('U406', $template_params);
            $session->param('codMsg', $codeMSG);
            $session->param('redirectTo', '/cgi-bin/koha/auth.pl');
            redirectTo('/cgi-bin/koha/auth.pl'); 
        } 
        elsif ($estado eq "sin_sesion") { 
            #ESTO DEBERIA PASAR solo cuando la sesion esta sin iniciar
            #_destruirSession('U406', $template_params);
            $session->param('codMsg', $codeMSG);
            }
        else { 
            #ESTO MENOS
            _destruirSession('U406', $template_params);
            $session->param('codMsg', $codeMSG);
            $session->param('redirectTo', '/cgi-bin/koha/error.pl');
            redirectTo('/cgi-bin/koha/error.pl'); 
        }
        
        #por aca se permite llegar a paginas que no necesitan autenticarse
        my $insecure = C4::AR::Preferencias->getValorPreferencia('insecure');
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
            my $nroRandom   = $session->param('nroRandom');
            C4::AR::Debug::debug("checkauth=> nroRandom desde la session: ".$nroRandom);
            #se verifica la password ingresada
            my ($passwordValida, $cardnumber, $branch) = _verificarPassword($userid,$password,$nroRandom);
            C4::AR::Debug::debug("la pass es valida?".$passwordValida);
            if ($passwordValida) {
            #se valido la password y es valida
            #setea loguins duplicados si existe, dejando logueado a un solo usuario a la vez
                _setLoguinDuplicado($userid,  $ENV{'REMOTE_ADDR'});
                $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($userid);
                # TODO todo esto va en una funcion
                $sessionID  = $session->param('sessionID');
                $sessionID.="_".$branch;
                _actualizarSession($sessionID, $userid, $socio->getNro_socio(), $time, '', $type, $flagsrequired, _generarToken(), $session);
                C4::AR::Debug::debug("userid en actualizarSession actualizadoarafue".$session->param('userid'));
                buildSocioData($session,$socio);
                C4::AR::Debug::debug($session->param('usr_apellido'));
                #Logueo una nueva sesion
                _session_log(sprintf "%20s from %16s logged out at %30s.\n", $userid,$ENV{'REMOTE_ADDR'},$time);
                #por defecto no tiene permisos
                if( $flags = $socio->tienePermisos($flagsrequired) ){
                    _realizarOperacionesLogin($type,$socio);
                }
                #Si se logueo correctamente en intranet entonces guardo la fecha
                my $now = Date::Manip::ParseDate("now");
                $socio->setLast_login($now);
                $socio->save();
                if ($type eq 'opac') {
                    $session->param('redirectTo', '/cgi-bin/koha/opac-main.pl?token='.$session->param('token'));
                    redirectToNoHTTPS('/cgi-bin/koha/opac-main.pl?token='.$session->param('token'));
                    #$session->secure(0);
                }else{
                    #C4::AR::Debug::debug("DESDE Auth, redirect al MAIN");
                    $session->param('redirectTo', '/cgi-bin/koha/mainpage.pl?token='.$session->param('token'));
                    redirectTo('/cgi-bin/koha/mainpage.pl?token='.$session->param('token'));
                }

            }else{
                #usuario o password invalida
                if ($userid) {
                    #intento de loguin
                    $template_params->{'loginAttempt'} = 1;
                    _destruirSession('U406', $template_params);
                }
                #genero una nueva session y redirecciono a auth.tmpl para que se loguee nuevamente
                redirectToAuth($template_params);
            }#end if ($passwordValida)
        }# end unless ($userid)
    }# el else de DEMO
}# end checkauth

=item sub _realizarOperacionesLogin

Funcion que realiza todas las operaciones asociadas a un inicio de sesion como ser, revisar si ayer fue feriado y dar de baja reservas de acuerdo a las sanciones

=cut

sub _realizarOperacionesLogin{
    my ($type,$socio)=@_;
    C4::AR::Debug::debug("_realizarOperacionesLOGIN=> t_operacionesDeINTRA\n");
    #WARNING: Cuando pasan dias habiles sin actividad se consideran automaticamente feriados
    #my $sth=$dbh->prepare("SELECT MAX(last_login) AS lastlogin FROM usr_socio");
    #$sth->execute();
    #my $lastlogin= $sth->fetchrow;
    my $dateformat = 'iso';
    my $lastlogin= C4::AR::Usuarios::getLastLoginTime($type);
    my $prevWorkDate = C4::Date::format_date_complete(Date::Manip::Date_PrevWorkDay("today",1),$dateformat);
    C4::AR::Debug::debug("_realizarOperacionesLOGIN=> t_operacionesDeINTRA lastlogin".$lastlogin);
    C4::AR::Debug::debug("_realizarOperacionesLOGIN=> t_operacionesDeINTRA prevWorkDate".$prevWorkDate);
    my $enter=0;
    if ($lastlogin){
        while (Date::Manip::Date_Cmp($lastlogin,$prevWorkDate)<0) {
            C4::AR::Debug::debug("_realizarOperacionesLOGIN=> t_operacionesDeINTRA lastlogin".$lastlogin);
            my $nextWorkingDay=C4::Date::format_date_complete(Date::Manip::Date_NextWorkDay($lastlogin,1),$dateformat);
            C4::AR::Debug::debug("_realizarOperacionesLOGIN=> t_operacionesDeINTRA nextworkingDay".$nextWorkingDay);
            if(Date::Manip::Date_Cmp($nextWorkingDay,$prevWorkDate)<=0) {
                my $feriado= C4::Modelo::PrefFeriado->new();
                $feriado->agregar(C4::Date::format_date_in_iso($nextWorkingDay,$dateformat),"true","Biblioteca sin actividad");
                }
            $lastlogin=$nextWorkingDay;
            $enter=1;
        }
        #Genera una comprobacion una vez al dia, cuando se loguea el primer usuario
        my $today = C4::Date::format_date_in_iso(Date::Manip::ParseDate("today"),$dateformat);
        if (Date::Manip::Date_Cmp($lastlogin,$today)<0) {
            # lastlogin es anterior a hoy
            if ($type eq 'intranet') {
            ##Si es un usuario de intranet entonces se borran las reservas de todos los usuarios sancionados
                C4::AR::Debug::debug("_realizarOperaciones=> t_operacionesDeINTRA\n");
                _operacionesDeINTRA($socio);
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
        _operacionesDeOPAC($socio);
    } 
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
    print $query->header(-cookie=>$cookie, -type=>'text/html', charset => C4::Context->config("charset")||'UTF-8', "Cache-control: public");
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


=item sub _getTimeOut

    TimeOut para la sesion

    Parametros: 

=cut
sub _getTimeOut {
    my $timeout = C4::AR::Preferencias->getValorPreferencia('timeout') || C4::Context->config('timeout') ||600;
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
    C4::AR::Debug::debug("_hashear_password=> "._hashear_password(_hashear_password($password, 'MD5_B64'), 'SHA_256_B64'));
    return _hashear_password(_hashear_password($password, 'MD5_B64'), 'SHA_256_B64');
}


=item sub desencriptar

    Esta funcion desencripta el texto_a_desencriptar con la clave $key usando AES
    Parametros: 
    $texto_a_desencriptar
    $key= clave para desencriptar

=cut
sub desencriptar{
    my ($texto_a_desencriptar, $key) = @_;
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
            redirectTo('/cgi-bin/koha/change_password.pl?token='.$token);
    } else {
            redirectTo('/cgi-bin/koha/usuarios/change_password.pl?token='.$token);
    }
}
=item sub cerrarSesion

Funcion que cierra la sesion generando una nueva

=cut

sub cerrarSesion{
    my ($t_params) = @_;
    #se genera un nuevo nroRandom para que se autentique el usuario
    my $nroRandom       = C4::Auth::_generarNroRandom();
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
    $session = C4::Auth::_generarSession(\%params);
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
    $dbh, $userid, $password, $nroRandom

=cut
sub _verificarPassword {
	my ($userid, $password, $nroRandom) = @_;
    C4::AR::Debug::debug("_verificarPassword=> verificarPassword:");
    C4::AR::Debug::debug("_verificarPassword=> userID: ".$userid);
    C4::AR::Debug::debug("_verificarPassword=> nroRandom: ".$nroRandom);
    # Si se quiere dejar de usar el servidor ldap para hacer la autenticacion debe cambiarse 
    # la llamada a la funcion checkpwldap por checkpw
	my ($passwordValida, $cardnumber, $ui);
    ## FIXME falta verificar la pass en LDAP si esta esta usando
	if ( C4::AR::Preferencias->getValorPreferencia('ldapenabled')) {
	#se esta usando LDAP
		($passwordValida, $cardnumber, $ui) = checkpwldap($userid,$password,$nroRandom);
	} else {
         ($passwordValida, $cardnumber, $ui) = _checkpw($userid,$password,$nroRandom); 
	}
    C4::AR::Debug::debug("_verificarPassword=> password valida?: ".$passwordValida);
	return ($passwordValida, $cardnumber, $ui);
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
        C4::AR::Debug::debug("redirectTo=> url: ".$url);
        print_header($session);
 		print 'CLIENT_REDIRECT';
        exit;
	}else{
        C4::AR::Debug::debug("redirectTo=> SERVER_REDIRECT");       
		my $input = CGI->new(); 
		print $input->redirect( 
					-location => $url, 
					-status => 301,
		); 
        C4::AR::Debug::debug("redirectTo=> url: ".$url);
        exit;
	}
    
}

sub redirectToAuth {
    my ($template_params) = @_;
    my $url;
    $url = '/cgi-bin/koha/auth.pl';
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
        print_header($session);
        print 'CLIENT_REDIRECT';
        exit;
    }else{
        #redirijo en el servidor
        C4::AR::Debug::debug("redirectToNoHTTPS=> SERVER_REDIRECT");    
        my $input = CGI->new(); 
        print $input->redirect( 
            -location => "http://".$ENV{'SERVER_NAME'}.$url, 
            -status => 301,
        ); 
        C4::AR::Debug::debug("redirectTo=> url: ".$url);
        exit;
    }
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
        print_header($session);
        print 'CLIENT_REDIRECT';
    }else{
    #redirijo en el servidor
        C4::AR::Debug::debug("redirectToHTTPS=> SERVER_REDIRECT\n");    
        my $input = CGI->new(); 
        print $input->redirect( 
            -location => $protocolo."://".$ENV{'SERVER_NAME'}.":".$puerto.$url,  
            -status => 301,
        ); 
        C4::AR::Debug::debug("redirectTo=> url: ".$url."\n");
    }
}
=item sub _operacionesDeOPAC

Funcion que realiza las operaciones para un socio cuando se esta logueando en el opac de ser necesario.
Por ejemplo borrar las reservas que tiene si esta sancionado

=cut

sub _operacionesDeOPAC{
	my ($socio) = @_;
    C4::AR::Debug::debug("_operacionesDeOPAC !!!!!!!!!!!!!!!!!");
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
		#Se borran las reservas de todos los usuarios sancionados
		$reserva->cancelar_reservas_sancionados($userid);
		#Ademas, se borran las reservas de los usuarios que no son alumnos regulares
		$reserva->cancelar_reservas_no_regulares($userid);
		#Ademas, se borran las reservas vencidas
		$reserva->cancelar_reservas_vencidas($userid, $db);	
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
        if ( ($socio->persona)&&($socio->getActivo) ) {
            C4::AR::Debug::debug("_checkpw=> tengo persona y socio\n");
            #existe el socio y se encuentra activo
            my $hashed_password= $socio->getPassword;
            my $ui= $socio->getId_ui;
            my $dni= $socio->persona->getNro_documento;
            return _verificar_password_con_metodo($hashed_password, $password, $dni, $nroRandom, _getMetodoEncriptacion()), $userid, $ui;
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
    my ($hashed_password, $password, $dni, $nroRandom, $metodo) = @_;
    C4::AR::Debug::debug("_verificar_password_con_metodo=> password del cliente: ".$password."\n");
    C4::AR::Debug::debug("_verificar_password_con_metodo=> password de la base: ".$hashed_password."\n");
    C4::AR::Debug::debug("_verificar_password_con_metodo=> password_hasheada_con_metodo.nroRandom: "._hashear_password($hashed_password.$nroRandom, $metodo)."\n");
    if ($password eq _hashear_password($hashed_password.$nroRandom, $metodo)) {
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






