#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Z3950;
use C4::Auth;
use C4::Interface::CGI::Output;
use MARC::Record;
use JSON;

my $input=new CGI;
my $authnotrequired= 0;
my $Messages_arrayref;
my $obj=$input->param('obj');
   $obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipo= $obj->{'tipo'};

if($tipo eq "BUSCAR"){

my $titulo = $obj->{'titulo'};
my $autor = $obj->{'autor'};
my $search='';

if ($titulo ne ''){ 
    $search='title='.$titulo;
    if ($autor ne ''){
        $search.=' and author='.$autor;
    }
        }
elsif ($autor ne '') {
   $search='author='.$autor;
}

my @resultado = C4::AR::Z3950::buscarEnZ3950Async($search);

my ($template, $session, $t_params) = get_template_and_user(
            {template_name => "z3950/resultadoFiltradoZ3950.tmpl",
                    query => $input,
                    type => "intranet",
                    authnotrequired => 0,
                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });

    $t_params->{'RESULTADO'}= \@resultado;
    $t_params->{'cant_resultados'}= scalar(@resultado);

    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}
