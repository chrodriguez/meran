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

use C4::AR::Utilidades;
use C4::AR::Estadisticas;

my $env;
my $query = new CGI;
my $nameShelf = $query->param('viewShelfItems');
my $bib = $query->param('biblio');
my $vol = $query->param('volume');
my $edic = $query->param('edicion');
my $titlebib = $query->param('title');
my $fecha = $query->param('fecha');
my $desc = $query->param('desc');


my $headerbackgroundcolor='#663266';
my $circbackgroundcolor='#555555';
my $circbackgroundcolor='#550000';
my $linecolor1='#bbbbbb';
my $linecolor2='#dddddd';
my $type='public';
my $color='';


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "opac-shelves.tmpl",
							query => $query,
							type => "opac",
							authnotrequired => 1,
							flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
						});

# my $obj=$input->param('obj');

# $obj=from_json_ISO($obj);
# my $op= $obj->{'Accion'};

#Para mandar la dir de mail
# getpatroninformation DEPRECATED
my ($borr, $flags) = getpatroninformation($loggedinuser,"");
if ($borr and ($borr->{'emailaddress'})){  $template->param(MAIL =>$borr->{'emailaddress'} ); }
#

if (C4::AR::Preferencias->getValorPreferencia('marc')) {
        $template->param(script => "MARCdetail.pl");
} else {
        $template->param(script => "opac-detail.pl");
}
=item
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
 			pagetitle => "Estantes Virtuales",
			headerbackgroundcolor => $headerbackgroundcolor,
			circbackgroundcolor => $circbackgroundcolor });

SWITCH: {
	if ($query->param('viewshelf')) {  viewshelf($query->param('viewshelf'),$template); last SWITCH;}
	if ($query->param('shelves')) {  shelves(); last SWITCH;}
}
my %shelflist;

=item
if ($query->param('viewShelfItems')) {
  %shelflist = &getbookshelfItems($type,$nameShelf);
    $template->param ({viewShelfItems => $nameShelf});
      $template->param ({biblio => $bib});
        $template->param ({volume => $vol});
	  $template->param ({edicion => $edic});
	    $template->param ({desc => $desc});
	      $template->param ({fecha => $fecha});

	        $template->param ({titlebib => $titlebib});

		}else
=cut		

if ($nameShelf) {                                 #cambiar el  campo por algo de search= shelfsearch

my $count=0;
my $startfrom = $query->param('startfrom');

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta

my $ini=$query->param('startfrom');
my $cantR=cantidadRenglones();

#if (($query->param('init') eq "")){
 #        $ini=0;}
#else {$ini= ($query->param('init')-1)* $cantR; };

#FIN inicializacion
  (%shelflist) = &getbookshelfLike($nameShelf, $ini,$cantR);
  ($count)=      &getbookshelfLikeCount($nameShelf);

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


  $template->param ({viewShelfItems => $nameShelf});
  
  #$template->param ({biblio => $bib});
  #$template->param ({volume => $vol});
  #$template->param ({edicion => $edic});
  #$template->param ({desc => $desc});
  #$template->param ({fecha => $fecha});

  #$template->param ({titlebib => $titlebib});

}
     else{

my $count=0;
my $startfrom = $query->param('startfrom');

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta

my $ini=$query->param('startfrom');
my $cantR=cantidadRenglones();

  %shelflist = &GetShelfList($type,  $ini,$cantR);
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

my $color='';
my @shelvesloop;

my @key=sort { noaccents($shelflist{$a}->{'shelfname'}) cmp noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);
foreach my $element (@key) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}= $color;
		$line{'shelf'}=$element;
		#los datos del padre, sirve para la busqueda
                $line{'numberparent'}=$shelflist{$element}->{'numberparent'};
		#los datos del padre,sirve para la busqueda
                $line{'nameparent'}=$shelflist{$element}->{'nameparent'};
		$line{'shelfname'}=$shelflist{$element}->{'shelfname'};
		$line{'shelfbookcount'}=$shelflist{$element}->{'count'};
		$line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;

		push (@shelvesloop, \%line);
}
$template->param(shelvesloop => \@shelvesloop);

output_html_with_http_headers $cookie, $template->output;

