package C4::Output;

# $Id: Output.pm,v 1.45.2.2 2004/02/29 07:59:08 acli Exp $

#package to deal with marking up output
#You will need to edit parts of this pm
#set the value of path to be where your html lives


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

# NOTE: I'm pretty sure this module is deprecated in favor of
# templates.

use strict;
require Exporter;

#use C4::Context;
use Template;
use Template::Filters;
use HTML::Template; #LUEGO DE PASAR TODO ELIMINAR PM, NO SE USA MAS
use HTML::Template::Expr; #LUEGO DE PASAR TODO ELIMINAR PM, NO SE USA MAS

use C4::AR::Filtros;
use C4::AR::Preferencias;
use C4::AR::Auth;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Output - Functions for generating HTML for the Koha web interface

=head1 SYNOPSIS

  use C4::Output;

  $str = &mklink("http://www.koha.org/", "Koha web page");
  print $str;

=head1 DESCRIPTION

The functions in this module generate HTML, and return the result as a
printable string.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
                gettemplate
         );

#==========================================================FUNCIONES NUEVAS=================================================

sub gettemplate {
    my ($tmplbase, $opac, $loging_out, $socio) = @_;


#     my $preferencias_hash_ref = C4::AR::Preferencias::getPreferenciasByArray(['tema_opac', 'tema_intra', 'defaultUI', 'titulo_nombre_ui']);

# C4::AR::Debug::debug("tema_opac ".$preferencias_hash_ref->{'tema_opac'});

    my $htdocs;
    my $tema_opac   = C4::AR::Preferencias::getValorPreferencia('tema_opac') || 'default';
    my $tema_intra  = C4::AR::Preferencias::getValorPreferencia('tema_intra') || 'default';
    my $temas       = C4::Context->config('temas');
    my $tema;
    my $type;

    if ($opac ne "intranet") {
        $htdocs     = C4::Context->config('opachtdocs');
        $temas      = C4::Context->config('temasOPAC');
        $tema       = $tema_opac;
        $type       = 'OPAC';
    } else {
        $htdocs     = C4::Context->config('intrahtdocs');
        $temas      = C4::Context->config('temas');
        $tema       = $tema_intra;
        $type       = 'INTRA';
    }

    my $filter      = Template::Filters->new({
                            FILTERS => {    'i18n' =>  \&C4::AR::Filtros::i18n, #se carga el filtro i18n
                                },
                    });


    my $template = Template->new({
                    INCLUDE_PATH    => [
                                            "$htdocs",
                                            "$htdocs/includes/",
                                            "$htdocs/catalogacion/",
                                            "$htdocs/includes/popups/",
                                            "$htdocs/includes/menu",
                                            C4::Context->config('includes_general'),
                                    ],
                    ABSOLUTE        => 1,
                    CACHE_SIZE      => 200,
                    COMPILE_DIR     => '/tmp/ttc',
                    RELATIVE        => 1,
                    EVAL_PERL       => 1,
                    LOAD_FILTERS    => [ $filter ],
#                   RELATIVE => 1,
                    }); 

    #se inicializa la hash de los parametros para el template
    my %params = ();

    #se asignan los parametros que son necesarios para todos los templates
    my $ui;
    my $nombre_ui       = '';
    my $default_ui      = C4::AR::Preferencias::getValorPreferencia('defaultUI');
    $ui                 = C4::Modelo::PrefUnidadInformacion->getByCode($default_ui);

    my $date            = C4::AR::Utilidades::getDate();
    if($ui){
        $nombre_ui = $ui->getNombre();
    }

    my $user_theme,
    my $user_theme_intra;
    my ($session)       = CGI::Session->load();

    $user_theme         = $session->param('urs_theme') || $tema_opac;
    $user_theme_intra   = $session->param('usr_theme_intra') || $tema_intra;

    if ($loging_out){
        $user_theme         = $tema_opac;
        $user_theme_intra   = $tema_intra;
    }

    %params= (
# FIXME DEPRECATED
            themelang           => ($opac ne 'intranet'? '/opac-tmpl/': '/intranet-tmpl/') ,
# FIXME DEPRECATED
            interface           => ($opac ne 'intranet'? '/opac-tmpl': '/intranet-tmpl'),
#             sitio               => ($opac ne 'intranet'? 'opac': 'intranet'),  #indica desde donde se hace el requerimiento
            type                => ($opac ne 'intranet'? 'opac': 'intranet'),  #indica desde donde se hace el requerimiento
            tema                => $tema,
            temas               => $temas,
            titulo_nombre_ui    => C4::AR::Preferencias::getValorPreferencia('titulo_nombre_ui'),
            template_name       => "$htdocs/$tmplbase", #se setea el nombre del tmpl
            ui                  => $ui,
            actual_year         => $date->{'year'},
            date                => $date,
            localization_FLAGS  => C4::AR::Filtros::setFlagsLang($type,$user_theme),
            HOST                => $ENV{HTTP_HOST},
            user_theme          => $user_theme,
            user_theme_intra    => $user_theme_intra,
            timeInterval        => C4::AR::Preferencias::getValorPreferencia('timeInterval'),
            url_prefix          => C4::AR::Utilidades::getUrlPrefix(),
            SERVER_ADDRESS      => $ENV{'SERVER_NAME'},
            socio_data          => C4::AR::Auth::buildSocioDataHashFromSession(),
            date_separator      => C4::AR::Filtros::i18n("de"),            
        );

    return ($template, \%params);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
