#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::AR::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $query = new CGI;

my ($template, $t_params)= C4::Output::gettemplate("informacion.tmpl", 'intranet');

my $session = CGI::Session->load();
##En este pl, se muestran todos los mensajes al usuario con respecto a la falta de permisos,
#sin destruir la sesion del usuario, permitiendo asi que navegue por donde tiene permisos
C4::AR::Debug::debug("informacion.pl =>  codMsg: ".$session->param("codMsg"));
$t_params->{'mensaje'}= C4::AR::Mensajes::getMensaje($session->param("codMsg"),'INTRA',[]);





#my $yo = C4::AR::Usuarios::getSocioInfoPorNroSocio("gaspo53");

#$yo->convertirEnSuperLibrarian();

#C4::AR::Debug::debug("SEESION TYPE: ===================>>>>>>>>>>> ".$session->param('type'));

my $nivel2_array_ref = C4::AR::Nivel2::getAllNivel2();

foreach my $nivel2 (@$nivel2_array_ref){

    my $tipo_doc = $nivel2->getTipoDocumento();

    C4::AR::Debug::debug("============== seteando tipo_doc: ".$tipo_doc." al registro: ".$nivel2->nivel1->getId1()." ==============");
    $nivel2->nivel1->setTemplate($tipo_doc);
    C4::AR::Debug::debug("seteando tipo_doc: ".$tipo_doc." al grupo: ".$nivel2->getId2());
    $nivel2->setTemplate($tipo_doc);

    my $nivel3_array_ref = C4::AR::Nivel3::getNivel3FromId2($nivel2->getId2());
    
    foreach my $nivel3 (@$nivel3_array_ref){

        C4::AR::Debug::debug("seteando tipo_doc: ".$tipo_doc." al ejemplar: ".$nivel3->getId());
        $nivel3->setTemplate($tipo_doc);
    }
}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);