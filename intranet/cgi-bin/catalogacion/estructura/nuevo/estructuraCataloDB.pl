#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;


my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";
my $nivel=$obj->{'nivel'};
my $itemType='ALL';
if($nivel > 1){
    $itemType=$obj->{'itemtype'};
}

if($tipoAccion eq "MOSTRAR_CAMPOS"){
#Se muestran las catalogaciones

    my ($template, $session, $t_params) = get_template_and_user({
                                                        template_name => "catalogacion/estructura/nuevo/mostrarCatalogacion.tmpl",
			                                            query => $input,
			                                            type => "intranet",
			                                            authnotrequired => 0,
			                                            flagsrequired => {editcatalogue => 1},
			                                            debug => 1,
			        });


    my @results = &buscarCamposModificados($nivel,$itemType);
    
    my $cant= scalar(@results); #Para ver si se muestra la tabla o no en el template
    
    $t_params->{'RESULTDATA'}= \@results;
    $t_params->{'nivel'}= $nivel;
    $t_params->{'cant'}= $cant;
		    
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}