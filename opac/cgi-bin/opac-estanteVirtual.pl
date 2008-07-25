#!/usr/bin/perl


use strict;
use CGI;
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
# use C4::AR::Estadisticas;

# my $env;
my $input = new CGI;


# my $headerbackgroundcolor='#663266';
# my $circbackgroundcolor='#555555';
# my $circbackgroundcolor='#550000';
# my $linecolor1='#bbbbbb';
# my $linecolor2='#dddddd';
my $type='public';
# my $color='';


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "opac-estanteVirtual.tmpl",
							query => $input,
							type => "opac",
# 							authnotrequired => 1,
							flagsrequired => {borrow => 1},
						});


my $themelang = $template->param('themelang');
open(A, ">>/tmp/debug.txt");
print A "opac-estantevirtual themeland $themelang \n";
close(A);

#Para mandar la dir de mail
my ($borr, $flags) = getpatroninformation(undef, $loggedinuser);
if ($borr and ($borr->{'emailaddress'})){  $template->param(MAIL =>$borr->{'emailaddress'} ); }
#


=item
if (C4::Context->boolean_preference('marc') eq '1') {
        $template->param(script => "MARCdetail.pl");
} else {
        $template->param(script => "opac-detail.pl");
}
=cut

=item
$template->param({	
# 			loggedinuser => $loggedinuser,
#  			pagetitle => "Estantes Virtuales",
# 			headerbackgroundcolor => $headerbackgroundcolor,
# 			circbackgroundcolor => $circbackgroundcolor 
		});
=cut

# SWITCH: {
# 	if ($input->param('viewshelf')) {  viewshelf($input->param('viewshelf'),$template); last SWITCH;}
# 	if ($input->param('shelves')) {  shelves(); last SWITCH;}
# }
my %shelflist;

my $obj=$input->param('obj');
$obj= &C4::AR::Utilidades::from_json_ISO($obj);
# my $startfrom = $input->param('startfrom');

my $funcion= $obj->{'funcion'};
my $ini= $obj->{'ini'}||'';
my $count=0;

my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);

  %shelflist = &GetShelfList($type);
  ($count)= &getshelfListCount($type);

&C4::AR::Utilidades::crearPaginador($template, $count, $cantR, $pageNumber,$funcion);


$template->param({LibraryName => C4::Context->preference("LibraryName")});


my $color='';
my @shelvesloop;

my @key=sort { noaccents($shelflist{$a}->{'shelfname'}) cmp noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);


$ini= $ini*$cantR;
my $fin= $cantR-1+$ini;
my $cantEstantes= scalar(@key);
if($fin > $cantEstantes){
#si hay menos estantes para mostrar que renglones por pagina, el limite es la cantdad de estantes para mostrar
	$fin= $cantEstantes - 1;
}
my @keyAux=@key[$ini..$fin];

foreach my $element (@keyAux) {
		my %line;
# 		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
# 		$line{'color'}= $color;
		$line{'shelf'}=$element;
		#los datos del padre, sirve para la busqueda
#                 $line{'numberparent'}=$shelflist{$element}->{'numberparent'};
		#los datos del padre,sirve para la busqueda
#                 $line{'nameparent'}=$shelflist{$element}->{'nameparent'};
		$line{'shelfname'}=$shelflist{$element}->{'shelfname'};
		$line{'shelfbookcount'}=$shelflist{$element}->{'count'};
		$line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;

		push (@shelvesloop, \%line);
}

$template->param(shelvesloop => \@shelvesloop);

output_html_with_http_headers $input, $cookie, $template->output;

=item
sub shelves {

       if ($input->param('tipo') eq ('addShelves')) {
        if (my $newshelf=$input->param('addBookShelves')) {
                AddShelf($env,$newshelf,$type,0);
        }}
       if ($input->param('tipo') eq ('RemoveShelf')) {
	foreach ($input->param()) {
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
=cut

=item
sub viewshelf {
       
 my ($shelfnumber,$templ)=@_; 

	if ($input->param('tipo') eq ('agregarEstante')) {
        if (my $newshelf=$input->param('addshelves')) {
                my $parent=$input->param('parent');
                AddShelf($env,$newshelf,$type,$parent);
        }}
        
        if ($input->param('tipo') eq ('remShelf')){
          foreach ($input->param()) {
            if (/DEL-(\d+)/) {
                    my $delshelf=$1;
                    my $texto=RemoveShelf($env,$delshelf);
      		    $template->param(textodelete => $texto);                                                                                                          }
          }
        }
           
        if ($input->param('tipo') eq ('addItems')) {
           if (my $newitems=$input->param('addbarcode')) {
                AddToShelf(my $env,$newitems,$shelfnumber);
               }
          }
            
          if ($input->param('tipo') eq ('RemoveItems')){
           foreach ($input->param()) {
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
		     if ($input->param('orden')){$orden=$input->param('orden');}
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
				viewshelf => $shelfnumber#$input->param('viewshelf')
					);
}

=cut