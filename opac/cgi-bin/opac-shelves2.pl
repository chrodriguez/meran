#!/usr/bin/perl
#script to provide bookshelf management
# WARNING: This file uses 4-character tabs!
#
# $Header: /cvsroot/koha/koha/shelves.pl,v 1.12.2.1 2004/02/06 14:22:19 tipaul Exp $
#
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
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Estadisticas;

my $mensaje;
my $env;
my $query = new CGI;
my $bibitem = $query->param('viewShelfItems');
my $nameShelf = $query->param('viewShelfName');
my $bib = $query->param('biblio');
my $vol = $query->param('volume');
my $edic = $query->param('edicion');
my $titlebib = $query->param('title');
my $fecha = $query->param('fecha');
my $desc = $query->param('desc');


my $headerbackgroundcolor='#663266';
my $circbackgroundcolor='#555555';
my $circbackgroundcolor='#550000';
my $linecolor1='par';
my $linecolor2='impar';
my $type='public';
my $class='par';
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "opac-shelves.tmpl",
							query => $query,
							type => "opac",
							authnotrequired => 0,
							flagsrequired => {catalogue => 1},
						});

if (C4::AR::Preferencias->getValorPreferencia('marc')) {
        $template->param(script => "MARCdetail.pl");
} else {
        $template->param(script => "detail.pl");
}
=c
if ($query->param('modifyshelfcontents')) {
	my $shelfnumber=$query->param('shelfnumber');
	my $barcode=$query->param('addbarcode');
	#my ($item) = getiteminformation($env, 0, $barcode);
	#AddToShelf($env, $item->{'itemnumber'}, $shelfnumber);
	my $itemnumber=$barcode; 
        AddToShelf($env,$itemnumber,$shelfnumber);
        foreach ($query->param) {
		if (/REM-(\d*)/) {
			my $itemnumber=$1;
			RemoveFromShelf($env, $itemnumber, $shelfnumber);
		}
	}
}
my ($shelflist) = GetShelfList($type);
=cut
$template->param({	loggedinuser => $loggedinuser,
					headerbackgroundcolor => $headerbackgroundcolor,
					circbackgroundcolor => $circbackgroundcolor });

SWITCH: {
	if ($query->param('viewshelf')) {  viewshelf($query->param('viewshelf')); last SWITCH;}
	if ($query->param('shelves')) {  shelves(); last SWITCH;}
}
my %shelflist;
if ($query->param('viewShelfItems')) {
  %shelflist = &getbookshelfItems($type,$bibitem);
  $template->param ({viewShelfItems => $bibitem});
  $template->param ({biblio => $bib});
  $template->param ({volume => $vol});
  $template->param ({edicion => $edic});
  $template->param ({desc => $desc});
  $template->param ({fecha => $fecha});

  $template->param ({titlebib => $titlebib});
  $template->param ({viewShelfItems => $bibitem});
  
}elsif ($nameShelf) { #Buscar por nombre
my $count=0;
my $startfrom = $query->param('startfrom');

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta

my $ini=$query->param('startfrom');
my $cantR=cantidadRenglones();

#FIN inicializacion
  (%shelflist) = &getbookshelfLike($nameShelf, $ini,$cantR);
  ($count)=      &getbookshelfLikeCount($nameShelf);
# sorting out which results to display.
my $num = 1;

$template->param(startfrom => $startfrom+1);
($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$cantR)) : ($template->param(endat => $count));
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$cantR<$count) ? ($startfrom+$cantR) : (-1);my $prevstartfrom=($startfrom-$cantR>=0) ? ($startfrom-$cantR) : (-1);
$template->param(nextstartfrom => $nextstartfrom);
my $displaynext=($nextstartfrom==-1) ? 0 : 1;
my $displayprev=($prevstartfrom==-1) ? 0 : 1;
$template->param(displaynext => $displaynext);
$template->param(displayprev => $displayprev);
$template->param(prevstartfrom => $prevstartfrom);

my $numbers;
@$numbers = ();
if ($count>$cantR) {
    for (my $i=0; $i<($count/$cantR); $i++) {
        my $highlight=0;
        my $break=0;
      my $themelang = $template->param('themelang');
        ($startfrom==($i*$cantR)) && ($highlight=1);
        if ((($i+1) % 29) eq 0){$break=1;}
        push @$numbers, { number => $i+1, highlight => $highlight , break => $break, startfrom => (($i)*$cantR) };
   }
}$template->param({numbers => $numbers});
$template->param({LibraryName => C4::AR::Preferencias->getValorPreferencia("LibraryName")});