sub shelves {

       if ($query->param('tipo') eq ('addShelves')) {
        if (my $newshelf=$query->param('addBookShelves')) {
                AddShelf($env,$newshelf,$type,0);
        }}
       if ($query->param('tipo') eq ('RemoveShelf')) {
	foreach ($query->param()) {
            if (/SEL-(\d+)/) {
                    my $delshelf=$1;
                    my $texto=RemoveShelf(my $env, $delshelf);
	 	    $template->param(textodelete => $texto);
                   }
            }
      }


	my (%shelflist) = &GetShelfList($type);
 	my $color='';
	my @shelvesloop;
        my @key=sort { noaccents($shelflist{$a}->{'shelfname'} ) cmp noaccents($shelflist{$b}->{'shelfname'} ) } keys(%shelflist);
        foreach my $element (@key) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}=$color;
		$line{'shelf'}=$element;
		$line{'shelfname'}=$shelflist{$element}->{'shelfname'} ;
		$line{'shelfbookcount'}=$shelflist{$element}->{'count'} ; 
                $line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;
		push(@shelvesloop, \%line);
	}
	$template->param(shelvesloop=>\@shelvesloop,
 			pagetitle => "Estantes Virtuales",
							shelves => 1,
						);
}

sub viewshelf {
       
 my ($shelfnumber,$templ)=@_; 

	if ($query->param('tipo') eq ('agregarEstante')) {
        if (my $newshelf=$query->param('addshelves')) {
                my $parent=$query->param('parent');
                AddShelf($env,$newshelf,$type,$parent);
        }}
        
        if ($query->param('tipo') eq ('remShelf')){
          foreach ($query->param()) {
            if (/DEL-(\d+)/) {
                    my $delshelf=$1;
                    my $texto=RemoveShelf($env,$delshelf);
      		    $template->param(textodelete => $texto);                                                                                                          }
          }
        }
           
        if ($query->param('tipo') eq ('addItems')) {
           if (my $newitems=$query->param('addbarcode')) {
                AddToShelf(my $env,$newitems,$shelfnumber);
               }
          }
            
          if ($query->param('tipo') eq ('RemoveItems')){
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
                ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
                $line{'color'}= $color;
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
                ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
                $line{'color'}= $color;
                $line{'shelfname'}=$shelfcontentslist{$element}->{'shelfname'};
                $line{'shelfnumber'}=$shelfcontentslist{$element}->{'shelfnumber'};
                $line{'count'}=$shelfcontentslist{$element}->{'count'};
		$line{'countshelf'}=$shelfcontentslist{$element}->{'countshelf'};
		push (@shelvesloopshelves, \%line);}

#para los contenidos
	#my $color='';

	          ###Matias: Para el orden
		     my $orden='title';
		     if ($query->param('orden')){$orden=$query->param('orden');}
		   ###
		                                        

	my @bitemsloop;
        my @key=sort { noaccents($bitemlist{$a}->{$orden} ) cmp noaccents($bitemlist{$b}->{$orden} ) } keys(%bitemlist);
	
        my $bibitem;
        foreach my $element (@key) {
                my %line;
                ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
                $line{'color'}= $color;
                $line{'biblioitemnumber'}=$bitemlist{$element}->{'biblioitemnumber'};
                $line{'title'}=$bitemlist{$element}->{'title'};
		$line{'unititle'}=$bitemlist{$element}->{'unititle'};
                $line{'biblionumber'}=$bitemlist{$element}->{'biblionumber'};
		##AUTOR###
		$line{'completo'}=$bitemlist{$element}->{'completo'};
		$line{'id'}=$bitemlist{$element}->{'id'};
		#########
                $line{'place'}=$bitemlist{$element}->{'place'};
                $line{'editors'}=$bitemlist{$element}->{'editors'};
		$bibitem=$bitemlist{$element}->{'biblioitemnumber'};
		($line{'total'},$line{'unavailable'},$line{'counts'}) = C4::BookShelves::itemcountbibitem($bibitem,'opac'); 
#REHACER LA FUNCION, NO SE SABE PARA QUE SIRVE!!!!!!!!
#SE COPIO LA FUNCION EN EL PL PARA TENERLA DE REFERENCIA---SE TIENE QUE BORRAR!!!!!
				      
                push (@bitemsloop, \%line);
	}

	$templ->param(	bitemsloop => \@bitemsloop,
                                shelvesloopshelves => \@shelvesloopshelves,
                                parentloop => \@parentloop,  
 	                        shelfname => $shelfname,
                                shelfnumber => $shelfnumber,
 				pagetitle => "Estantes Virtuales",
				viewshelf => $shelfnumber#$query->param('viewshelf')
					);
}

