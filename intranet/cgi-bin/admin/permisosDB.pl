#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Preferencias;
# use C4::AR::Utilidades;
use JSON;

my $input = new CGI;
# my $obj=$input->param('obj');
# $obj=C4::AR::Utilidades::from_json_ISO($obj);

# my $json = $obj->{'json'};
# my $tabla = $obj->{'tabla'};
# my $tipo = $obj->{'tipo'};
# my $accion = $obj->{'accion'};

# my ($userid, $session, $flags) = checkauth($input, 0,{});
my $accion = undef;
if(!$accion){
    #Busca las preferencias segun lo ingresado como parametro y luego las muestra

    my ($template, $session, $t_params)  = get_template_and_user({	template_name => "admin/permisos.tmpl",
																    query => $input,
																    type => "intranet",
																    authnotrequired => 0,
																    flagsrequired => {parameters => 1},
																    debug => 1,
			        });

    my $combo_tipoDoc = C4::AR::Utilidades::generarComboTipoNivel3();
    $t_params->{'combo_tipoDoc'} = $combo_tipoDoc;
    my $combo_UI = C4::AR::Utilidades::generarComboUI();
    $t_params->{'combo_UI'}=$combo_UI;
    my $combo_permisos = C4::AR::Utilidades::generarComboPermisos();
    $t_params->{'combo_permisos'}=C4::AR::Permisos::comboPermisos();


	C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}#end if($accion eq "BUSCAR_PREFERENCIAS")


