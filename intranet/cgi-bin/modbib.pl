#!/usr/bin/perl

# $Id: modbib.pl,v 1.14 2003/07/15 11:34:52 slef Exp $

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/2002 by hdl@ifrance.com : templating


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

use C4::Search;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Context;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input = new CGI;

my $bibnum=$input->param('bibnum');
my $data=&bibdata($bibnum);
my ($subjectcount, $subject)     = &subject($bibnum);
my ($subtitlecount, $subtitle)   = &subtitle($bibnum);
#my ($addauthorcount, $addauthor) = &addauthor($bibnum);
my $sub        = $subject->[0]->{'nombre'};
#my $additional = $addauthor->[0]->{'author'};
my $subtitles = $subtitle->[0]->{'subtitle'};

my @autorPPAL= &getautor($data->{'author'});
my @autoresAdicionales=&getautoresAdicionales($bibnum);
my @colaboradores=&getColaboradores($bibnum);

my $submit=$input->param('submit.x');
#Matias para ver de donde viene
my $from=$input->param('from');
#


if ($submit eq '') {
  print $input->redirect("/cgi-bin/koha/delbiblio.pl?biblio=$bibnum&from=$from");
} # if

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "modbib.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

# have to get all subtitles, subjects and additional authors
$sub = join("\n", map { $_->{'nombre'} } @{$subject});
$subtitles = join("\n", map { $_->{'subtitle'} } @{$subtitle});

$data->{'title'} = &tidyhtml($data->{'title'});

## Tipos de colaboradores

my %tiposColaboradores=obtenerTiposDeColaboradores();
$tiposColaboradores{0}='--Seleccione uno--';
my @colabtypes;
foreach my $aux  ( sort { $tiposColaboradores{$a} cmp $tiposColaboradores{$b} } keys(%tiposColaboradores)){ push(@colabtypes,$aux);}
my $referenciaColaboradores=CGI::scrolling_list(-name     =>'referenciaColaboradores',
                                                -defaults => 0,
						-values => \@colabtypes,
						-labels    => \%tiposColaboradores,
						-size     => 1,
						-id =>"referenciaColaboradores",
						-onChange=>"cambiarTipo();",
						);

##

$template->param ( biblionumber => $bibnum,
						biblioitemnumber => $data->{'biblioitemnumber'},
						author => \@autorPPAL,
						title => $data->{'title'},
						abstract => $data->{'abstract'},
						subject => $sub,
						seriestitle => $data->{'cdu'},
						additionalauthors => \@autoresAdicionales,
						colaboradores => \@colaboradores,
						subtitle => $subtitles,
						unititle => $data->{'unititle'},
						notes => $data->{'notes'},
						serial => $data->{'serial'},
						responsability => $data->{'responsability'},
						from => $from,
						referenciaColaboradores=> $referenciaColaboradores,
						resp => C4::Context->preference("responsability") 
						# Esta habilitada la mencion de resp.?
						);

output_html_with_http_headers $input, $cookie, $template->output;

sub tidyhtml {
  my ($inp)=@_;
  $inp=~ s/\"/\&quot\;/g;
  return($inp);
}
