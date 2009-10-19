package C4::AR::PortadasRegistros;


use strict;
require Exporter;

use C4::Context;
use HTTP::Request;
use LWP::UserAgent;
use C4::AR::Busquedas;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(	
        &getImageByIsbn 
		&getImageForId1 
		&getImageForId2 
		&getLargeImage 
		&insertCover
		&getAllImages
		);


sub getPortadaByIsbn{
my ($isbn) = @_;

    use C4::Modelo::CatPortadaRegistro;
    use C4::Modelo::CatPortadaRegistro::Manager;

    my @filtros;
    push(@filtros, ( isbn    => { eq => $isbn}));

   my $portada_array_ref = C4::Modelo::CatPortadaRegistro::Manager->get_cat_portada_registro( query => \@filtros);

    if (scalar(@$portada_array_ref) == 0){
        return 0;
    }else{
        return $portada_array_ref->[0];
    }
}

sub insertCover {
    my ($isbn,$url,$size)=@_;

    my $portada = C4::AR::PortadasRegistros::getPortadaByIsbn($isbn);

    if (!$portada) {#NO existe, hay que agregarlo
        $portada = C4::Modelo::CatPortadaRegistro->new();
        $portada->setIsbn($isbn);
    }

	if ($size eq 'S') {$portada->setSmall($url);}
	    elsif ($size eq 'M'){$portada->setMedium($url);}	
            else {$portada->setLarge($url);}

    $portada->save;
}

sub getAllImagesByIsbn {
    my ($isbn)=@_;
    C4::AR::PortadasRegistros::getImageByIsbn($isbn,'S');
    C4::AR::PortadasRegistros::getImageByIsbn($isbn,'M');
    C4::AR::PortadasRegistros::getImageByIsbn($isbn,'L');
}

sub getImageByIsbn {
    my ($isbn,$size)=@_;
    my $url="";
    my $path=C4::Context->config("covers"); #Donde se guardan las imagenes
    my $file="";
    my $msg='';

    my $portada = C4::AR::PortadasRegistros::getPortadaByIsbn($isbn);

    if (($portada)&&($size eq 'S')) {$url=$portada->getSmall;}
    elsif (($portada)&&($size eq 'M')) {$url=$portada->getMedium;}
        elsif (($portada)&&($size eq 'L')) {$url=$portada->getLarge;}

    if ($url eq ''){

        my $isbnaux=$isbn;
        #Realiza la Busqueda
        $isbnaux =~ s/-//g; # Quito los - para buscar

        #Armo la URL --> http://covers.openlibrary.org/b/$key/$value-$size.jpg
        $file= $isbnaux."-".$size.".jpg";
        $url= "http://covers.openlibrary.org/b/isbn/".$file."?default=false";

C4::AR::Debug::debug( "Obteniendo : ".$url);
		my $request = HTTP::Request->new(GET => $url);
		my $ua = LWP::UserAgent->new;
 		my $response = $ua->request($request);
        if ($response->is_success) {
		    my $buffer = $response->content;
		    if (!open(WFD,">$path$file")) {
                C4::AR::Debug::debug( "Hay un error y el archivo no puede escribirse en el servidor.");
            }
		    else {
                binmode WFD;
			    print WFD $buffer;
			    close(WFD);
			    C4::AR::PortadasRegistros::insertCover ($isbn,$file,$size);
			    return $file;
            }
        }
        else{
        C4::AR::Debug::debug( $response->status_line);
        }
	}
return $url;
}

sub getImageForId1 {
my ($id1,$size)=@_;
my $url='';

my $isbn = C4::AR::Nivel2::getISBNById1($id1);

if ($isbn) {
my $portada = getPortadaByIsbn($isbn);

    if (($portada)&&($size eq 'S')) {$url=$portada->getSmall;}
    elsif (($portada)&&($size eq 'M')) {$url=$portada->getMedium;}
        elsif (($portada)&&($size eq 'L')) {$url=$portada->getLarge;}
}
return $url;
}


sub getImageForId2 {
    my ($id2,$size)=@_;
    my $url='';

    my $n2r = C4::AR::Nivel2::getISBN($id2);
    my $isbn=$n2r->getDato;

    if ($isbn ne ''){
    $url= getImageByIsbn($isbn,$size);
    }
    return($url);
}


#esto tarda hay que hacerlo cada cierto tiempo!!!
sub getAllImages {

#Busco solo los que tienen ISBN

    open (L,">>/tmp/covers");

    my $repetibles_array_ref = C4::AR::Busquedas::buscarTodosLosDatosDeCampoRepetibleN2("020","a");

    foreach my $n2r (@$repetibles_array_ref)
	{
	printf L "Bajando  ISBN: ".$n2r->getDato."  \n";

	my $urlsmall= getImageByIsbn($n2r->getDato,'S');
	printf L "Url Small: ".$urlsmall."  \n";

	my $urlmedium= getImageByIsbn($n2r->getDato,'M');
	printf L "Url Medium: ".$urlmedium."  \n";

	my $urllarge= getImageByIsbn($n2r->getDato,'L');
	printf L "Url Large: ".$urllarge."  \n";
	}

close L;
}