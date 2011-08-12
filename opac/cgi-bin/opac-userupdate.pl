#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;
use C4::Date;

my $query = new CGI;

my $input = $query;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-main.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
             });


my $nro_socio = C4::AR::Auth::getSessionNroSocio();

my ($socio, $flags) = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

C4::AR::Validator::validateObjectInstance($socio);

my %data_hash;
my $msg_object = C4::AR::Mensajes::create();
$data_hash{'nombre'} = $input->param('nombre');
$data_hash{'apellido'} = $input->param('apellido');
$data_hash{'direccion'} = $input->param('direccion');
$data_hash{'numero_telefono'} = $input->param('telefono');
$data_hash{'id_ciudad'} = $input->param('id_ciudad');
$data_hash{'email'} = $input->param('email');
$data_hash{'actualPassword'} = $input->param('actual_password');
$data_hash{'newpassword'} = $input->param('new_password1');
$data_hash{'newpassword1'} = $input->param('new_password2');
$data_hash{'tema'} = $input->param('temas_opac') || 0;

my $fields_to_check = ['nombre','apellido','direccion','numero_telefono','id_ciudad','email'];
my $update_password = C4::AR::Utilidades::validateString($data_hash{'actualPassword'});

if ($update_password){
    $fields_to_check = ['nombre','apellido','direccion','numero_telefono','id_ciudad','email', 'actualPassword','newpassword','newpassword1'];
}

if (C4::AR::Validator::checkParams('VA002',\%data_hash,$fields_to_check)){
	my $cod_msg = undef;
	
    if ($update_password){
        $data_hash{'nro_socio'} = $socio->getNro_socio;
        $msg_object = C4::AR::Usuarios::cambiarPassword(\%data_hash);
    }

    if (!$msg_object->{'error'}){
    	eval {
	        $socio->persona->modificarVisibilidadOPAC(\%data_hash);
	        $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio->getNro_socio);
	        C4::AR::Auth::buildSocioData($session,$socio);
            $cod_msg = 'U338';
    	};
    	
    	if (@$){
    		$cod_msg = 'U339';
    	}
    }else{
       $cod_msg = C4::AR::Mensajes::getFirstCodeError($msg_object);
    }


    C4::AR::Mensajes::add($msg_object, {'codMsg'=> $cod_msg, 'params' => []} ) ;
    $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje($cod_msg,'opac');
    
    if ($data_hash{'tema'}){
        $socio->setThemeSave($data_hash{'tema'});
    }

    my $dateformat = C4::Date::get_date_format();


    $t_params->{'partial_template'}= "informacion.inc";
}else{
    $t_params->{'combo_temas'} = C4::AR::Utilidades::generarComboTemasOPAC();
    $t_params->{'socio'} = $socio;
    $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje('VA002','opac');
    $t_params->{'partial_template'}= "opac-modificar_datos.inc";
}

$t_params->{'socio'}= $socio;
$t_params->{'opac'} = 1;

C4::AR::Auth::updateLoggedUserTemplateParams($session,$t_params,$socio);

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
