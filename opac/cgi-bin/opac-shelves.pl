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
							flagsrequired => {borrow => 1},
						});

# my $obj=$input->param('obj');

# $obj=from_json_ISO($obj);
# my $op= $obj->{'Accion'};

#Para mandar la dir de mail
my ($borr, $flags) = getpatroninformation(undef, $loggedinuser);
if ($borr and ($borr->{'emailaddress'})){  $template->param(MAIL =>$borr->{'emailaddress'} ); }
#

if (C4::Context->boolean_preference('marc') eq '1') {
        $template->param(script => "MARCdetail.pl");
} else {
        $template->param(script => "opac-detail.pl");
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
 			pagetitle => "Estantes Virtuales",
			headerbackgroundcolor => $headerbackgroundcolor,
			circbackgroundcolor => $circbackgroundcolor });

SWITCH: {
	if ($query->param('viewshelf')) {  viewshelf($query->param('viewshelf'),$template); last SWITCH;}
	if ($query->param('shelves')) {  shelves(); last SWITCH;}
}
my %shelflist;
=cut
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
$template->param({LibraryName => C4::Context->preference("LibraryName")});


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
$template->param({LibraryName => C4::Context->preference("LibraryName")});


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

output_html_with_http_headers $query, $cookie, $template->output;

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


       #if ($query->param('tipo') eq ('agregarEstante')) {
	#if (my $newshelf=$query->param('addshelves')) {
         #       my $parent=$query->param('parent');
	#	my ($status, $string) = AddShelf($env,$newshelf,$type,$parent);
	#	if ($status) {
	#		$template->param(status1 => $status, string1 => $string);
#	               	     }
#	}}
#	 if ($query->param('tipo') eq ('remShelf')){ 
 #       my @paramsloop;
#	foreach ($query->param()) {
#		my %line;
#		if (/DEL-(\d+)/) {
#			my $delshelf=$1;
#			my ($status, $string) = RemoveShelf($env,$delshelf);
#			if ($status) {
#				$line{'status'}=$status;
#				$line{'string'} = $string;
#			             }
 #                                }
		#if the shelf is not deleted, %line points on null
#		push(@paramsloop,\%line);
#	}
#	$template->param(paramsloop => \@paramsloop);}

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
		($line{'total'},$line{'unavailable'},$line{'counts'}) = itemcountbibitem($bibitem,'opac'); 
#REHACER LA FUNCION, NO SE SABE PARA QUE SIRVE!!!!!!!!
#SE COPIO LA FUNCION EN EL PL PARA TENERLA DE REFERENCIA---SE TIENE QUE BORRAR!!!!!
				      
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

	$templ->param(	bitemsloop => \@bitemsloop,
                                shelvesloopshelves => \@shelvesloopshelves,
                                parentloop => \@parentloop,  
 	                        shelfname => $shelfname,
                                shelfnumber => $shelfnumber,
 				pagetitle => "Estantes Virtuales",
				viewshelf => $shelfnumber#$query->param('viewshelf')
					);
}


=item
itemcountbibitem
SE USA SOLAMENTE EN opac-shelves.pl
VER SI QUEDA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
=cut
sub itemcountbibitem {

  my ($bibitem,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from branches";
  my $sth=$dbh->prepare($query);
  $sth->execute();
  my %counts;
  while (my $dataorig=$sth->fetchrow_hashref){
  		$counts{$dataorig->{'branchcode'}}{'nombre'}=$dataorig->{'branchcode'};
  	}
  #Cantidad de ejemplares
  my $query2="select holdingbranch, wthdrawn , notforloan, biblioitemnumber from items where items.biblioitemnumber=?";
  if (($type ne 'intra')&&(C4::Context->preference("opacUnavail") eq 0)){
    $query2.=" and (wthdrawn=0 or wthdrawn is NULL or wthdrawn=2)"; #wthdrawn=2 es COMPARTIDO
  			}
  $sth=$dbh->prepare($query2);
  $sth->execute($bibitem);
  my $data;
  my $total=0;
  my $unavailable=0;
  #Fin: Cantidad de ejemplares
  #Los agrupo por holding branch
  while ($data=$sth->fetchrow_hashref) { 
        $counts{$data->{'holdingbranch'}}{'cantXbranch'}++; #Total
	
	if ($data->{'wthdrawn'} eq 2){ #COMPARTIDO
	 $counts{$data->{'holdingbranch'}}{'cantXbranchShared'}++;
	}else {
        if ($data->{'wthdrawn'} >0){
				$counts{$data->{'holdingbranch'}}{'cantXbranchUnavail'}++; #No Disponible 
				$unavailable++;	
				}else{ 
	if ($data->{'notforloan'}){
		$counts{$data->{'holdingbranch'}}{'cantXbranchNotForLoan'}++; # Para Sala
				}else{
		$counts{$data->{'holdingbranch'}}{'cantXbranchForLoan'}++; # Para Prestamo		
				}
				}
		}
				
  	$total++;
             } 
   #Cantidad de ejemplares prestados y/o reservados
   
   my $query2= "SELECT count( * ) AS c, holdingbranch
		FROM issues, items
		WHERE items.biblioitemnumber = ? AND items.itemnumber = issues.itemnumber AND issues.returndate IS NULL
		GROUP BY holdingbranch";
   $sth=$dbh->prepare($query2);                     
   $sth->execute($bibitem);
   while ($data=$sth->fetchrow_hashref){
	$counts{$data->{'holdingbranch'}}{'prestados'}=$data->{'c'};
		}
  $sth->finish;


 my $query3= "SELECT count( * ) AS c, items.holdingbranch
		FROM reserves, biblioitems, items
		WHERE biblioitems.biblioitemnumber = ? AND biblioitems.biblioitemnumber = items.biblioitemnumber AND 
		biblioitems.biblioitemnumber = reserves.biblioitemnumber AND reserves.constrainttype IS NULL  GROUP BY holdingbranch";
   $sth=$dbh->prepare($query3);
   $sth->execute($bibitem);
   while ($data=$sth->fetchrow_hashref){
        $counts{$data->{'holdingbranch'}}{'reservados'}=$data->{'c'};
                }
  $sth->finish;


my @results;
  foreach my $key (keys %counts){	
	if(($type eq 'opac')&&(C4::Context->preference("opacUnavail") eq 0)){ # Si no hay ninguno disponible no lo muestro en el opac
		if (($counts{$key}->{'cantXbranch'})&&($counts{$key}->{'cantXbranch'} gt $counts{$key}->{'cantXbranchUnavail'}))
			{push(@results,$counts{$key});}
			 }
	  else {($counts{$key}->{'cantXbranch'} && push(@results,$counts{$key}));}
	}
  return ($total,$unavailable,\@results);
}




# Local Variables:
# tab-width: 4
# End:
