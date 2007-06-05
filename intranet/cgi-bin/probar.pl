#!/usr/bin/perl

# Carga los modulos requeridos
use HTML::Template;
use strict;
use CGI;
use C4::Output; # contains gettemplate
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Sanctions;
use C4::Context;
                                                                                                                             
my $query=new CGI;
my $date_due=$query->param('date_due') || '1978-05-13'; #fecha en la que tenia que devolver
my $returndate=$query->param('returndate') || '1978-05-13'; #verdadera fecha en la que devolvio
                                                                                                                             
# if its a subject we need to use the subject.tmpl
my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => ('probar.tmpl'),
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {catalogue => 1},
    });


# Se conecta con la base de datos MySql para determinar si el usuario ya existe
my $dbh = C4::Context->dbh;
my $res= SanctionDays($dbh, $returndate, $date_due, 'DO', 'DO');
$template->param(res => $res);
output_html_with_http_headers $query, $cookie, $template->output;
