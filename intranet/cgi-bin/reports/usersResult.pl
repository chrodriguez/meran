#!/usr/bin/perl



# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;
use C4::Koha;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/usersResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $orden;
if ($input->param('orden') eq ""){
	 $orden='cardnumber'
}
else {
	$orden=$input->param('orden')
};

my $year = $input->param('year');
my $categ= $input->param('categoria');
my @chck=split('#',$input->param('chck'));
my $usos=$input->param('usos');
my $branch=$input->param('branch');


my $ini= ($input->param('ini'));
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

#esto se tiene q hacer todo dentro de usuarios ARREGLAR!!!!!!!!!!!!!!
my $cantidad =cantidadUsuarios($branch,$year,$usos,$categ,@chck);#Obtengo la cantidad total de usuarios para poder paginar
#Obtengo los usuarios de una pagina dada
my (@resultsdata)= usuarios($branch,$orden,$ini,$cantR,$year,$usos,$categ,@chck);
my ($template, $ini)=C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,"consultar");


$template->param( 	orden		 => $orden,
			resultsloop      => \@resultsdata,
			cantidad  	 => $cantidad
		);

output_html_with_http_headers $input, $cookie, $template->output;
