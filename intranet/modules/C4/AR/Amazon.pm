package C4::AR::Amazon;


use strict;
require Exporter;

use C4::Context;
use Net::Amazon;
use Net::Amazon::Request::ISBN;
use HTTP::Request;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(	&getImageByIsbn 
		&getImageForId1 
		&getImageForId2 
		&getLargeImage
		&getCover 
		&insertCover
		&getAllImages
		);



sub insertCover {
my ($isbn,$url,$size)=@_;
my $sql="";
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select count(*) from cat_tapa_amazon where isbn = ? ;");
$sth->execute($isbn);

if ($sth->fetchrow > 0) { #Existe, hay que actualizarlo
	if ($size eq 'small') {$sql = "Update cat_tapa_amazon set small =? where isbn = ? ;";}
	elsif ($size eq 'medium'){$sql = "Update cat_tapa_amazon set medium=? where isbn = ? ;";}	
        else {$sql = "Update cat_tapa_amazon set large=? where isbn = ? ;";}
} else { #NO existe, hay que agregarlo
if ($size eq 'small') {$sql = "Insert into cat_tapa_amazon (small,isbn) values (?,?) ;";}
         elsif ($size eq 'medium') {$sql = "Insert into cat_tapa_amazon (medium,isbn) values (?,?) ;";}
		else {$sql = "Insert into cat_tapa_amazon (large,isbn) values (?,?) ;";}
}

my $sth2=$dbh->prepare($sql);
$sth2->execute($url,$isbn);
}

sub getCover { #Recupero una URL de la base
my ($isbn,$size)=@_;
my $url='';
my $sql='';
if ($size eq 'small') {$sql = "Select small from cat_tapa_amazon where isbn= ? and small is not NULL;"}
	elsif($size eq 'medium') {$sql = "Select medium from cat_tapa_amazon where isbn= ? and medium is not NULL;"}
        else {$sql = "Select large from cat_tapa_amazon where isbn= ? and large is not NULL;"}

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare($sql);
$sth->execute($isbn);
if (my $res=$sth->fetchrow) {$url=$res;}
return $url;
}

sub getImageByIsbn {
my ($isbn,$size)=@_;
my $url="";
my $path=C4::Context->config("amazon_covers"); #Donde se guardan las imagenes
my $file="";
my $msg='';

$url = getCover($isbn,$size);
if ($url eq ''){

my $isbnaux=$isbn;
#Se Conecta
my $ua = Net::Amazon->new(token => C4::AR::Preferencias->getValorPreferencia("amazon-token"));
#Realiza la Busqueda
$isbnaux =~ s/-//g; # Quito los - para buscar

my $req = Net::Amazon::Request::ISBN->new(isbn  => $isbnaux);
my $resp = $ua->request($req);


if($resp->is_success()) {
  for my $prop ($resp->properties) {
  	if ($size eq 'small'){$url=$prop->SmallImageUrl();} 
	elsif ($size eq 'medium') { $url=$prop->MediumImageUrl();}
		else {$url=$prop->LargeImageUrl();}
	
	if ($url ne ''){#Inserto la url de la imagen que obtuve

			$file=substr($url,rindex($url,'/')+1); 
			my $request = HTTP::Request->new(GET => $url);
			my $ua = LWP::UserAgent->new;
 			my $res = $ua->request($request);
			my $buffer = $res->content;
			if (!open(WFD,">$path$file")) 
			{$msg="Hay un error y el archivo no puede escribirse en el servidor.";}

			 binmode WFD;
			 print WFD $buffer;
			 close(WFD);
			insertCover ($isbn,$file,$size);
			return ($file); 
			}
 }
}#succes

}# getCover

return $url;
}

sub getLargeImage {
my ($isbn)=@_;
my $url='';

if ($isbn ne ''){
$url= getImageByIsbn($isbn,"large");
}
return($url);
}

sub getImageForId1 {
my ($id1,$size)=@_;
my $url='';
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select cat_nivel2_repetible.dato from cat_nivel2 left join cat_nivel2_repetible on 
			cat_nivel2.id2 = cat_nivel2_repetible.id2 where cat_nivel2_repetible.campo='020' 
			and cat_nivel2_repetible.subcampo='a' and  cat_nivel2.id1= ? ;");
$sth->execute($id1);


while ((my $isbn=$sth->fetchrow)&&( $url eq '')) {
	if ($isbn ne ''){
		$url= getCover($isbn,$size);
		}
	}
$sth->finish;
return $url;
}


sub getImageForId2 {
my ($id2,$size)=@_;
my $url='';
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select cat_nivel2_repetible.dato from cat_nivel2_repetible where 
			cat_nivel2_repetible.campo='020' and cat_nivel2_repetible.subcampo='a' 
			and  cat_nivel2_repetible.id2= ? ;");
$sth->execute($id2);

my $isbn=$sth->fetchrow;
$sth->finish;
if ($isbn ne ''){
$url= getImageByIsbn($isbn,$size);
}
return($url);
}


#esto tarda hay que hacerlo cada cierto tiempo!!!
sub getAllImages {

my $dbh = C4::Context->dbh;
#Busco solo los que tienen ISBN

open (L,">>/tmp/amazon_covers");

my $query = " SELECT dato FROM cat_nivel2_repetible WHERE campo = '020' and subcampo = 'a' ;";
my $sth=$dbh->prepare($query);
   $sth->execute();

   while(my $isbn= $sth->fetchrow)
	{
	printf L "Bajando  ISBN: ".$isbn."  \n";

	my $urlsmall= getImageByIsbn($isbn,'small');
	printf L "Url Small: ".$urlsmall."  \n";

	my $urlmedium= getImageByIsbn($isbn,'medium');
	printf L "Url Medium: ".$urlmedium."  \n";

	my $urllarge= getImageByIsbn($isbn,'large');
	printf L "Url Large: ".$urllarge."  \n";
	}

close L;
}