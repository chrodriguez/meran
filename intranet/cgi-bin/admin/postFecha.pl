#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Novedades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "admin/feriados.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'usuarios'},
                                    debug => 1,
                });


my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $fecha = $obj->{'date'};
my $status = $obj->{'stat'};
my $feriado = $obj->{'feriado'};

C4::AR::Utilidades::setFeriado($fecha,$status,$feriado);

C4::AR::Auth::print_header($session);

