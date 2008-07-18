#!/usr/bin/perl


use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::Biblio;

my $input = new CGI;
my $biblioitemnumber=$input->param('biblioitemnumber');
my $biblionumber=$input->param('biblionumber');
my $infoIndice=$input->param('indice');
my $tipo=$input->param('tipoAccion')||" ";

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => 'indiceLibro.tmpl',
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {circulate => 1},
    });


if($tipo eq "DELETE"){
	$infoIndice= "";
	$tipo= "UPDATE";
}

if($tipo eq "UPDATE"){
	&insertIndice($biblioitemnumber, $biblionumber, $infoIndice);
}

my ($resultsdata)=&C4::AR::Nivel2::getIndice($biblioitemnumber, $biblionumber);

my $allsubtitles;
my ($subtitlecount,$subtitles) =&subtitle($biblionumber);
if ($subtitlecount) {
	$allsubtitles=" " . $subtitles->[0]->{'subtitle'};
        for (my $i = 1; $i < $subtitlecount; $i++) {
                $allsubtitles.= ", " . $subtitles->[$i]->{'subtitle'};
        } # for
} # if

# getbiblio se elimino
# my ( $bibliocount, @biblios ) = &getbiblio($biblionumber);
my @autorPPAL= &getautor($biblios[0]->{'author'});
my @autoresAdicionales=C4::AR::Nivel1::getAutoresAdicionales($biblionumber);
my @colaboradores=C4::AR::Nivel1::getColaboradores($biblionumber);

$template->param(
		infoIndice => $resultsdata->{'indice'},
 		biblionumber => $biblionumber,
         	biblioitemnumber => $biblioitemnumber,
		TITLE     => $biblios[0]->{'title'},
		UNITITLE    => $biblios[0]->{'unititle'},
            	SUBTITLE    => $allsubtitles,
		AUTHOR    => \@autorPPAL,
		ADDITIONAL => \@autoresAdicionales,
	    	COLABS => \@colaboradores,
);

output_html_with_http_headers $input, $cookie, $template->output;
