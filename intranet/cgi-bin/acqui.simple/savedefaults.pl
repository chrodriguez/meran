#!/usr/bin/perl

# $Id: saveitem.pl,v 1.8 2003/05/04 03:16:15 rangi Exp $

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

use CGI;
use strict;
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;


my $input            = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});
my $barcode          = $input->param('barcode');
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');
my $responsable      = $input->param('userloggedname');

=item
my $item             = {
    biblionumber     => $biblionumber,
    biblioitemnumber => $biblioitemnumber?$biblioitemnumber:"",
    homebranch       => $input->param('homebranch'),
    holdingbranch    => $input->param('homebranch'), #esta es la linea que agregue
    replacementprice => $input->param('replacementprice')?$input->param('replacementprice'):"",
    #Agregado el bulk por Einar, el bulk es la signatura topografica 
    bulk        => $input->param('bulk')?$input->param('bulk'):"",
    #Corregido el notes por el itemsnotes porque las notas del item son el items note
    itemnotes        => $input->param('itemnotes')?$input->param('itemnotes'):"",
    #Agregado por Einar, para saber si es para sala o si esta perdido o si esta withdrawn y modificado por Matias
    notforloan        => $input->param('notforloan')?$input->param('notforloan'):"",
    withdrawn        => $wthdrawn,
}; # my $item
=cut

my $biblioitem       = {
    biblionumber      => $biblionumber,
    itemtype          => $input->param('itemtype'),
    isbncode          => $input->param('isbncode')?$input->param('isbncode'):"",
    #isbn2             => $input->param('isbnSec')?$input->param('isbnSec'):"",#ISBN secundario para algunos casos especiales
    publishercode     => $input->param('publishercode')?$input->param('publishercode'):"",
    publicationyear   => $input->param('publicationyear')?$input->param('publicationyear'):"",
    place             => $input->param('place')?$input->param('place'):"",
    #Country, language, support y series fueron agregados por Einar.
    serie             => $input->param('serie')?$input->param('serie'):"",
    support           => $input->param('support')?$input->param('support'):"",
    country           => $input->param('country')?$input->param('country'):"",
    language          => $input->param('language')?$input->param('language'):"",
    classification    => $input->param('level')?$input->param('level'):"",
    
    illus             => $input->param('illus')?$input->param('illus'):"",
    url               => $input->param('url')?$input->param('url'):"",
    dewey             => $input->param('dewey')?$input->param('dewey'):"",
    issn              => $input->param('issn')?$input->param('issn'):"",
    lccn              => $input->param('lccn')?$input->param('lccn'):"",
    volume            => $input->param('volume')?$input->param('volume'):"",
    number            => $input->param('number')?$input->param('number'):"",
    volumeddesc       => $input->param('volumeddesc')?$input->param('volumeddesc'):"",
    pages             => $input->param('pages')?$input->param('pages'):"",
    size              => $input->param('size')?$input->param('size'):"",
    bnotes            => $input->param('notes')?$input->param('notes'):"",
    
}; # my biblioitem

my $newgroup = 0;
my $website  = 0;
my $count;
my @results;
my $tipo=$input->param('tipo');

&guardarDefaults($biblioitem);




print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber");
