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

    my ($cant, $catalogaciones_array_ref) = &C4::AR::Catalogacion::getCatalogaciones($nivel,$itemType);
    my @results;
    for (my $i=0; $i < $cant; $i++){
        
        my %row = (
                catalogacion => $catalogaciones_array_ref->[$i],
        );
    
        push(@results, \%row);
    }
   
    $t_params->{'RESULTDATA'}= \@results;
    $t_params->{'nivel'}= $nivel;
		    
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}