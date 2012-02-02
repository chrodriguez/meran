#!/usr/bin/perl

require Exporter;

use strict;
use JSON;
use CGI;
use C4::AR::Auth;
use C4::AR::PdfGenerator;


my $input = new CGI;
my ($template, $session, $t_params);

($template, $session, $t_params)        = get_template_and_user({
                        template_name   => "usuarios/reales/libre_deuda.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => {  ui            => 'ANY', 
                                            tipo_documento  => 'ANY', 
                                            accion          => 'CONSULTA', 
                                            entorno         => 'undefined'},
                        debug           => 1,
 });

#my $authnotrequired= 0;

#my ($userid, $session, $flags) = C4::AR::Auth::checkauth(   $input, 
#                                                        $authnotrequired,
#                                                        {   ui => 'ANY', 
#                                                            tipo_documento => 'ANY', 
#                                                            accion => 'CONSULTA', 
#                                                            entorno => 'usuarios',
#                                                            tipo_permiso => 'catalogo'
#                                                        },
#                                                        "intranet"
#                            );

my $nro_socio   = $input->param('nro_socio');
my $msg_object  = C4::AR::Usuarios::_verificarLibreDeuda($nro_socio);

if (!($msg_object->{'error'})){

    # aca armamos toda la data para pasarla a un html
    my $socio                       = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
    
    #si levanta un socio valido
    if($socio){
        my $cuerpo_mensaje              = C4::AR::Preferencias::getValorPreferencia('libreDeudaMensaje');
        my $branchcode                  = C4::AR::Preferencias::getValorPreferencia('defaultUI');
        my $biblio                      = C4::AR::Busquedas::getBranch($branchcode);
        
        $cuerpo_mensaje                 =~ s/SOCIO/$socio->{'persona'}->{'nombre'}\ $socio->{'persona'}->{'apellido'}/;
        $cuerpo_mensaje                 =~ s/UI_NAME/$biblio->{'nombre'}/;
        $cuerpo_mensaje                 =~ s/DOC/$socio->{'persona'}->{'nro_documento'}/;
        
        my @datearr                     = localtime(time);
	    my $anio                        = 1900 + $datearr[5];
	    my $mes                         = &C4::Date::mesString( $datearr[4] + 1 );
	    my $dia                         = $datearr[3];

        $t_params->{'fecha'}            = "La Plata ".$dia." de ".$mes." de ".$anio;
        $t_params->{'biblio'}           = $biblio;
        C4::AR::Utilidades::printHASH($biblio);
        use Encode;
        $t_params->{'cuerpo_mensaje'}   = Encode::decode_utf8($cuerpo_mensaje);
        
        $t_params->{'escudo'}           = C4::Context->config('intrahtdocs') . '/temas/'
                  . C4::AR::Preferencias::getValorPreferencia('defaultUI')
                  . '/imagenes/escudo-DEFAULT'
                  . '.jpg';
            
        $t_params->{'titulo'}           = "CERTIFICADO DE LIBRE DEUDA";
        $t_params->{'atencion'}         =  C4::AR::Preferencias::getValorPreferencia('open') . " a "
            . C4::AR::Preferencias::getValorPreferencia('close') ;

                   
        $t_params->{'print_format'}     = C4::AR::Preferencias::getValorPreferencia('libre_deuda_fill_a4');
        
        C4::AR::Debug::debug("libreeeeeee".C4::AR::Preferencias::getValorPreferencia('libre_deuda_fill_a4'));
        my $out         = C4::AR::Auth::get_html_content($template, $t_params, $session);
        my $filename    = C4::AR::PdfGenerator::pdfFromHTML($out);
        print C4::AR::PdfGenerator::pdfHeader();
# 
        C4::AR::PdfGenerator::printPDF($filename);

	}else{
	    #redirigimos 
	    C4::AR::Auth::redirectTo(C4::AR::Utilidades::getUrlPrefix().'/mainpage.pl?token='.$session->param('token'));
	}
	
} else {
    my $infoOperacionJSON = to_json $msg_object;
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
}
