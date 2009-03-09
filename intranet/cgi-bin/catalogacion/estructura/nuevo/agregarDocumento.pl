#!/usr/bin/perl

# $Id: addbiblio.pl,v 1.32.2.7 2004/03/19 08:21:01 tipaul Exp $

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

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use JSON;
my $input = new CGI;


my ($template, $session, $t_params) = get_template_and_user ({
                                                template_name	=> 'catalogacion/estructura/nuevo/agregarDocumento.tmpl',
                                                query		=> $input,
                                                type		=> "intranet",
                                                authnotrequired	=> 0,
                                                flagsrequired	=> { circulate => 1 },
    					});

my $nivel=1;

my %params_combo;
$params_combo{'onChange'}= 'mostrarEstructuraDelNivel1()';
$params_combo{'default'}= 'SIN SELECCIONAR';
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'selectItemType'}= $comboTiposNivel3;

# Campos fijos del nivel 2 y 3
$params_combo{'default'}= 'SIN SELECCIONAR';
$params_combo{'id'}= 'id_ui_origen';
$params_combo{'onChange'}= '';
my $comboSelectUIOrigen= &C4::AR::Utilidades::generarComboUI(\%params_combo);
$t_params->{'selectUIOrigen'}= $comboSelectUIOrigen;

$params_combo{'default'}= 'SIN SELECCIONAR';
$params_combo{'id'}= 'id_ui_poseedora';
$params_combo{'onChange'}= '';
my $comboSelectUIPoseedora= &C4::AR::Utilidades::generarComboUI(\%params_combo);
$t_params->{'selectUIPoseedora'}= $comboSelectUIPoseedora;

$params_combo{'id'}= 'id_tipo_documento';
my $comboTipoNivel3Fijo= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'comboTipoDocumento'}= $comboTipoNivel3Fijo;

$t_params->{'nivel'}= $nivel;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