#fin de paginacion
  $template->param ({viewShelfItems => $nameShelf});

} else{

my $count=0;
my $startfrom = $query->param('startfrom');

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta

my $ini=0;
if($query->param('startfrom')){$ini=$query->param('startfrom');};
my $cantR=cantidadRenglones();

#if (($query->param('init') eq "")){
 #        $ini=0;}
#else {$ini= ($query->param('init')-1)* $cantR; };

#FIN inicializacion

  %shelflist = &GetShelfList($type, $ini, $cantR);
  ($count)=      &getshelfListCount($type);

#paginacion
# sorting out which results to display.
my $num = 1;

$template->param(startfrom => $startfrom+1);
($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$cantR)) : ($template->param(endat => $count));
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$cantR<$count) ? ($startfrom+$cantR) : (-1);
my $prevstartfrom=($startfrom-$cantR>=0) ? ($startfrom-$cantR) : (-1);
$template->param(nextstartfrom => $nextstartfrom);
my $displaynext=($nextstartfrom==-1) ? 0 : 1;
my $displayprev=($prevstartfrom==-1) ? 0 : 1;
$template->param(displaynext => $displaynext);
$template->param(displayprev => $displayprev);
$template->param(prevstartfrom => $prevstartfrom);



my $numbers;
@$numbers = ();
if ($count>$cantR) {
    for (my $i=0; $i<($count/$cantR); $i++) {
        my $highlight=0;
        my $break=0;
      my $themelang = $template->param('themelang');
        ($startfrom==($i*$cantR)) && ($highlight=1);
        if ((($i+1) % 29) eq 0){$break=1;}

        push @$numbers, { number => $i+1, highlight => $highlight , break => $break, startfrom => (($i)*$cantR) };
   }
}
$template->param({numbers => $numbers});
$template->param({LibraryName => C4::AR::Preferencias->getValorPreferencia("LibraryName")});


#fin de paginacion

}
my $class='par';
my @shelvesloop;

my @key=sort { noaccents($shelflist{$a}->{'shelfname'}) cmp noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);
foreach my $element (@key) {
		my %line;
		($class eq $linecolor1) ? ($class=$linecolor2) : ($class=$linecolor1);
		$line{'clase'}= $class;
		$line{'shelf'}=$element;
		$line{'shelfnumberParent'}=$shelflist{$element}->{'shelfnumberParent'};
		$line{'parentname'}=$shelflist{$element}->{'parentname'};
		$line{'shelfname'}=$shelflist{$element}->{'shelfname'};
		$line{'shelfbookcount'}=$shelflist{$element}->{'count'};
		$line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;

		push (@shelvesloop, \%line);
}
$template->param(shelvesloop => \@shelvesloop
);

output_html_with_http_headers $query, $cookie, $template->output;

sub shelves {
       checkauth($query,0,{editcatalogue => 1},"intranet");
       
       if ($query->param('tipo') eq ('addShelves')) {
        if (my $newshelf=$query->param('addBookShelves')) {
                my $seAgrego=AddShelf($env,$newshelf,$type,0);
	        if ($seAgrego eq 0) {$template->param(mensaje => 'Ya existe un Estante Virtual con el nombre '.$newshelf)}	
        }}
       if ($query->param('tipo') eq ('RemoveShelf')) {
	foreach ($query->param()) {
            if (/SEL-(\d+)/) {
                    my $delshelf=$1;
                    my $res=RemoveShelf($env, $delshelf);
                if ($res ne 0){ $template->param(textodelete => $res);  }  
		}
            }
      }

}

sub viewshelf {
       my $shelfnumber= shift;
       if ($query->param('tipo') eq ('agregarEstante')) {
        if (my $newshelf=$query->param('addshelves')) {
		checkauth($query,0,{editcatalogue => 1},"intranet");
                my $parent=$query->param('parent');
                my $seAgrego=AddShelf($env,$newshelf,$type,$parent);
		 if ($seAgrego eq 0) {$template->param(mensaje => 'Ya existe un Estante Virtual con ese Nombre.')}
        }}
        
        if ($query->param('tipo') eq ('remShelf')){
	checkauth($query,0,{editcatalogue => 1},"intranet");
          foreach ($query->param()) {
            if (/DEL-(\d+)/) {
                    my $delshelf=$1;
                    my $res=RemoveShelf($env,$delshelf);
		  if ($res ne 0){ $template->param(textodelete => $res); }
                  }
          }
        }
           
        if ($query->param('tipo') eq ('addItems')) {
		checkauth($query,0,{editcatalogue => 1},"intranet");
           if (my $newitems=$query->param('addbarcode')) {
                AddToShelf(my $env,$newitems,$shelfnumber);
               }
          }
            
          if ($query->param('tipo') eq ('RemoveItems')){
	  checkauth($query,0,{editcatalogue => 1},"intranet");
           foreach ($query->param()) {
            if (/REM-(\d+)/) {
                    my $itemnumber=$1;
                    RemoveFromShelf($env, $itemnumber, $shelfnumber);
                   }
            }
          }        

       my $shelfname=GetShelfName($env,$shelfnumber);
       my %shelfnameParent=GetShelfParent($env,$type,$shelfnumber);
       
       my ($count,%bitemlist) = GetShelfContents($env, $type,$shelfnumber);
       my (%shelfcontentslist)= GetShelfContentsShelf($env,$type,$shelfnumber);

#para los Superestantes
       my @parentloop;
       my @key=sort { noaccents($shelfnameParent{$a}->{'shelfname'} ) cmp noaccents($shelfnameParent{$b}->{'shelfname'} ) } keys(%shelfnameParent);
       foreach my $element (@key) {
                 my %line;
                ($class eq $linecolor1) ? ($class=$linecolor2) : ($class=$linecolor1);
                $line{'clase'}= $class;
                $line{'shelfname'}=$shelfnameParent{$element}->{'shelfname'};
                $line{'shelfnumber'}=$shelfnameParent{$element}->{'shelfnumber'};
                $line{'count'}=$shelfnameParent{$element}->{'count'};
                $line{'countshelf'}=$shelfnameParent{$element}->{'countshelf'};

                push (@parentloop, \%line);}


#para los subestantes
       my @shelvesloopshelves;
       my @key=sort { noaccents($shelfcontentslist{$a}->{'shelfname'} ) cmp noaccents($shelfcontentslist{$b}->{'shelfname'} ) } keys(%shelfcontentslist);

       foreach my $element (@key) {
                my %line;
                ($class eq $linecolor1) ? ($class=$linecolor2) : ($class=$linecolor1);
                $line{'clase'}= $class;
                $line{'shelfname'}=$shelfcontentslist{$element}->{'shelfname'};
                $line{'shelfnumber'}=$shelfcontentslist{$element}->{'shelfnumber'};
                $line{'count'}=$shelfcontentslist{$element}->{'count'};
		$line{'countshelf'}=$shelfcontentslist{$element}->{'countshelf'};
		push (@shelvesloopshelves, \%line);}

#para los contenidos
	#my $color='';
	my @bitemsloop;
        my @key=sort { noaccents($bitemlist{$a}->{'title'} ) cmp noaccents($bitemlist{$b}->{'title'} ) } keys(%bitemlist);

        foreach my $element (@key) {
                my %line;
                ($class eq $linecolor1) ? ($class=$linecolor2) : ($class=$linecolor1);
                $line{'clase'}= $class;                             
                $line{'biblioitemnumber'}=$bitemlist{$element}->{'biblioitemnumber'};
                $line{'title'}=$bitemlist{$element}->{'title'};
                $line{'biblionumber'}=$bitemlist{$element}->{'biblionumber'};
                $line{'author'}=$bitemlist{$element}->{'author'};
                $line{'place'}=$bitemlist{$element}->{'place'};
                $line{'editors'}=$bitemlist{$element}->{'editors'}; 
                push (@bitemsloop, \%line);
}
 

	  
          #  for (my $i = 0; $i < $count; $i++) {
	#	  my %line;
         #       ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
          #      $line{'biblioitemnumber'}=$bitemlist->[$i]->{'biblioitemnumber'};        
           #     $line{'shelfnumber'}=$bitemlist->[$i]->{'shelfnumber'};  
            #    $line{'color'}=$color;
       	#	 push(@bitemsloop, \%line);
       # } 

	$template->param(	bitemsloop => \@bitemsloop,
                                shelvesloopshelves => \@shelvesloopshelves,
                                parentloop => \@parentloop,  
 	                        shelfname => $shelfname,
                                shelfnumber => $shelfnumber,
 				#startfrom => $query->param('startfrom'),
				viewshelf => $shelfnumber#$query->param('viewshelf')

					);
}

#
# $Log: shelves.pl,v $
# Revision 1.12.2.1  2004/02/06 14:22:19  tipaul
# fixing bugs in bookshelves management.
#
# Revision 1.12  2003/02/05 10:04:14  acli
# Worked around weirdness with HTML::Template; without the {}, it complains
# of being passed an odd number of arguments even though we are not
#
# Revision 1.11  2003/02/05 09:23:03  acli
# Fixed a few minor errors to make it run
# Noted correct tab size
#
# Revision 1.10  2003/02/02 07:18:37  acli
# Moved C4/Charset.pm to C4/Interface/CGI/Output.pm
#
# Create output_html_with_http_headers function to contain the "print $query
# ->header(-type => guesstype...),..." call. This is in preparation for
# non-HTML output (e.g., text/xml) and charset conversion before output in
# the future.
#
# Created C4/Interface/CGI/Template.pm to hold convenience functions specific
# to the CGI interface using HTML::Template
#
# Modified moremembers.pl to make the "sex" field localizable for languages
# where M and F doesn't make sense
#
# Revision 1.9  2002/12/19 18:55:40  hdl
# Templating reservereport et shelves.
#
# Revision 1.9  2002/08/14 18:12:51  hdl
# Templating files
#
# Revision 1.8  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.7  2002/07/05 05:03:37  tonnesen
# Minor changes to authentication routines.
#
# Revision 1.5  2002/07/04 19:42:48  tonnesen
# Minor changes
#
# Revision 1.4  2002/07/04 19:21:29  tonnesen
# Beginning of authentication api.  Applied to shelves.pl for now as a test case.
#
# Revision 1.2.2.1  2002/06/26 20:28:15  tonnesen
# Some udpates that I made here locally a while ago.  Still won't be useful, but
# should be functional
#
#
#




# Local Variables:
# tab-width: 4
# End:
